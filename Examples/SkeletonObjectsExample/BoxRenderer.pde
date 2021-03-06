/////////////////////////////////////
//
// BASE 2D RENDERER (RECTANGLES AND TEXTURES)
//
//

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;


public class BoxRenderer implements BodyPartRenderer
{
  private PGraphics renderer;
  private Skeleton mSkeleton;
  private PApplet app;
  private float rendererScaleW, rendererScaleH;

  public ToxiclibsSupport gfx;

  TriangleMesh origMesh, mesh;

  public void initRenderer(PApplet _app)
  {
    app = _app;
    gfx=new ToxiclibsSupport(app);
    mSkeleton = null;
    //origMesh =(TriangleMesh)new AABB(new Vec3D(), 1).toMesh();
    
    // load a mesh from a 3D STL file
    STLReader reader = new STLReader(); 
    origMesh = (TriangleMesh) reader.loadBinary(dataPath("head.stl"), TriangleMesh.class);
    //origMesh.transform(new Matrix4x4().translateSelf(0, 0, 1));
    origMesh.scale(0.05);
  }

  public BoxRenderer(PGraphics g)
  {
    setRenderer(g);
  }

  public void setRenderer(PGraphics g)
  {
    renderer = g;
    if (app != null)
    {
      rendererScaleW = renderer.width/((float)app.width);
      rendererScaleH = renderer.height/((float)app.height);
    }
    else
    {
      rendererScaleW = 1f;
      rendererScaleH = 1f;
    }
  }

  public void setSkeleton(Skeleton s)
  {
    mSkeleton = s;
  }   

  public void render()
  {
    render(mSkeleton);
  }

  /*
   * render a full skeleton, part-by-part
   */
  void render(Skeleton skeleton)
  {
    if (skeleton != null && skeleton.calibrated)  // first check if there is anything to draw!
    {
      // these draw based on percentages (so they scale to the body parts)
      for (BodyPart bodyPart : skeleton.mBodyParts)
      {
        render( bodyPart );
      }
    }
  }


