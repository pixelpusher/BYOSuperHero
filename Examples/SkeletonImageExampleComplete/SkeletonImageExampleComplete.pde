// Demonstrates how to draw rectangular shapes between skeleton points.
//
// By Evan Raskob <evan@openlabworkshops.org> for Openlab Workshops 
// http://openlabworkshops.org
//
// Licensed CC-Unported-By-Attribution


import processing.opengl.*;
import SimpleOpenNI.*;


// images for body parts:
PImage bodyTex, headTex, armTex, legTex;

String bodyTexFile = "FieryMarioBody.png";
String headTexFile = "FieryMarioHead.png";
String armTexFile  = "FieryMarioLeftArm.png";
String legTexFile  = "FieryMarioLeftLeg.png";


// these are our user's skeleton data
ArrayList<Skeleton> skeletons = new ArrayList<Skeleton>();

// shortcut to the current skeleton we want to draw
Skeleton currentSkeleton = null;

// current skeleton iterator
ListIterator<Skeleton> currentSkeletonIter = skeletons.listIterator();

// Kinect-specific variables
SimpleOpenNI  context;


///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, OPENGL);  

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
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  // update the Kinect cam
  context.update();


  // draw only the current:
  //  if (currentSkeleton != null && currentSkeleton.calibrated)
  //  {

  // draw all our skeletons
  for (Skeleton skel : skeletons)
  { 
    // if it is calibrated
    if (skel.calibrated)
    {
      // these draw based on pixels
      renderRectFromVectors(skel.leftShoulderPos, skel.rightShoulderPos, skel.rightHipPos, skel.leftHipPos, 5, 10, bodyTex);

      renderRectFromVectors(skel.leftShoulderPos, skel.leftHandPos, 25, armTex);      
      renderRectFromVectors(skel.rightShoulderPos, skel.rightHandPos, 25, armTex, 1);

      renderRectFromVectors(skel.facePos, skel.neckPos, 40, 40, headTex);

      renderRectFromVectors(skel.leftHipPos, skel.leftFootPos, 30, legTex);      
      renderRectFromVectors(skel.rightHipPos, skel.rightFootPos, 30, legTex, 1);
    }
    // end of drawing skeleton stuff
  }
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



// -----------------------------------------------------------------
// SimpleOpenNI event handlers -- these add and remove skeletons from our list

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  context.startPoseDetection("Psi", userId);


  // add to list of skeletons if this id doesn't already exist
  ListIterator<Skeleton> iterator = skeletons.listIterator();

  boolean found = false;

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      // we're already tracking this skeleton
      found = true;
      s.calibrated = false;
      break;
    }
  }

  // start tracking this one if not found in our list
  if (!found)
  {
    iterator.add(new Skeleton(userId) );

    // reset iterator
    currentSkeletonIter = skeletons.listIterator();
  }
}


void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);

  // add to list of skeletons if this id doesn't already exist
  ListIterator<Skeleton> iterator = skeletons.listIterator();

  boolean found = false;

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      iterator.remove();

      // reset iterator
      currentSkeletonIter = skeletons.listIterator();     
      break;
    }
  }
}



void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);

  boolean found = false;

  ListIterator<Skeleton> iterator = skeletons.listIterator();

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      s.calibrated = false;
      found = true;
      break;
    }
  }
}


void onEndCalibration(int userId, boolean successful)
{
  println("onEndCalibration - userId: " + userId + ", successful: " + successful);

  if (successful) 
  {
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }

  boolean found = false;

  ListIterator<Skeleton> iterator = skeletons.listIterator();

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      s.calibrated = successful;
      found = true;

      // set as current skeleton    
      if (successful)
        currentSkeleton = s;

      break;
    }
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

