// Demonstrates how to draw rectangular shapes between skeleton points.
//
// By Evan Raskob <evan@openlabworkshops.org> for Openlab Workshops 
// http://openlabworkshops.org
//
// Licensed CC-Unported-By-Attribution


import processing.opengl.*;
import SimpleOpenNI.*;


// images for body parts:
PImage bodyTex, headTex, armTex, toparmTex, toplegTex, legTex;

String bodyTexFile = "FieryMarioBody.png";
String headTexFile = "FieryMarioHead.png";
String armTexFile  = "FieryMarioLeftArm.png";
String toparmTexFile  = "toparm.png";
String legTexFile  = "FieryMarioLeftLeg.png";
String toplegTexFile  = "topleg.png";

// these are our user's skeleton data
ArrayList<Skeleton> skeletons = new ArrayList<Skeleton>();

// shortcut to the current skeleton we want to draw
Skeleton currentSkeleton = null;

// this is a reference to the part that draws body parts to the screen
BodyPartRenderer bodyPartRenderer;
// these are the actual renderers
BodyPartRenderer bodyPart2DRenderer, bodyPartParticleRenderer;

BoxRenderer boxRenderer;


// this contains methods for creating new body parts and adding them to skeletons (to keep track of)
BodyPartFactory bodyPartFactory;

// currently selected skeleton 
ListIterator<Skeleton> currentSkeletonIter = skeletons.listIterator();

// Kinect-specific variables:
//
// The Kinect device object
SimpleOpenNI  context;

float screenWidthToKinectWidthRatio = 1.0f;
float screenHeightToKinectHeightRatio = 1.0f;

// last time we saved an image
int lastSaveTime = 0;

boolean drawDepthImage = true;
boolean saveFrames = false;




///////////////////////////////////////////
// SETUP
//

void setup()
{
  println("start setup");

  size(640, 480, OPENGL);  

// controlP5 gui utilities
// comment out if not needed
  setupGUI();


  screenWidthToKinectWidthRatio = width/640.0f;
  screenHeightToKinectHeightRatio = height/480.0f;

  // load some texture files
  bodyTex = loadImage(bodyTexFile);
  headTex = loadImage(headTexFile);
  armTex = loadImage(armTexFile);
  toplegTex = loadImage(toplegTexFile);
  legTex = loadImage(legTexFile);
  toparmTex = loadImage(toparmTexFile);

  // create kinect tracking context
  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  // create body part factory for creating new body parts
  bodyPartFactory = BodyPartFactory.getInstance();

  // this will draw body parts and skeletons (collections of body parts) to the screen
  //bodyPartRenderer = new BasicBodyPartRenderer(this.g);

  // or try this renderer...
  bodyPartParticleRenderer = new ParticleBodyPartRenderer(this.g);

  bodyPartRenderer = bodyPart2DRenderer= new BasicBodyPartRenderer(this.g);
  boxRenderer = new BoxRenderer(this.g);
  
  boxRenderer.initRenderer(this);
  bodyPartRenderer = (BodyPartRenderer)boxRenderer;
}


/////////////////////////////
// BUILD SKELETON
// 
// This is run whenever a new skeleton (user) is calibrated (e.g. when it is recognised by Kinect).
// It builds a skeleton out of appropriate body parts.  If you wanted to build custom skeletons with other body parts,
// this is the place for it.
//

void buildSkeleton(Skeleton s)
{
  println("BUILDING SKELETON!");


  // note - padding is represented as 4 numbers: LEFT, RIGHT, TOP, BOTTOM

  // BODY TRUNK (TORSO) - this is padded in pixels

  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP, BodyPart.TORSO)
    .setPadding(0.1, 0.1, 0.15, 0.2)
      .setTexture(bodyTex);

  // PELVIS
