/////////////////////////////////////
//
// PARTICLES RENDERER 
//
//

import processing.core.*;
import java.util.ArrayList;


public class ParticleBodyPartRenderer implements BodyPartRenderer
{
  private PGraphics renderer;

  ArrayList<Particle> particles = new ArrayList<Particle>();
  float D;             // base diameter of all particles
  float mass = 0.2f;    // universal mass of all particles
  float DIST = 80*80;  // min distance for forces to act on
  float MIN_DIST = 40; // min dist between mouse positions for adding new particles
  boolean drawLines = true;  // draw lines btw particles?
  int MAX_PARTICLES = 200;

  private ArrayList<PVector> allJointPositions;

  public ParticleBodyPartRenderer(PGraphics g)
  {
    renderer = g;

    D = min(renderer.width, renderer.height) / 40;  // base diameter of particles on screen size.  change this for bigger/smaller particles
    DIST = 8f*pow(D, 2);     // distance between particles.  Smaller = more detail in final image
    MIN_DIST = D/10;              // see above

    allJointPositions = new ArrayList<PVector>();
  }


  /*
   * render a full skeleton, part-by-part
   */
  void render(Skeleton skeleton)
  {
    allJointPositions.clear();

    renderer.hint(DISABLE_DEPTH_TEST);
    if (skeleton.calibrated)  // first check if there is anything to draw!
    {
      fill(255);
      // these draw based on percentages (so they scale to the body parts)
      for (BodyPart bodyPart : skeleton.mBodyParts)
      {
        render( bodyPart );

        if (bodyPart.getType() == bodyPart.RIGHT_ARM_LOWER)
        {
          PVector prev = bodyPart.getPrevJoint(SimpleOpenNI.SKEL_RIGHT_HAND);
          PVector current = bodyPart.getJoint(SimpleOpenNI.SKEL_RIGHT_HAND);

          createNewParticle(current, prev);
        }
        else if (bodyPart.getType() == bodyPart.LEFT_ARM_LOWER)
        {
          PVector prev = bodyPart.getPrevJoint(SimpleOpenNI.SKEL_LEFT_HAND);
          PVector current = bodyPart.getJoint(SimpleOpenNI.SKEL_LEFT_HAND);

          createNewParticle(current, prev);
        }

      }

      // optional - keep track of "dead" particles, to remove later
      ArrayList<Particle> deadParticles = new ArrayList<Particle>();

      renderer.noStroke();

      // go through the particles and update their position data
      for (Particle p : particles)
      {
        p.update();

        if (p.alive)
        {
          //color c = bgImage.pixels[((int)p.pos.y)*bgImage.width + (int)p.pos.x];

          //color c = getColorFromPosition(p.pos); 
          color c = color(255);

          p.draw(c);
        }
        else
          deadParticles.add(p);
      }

      // not using this yet... but could...
      for (Particle p : deadParticles)
      {
        particles.remove(p);
        p = null;
      }

      // handle inter-particle forces
      repulseParticles(allJointPositions);
    }

    renderer.hint(ENABLE_DEPTH_TEST);
  }


  /*
   * render a single body part
   */
  void render(BodyPart bodyPart)
  {
    renderer.pushMatrix();
    renderer.translate(bodyPart.getScreenOffsetX(), bodyPart.getScreenOffsetY(), bodyPart.getScreenOffsetZ());

    if (bodyPart instanceof OnePointBodyPart)
    {
      PImage tex = bodyPart.getTexture();
      OnePointBodyPart obp = (OnePointBodyPart)bodyPart;

      allJointPositions.add(obp.screenPoint1);

      renderer.pushMatrix();
      renderer.translate(obp.screenPoint1.x, obp.screenPoint1.y, obp.screenPoint1.z);  

      float w = renderer.width*(obp.getLeftPadding()+obp.getRightPadding());
      float h = renderer.height*(obp.getTopPadding()+obp.getBottomPadding());

      if (obp.depthDisabled)
      {
        hint(DISABLE_DEPTH_TEST);
      }

      if (tex != null)
      {
        renderer.imageMode(CENTER);    
        renderer.image(tex, 0, 0, w, h);
      }
      else
      {
        fill(255);
        renderer.rectMode(CENTER);    
        renderer.rect(0, 0, w, h);
      }
      if (obp.depthDisabled)
      {
        hint(ENABLE_DEPTH_TEST);
      }
      renderer.popMatrix();
    }
    else if (bodyPart instanceof TwoPointBodyPart)
    {      
      TwoPointBodyPart tbp = (TwoPointBodyPart)bodyPart;
      renderer.pushMatrix();
      renderer.translate(tbp.screenPoint1.x, tbp.screenPoint1.y, tbp.screenPoint1.z);
      renderer.ellipse(0, 0, renderer.width/20, renderer.width/20);
      renderer.popMatrix();

      allJointPositions.add(tbp.screenPoint1);

      renderer.pushMatrix();
      renderer.translate(tbp.screenPoint2.x, tbp.screenPoint2.y, tbp.screenPoint2.z);
      renderer.ellipse(0, 0, renderer.width/20, renderer.width/20);
      renderer.popMatrix();

      allJointPositions.add(tbp.screenPoint2);

      //      renderRectFromVectors(tbp.screenPoint1, tbp.screenPoint2, tbp.getLeftPadding(), tbp.getRightPadding(), 
      //      tbp.getTopPadding(), tbp.getBottomPadding(), tbp.getTexture(), tbp.getReversed() );
    }
    else if (bodyPart instanceof FourPointBodyPart)
    {
      FourPointBodyPart fbp = (FourPointBodyPart)bodyPart;

      //      renderRectFromVectors(fbp.screenPoint1, fbp.screenPoint2, fbp.screenPoint3, fbp.screenPoint4, 
      //      fbp.getLeftPadding(), fbp.getRightPadding(), fbp.getTopPadding(), fbp.getBottomPadding(), 
      //      fbp.getTexture(), fbp.getReversed() );
    }

    renderer.popMatrix();
  }