  /*
   * render a single body part
   */
  void render(BodyPart bodyPart)
  {
    renderer.pushMatrix();
    //    renderer.translate(-renderer.width/2, -renderer.height/2, 0);
    //    renderer.scale(2,2,1);


    renderer.translate(bodyPart.getScreenOffsetX(), bodyPart.getScreenOffsetY(), bodyPart.getScreenOffsetZ());

    if (bodyPart instanceof OnePointBodyPart)
    {
      PImage tex = bodyPart.getTexture();
      OnePointBodyPart obp = (OnePointBodyPart)bodyPart;

      Vec3D p1 = new Vec3D(obp.screenPoint1.x, obp.screenPoint1.y, obp.screenPoint1.z);

      renderer.pushMatrix();
      gfx.setGraphics(renderer);

      if (obp.depthDisabled)
      {
        hint(DISABLE_DEPTH_TEST);
      }

      float w = 0.1f*renderer.width*(obp.getLeftPadding()+obp.getRightPadding());
      float h = 0.1f*renderer.height*(obp.getTopPadding()+obp.getBottomPadding());

      // scale from point to point
      mesh = origMesh.getScaled(new Vec3D(w, h, h));
      gfx.translate(p1);
      gfx.rotate(millis()*0.01f);

      if (tex != null)
      {
        gfx.texturedMesh(mesh, tex, false);
      }
      else
      {

        gfx.mesh(mesh, false, 10);
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

      renderMeshFromVectors(tbp.screenPoint1, tbp.screenPoint2, tbp.getLeftPadding(), tbp.getRightPadding(), 
      tbp.getTopPadding(), tbp.getBottomPadding(), tbp.getTexture(), tbp.getReversed() );
    }
    else if (bodyPart instanceof FourPointBodyPart)
    {
      FourPointBodyPart fbp = (FourPointBodyPart)bodyPart;

      renderMeshFromVectors(fbp.screenPoint1, fbp.screenPoint2, fbp.screenPoint3, fbp.screenPoint4, 
      fbp.getLeftPadding(), fbp.getRightPadding(), fbp.getTopPadding(), fbp.getBottomPadding(), 
      fbp.getTexture(), fbp.getReversed() );
    }

    renderer.popMatrix();
  }

  // utility function to make typing easier
  Vec3D Vec3DFromPVector(PVector v)
  {
    Vec3D v3d = new Vec3D(v.x, v.y, v.z);
    return v3d;
  }


  void  renderMeshFromVectors(PVector screenPoint1, PVector screenPoint2, float leftPadding, float rightPadding, 
  float topPadding, float bottomPadding, PImage tex, boolean reversed)
  {
    Vec3D p1 = Vec3DFromPVector(screenPoint1);
    Vec3D p2 = Vec3DFromPVector(screenPoint2);

    float diff = p2.distanceTo(p1)/2;
    float scaleX = diff*(leftPadding+rightPadding);
    float scaleY = diff*(topPadding+bottomPadding);

    //Vec3D meshScale = Vec3D(diff*(leftPadding+rightPadding), diff*(topPadding+bottomPadding), diff);
    drawMeshBetween(p1, p2, scaleX, scaleY, origMesh, renderer);
  }

  void  renderMeshFromVectors(PVector screenPoint1, PVector screenPoint2, PVector screenPoint3, PVector screenPoint4, float leftPadding, float rightPadding, 
  float topPadding, float bottomPadding, PImage tex, boolean reversed)
  {
    Vec3D p1 = Vec3DFromPVector(screenPoint1);
    Vec3D p2 = Vec3DFromPVector(screenPoint2);

    float diff = p2.distanceTo(p1);
    float scaleX = diff*(leftPadding+rightPadding);
    float scaleY = diff*(topPadding+bottomPadding);

    //Vec3D meshScale = Vec3D(diff*(leftPadding+rightPadding), diff*(topPadding+bottomPadding), diff);
    drawMeshBetween(p1, p2, scaleX, scaleY, origMesh, renderer);
  }


  public void drawMeshBetween(Vec3D p1, Vec3D p2, float scaleX, float scaleY, TriangleMesh mesh, PGraphics buffer)
  {
    //place p1-p2 vector diff at origin
    gfx.setGraphics(buffer);

    Vec3D meshDiff = p2.sub(p1);
    float meshMag = meshDiff.magnitude();
    Vec3D dir = meshDiff.getNormalized();

    // scale properly
    Vec3D meshScale = new Vec3D(scaleX, scaleY, meshMag/2);

    // scale from point to point
    mesh = mesh.getScaled(meshScale);

    // get current rotation
    float[] axis=Quaternion.getAlignmentQuat(dir, Vec3D.Z_AXIS).toAxisAngle();

    buffer.noStroke();
    buffer.pushMatrix();

    // move to 1st points
    gfx.translate(p1);

    // align the Z axis of the box with the direction vector  
    buffer.rotate(axis[0], axis[1], axis[2], axis[3]);


    // draw rotated coordinate system
    gfx.origin(new Vec3D(), 100);
    gfx.mesh(mesh, false, 10);
    buffer.popMatrix();
  }




  void renderRectFromVectors(PVector p1, PVector p2, float padLeft, float padRight, float padTop, float padBottom, PImage tex, boolean reversed)
  {
    // rotate the screen the angle btw the two vectors and then draw it rightside-up
    float angle = atan2(p2.y-p1.y, p2.x-p1.x);

    float w2 =  (p1.x - p2.x)*0.5f;
    float h2 =  (p1.y - p2.y)*0.5f;
    float xCenter = p1.x - w2;
    float yCenter = p1.y - h2;

    // height of the shape
    //float xdiff = p1.x-p2.x;
    //float ydiff = p1.y-p2.y;
    //float h = sqrt( xdiff*xdiff + ydiff*ydiff);
    float h = p1.dist(p2);

    float widthPadding = h*(padLeft+padRight);

    float totalHeight =  h + h*(padTop+padBottom);

    // save drawing state
    renderer.pushMatrix();

    // rotations are at 0,0 by default, but we want to rotate around the center
    // of this shape

    renderer.translate(xCenter, yCenter, (p1.z+p2.z)/2);
    //renderer.ellipse(0, 0, 20, 20);

    // rotate
    renderer.rotate(angle);

    // center screen
    renderer.translate(-h*padTop-h*0.5f, -padLeft*h);

    renderRect(totalHeight, widthPadding, p1.z, p2.z, tex, reversed);

    renderer.popMatrix();
  }


  void renderRect(float w, float h, PImage tex)
  {
    renderRect(w, h, tex, false);
  }




  void renderRect(float w, float h, PImage tex, boolean reversed)
  {
    renderer.textureMode(NORMALIZED);
    int r = reversed ? 1 : 0;

    // now draw rightside up
    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(0, 0, 1-r, 0);
      renderer.vertex(w, 0, 1-r, 1);
      renderer.vertex(w, h, r-0, 1);

      renderer.vertex(w, h, r-0, 1);
      renderer.vertex(0, h, r-0, 0);
      renderer.vertex(0, 0, 1-r, 0);
    }
    else
    {
      renderer.vertex(0, 0);
      renderer.vertex(w, 0);
      renderer.vertex(w, h);

      renderer.vertex(w, h);
      renderer.vertex(0, h);
      renderer.vertex(0, 0);
    }
    renderer.endShape(CLOSE);
  }



