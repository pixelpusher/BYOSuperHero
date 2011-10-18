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


int skelID=1; // the skeleton we are tracking

///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, OPENGL);  

  bodyTex = loadImage(bodyTexFile);
  headTex = loadImage(headTexFile);
  armTex = loadImage(armTexFile);
  legTex = loadImage(legTexFile);


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





  // draw the skeleton if it's available
  if (context.isTrackingSkeleton(skelID))
  {  
    // get joint positions in 3D world for the tracked limbs
    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulderPos);
    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulderPos);

    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_LEFT_HIP, leftHipPos);
    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_RIGHT_HIP, rightHipPos);

    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_HEAD, facePos);
    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_NECK, neckPos);

    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);

    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_LEFT_FOOT, leftFootPos);
    context.getJointPositionSkeleton(skelID, SimpleOpenNI.SKEL_RIGHT_FOOT, rightFootPos);

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





    // these draw based on pixels

      renderRectFromVectors(leftShoulderPos, rightShoulderPos, rightHipPos, leftHipPos, 5, 10, bodyTex);

    renderRectFromVectors(leftShoulderPos, leftHandPos, 25, armTex);      
    renderRectFromVectors(rightShoulderPos, rightHandPos, 25, armTex, 1);

    renderRectFromVectors(facePos, neckPos, 40, 40, headTex);

    renderRectFromVectors(leftHipPos, leftFootPos, 0, 30, legTex);      
    renderRectFromVectors(rightHipPos, rightFootPos, 0, 30, legTex, 1);     

    // end of drawing skeleton stuff
  }
}



void keyReleased()
{
  switch(key)
  {
  case '1': 
    skelID = 1;
    break;

  case '2': 
    skelID = 2;
    break;

  case '3': 
    skelID = 3;
    break;

  case '4': 
    skelID = 4;
    break;

  case '5': 
    skelID = 5;
    break;
  }
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

