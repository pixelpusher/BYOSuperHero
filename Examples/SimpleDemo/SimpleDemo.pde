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

ImageParticleSwarm swarm;
ParticleExpander particleExpander;

TriangleMesh triMesh;

Vec3D prev=new Vec3D();
Vec3D p=new Vec3D();
Vec3D q=new Vec3D();

Vec2D rotation=new Vec2D();

boolean mouseWasDown = false;

float MIN_DIST = 7.0f;
float weight=0;


LinkedList<ImageParticleSwarm> swarms;
GLTexture tex;



PVector handLeft, handRight, phandLeft, phandRight;



import SimpleOpenNI.*;


SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);



void setup()
{  
  size(640, 480, GLConstants.GLGRAPHICS);  


  handLeft = new PVector();
  handRight = new PVector();
  phandLeft = new PVector();
  phandRight = new PVector();


  GL gl;
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
  gl = pgl.beginGL();  // always use the GL object returned by beginGL
  gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  pgl.endGL();

  swarms = new LinkedList<ImageParticleSwarm>();
  particleExpander = new ParticleExpander();

  triMesh =new TriangleMesh("mesh1");

  // any particle texture... small is better
  tex = new GLTexture(this, "whitetoady.png");


  context = new SimpleOpenNI(this);

  // disable mirror
  context.setMirror(false);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  stroke(255, 255, 255);
  smooth();  
  perspective(95, 
  float(width)/float(height), 
  10, 150000);
}

void draw()
{

  // update the cam
  context.update();

  if ( context.isTrackingSkeleton(1) )
  {
    int userId = 1;

    phandLeft.set(handLeft);
    context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, handLeft);

    phandRight.set(handRight);
    context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, handRight);
  }

  handMoved();

  background(0, 0, 0);
  pushMatrix();
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  int[]   depthMap = context.depthMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera


  stroke(100); 

  for (int y=0;y < context.depthHeight();y+=steps)
  {
    for (int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        // draw the projected point
        realWorldPoint = context.depthMapRealWorld()[index];
        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
      }
    }
  } 


  // draw the skeleton if it's available
  if (context.isTrackingSkeleton(1))
    drawSkeleton(1);

  // draw the kinect cam
  context.drawCamFrustum();
  popMatrix();

  hint(DISABLE_DEPTH_TEST);
  // draw particle systems
  // rotate around center of screen (accounted for in mouseDragged() function)
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rotation.x);
  rotateY(rotation.y);

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
  }
}


void keyPressed()
{  
  if (key == CODED)
    switch(keyCode)
    {
    case LEFT:
      rotY += 0.1f;
      break;
    case RIGHT:
      // zoom out
      rotY -= 0.1f;
      break;
    case UP:
      if (keyEvent.isShiftDown())
        zoomF += 0.01f;
      else
        rotX += 0.1f;
      break;
    case DOWN:
      if (keyEvent.isShiftDown())
      {
        zoomF -= 0.01f;
        if (zoomF < 0.01)
          zoomF = 0.01;
      }
      else
        rotX -= 0.1f;
      break;
    }
}



void newSwarm()
{
  swarm = new ImageParticleSwarm(this, tex);
  if (swarm.makeModel( triMesh ))
  {
    swarms.add( swarm );

    if (swarms.size() > 10)
    {
      ImageParticleSwarm first = swarms.removeFirst();
      first.destroy();
    }
  }
  // clear tri mesh
  triMesh.clear();
}


void mousePressed()
{
  Vec3D pos=new Vec3D(mouseX-width/2, mouseY-height/2, 0);
  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);
  Vec3D a=pos.add(0, 0, weight);
  Vec3D b=pos.add(0, 0, -weight);

  // store current points for next iteration
  prev=pos;
  p.set(pos);
  q.set(pos);
}



void handMoved()
{

  if ( handRight.dist(phandRight) > 1)
  {

    // get 3D rotated mouse position
    Vec3D pos=new Vec3D(handRight.x-width/2, handRight.y-height/2, 0);

    pos.rotateX(rotation.x);
    pos.rotateY(rotation.y);
    // use distance to previous point as target stroke weight
    weight+=(sqrt(pos.distanceTo(prev))*2-weight)*0.1;
    // define offset points for the triangle strip

    println("weight " + weight + " / " + MIN_DIST );

    if (weight > MIN_DIST)
    {
      Vec3D a=pos.add(0, 0, weight);
      Vec3D b=pos.add(0, 0, -weight);

      // add 2 faces to the mesh
      triMesh.addFace(p, b, q);
      triMesh.addFace(p, a, b);
      // store current points for next iteration
      prev=pos;
      p=a;
      q=b;
    }

    if (triMesh.getNumVertices() > 600)
    {
      newSwarm();
    }
  }
}




void drawMesh() {

  noStroke();    
  fill(255, 80);
  beginShape(TRIANGLES);
  // iterate over all faces/triangles of the mesh
  for (Iterator i=triMesh.faces.iterator(); i.hasNext();) {
    Face f=(Face)i.next();
    // create vertices for each corner point
    vertex(f.a);
    vertex(f.b);
    vertex(f.c);
  }
  endShape();
}



void drawMeshUniqueVerts() {
  //  noStroke();

  stroke(0, 255, 0);
  strokeWeight(4);

  beginShape(POINTS);

  // get unique vertices, use with indices
  float[] triVerts = triMesh.getUniqueVerticesAsArray(); 
  for (int i=0; i < triVerts.length; i += 3)
  {  
    vertex(triVerts[i], triVerts[i+1], triVerts[i+2]);
  }
  endShape();
}




// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  strokeWeight(3);

  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

  strokeWeight(1);
}

void drawLimb(int userId, int jointType1, int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;

  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId, jointType1, jointPos1);
  confidence = context.getJointPositionSkeleton(userId, jointType2, jointPos2);

  stroke(255, 0, 0, confidence * 200 + 55);
  line(jointPos1.x, jointPos1.y, jointPos1.z, 
  jointPos2.x, jointPos2.y, jointPos2.z);

  drawJointOrientation(userId, jointType1, jointPos1, 50);
}

void drawJointOrientation(int userId, int jointType, PVector pos, float length)
{
  // draw the joint orientation  
  PMatrix3D  orientation = new PMatrix3D();
  float confidence = context.getJointOrientationSkeleton(userId, jointType, orientation);
  if (confidence < 0.001f) 
    // nothing to draw, orientation data is useless
    return;

  pushMatrix();
  translate(pos.x, pos.y, pos.z);

  // set the local coordsys
  applyMatrix(orientation);

  // coordsys lines are 100mm long
  // x - r
  stroke(255, 0, 0, confidence * 200 + 55);
  line(0, 0, 0, 
  length, 0, 0);
  // y - g
  stroke(0, 255, 0, confidence * 200 + 55);
  line(0, 0, 0, 
  0, length, 0);
  // z - b    
  stroke(0, 0, 255, confidence * 200 + 55);
  line(0, 0, 0, 
  0, 0, length);
  popMatrix();
}

// -----------------------------------------------------------------
// SimpleOpenNI user events

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
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

