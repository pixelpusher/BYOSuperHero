

PVector p1 = new PVector();
PVector p2 = new PVector();


void setup()
{
  size(640,480);
  
  // set point 1 to midway across the screen, at screen depth
  p1.set( width/2, height/2, 0);
  
}


void draw()
{
  smooth();
  background(0); // clear screen
  
  // set my 2nd point to be the mouse position
  p2.set( mouseX, mouseY, 0);
  
  stroke(255);
  strokeWeight(4);
  //line( p1.x, p1.y,  p2.x, p2.y);
  
  //float angle = PVector.angleBetween(p2,p1);
  
  float angle = atan2(p2.y-p1.y, p2.x-p1.x);
  
  textSize(36); // 36 pixels
  text("angle:" + degrees(angle), mouseX,mouseY);
 
 
   pushMatrix();
   // rotate the entire screen a certain angle
   translate(width/2,height/2);
   rotate( angle);
   
   
   fill(255,255,0);
   rect(0,0, 80,60);

   stroke(255,80,255);
   line(0,0, 200,0);

   popMatrix();
 
}
   
  
