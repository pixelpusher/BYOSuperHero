import controlP5.*;

// Demonstrates how to draw rectangular shapes between skeleton points.
//
// By Evan Raskob <evan@openlabworkshops.org> for Openlab Workshops 
// http://openlabworkshops.org
//
// Licensed CC-Unported-By-Attribution


import processing.opengl.*;
import SimpleOpenNI.*;
import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;



// images for body parts:
PImage bodyTex, headTex, armTex, legTex;

String bodyTexFile = "body.png";
String headTexFile = "head.png";
String armTexFile  = "arm.png";
String legTexFile  = "leg.png";

float handElbowDiffThresh = 0.15f; // some threshold

final int MAX_SWARMS = 20;  // max number of fireball clusters

Slider yscaler, faceSlider;

// images for fireballs
GLTexture fireballTex;

// list of fireball "swarms" 
LinkedList<ImageParticleSwarm> swarms;

// list of individual movers for each fireball swarm
LinkedList<ParticleBehaviour> particleMovers;


// these are our user's skeleton data
ArrayList<Skeleton> skeletons = new ArrayList<Skeleton>();

// shortcut to the current skeleton we want to draw
Skeleton currentSkeleton = null;

// current skeleton iterator
ListIterator<Skeleton> currentSkeletonIter = skeletons.listIterator();

// Kinect-specific variables
SimpleOpenNI  context;

ControlP5 gui;

float scaleY = 0.8;
float faceSize = 75.0f;

PImage rgbImg;
PGraphics maskImg;

///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, GLConstants.GLGRAPHICS);  

// this next bit of code disables "screen tearing"
  GL gl;
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
  gl = pgl.beginGL();  // always use the GL object returned by beginGL
  gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  pgl.endGL();
  
  gui = new ControlP5(this);
  yscaler = gui.addSlider("scaleY", 0, 1, 10,10, 100, 20);
faceSlider = gui.addSlider("faceSize", 0, 200, 10,30, 100, 20);

  // create fireball particle "swarm"
  swarms = new LinkedList<ImageParticleSwarm>();
  particleMovers = new LinkedList<ParticleBehaviour>();

  // any particle texture... small is better
  fireballTex = new GLTexture(this, "mario_fireball.png");


  rgbImg = new PImage();
  maskImg = new PGraphics();
  maskImg = createGraphics(640,480,P3D);

  // load some texture files
  bodyTex = loadImage(bodyTexFile);
  headTex = loadImage(headTexFile);
  armTex = loadImage(armTexFile);
  legTex = loadImage(legTexFile);

  // create kinect tracking context
  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  context.enableRGB();
  
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  
  background(123,27,40);
  
  // update the Kinect cam
  context.update();


  
  rgbImg = context.rgbImage();
  
  

  // draw only the current:
  //  if (currentSkeleton != null && currentSkeleton.calibrated)
  //  {

  // draw all our skeletons
  for (Skeleton skel : skeletons)
  { 
    // if it is calibrated
    if (skel.calibrated)
    {
      // update skeleton joints coordinates
      skel.update(context);
      
      // Check if hand is straight out from elbow (parallel to floor).
      // First get direction of hand relative to elbow
      PVector handElbowDir = PVector.sub(skel.rightHandPos, skel.rightElbowPos);
      
      float yangle = atan2(handElbowDir.y, handElbowDir.x);
      
      // normalize to between 0 and 1
      handElbowDir.normalize();
      
      if ( abs(handElbowDir.y) < handElbowDiffThresh )
      {
        // hand is pretty much horizontal - shoot some fireballs!
        newSwarm( fireballTex, skel.rightHandPos, handElbowDir );
      }
      
      PVector NewLS = new PVector();
      NewLS.set(skel.leftShoulderPos.x, skel.leftShoulderPos.y*scaleY, skel.leftShoulderPos.z);

      PVector NewRS = new PVector();
      NewRS.set(skel.rightShoulderPos.x, skel.rightShoulderPos.y*scaleY, skel.rightShoulderPos.z);
      
      // these draw based on pixels
      renderRectFromVectors(NewLS, NewRS, skel.rightHipPos, skel.leftHipPos, 160, 10, bodyTex);

      renderRectFromVectors(skel.leftShoulderPos, skel.leftHandPos, 100, armTex);      
      renderRectFromVectors(skel.rightShoulderPos, skel.rightHandPos, 100, armTex, 1);

      //renderRectFromVectors(skel.facePos, skel.neckPos, 160, 0, headTex);

      renderRectFromVectors(skel.leftHipPos, skel.leftFootPos, 120, legTex);      
      renderRectFromVectors(skel.rightHipPos, skel.rightFootPos, 120, legTex, 1);
      
      //fill(255,255,0);
      //ellipse(skel.rightElbowPos.x, skel.rightElbowPos.y, skel.rightElbowPos.z*80,skel.rightElbowPos.z*80);
      //fill(255,0,255);
      //ellipse(skel.rightHandPos.x, skel.rightHandPos.y, skel.rightHandPos.z*80,skel.rightHandPos.z*80);
      
      
      // DEBUGGING
      //fill(255);
      //textSize(24);
      //text("y diff / angle = " + handElbowDir.y + " / " + degrees(yangle), 10, 25*skel.id);
      
      maskImg.beginDraw();
      maskImg.background(0);
      maskImg.fill(255);
      maskImg.ellipse(skel.facePos.x, skel.facePos.y, faceSize*skel.facePos.z, faceSize*skel.facePos.z);
      maskImg.endDraw();
      
    }
    // end of drawing skeleton stuff
  }
  
  rgbImg.mask(maskImg);
  // draw depthImageMap
  //image(rgbImg, 640, 0);
  image(rgbImg,0,0);
  drawSwarms();
  
}



