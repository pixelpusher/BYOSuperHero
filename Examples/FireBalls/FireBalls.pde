import toxi.geom.*;
import toxi.geom.mesh.*;
import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;


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
  
  
  meshBuilder = new SurfaceMeshBuilder( new SuperEllipsoid( random(-2.5,2.5), random(-2.5,2.5) ) );
  
}



/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  background(0);
  hint(DISABLE_DEPTH_TEST);
  GLGraphics renderer = (GLGraphics)g;

  renderer.beginGL();  
  //renderer.setDepthMask(false);
  
  // now update and draw models
  int currentTime = millis();
  
  ListIterator<ParticleMover> iter = particleBlasters.listIterator();
  
  for (ImageParticleSwarm swarm : swarms)
  {
    ParticleMover particleBlaster = iter.next();
    
    swarm.update(particleBlaster, currentTime);
    swarm.render();
  }

  //renderer.setDepthMask(true);
  renderer.endGL();
}





void mousePressed()
{
  if (!mouseWasDown)
  {
    mouseWasDown = true;
    meshBuilder.setFunction( new SuperEllipsoid( random(-2,2), random(-2,2) ) );
  
    newSwarm(fireballTex, mouseX, mouseY);
  }
}



void mouseReleased()
{
  mouseWasDown = false;
}





void newSwarm(GLTexture tex, float x, float y)
{
  TriangleMesh mesh = (TriangleMesh)meshBuilder.createMesh(null,5, 5);
  mesh.computeVertexNormals();
  
  // position at mouse
  mesh.translate(new Vec3D(x, y,0) );
  
  ImageParticleSwarm swarm = new ImageParticleSwarm(this, tex);
  
  if (swarm.makeModel( mesh ))
  {
    swarms.add( swarm );
    
    // now create object to move this swarm of fireballs
    ParticleMover particleBlaster = new ParticleMover();
    
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
