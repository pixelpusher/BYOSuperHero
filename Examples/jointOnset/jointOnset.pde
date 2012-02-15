// Mario fireballer puppet, using GLModel and fireball sprite textures.
// By Evan Raskob


import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*; 
import codeanticode.glgraphics.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import java.nio.FloatBuffer;
import SimpleOpenNI.*;

ImageParticleSwarm swarm;
ParticleExpander particleExpander;


TriangleMesh triMesh;  // for drawing flame trails
Vec2D rotation=new Vec2D();


ArrayList<Vec3D> handPositions;  // a list of previous hand positions

Vec3D prev=new Vec3D();
Vec3D p=new Vec3D();
Vec3D q=new Vec3D();


boolean mouseWasDown = false;

float MIN_DIST = 2.0f;
float weight=0;

LinkedList<ImageParticleSwarm> swarms;
GLTexture fireballTex;

// images for body parts and background:
GLTexture bodyTex, headTex, armTex, legTex, bgTex;

String bodyTexFile = "FieryMarioBody.png";
String headTexFile = "FieryMarioHead.png";
String armTexFile  = "FieryMarioLeftArm.png";
String legTexFile  = "FieryMarioLeftLeg.png";
String bgTexFile   = "mario_bg.png";


boolean drawLimbs = false;
boolean drawMovement = false;
boolean drawBG = true;



// relevant skeleton positions from our Kinect
PVector rightShoulderPos = new PVector();
PVector leftShoulderPos = new PVector();
PVector rightHipPos = new PVector();
PVector leftHipPos = new PVector();
PVector facePos = new PVector();
PVector neckPos = new PVector();
PVector leftHandPos = new PVector();
PVector rightHandPos = new PVector();
PVector leftFootPos = new PVector();
PVector rightFootPos = new PVector();


// Kinect-specific variables
SimpleOpenNI  context;
MoveDetect md;