//
// swap tracked skeleton
//
void keyReleased()
{
  switch(key)
  {
  case ',': 
    // next element
    if ( currentSkeletonIter.hasNext() ) 
    {
      currentSkeleton = currentSkeletonIter.next();
    }
    else
    {
      // back to the beginning! 
      currentSkeletonIter = skeletons.listIterator();
      if ( currentSkeletonIter.hasNext() ) 
      {
        currentSkeleton = currentSkeletonIter.next();
      } 
      else
        currentSkeleton = null;
    }
    break;

  case '.': 
    // next element
    if ( currentSkeletonIter.hasPrevious() ) 
    {
      currentSkeleton = currentSkeletonIter.previous();
    }
    else
    {
      if (skeletons.size() > 0)
      {
        // back to the end! 
        currentSkeletonIter = skeletons.listIterator(skeletons.size()-1);
        currentSkeleton = currentSkeletonIter.next();
      }
      else
        currentSkeleton = null;
    }
    break;
  }
}



void newSwarm(GLTexture tex, PVector startPos, PVector direction)
{
  // number of fireballs in this swarm
  int numFireballs = int( random(2, 6) );

  // a bit of randomness to their position
  float w = width/60.0f;
  float h = height/60.0f;

  ArrayList<PVector> fireballCoords = new ArrayList<PVector>();

  // add some coordinates for our fireballs
  for (int i=0; i < numFireballs; i++)
  {
    fireballCoords.add( new PVector( startPos.x + random(-w, w), startPos.y + random(-h, h), startPos.z ) );
  }

  ImageParticleSwarm swarm = new ImageParticleSwarm(this, tex);

  if (swarm.makeModel( fireballCoords ))
  {
    swarms.add( swarm );

    // now create object to move this swarm of fireballs
    ParticleMover particleBehaviour = new ParticleMover( fireballCoords.size() );

    float vel = random(10, 40);

    particleBehaviour.noisiness = 0.3;

    particleBehaviour.setVelocities( PVector.mult(direction, vel ) );      

    particleMovers.add( particleBehaviour );
    
    // DEBUG:
    //println("*****ADDED NEW SWARM****");
    
  }


  if (swarms.size() > MAX_SWARMS)
  {
    ImageParticleSwarm first = swarms.removeFirst();
    first.destroy();

    particleMovers.removeFirst();
  }
}


void drawSwarms()
{
  GLGraphics renderer = (GLGraphics)g;

  renderer.beginGL();  
  renderer.setDepthMask(false);

  // now update and draw models
  int currentTime = millis();

  ListIterator<ParticleBehaviour> iter = particleMovers.listIterator();

  for (ImageParticleSwarm swarm : swarms)
  {
    ParticleBehaviour particleMover = iter.next();

    swarm.update(particleMover, currentTime);
    swarm.render();
  }

  renderer.setDepthMask(true);
  renderer.endGL();
}


