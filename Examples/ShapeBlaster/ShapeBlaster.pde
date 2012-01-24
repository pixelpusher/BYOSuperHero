import controlP5.*;

import toxi.geom.*;
import toxi.geom.mesh.*;
import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;


// This examples uses the library controlP5




////////////////////////////////
// GLOBAL VARS

// images for fireballs
GLTexture fireballTex;

// fireball "swarm" vars
LinkedList<ImageParticleSwarm> swarms;

LinkedList<ParticleMover> particleBlasters;

TriangleMesh triMesh;  // for drawing flame trails

boolean mouseWasDown = false;

SurfaceMeshBuilder meshBuilder;

// GUI
ControlP5 controlP5;
Slider2D s;
Slider noisySlider;


///////////////////////////////////////////
// SETUP
//

void setup()
{
  size(640, 480, GLConstants.GLGRAPHICS);  

  // create fireball particle "swarm"
  swarms = new LinkedList<ImageParticleSwarm>();
  particleBlasters = new LinkedList<ParticleMover>();

  // fire trail
  triMesh =new TriangleMesh("mesh1");

  // any particle texture... small is better
  fireballTex = new GLTexture(this, "mario_fireball.png");


  meshBuilder = new SurfaceMeshBuilder( new SuperEllipsoid( random(-2.5, 2.5), random(-2.5, 2.5) ) );

  // GUI
  controlP5 = new ControlP5(this);
  s = controlP5.addSlider2D("shape", 10, 40, 100, 100);
  noisySlider = controlP5.addSlider("noisiness", 0.0,10.0, 10,5, 100,25);
  s.setArrayValue(new float[] {
    50, 50
  }
  );
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  background(80);

  GLGraphics renderer = (GLGraphics)g;

  renderer.beginGL();  
  //renderer.setDepthMask(false);
  renderer.gl.glDisable(GL.GL_DEPTH_TEST);

  renderer.gl.glEnable(GL.GL_LIGHTING);

  // Disabling color tracking, so the lighting is determined using the colors
  // set only with glMaterialfv()
  //renderer.gl.glDisable(GL.GL_COLOR_MATERIAL);

  // Enabling color tracking for the specular component, this means that the 
  // specular component to calculate lighting will obtained from the colors 
  // of the model (in this case, pure green).
  // This tutorial is quite good to clarify issues regarding lighting in OpenGL:
  // http://www.sjbaker.org/steve/omniv/opengl_lighting.html
  renderer.gl.glEnable(GL.GL_COLOR_MATERIAL);
  renderer.gl.glColorMaterial(GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR);  

  renderer.gl.glEnable(GL.GL_LIGHT0);
  renderer.gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, new float[] {
    0.1, 0.1, 0.1, 0.8
  }
  , 0);
  renderer.gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, new float[] {
    1, 0.4, 0.2, 0.8
  }
  , 0);  
  renderer.gl.glLightfv(GL.GL_LIGHT0, GL.GL_POSITION, new float[] {
    -1000, 600, 2000, 0
  }
  , 0);
  renderer.gl.glLightfv(GL.GL_LIGHT0, GL.GL_SPECULAR, new float[] { 
    1, 1, 1, 0.8
  }
  , 0); 


  // now update and draw models
  int currentTime = millis();

  ListIterator<ParticleMover> iter = particleBlasters.listIterator();

  for (ImageParticleSwarm swarm : swarms)
  {
    ParticleMover particleBlaster = iter.next();

    swarm.update(particleBlaster, currentTime);
    swarm.render();
  }

  //back to original state so it doesn't affect the pcontrol GUI
  renderer.gl.glDisable(GL.GL_LIGHTING);


  renderer.endGL();
}





void mousePressed()
{
  if (!s.isInside() && !noisySlider.isInside() && !mouseWasDown)
  {
    mouseWasDown = true;

    float paramx = map(s.arrayValue()[0], 0, 100, EPSILON, 5);
    float paramy = map(s.arrayValue()[1], 0, 100, EPSILON, 5);

    meshBuilder.setFunction( new SuperEllipsoid( paramx, paramy ) );

    newSwarm(fireballTex, mouseX, mouseY);
  }
}



void mouseReleased()
{
  mouseWasDown = false;
}





void newSwarm(GLTexture tex, float x, float y)
{
  TriangleMesh mesh = (TriangleMesh)meshBuilder.createMesh(null, 27, 27);
  mesh.computeVertexNormals();

  // position at mouse
  mesh.rotateX( random(-PI, PI) );
  mesh.translate(new Vec3D(x, y, 0) );


  ImageParticleSwarm swarm = new ImageParticleSwarm(this, tex);

  if (swarm.makeModel( mesh ))
  {
    swarms.add( swarm );

    // now create object to move this swarm of fireballs
    ParticleMover particleBlaster = new ParticleMover();
    particleBlaster.noisiness = noisySlider.value();
    float angle = atan2(y-height/2, x-width/2);
    float vel = random(1, 5);

    particleBlaster.vx = vel * cos(angle); 
    particleBlaster.vy = vel * sin(angle);

    particleBlasters.add( particleBlaster );

    if (swarms.size() > 5)
    {
      ImageParticleSwarm first = swarms.removeFirst();
      first.destroy();

      particleBlasters.removeFirst();
    }
  }

  // clear tri mesh
  mesh.clear();
}

