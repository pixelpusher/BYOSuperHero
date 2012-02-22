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

// current skeleton iterator
ListIterator<Skeleton> currentSkeletonIter = skeletons.listIterator();

// Kinect-specific variables
SimpleOpenNI  context;

float screenWidthToKinectWidthRatio = 1.0f;
float screenHeightToKinectHeightRatio = 1.0f;

int lastSaveTime = 0;

boolean drawDepthImage = true;
boolean saveFrames = false;


///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, OPENGL);  

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
      // these draw based on percentages (so they scale to the body parts)
      
      // note - padding is represented as 4 numbers: LEFT, RIGHT, TOP, BOTTOM


      // BODY TRUNK (CHEST) - this is padded in pixels
      renderRectFromVectors(skel.leftShoulderPos, skel.rightShoulderPos, skel.rightHipPos, skel.leftHipPos, 5, 5, 10, 30, bodyTex);

      //UPPER ARMS
      renderRectFromVectors(skel.leftShoulderPos, skel.leftElbowPos, 0.2, 0.2, 0.0, 0.2, toparmTex);      
      renderRectFromVectors(skel.rightShoulderPos, skel.rightElbowPos, 0.2, 0.2, 0.0, 0.2, toparmTex, 1);

      //FOREARMS
      renderRectFromVectors(skel.leftElbowPos, skel.leftHandPos, 0.15, 0.15, 0.15, 0.0, armTex);      
      renderRectFromVectors(skel.rightElbowPos, skel.rightHandPos, 0.15, 0.15, 0.15, 0.0, armTex, 1);

      hint(DISABLE_DEPTH_TEST);
      // NECK
      renderRectFromVectors(skel.facePos, skel.neckPos, 0.1, 0.0, null);

      // FACE 
      pushMatrix();
      translate(skel.facePos.x, skel.facePos.y, skel.facePos.z);  
      imageMode(CENTER);
      float faceHeight = skel.facePos.y-skel.neckPos.y;
      
      image(headTex, 0, 0, faceHeight*0.66, faceHeight);
      popMatrix();
      hint(ENABLE_DEPTH_TEST);

      // UPPER LEGS (THIGHS)
      renderRectFromVectors(skel.leftHipPos, skel.leftKneePos, 0.15, 0.2, 0.0, 0.2, toplegTex);      
      renderRectFromVectors(skel.rightHipPos, skel.rightKneePos, 0.15, 0.2, 0.0, 0.2, toplegTex, 1);

      // LOWER LEGS (CALVES, ETC)
      renderRectFromVectors(skel.leftKneePos, skel.leftFootPos, 0.125, 0.125, 0.125, 0.0, legTex);      
      renderRectFromVectors(skel.rightKneePos, skel.rightFootPos, 0.125, 0.125, 0.125, 0.0, legTex, 1);

      //FEET
      /*
      pushMatrix();
       translate(skel.facePos.x, skel.facePos.y,skel.facePos.z);  
       rectMode(CENTER);
       float faceHeight = skel.facePos.y-skel.neckPos.y;
       rect(0,0, faceHeight, faceHeight*0.66);
       popMatrix();
       */

      if (saveFrames && (millis()-lastSaveTime) > 2000)
      {
        fill(0,255,0);
        ellipse(width-40, 40, 30,30);
        lastSaveTime = millis();
        saveImage = true;
      }
    }
    // end of drawing skeleton stuff
  }

  if (saveImage)  saveFrame("kinect"+year()+"-"+month()+"-"+day()+"_"+hour()+"."+minute()+"."+second()+".png");
}



//
// swap tracked skeleton
//
void keyReleased()
{
  switch(key)
  {
  case 'd': 
    drawDepthImage = true;
    break;  

  case 's': saveFrames = !saveFrames;
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