  void createNewParticle(PVector prev, PVector current)
  {
    PVector diff = PVector.sub(current, prev);
    // add a new particle if the mouse is pressed
    if (diff.mag() > MIN_DIST)
    {
      Particle p = new Particle(current.x, current.y, D);
      //    p.v.x = 0.01*(pmouseX-mouseX);
      //    p.v.y = 0.01*(pmouseY-mouseY);

      // set max velocity based on screen size
      p.MAXV.x = renderer.width/200.0;
      p.MAXV.y = renderer.height/200.0;

      particles.add(p);

      if (particles.size() > MAX_PARTICLES)
      {
        particles.remove(0);
      }
    }
  }


  void repulseParticles(ArrayList<PVector> jointPositions) 
  {
    renderer.beginShape(LINES);

    for (int i=0; i<particles.size(); ++i)
    {
      Particle p0 = particles.get(i);

      for (PVector jointPos : jointPositions)
      {
        float distSquared = pow(p0.pos.x-jointPos.x, 2) + pow(p0.pos.y-jointPos.y, 2);
        float m = constrain((p0.d + D), 0.4f, 1.6f);
        Vec2D dir = p0.pos.sub(jointPos.x, jointPos.y);
        float F = min(0.02, 1.0f/distSquared) / m;

        dir.scaleSelf( F );
        p0.a.addSelf(dir);
      }

      for (int ii=i+1; ii<particles.size(); ++ii ) {

        Particle p1 = particles.get(ii);

        Vec2D dir = p0.pos.sub(p1.pos);

        float distSquared = dir.magSquared();

        if ( distSquared > 0.0f && distSquared <= DIST)
        {
          dir.normalize();

          float m = constrain(0.85*(p0.d + p1.d), 0.4f, 0.8f);

          float F = min(0.1, 1.0f/distSquared) / m;

          dir.scaleSelf( F );
          if (drawLines)
          {
            //stroke(255,80);
            //stroke(0,200,0);
            renderer.stroke(p0.c & 0x66FFFFFF);                                      
            //line(p0.pos.x, p0.pos.y, p1.pos.x, p1.pos.y);

            renderer.vertex(p0.pos.x, p0.pos.y);
            renderer.stroke(p1.c & 0x66FFFFFF);
            renderer.vertex(p1.pos.x, p1.pos.y);
          }
          p0.a.addSelf(dir);
          p1.a.subSelf(dir);
        }
      }
    }
    renderer.endShape();
  }




  // a simple Particle class with acceleration and velocity

  class Particle
  {
    Vec2D MAXV = new Vec2D(2, 2);  // max velocity this particle can have (absolute)

    Vec2D pos;  // position  
    Vec2D v;    // instantaneous velocity
    Vec2D a;    // instantaneous acceleration
    float d;    // diameter
    color c;    // color
    boolean alive = false; 
    int life = 255;

    Particle(float _x, float _y, float _d)
    {
      pos = new Vec2D(_x, _y);
      v = new Vec2D();
      a = new Vec2D();
      d = _d;
      alive = true;
    }


    void draw(color _c)
    {
      c = _c;
      renderer.fill(255, life);
      //d = lerp(d, (0.5*brightness(c)/255.0 + 0.1), 0.5);
      float realD = life/255f*D; 
      renderer.ellipse(pos.x, pos.y, realD, realD);
    }

    void update()
    {
      life--;
      if (life < 0)
        alive = false;
      else
      {

        if (v.x > MAXV.x)
          v.x = MAXV.x;

        if (v.x < -MAXV.x)
          v.x = -MAXV.x;

        if (v.y > MAXV.y)
          v.y = MAXV.y;

        if (v.y < -MAXV.y)
          v.y = -MAXV.y;

        pos.addSelf(v);
        v.scaleSelf(0.95);
        v.x += a.x;
        v.y += a.y;
        a.scaleSelf(0.5);

        //    if (pos.x >= width || pos.x <= 0 ||
        //        pos.y >= height || pos.y <= 0)

        if (pos.x >= renderer.width || pos.x <= 0)
        {
          alive = false;
          pos.x = constrain(pos.x, 0, renderer.width-1);
          v.x = -v.x;
          a.x = 0;
        }
        if (pos.y >= renderer.height || pos.y <= 0)
        {
          alive = false;
          pos.y = constrain(pos.y, 0, renderer.height-1);
          v.y = -v.y;
          a.y = 0;
        }
      }
    }
  }


  // end particles renderer
}