  void renderRect(float w, float h, float d1, float d2, PImage tex, boolean reversed)
  {
    int r = reversed ? 1 : 0;

    renderer.textureMode(NORMALIZED);

    // now draw rightside up
    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(0, 0, d1, 1-r, 0);
      renderer.vertex(w, 0, d1, 1-r, 1);
      renderer.vertex(w, h, d2, r-0, 1);

      renderer.vertex(w, h, d2, r-0, 1);
      renderer.vertex(0, h, d2, r-0, 0);
      renderer.vertex(0, 0, d1, 1-r, 0);
    }
    else
    {
      renderer.vertex(0, 0);
      renderer.vertex(w, 0);
      renderer.vertex(w, h);

      renderer.vertex(w, h);
      renderer.vertex(0, h);
      renderer.vertex(0, 0);
    }
    renderer.endShape(CLOSE);
  }


  // untextured rectagle between 4 points 
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4)
  {
    renderRectFromVectors( p1, p2, p3, p4, 0, 0, null);
  }


  // textured rectangle between 4 points
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, PImage tex)
  {
    renderRectFromVectors( p1, p2, p3, p4, 0, 0, tex);
  }


  //
  // Render a clockwise list of vectors as a (optionally) textured rectangle with padding  
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, float padX, float padY, PImage tex, boolean reversed)
  {
    float pX1 = padX*(p2.x-p1.x);
    float pX2 = padX*(p3.x-p4.x);

    float pY1 = padY*(p4.y-p1.y);
    float pY2 = padY*(p3.y-p2.y);

    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(p1.x-pX1, p1.y-pY1, 0, 0);
      renderer.vertex(p2.x+pX1, p2.y-pY2, 100, 0);
      renderer.vertex(p3.x+pX2, p3.y+pY1, 100, 100);

      renderer.vertex(p3.x+pX2, p3.y+pY1, 100, 100);
      renderer.vertex(p4.x-pX2, p4.y+pY2, 0, 100);
      renderer.vertex(p1.x-pX1, p1.y-pY1, 0, 0);
    }
    else
    {
      renderer.vertex(p1.x-pX1, p1.y-pY1);
      renderer.vertex(p2.x+pX1, p2.y-pY2);
      renderer.vertex(p3.x+pX2, p3.y+pY1);

      renderer.vertex(p3.x+pX2, p3.y+pY1);
      renderer.vertex(p4.x-pX2, p4.y+pY2);
      renderer.vertex(p1.x-pX1, p1.y-pY1);
    }
    renderer.endShape();
  }


  //
  // Render a clockwise list of vectors as a (optionally) textured rectangle with padding  
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, float padL, float padR, float padT, float padB, PImage tex, boolean reversed)
  {
    float WT = p2.x-p1.x;
    float WB = p3.x-p4.x;

    float padWidthLT = padL*WT;
    float padWidthLB = padL*WB;

    float padWidthRT = padR*WT;
    float padWidthRB = padR*WB;


    float HL = p4.y-p1.y;
    float HR = p3.y-p2.y;

    float padHeightTL = padT*HL;
    float padHeightTR = padT*HR;

    float padHeightBL = padB*HL;
    float padHeightBR = padB*HR;

    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL, 0, 0);
      renderer.vertex(p2.x+padWidthRT, p2.y-padHeightTR, 100, 0);
      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR, 100, 100);

      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR, 100, 100);
      renderer.vertex(p4.x-padWidthLB, p4.y+padHeightBL, 0, 100);
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL, 0, 0);
    }
    else
    {
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL);
      renderer.vertex(p2.x+padWidthRT, p2.y-padHeightTR);
      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR);

      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR);
      renderer.vertex(p4.x-padWidthLB, p4.y+padHeightBL);
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL);
    }
    renderer.endShape();
  }


  //
  // Render a clockwise list of vectors as a rectangle with padding
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padX, int padY)
  {
    renderRectFromVectors( p1, p2, p3, p4, padX, padY, null);
  }

  //
  // Render a clockwise list of vectors as an (optionally) textured rectangle with padding
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padX, int padY, PImage tex)
  {
    renderRectFromVectors( p1, p2, p3, p4, padX, padX, padY, padY, tex, false);
  }

  //
  // ignores reversed for now
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padXLeft, int padXRight, int padYTop, int padYBottom, PImage tex, boolean reversed)
  {

    float pX1 = padXLeft;
    float pX2 = padXRight;

    float pY1 = padYTop;
    float pY2 = padYBottom;

    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);    
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z, 0, 0);
      renderer.vertex(p2.x+pX1, p2.y-pY1, p2.z, 100, 0);
      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z, 100, 100);

      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z, 100, 100);
      renderer.vertex(p4.x-pX2, p4.y+pY2, p4.z, 0, 100);
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z, 0, 0);
    }
    else
    {
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z);
      renderer.vertex(p2.x+pX1, p2.y-pY1, p2.z);
      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z);

      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z);
      renderer.vertex(p4.x-pX2, p4.y+pY2, p4.z);
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z);
    }
    renderer.endShape();
  }

  // end class BodyPartRenderer
}