///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, GLConstants.GLGRAPHICS);  

  context = new SimpleOpenNI(this);
  md = new MoveDetect();

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  // this next bit of code disables "screen tearing"
  GL gl;
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
  gl = pgl.beginGL();  // always use the GL object returned by beginGL
  gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  pgl.endGL();


  // create fireball particle "swarm"
  swarms = new LinkedList<ImageParticleSwarm>();
  particleExpander = new ParticleExpander();

  // fire trail
  triMesh =new TriangleMesh("mesh1");

  handPositions = new ArrayList<Vec3D>();

  //
  // Load our textures from image files - 
  //

  // any particle texture... small is better
  fireballTex = new GLTexture(this, "mario_fireball.png");

  bodyTex = new GLTexture(this, bodyTexFile);
  headTex = new GLTexture(this, headTexFile);
  armTex = new GLTexture(this, armTexFile);
  legTex = new GLTexture(this, legTexFile);
  bgTex = new GLTexture(this, bgTexFile);
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  // update the Kinect cam
  context.update();

  hint(DISABLE_DEPTH_TEST);
  bgTex.render(0,0,width,height);


  if (drawBG)
  {
    // draw depthImageMap
    image(context.depthImage(), 0, 0);
  }


  for (int i=1; i<3; i++)
  {
    // draw the skeleton if it's available
    if (context.isTrackingSkeleton(i))
    {  
      // get joint positions in 3D world for the tracked limbs
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulderPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulderPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HIP, leftHipPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HIP, rightHipPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, facePos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_NECK, neckPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_FOOT, leftFootPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_FOOT, rightFootPos);

      // convert to screen coordinates
      context.convertRealWorldToProjective(leftShoulderPos, leftShoulderPos);
      context.convertRealWorldToProjective(rightShoulderPos, rightShoulderPos);

      context.convertRealWorldToProjective(rightHipPos, rightHipPos);
      context.convertRealWorldToProjective(leftHipPos, leftHipPos);

      context.convertRealWorldToProjective(neckPos, neckPos);
      context.convertRealWorldToProjective(facePos, facePos);      

      context.convertRealWorldToProjective(rightHandPos, rightHandPos);
      context.convertRealWorldToProjective(leftHandPos, leftHandPos);

      context.convertRealWorldToProjective(leftFootPos, leftFootPos);
      context.convertRealWorldToProjective(rightFootPos, rightFootPos);


      if (i == 1)
      {
        // calculate new joint movement function sample
        md.jointMovementFunction(i, SimpleOpenNI.SKEL_LEFT_HAND);
      }
      
      if (drawMovement)
      {  // plot the movement function
        md.plotMovementFunction();
      }

      if (md.swipeStart == 1)
      {

        handJerked();

        println("ONSET START:::::" + millis());
      }
      else if (md.onsetState == 1)
      {
        handMoved();
      }
      else
        if (md.swipeEnd == 1)
        {
          newSwarm(fireballTex, triMesh);
          println("ONSET END:::::" + millis());
        }


      // note: vectors must be clockwise!

      // void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, float padX, float padY, PImage tex)

noStroke();

// draw based on percentages...
//
      renderRectFromVectors(leftShoulderPos, rightShoulderPos, rightHipPos, leftHipPos, 0.15f, 0.05f, bodyTex);
      
      renderRectFromVectors(facePos, neckPos, 0f, 1f, headTex);
      
      renderRectFromVectors(leftHipPos, leftFootPos, 0f, 0.12f, legTex);      
      renderRectFromVectors(rightHipPos, rightFootPos, 0f, 0.12f, legTex, 1);      
      
      renderRectFromVectors(leftShoulderPos, leftHandPos, 0f, 0.12f, armTex);      
      renderRectFromVectors(rightShoulderPos, rightHandPos, 0f, 0.12f, armTex, 1);



// these draw based on pixels
//
//      renderRectFromVectors(leftShoulderPos, rightShoulderPos, rightHipPos, leftHipPos, 5, 10, bodyTex);
//
//      renderRectFromVectors(leftShoulderPos, leftHandPos, 0, 25, armTex);      
//      renderRectFromVectors(rightShoulderPos, rightHandPos, 0, 25, armTex, 1);
//      
//      renderRectFromVectors(facePos, neckPos, 0, 40, headTex);
//      
//      renderRectFromVectors(leftHipPos, leftFootPos, 0, 30, legTex);      
//      renderRectFromVectors(rightHipPos, rightFootPos, 0, 30, legTex, 1);      
      


      if (drawLimbs)
      {
        drawSkeleton(i);
      }
      
    // end of drawing skeleton stuff
    }
    
  // end for each user detected  
  }



  // draw particle systems
  // rotate around center of screen (accounted for in mouseDragged() function)
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rotation.x);
  rotateY(rotation.y);  
  drawHandPositions();


  // draw mesh as polygon (in white)
  drawMesh();

  // draw mesh unique points only (in green)
  drawMeshUniqueVerts();

  GLGraphics renderer = (GLGraphics)g;

  renderer.beginGL();  
  renderer.setDepthMask(false);

  // now models

  int currentTime = millis();

  for (ImageParticleSwarm swarm : swarms)
  {
    swarm.update(particleExpander, currentTime);
    swarm.render();
  }

  renderer.setDepthMask(true);
  renderer.endGL();
  // udpate rotation
  rotation.addSelf(0.014, 0.0237);
  popMatrix();
}


void vertex(Vec3D v) {
  vertex(v.x, v.y, v.z);
}



// -----------------------------------------------------------------
// Keyboard events
void keyReleased()
{
  switch(key)
  {
  case 'm':
    context.setMirror(!context.mirror());
    break;
  case ' ':
    // now models
    for (ImageParticleSwarm swarm : swarms)
    {
      swarm.destroy();
    }
    swarms.clear();
    break;

  case 's': 
    drawLimbs = !drawLimbs;
    break;

  case 'v': 
    drawMovement = !drawMovement;
    break;

  case 'b': 
    drawBG = !drawBG;
    break;
  }



  switch(keyCode)
  {
  case UP: 
    md.SMOOTHING += 0.05;
    break;

  case DOWN: 
    md.SMOOTHING -= 0.05;
    break;
  }

  md.SMOOTHING = constrain(md.SMOOTHING, 0.0f, 1.0f);
  println("SMOOTHING: " + md.SMOOTHING);
}



// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  stroke(255);
  strokeWeight(2);

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
    drawBG = false;
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

