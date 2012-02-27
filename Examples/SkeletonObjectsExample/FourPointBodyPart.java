import SimpleOpenNI.*;
import processing.core.PImage;
import processing.core.PVector;


public class FourPointBodyPart extends BodyPart
{
  public PVector worldPoint1, screenPoint1;
  public PVector worldPoint2, screenPoint2;
  public PVector worldPoint3, screenPoint3;
  public PVector worldPoint4, screenPoint4;
  
  
  private int joint1ID, joint2ID, joint3ID, joint4ID;
  
  //
  // Basic contructor
  //
  public FourPointBodyPart(int _joint1ID, int _joint2ID, int _joint3ID, int _joint4ID, int type )
  {
    setType(type);
    
    worldPoint1 = new PVector();
    screenPoint1 = new PVector();

    worldPoint2 = new PVector();
    screenPoint2 = new PVector();

    worldPoint3 = new PVector();
    screenPoint3 = new PVector();

    worldPoint4 = new PVector();
    screenPoint4 = new PVector();
    
    offsetPercent = new PVector();
    offsetCalculated = new PVector();
    
    joint1ID = _joint1ID;
    joint2ID = _joint2ID;
    joint3ID = _joint3ID;
    joint4ID = _joint4ID;

    tex = null;
    context = null;
    
    padR = padL = padT = padB = 0f;
  }
  
  
  public BodyPart update()
  {
    // get joint positions in 3D world for the tracked limbs
      context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);
      context.getJointPositionSkeleton(skeletonId, joint2ID, worldPoint2);
      context.getJointPositionSkeleton(skeletonId, joint3ID, worldPoint3);      
      context.getJointPositionSkeleton(skeletonId, joint4ID, worldPoint4);

      context.convertRealWorldToProjective(worldPoint1, screenPoint1);
      screenPoint1.z = worldDepthToScreen(screenPoint1.z);
      
      context.convertRealWorldToProjective(worldPoint2, screenPoint2);
      screenPoint2.z = worldDepthToScreen(screenPoint2.z);

      context.convertRealWorldToProjective(worldPoint3, screenPoint3);
      screenPoint3.z = worldDepthToScreen(screenPoint3.z);

      context.convertRealWorldToProjective(worldPoint4, screenPoint4);
      screenPoint4.z = worldDepthToScreen(screenPoint4.z);
      
      // now calculate offsets in screen coords
      offsetCalculated.x = offsetPercent.x*(screenPoint1.x+screenPoint2.x)*0.5f;
      offsetCalculated.y = offsetPercent.y*(screenPoint1.y+screenPoint4.y)*0.5f;
      offsetCalculated.z = offsetPercent.z*(screenPoint1.z+screenPoint4.z)*0.5f;
      
      return this;
  }
      
}

