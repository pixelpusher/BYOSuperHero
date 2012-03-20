// Demonstrates how to draw rectangular shapes between skeleton points.
//
// By Evan Raskob <evan@openlabworkshops.org> for Openlab Workshops 
// http://openlabworkshops.org
//
// and Becky Stewart and Adam Stark 
// http://www.codasign.com
//
// Licensed CC-Unported-By-Attribution

import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI  context;


PImage headImage;


void setup()
{

  // create a window the size of the depth information
  //size(context.depthWidth(), context.depthHeight(), OPENGL); 
  size(640, 480, OPENGL); 

  // instantiate a new context
  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);


  headImage = loadImage("doughnutbody.png");

  background(200, 0, 0);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();    

  //renderer = this.g;
}



void draw()
{
  
  fill(255,0,0,40); // 40 is alpha (0-255)
  rect(0,0,width,height);
  
  //background(255, 0, 0);
  
  // update the camera
  context.update();

  // draw depth image
  //image(context.depthImage(),0,0); 
 fill(255,80);
 
 noStroke();
 
  // for all users from 1 to 10
  int i;
  for (i=1; i<=10; i++)
  {
    // check if the skeleton is being tracked
    if (context.isTrackingSkeleton(i))
    { 

      drawRectangles(i);
      // draw a circle for a head 
      //circleForAHead(i);
    }
  }
}



void drawRectangles(int userId)
{
  PVector head = new PVector();
  PVector neck = new PVector();
  PVector torso = new PVector();

  PVector leftShoulder = new PVector();
  PVector rightShoulder = new PVector();

  PVector leftHip = new PVector();
  PVector rightHip = new PVector();

  PVector leftElbow = new PVector();
  PVector rightElbow = new PVector();
  PVector leftHand = new PVector();
  PVector rightHand = new PVector();

  PVector leftKnee = new PVector();
  PVector rightKnee = new PVector();
  PVector leftFoot = new PVector();
  PVector rightFoot = new PVector();

  // get joint positions
  getJointProjective(userId, SimpleOpenNI.SKEL_HEAD, head);
  getJointProjective(userId, SimpleOpenNI.SKEL_NECK, neck);
  getJointProjective(userId, SimpleOpenNI.SKEL_TORSO, torso);

  getJointProjective(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulder);
  leftShoulder.z = 0; // clamp to screen
  getJointProjective(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);
  rightShoulder.z = 0; // clamp to screen

  getJointProjective(userId, SimpleOpenNI.SKEL_LEFT_HIP, leftHip);
  getJointProjective(userId, SimpleOpenNI.SKEL_RIGHT_HIP, rightHip);
  rightHip.z = 0; // clamp to screen
  leftHip.z = 0; // clamp to screen

  getJointProjective(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
  getJointProjective(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
  getJointProjective(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  getJointProjective(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);

  getJointProjective(userId, SimpleOpenNI.SKEL_LEFT_KNEE, leftKnee);
  getJointProjective(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, rightKnee);
  getJointProjective(userId, SimpleOpenNI.SKEL_LEFT_FOOT, leftFoot);
  getJointProjective(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, rightFoot);


  // draw the rect
  renderRectFromVectors(head, neck, 100, headImage);
  renderRectFromVectors(leftShoulder, rightShoulder, rightHip, leftHip, 200,200,headImage); 

  renderRectFromVectors(leftShoulder, leftElbow, 20);
  renderRectFromVectors(rightShoulder, rightElbow, 20);

  renderRectFromVectors(leftElbow, leftHand, 20);
  renderRectFromVectors(rightElbow, rightHand, 20);

  renderRectFromVectors(leftHip, leftKnee, 20);
  renderRectFromVectors(leftKnee, leftFoot, 20);

  renderRectFromVectors(rightHip, rightKnee, 20);
  renderRectFromVectors(rightKnee, rightFoot, 20);
}

// gets the position of the specified joint and store it in the provided PVector
void getJointProjective(int userId, int joint, PVector jointProj)
{
  PVector jointReal = new PVector();

  // retrieve joint position in real world
  context.getJointPositionSkeleton(userId, joint, jointReal);

  // convert from real world to projective
  context.convertRealWorldToProjective(jointReal, jointProj);
}

// draws a circle at the position of the head
void circleForAHead(int userId)
{
  // get 3D position of a joint
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointPos);
  // println(jointPos.x);
  // println(jointPos.y);
  // println(jointPos.z);

  // convert real world point to projective space
  PVector jointPos_Proj = new PVector(); 
  context.convertRealWorldToProjective(jointPos, jointPos_Proj);

  // a 200 pixel diameter head
  float headsize = 200;

  // create a distance scalar related to the depth (z dimension)
  float distanceScalar = (525/jointPos_Proj.z);

  // set the fill colour to make the circle green
  fill(0, 255, 0); 

  // draw the circle at the position of the head with the head size scaled by the distance scalar
  ellipse(jointPos_Proj.x, jointPos_Proj.y, distanceScalar*headsize, distanceScalar*headsize);
}



// Event-based Methods

// when a person ('user') enters the field of view
void onNewUser(int userId)
{
  println("New User Detected - userId: " + userId);

  // start pose detection
  context.startPoseDetection("Psi", userId);
}

// when a person ('user') leaves the field of view 
void onLostUser(int userId)
{
  println("User Lost - userId: " + userId);
}

// when a user begins a pose
void onStartPose(String pose, int userId)
{
  println("Start of Pose Detected  - userId: " + userId + ", pose: " + pose);

  // stop pose detection
  context.stopPoseDetection(userId); 

  // start attempting to calibrate the skeleton
  context.requestCalibrationSkeleton(userId, true);
}

// when calibration begins
void onStartCalibration(int userId)
{
  println("Beginning Calibration - userId: " + userId);
}

// when calibaration ends - successfully or unsucessfully 
void onEndCalibration(int userId, boolean successfull)
{
  println("Calibration of userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");

    // begin skeleton tracking
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");

    // Start pose detection
    context.startPoseDetection("Psi", userId);
  }
}