//  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_RIGHT_HIP, BodyPart.PELVIS)
//    .setPadding(0.1, 0.1, 0.2, 0.2)
//      .setTexture(null);

  //UPPER LEFT ARM
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW, BodyPart.LEFT_ARM_UPPER)
    .setPadding(0.2, 0.2, 0.0, 0.2)
      .setTexture(toparmTex);

  //UPPER RIGHT ARM
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW, BodyPart.RIGHT_ARM_UPPER)
    .setPadding(0.2, 0.2, 0.0, 0.2)
      .setTexture(toparmTex)
        .setReversed(true);

  //LOWER LEFT ARM
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND, BodyPart.LEFT_ARM_LOWER)
    .setPadding(0.15, 0.15, 0.15, 0.0)
      .setTexture(armTex);

  //LOWER RIGHT ARM
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND, BodyPart.RIGHT_ARM_LOWER)
    .setPadding(0.15, 0.15, 0.15, 0.0)
      .setTexture(armTex)
        .setReversed(true);


  //LEFT HAND
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_WRIST, SimpleOpenNI.SKEL_LEFT_HAND, BodyPart.LEFT_HAND)
    .setPadding(0.15, 0.15, 0.15, 0.0)
      .setTexture(null);

  //RIGHT HAND
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_RIGHT_WRIST, SimpleOpenNI.SKEL_RIGHT_HAND, BodyPart.RIGHT_HAND)
    .setPadding(0.15, 0.15, 0.15, 0.0)
      .setTexture(null)
        .setReversed(true);

  //NECK
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK, BodyPart.NECK)
    .setPadding(0.1, 0.1, 0.0, 0.0);

  //HEAD
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_HEAD, BodyPart.HEAD)
    .setPadding(0.06, 0.06, 0.1, 0.1)
      .setTexture(headTex)
        .disableDepth(false);

  // UPPER LEFT LEG (THIGH)
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE, BodyPart.LEFT_LEG_UPPER)
    .setPadding(0.15, 0.2, 0.0, 0.2)
      .setTexture(toplegTex);

  // UPPER RIGHT LEG (THIGH)
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE, BodyPart.RIGHT_LEG_UPPER)
    .setPadding(0.15, 0.2, 0.0, 0.2)
      .setTexture(toplegTex)
        .setReversed(true);

  // LOWER LEFT LEG (CALVES, ETC)
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT, BodyPart.LEFT_LEG_LOWER)
    .setPadding(0.125, 0.125, 0.125, 0.0)
      .setTexture(legTex);

  // LOWER RIGHT LEG (CALVES, ETC)
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT, BodyPart.RIGHT_LEG_LOWER)
    .setPadding(0.125, 0.125, 0.125, 0.0)
      .setTexture(legTex)
        .setReversed(true);
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  background(0);

  // update the Kinect cam
  context.update();

  // draw depthImageMap
  if (drawDepthImage)
  {
    tint(180);
    image(context.depthImage(), 0, 0);
  }

  boolean saveImage = false;

  fill(255, 150);
  stroke(0, 0, 0);
  strokeWeight(2);

  // draw only the current: ?
  //  if (currentSkeleton != null)


  // Update all our skeletons with current data form Kinect, and
  // draw them.
  //
  for (Skeleton skel : skeletons)
  { 
    // update skeleton joints coordinates using current Kinect data
    skel.update();

    // get a reference to the right hand - should only be one for this example, but
    // there could be more if we built our skeleton differently
    //
//    ArrayList<BodyPart> rightHands = skel.getPartsByType(BodyPart.RIGHT_ARM_LOWER);
//    if ( rightHands.size() > 0 )
//    {
//      BodyPart rightHand = rightHands.get(0);
//      PVector handPos = rightHand.getJoint(SimpleOpenNI.SKEL_RIGHT_HAND);
//    }

    // these draw based on percentages (so they scale to the body parts)
    bodyPartRenderer.render( skel );


    // save frame image if necessary
    if (saveFrames && (millis()-lastSaveTime) > 2000)
    {
      fill(0, 255, 0);
      ellipse(width-40, 40, 30, 30);
      lastSaveTime = millis();
      saveImage = true;
    }
  }
  // end of drawing skeleton stuff

  if (saveImage)  saveFrame("kinect"+year()+"-"+month()+"-"+day()+"_"+hour()+"."+minute()+"."+second()+".png");
}



//
// swap tracked skeleton
//
void keyReleased()
{
  switch(key)
  {
  case 'r':
    if (bodyPartRenderer == bodyPartParticleRenderer)
      bodyPartRenderer = bodyPart2DRenderer;
    else
      bodyPartRenderer = bodyPartParticleRenderer;
    break;

  case 'd': 
    drawDepthImage = true;
    break;  

  case 's': 
    saveFrames = !saveFrames;
    break;

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

  default: 
    saveFrame("kinect"+year()+"-"+month()+"-"+day()+"_"+hour()+"."+minute()+"."+second()+".png");
    break;
  }
}

