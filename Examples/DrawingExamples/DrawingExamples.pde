import processing.opengl.*;

// Demonstrates how to draw rectangular shapes between two points.
//
// By Evan Raskob <evan@openlabworkshops.org> for Openlab Workshops 
// http://openlabworkshops.org
//
// Licensed CC-Unported-By-Attribution

// images for body parts:
PImage bodyTex, headTex, armTex, legTex;

String bodyTexFile = "FieryMarioBody.png";
String headTexFile = "FieryMarioHead.png";
String armTexFile  = "FieryMarioLeftArm.png";
String legTexFile  = "FieryMarioLeftLeg.png";


PVector point1, point2;

// possible drawing modes
final int EXACT = 0;
final int PAD   = 1;

// current drawing mode
int drawingMode = EXACT;

int lengthPadding = 20;
int widthPadding = 60;


String drawingModeText = "Press spacebar to toggle between drawing mode - currently: ";

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

  // create our points, one in the top left of screen and one in center
  point1 = new PVector(0, 0, 0);
  point2 = new PVector(width/2, height/2, 0);
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  smooth();

  // clear screen to black
  background(0);

  stroke(0, 255, 0);
  fill(255, 60);

  // update first vector position
  point1.set(mouseX, mouseY, 0);


  // draw using drawing mode
  switch ( drawingMode )
  {
  case EXACT:
    // try this with a texture:
    
    // without texture:
    renderRectFromVectors(point1, point2, widthPadding);

    /* UNCOMMENT THESE TO DRAW TEXTURE
    noStroke();
    noFill();
    renderRectFromVectors(point1, point2, widthPadding, armTex);
    */
    
    fill(255);
    text(drawingModeText+"EXACT", 10, 24);
    break;

  case PAD:
    renderRectFromVectors(point1, point2, widthPadding, lengthPadding );
    fill(255);
    text(drawingModeText+"PAD", 10, 24);
    break;
  }
}


void keyReleased()
{

  //flip drawing mode
  if (key == ' ')
    drawingMode = 1-drawingMode;
}

