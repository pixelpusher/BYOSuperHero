// Swarming points using GLModel and GLCamera, using sprite textures.
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

TriangleMesh triMesh;

ArrayList<Vec3D> handPositions;

Vec3D prev=new Vec3D();
Vec3D p=new Vec3D();
Vec3D q=new Vec3D();

Vec2D rotation=new Vec2D();

boolean mouseWasDown = false;

float MIN_DIST = 2.0f;
float weight=0;

LinkedList<ImageParticleSwarm> swarms;
GLTexture tex;


PVector rightShoulderPos = new PVector();
PVector leftShoulderPos = new PVector();
PVector rightHipPos = new PVector();
PVector leftHipPos = new PVector();
PVector facePos = new PVector();
PVector neckPos = new PVector();
PVector leftHandPos = new PVector();
PVector rightHandPos = new PVector();


SimpleOpenNI  context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);

MoveDetect md;

PImage marioBody, marioHead, marioArm, marioBG;

boolean drawLimbs = false;
boolean drawMovement = false;
boolean drawBG = true;


void setup()
{

  size(640, 480, GLConstants.GLGRAPHICS);  

  context = new SimpleOpenNI(this);
  md = new MoveDetect();

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);


  GL gl;
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
  gl = pgl.beginGL();  // always use the GL object returned by beginGL
  gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  pgl.endGL();

  swarms = new LinkedList<ImageParticleSwarm>();
  particleExpander = new ParticleExpander();

  triMesh =new TriangleMesh("mesh1");

  handPositions = new ArrayList<Vec3D>();

  // any particle texture... small is better
  tex = new GLTexture(this, "mario_fireball.png");

  marioBody = loadImage("FieryMarioBody.png");
  marioHead = loadImage("FieryMarioHead.png");
  marioArm = loadImage("FieryMarioLeftArm.png");
  marioBG = loadImage("mario_bg.png");
}

void draw()
{
  // update the cam
  context.update();


  hint(DISABLE_DEPTH_TEST);
  background(marioBG);
  
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
      vertex(leftShoulderPos.x-40, leftShoulderPos.y-40, 0, 0);
      vertex(rightShoulderPos.x+40, rightShoulderPos.y-40, 100, 0);
      vertex(leftHipPos.x-40, leftHipPos.y+40, 0, 100);

      vertex(rightShoulderPos.x+40, rightShoulderPos.y-40, 100, 0);
      vertex(rightHipPos.x+40, rightHipPos.y+40, 100, 100);
      vertex(leftHipPos.x-40, leftHipPos.y+40, 0, 100);
      endShape();

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, facePos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_NECK, neckPos);
      context.convertRealWorldToProjective(neckPos, neckPos);
      context.convertRealWorldToProjective(facePos, facePos);


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

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
      context.convertRealWorldToProjective(rightHandPos, rightHandPos);
      context.convertRealWorldToProjective(leftHandPos, leftHandPos);

      // TODO - draw arms!!!


      drawSkeleton(i);
    }
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

  if (drawLimbs)
  {
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
  // calculate new joint movement function sample
  md.jointMovementFunction(userId, SimpleOpenNI.SKEL_LEFT_HAND);

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
      newSwarm();
      println("ONSET END:::::" + millis());
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

