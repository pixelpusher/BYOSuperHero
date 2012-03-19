// Visual tool for building superheros 
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

final String jointsXMLFile = "joints.xml";

// shortcut to the current skeleton we want to draw
Skeleton currentSkeleton = null;

// this is a reference to the part that draws body parts to the screen
BodyPartRenderer bodyPartRenderer;
// these are the actual renderers
BodyPartRenderer bodyPart2DRenderer, bodyPartParticleRenderer;

// this contains methods for creating new body parts and adding them to skeletons (to keep track of)
BodyPartFactory bodyPartFactory;


float screenWidthToKinectWidthRatio = 1.0f;
float screenHeightToKinectHeightRatio = 1.0f;

// last time we saved an image
int lastSaveTime = 0;

boolean drawDepthImage = true;
boolean saveFrames = false;

SimpleOpenNI context = null;

HashMap<Integer, String> JOINT_NAMES; // plain text names of joints mapped to the OpenNI joint indices
HashMap<Integer, String> jointIDs; // OpenNI names of joints mapped to the OpenNI joint indices

ArrayList<Joint> joints;  // cached joint positions

float offsetX, offsetY;

///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, OPENGL); 

  currentSkeleton = new Skeleton(context); // remember that context is null because we are not using the camera now...

  screenWidthToKinectWidthRatio = width/640.0f;
  screenHeightToKinectHeightRatio = height/480.0f;

  // load some texture files
  bodyTex = loadImage(bodyTexFile);
  headTex = loadImage(headTexFile);
  armTex = loadImage(armTexFile);
  toplegTex = loadImage(toplegTexFile);
  legTex = loadImage(legTexFile);
  toparmTex = loadImage(toparmTexFile);


  // create body part factory for creating new body parts
  bodyPartFactory = BodyPartFactory.getInstance();

  // this will draw body parts and skeletons (collections of body parts) to the screen
  //bodyPartRenderer = new BasicBodyPartRenderer(this.g);

  // or try this renderer...
  bodyPartParticleRenderer = new ParticleBodyPartRenderer(this.g);

  bodyPartRenderer = bodyPart2DRenderer= new BasicBodyPartRenderer(this.g);

  context = new SimpleOpenNI(this);

  // set up joint names-to-ids hashmaps
  setupJointNames();

  BufferedReader reader = null;

  reader = createReader(jointsXMLFile);

  if (reader == null)
  {
    println("No xml file found:" + jointsXMLFile);
    exit();
  }
  joints = new ArrayList<Joint>();

  XML jointsXML = new XML (reader);

  XML jointNodes[] = jointsXML.getChildren("jointsData/jointsPositions");

  println("XML: Found " + jointNodes.length + " joints nodes");

  //
  // HANDLE joints
  //   
  for (int i=0; i < jointNodes.length; ++i)
  {
    XML node = jointNodes[i];

    String name = node.getString("id");
    float x = node.getFloat("x");
    float y = node.getFloat("y");
    float z = node.getFloat("z");

    int OpenNIID = jointStringToInt( name );
    Joint joint = new Joint(name, OpenNIID);
    joint.set(x, y, z);

    joints.add( joint );      
    println("Joint name:" + name);
  }

setupGui();
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
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_WRIST, BodyPart.LEFT_ARM_LOWER)
    .setPadding(0.15, 0.15, 0.15, 0.0)
      .setTexture(armTex);

  //LOWER RIGHT ARM
  bodyPartFactory.createPartForSkeleton(s, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_WRIST, BodyPart.RIGHT_ARM_LOWER)
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
        .disableDepth(true);

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

  // set all new joint positions [properly based on ones we read in      
  s.update( joints );
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  background(0);

  boolean saveImage = false;

  fill(255, 150);
  stroke(0, 0, 0);
  strokeWeight(2);

  // draw only the current: ?
  //  if (currentSkeleton != null)


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
  bodyPartRenderer.render( currentSkeleton );


  // save frame image if necessary
  if (saveFrames && (millis()-lastSaveTime) > 2000)
  {
    fill(0, 255, 0);
    ellipse(width-40, 40, 30, 30);
    lastSaveTime = millis();
    saveImage = true;
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

  default: 
    saveFrame("kinect"+year()+"-"+month()+"-"+day()+"_"+hour()+"."+minute()+"."+second()+".png");
    break;
  }
}

