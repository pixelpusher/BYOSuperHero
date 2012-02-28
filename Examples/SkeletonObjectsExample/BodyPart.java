import SimpleOpenNI.*;
import processing.core.PImage;
import processing.core.PVector;
import processing.core.PApplet.*;

public abstract class BodyPart
{ 
  /*
  BodyPart setPadding(float l, float r, float t, float b);
   
   BodyPart setTopPadding(float padPercent);
   BodyPart setBottomPadding(float padPercent);
   BodyPart setLeftPadding(float padPercent);
   BodyPart setRightPadding(float padPercent);
   
   BodyPart setType(int id); // Skeleton part id form SimpleOpenNI
   
   BodyPart setTexture(PImage _tex);
   PImage   getTexture(PImage _tex);
   */

  static int HEAD = 0;
  static int NECK = 1;
  static int LEFT_ARM_UPPER = 2;
  static int LEFT_ARM_LOWER = 3;
  static int RIGHT_ARM_UPPER = 4;
  static int RIGHT_ARM_LOWER = 5;
  static int TORSO = 6;
  static int LEFT_LEG_UPPER = 7;
  static int LEFT_LEG_LOWER = 8;
  static int RIGHT_LEG_UPPER = 9;
  static int RIGHT_LEG_LOWER = 10;

  protected PImage tex;
  protected float padR, padL, padT, padB;
  public boolean reversed;
  public boolean depthDisabled;
  
  protected SimpleOpenNI context;
  protected int skeletonId;
  protected int type;

  public PVector offsetPercent;  // offset for this body part (percentage-wise, in screen coords)
  public PVector offsetCalculated;

  static public boolean checkTypeIsValid(int _type)
  {
    if (_type >= BodyPart.HEAD && _type <= BodyPart.RIGHT_LEG_LOWER)
      return true;

    return false;
  }

  /*
   * this must be overridden by subclasses that actually implement this
   */
  public abstract BodyPart update();

  /*
   * This must be overridden by subclasses that actually implement this
   * Uses lerp() or some other method to give a bit of lag to the new movement
   * for each body part's joint point
   */
  public abstract BodyPart update(float[] lag); 

  public abstract PVector getJoint(int type); 

  /*
   * Useful for getting the screen depth for a given world depth
   */
  static float worldDepthToScreen(float z)
  {
    return (Math.abs(z) < 1E-5) ? 0f : 525.0f/z;
  }


  public BodyPart setContext(SimpleOpenNI _context)
  {
    context = _context;
    return this;
  }

  public SimpleOpenNI getContext()
  {
    return context;
  }

  public BodyPart setSkeletonId(int _skeletonId)
  {
    skeletonId = _skeletonId;
    return this;
  }

  public int getSkeletonId()
  {
    return skeletonId;
  }

  // TODO: should this be an enum?? -Evan
  //
  public BodyPart setType(int _type) throws BodyPartTypeNotValidException
  {
    if (BodyPart.checkTypeIsValid(_type))
      type = _type;
    else throw new BodyPartTypeNotValidException(_type);

    return this;
  }

  public int getType()
  {
    return type;
  }

  public BodyPart setOffsetX(int percent)
  {
    offsetPercent.x = percent;
    return this;
  }

  public BodyPart setOffsetY(int percent)
  {
    offsetPercent.y = percent;
    return this;
  }

  public BodyPart setOffsetZ(int percent)
  {
    offsetPercent.z = percent;
    return this;
  }

  public float getScreenOffsetX()
  {
    return offsetCalculated.x;
  }
  public float getScreenOffsetY()
  {
    return offsetCalculated.y;
  }
  public float getScreenOffsetZ()
  {
    return offsetCalculated.z;
  }


  public BodyPart setPadding(float l, float r, float t, float b)
  {
    padR = r;
    padL = l;
    padB = b;
    padT = t;
    return this;
  }

  public float[] getPadding()
  {
    return new float[] { 
      padR, padL, padT, padB
    };
  }

  public BodyPart setTopPadding(float padPercent)
  {
    padT = padPercent;
    return this;
  }
  public float getTopPadding()
  {
    return padT;
  }


  public BodyPart setBottomPadding(float padPercent)
  {
    padB = padPercent;
    return this;
  }
  public float getBottomPadding()
  {
    return padB;
  }


  public BodyPart setLeftPadding(float padPercent)
  {
    padL = padPercent;
    return this;
  }
  public float getLeftPadding()
  {
    return padL;
  }


  public BodyPart setRightPadding(float padPercent)
  {
    padR = padPercent;
    return this;
  }
  public float getRightPadding()
  {
    return padR;
  }

  public BodyPart setReversed(boolean r) // Skeleton part id form SimpleOpenNI
  {
    reversed = r;      
    return this;
  }

  public boolean getReversed() // Skeleton part id form SimpleOpenNI
  {
    return reversed;
  }

  public BodyPart disableDepth(boolean r) // Skeleton part id form SimpleOpenNI
  {
    depthDisabled = r;      
    return this;
  }

  public boolean getDepthDisabled() // Skeleton part id form SimpleOpenNI
  {
    return depthDisabled;
  }
  
  public BodyPart setTexture(PImage _tex)
  {
    tex = _tex;
    return this;
  }

  public PImage   getTexture()
  {
    return tex;
  }


  public class BodyPartTypeNotValidException extends RuntimeException
  {
    BodyPartTypeNotValidException() { 
      super();
    }
    BodyPartTypeNotValidException(int i)
    {
      super("Bad body part type: " + i);
    }
    BodyPartTypeNotValidException(String s) { 
      super(s);
    }
  }
}

