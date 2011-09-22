import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI  context;

MoveDetect md;

void setup()
{
  size(640, 480, OPENGL);

  context = new SimpleOpenNI(this);
  md = new MoveDetect();

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  //  size(context.depthWidth(), context.depthHeight(), OPENGL); 

  mFunction = new float[numPlotSamples];

  marioBody = loadImage("FieryMarioBody.png");
  marioHead = loadImage("FieryMarioHead.png");
  marioArm = loadImage("FieryMarioArm.png");
  
}

void draw()
{
  // update the cam
  context.update();

  // draw depthImageMap
  image(context.depthImage(), 0, 0);

  PVector rightShoulderPos = new PVector();
  PVector leftShoulderPos = new PVector();
  PVector rightHipPos = new PVector();
  PVector leftHipPos = new PVector();
  PVector facePos = new PVector();
  PVector neckPos = new PVector();
  PVector leftHandPos = new PVector();
  PVector rightHandPos = new PVector();
    
  hint(DISABLE_DEPTH_TEST);

  for (int i=1; i<3; i++)
  {
    // draw the skeleton if it's available
    if (context.isTrackingSkeleton(i))
    {  
      // get joint position for the given limb
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulderPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulderPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HIP, leftHipPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HIP, rightHipPos);

      context.convertRealWorldToProjective(leftShoulderPos, leftShoulderPos);
      context.convertRealWorldToProjective(rightShoulderPos, rightShoulderPos);
      context.convertRealWorldToProjective(rightHipPos, rightHipPos);
      context.convertRealWorldToProjective(leftHipPos, leftHipPos);

      textureMode(NORMALIZED);

      noStroke();
      beginShape(TRIANGLES);
      texture(marioBody);    
      vertex(leftShoulderPos.x-80, leftShoulderPos.y-40, 0, 0);
      vertex(rightShoulderPos.x+80, rightShoulderPos.y-40, 100, 0);
      vertex(leftHipPos.x-80, leftHipPos.y, 0, 100);

      vertex(rightShoulderPos.x+80, rightShoulderPos.y-40, 100, 0);
      vertex(rightHipPos.x+80, rightHipPos.y+40, 100, 100);
      vertex(leftHipPos.x-80, leftHipPos.y+40, 0, 100);
      endShape();

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, facePos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_NECK, neckPos);
      context.convertRealWorldToProjective(neckPos,neckPos);
      context.convertRealWorldToProjective(facePos,facePos);
      
      
      noStroke();
      beginShape(TRIANGLES);
      texture(marioHead);    
      vertex(facePos.x-80, facePos.y-80, 0, 0);
      vertex(facePos.x+80, facePos.y-80, 100, 0);
      vertex(neckPos.x-80, neckPos.y, 0, 100);

      vertex(facePos.x+80, facePos.y-80, 100, 0);
      vertex(neckPos.x+80, neckPos.y, 100, 100);
      vertex(neckPos.x-80, neckPos.y, 0, 100);
      endShape();
      
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, rightHandPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_NECK, leftHandPos);
      context.convertRealWorldToProjective(rightHandPos,rightHandPos);
      context.convertRealWorldToProjective(leftHandPos,leftHandPos);
      
      // TODO - draw arms!!!
            
      
      drawSkeleton(i);
    }
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data

  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,jointPos);
   println(jointPos);
   
   
   noStroke();
   fill(200,0,0);
   rect(10,10,jointPos.x/10,50);
   
   fill(0,200,0);
   rect(10,70,jointPos.y/10,50);
   
   fill(0,0,200);
   rect(10,130,jointPos.z/10,50);
   */

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

  // calculate new joint movement function sample
  md.jointMovementFunction(userId, SimpleOpenNI.SKEL_LEFT_HAND);

  // plot the movement function
  md.plotMovementFunction();
  
  if (md.swipeStart == 1)
  {
     println("ONSET START 111111111111111111111111111"); 
  }
  
  if (md.swipeEnd == 1)
  {
     println("ONSET END 0000000000000000000000000");  
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

