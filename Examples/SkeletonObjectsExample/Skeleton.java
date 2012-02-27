import SimpleOpenNI.*;
import java.util.ArrayList;

public class Skeleton
{
  // the userid from OpenNI
  public int id = 1;
  public SimpleOpenNI context;
  
  // are we calibrated and ready to draw?
  public boolean calibrated = false;

  // relevant skeleton positions from our Kinect in screen coordinates:

  public ArrayList<BodyPart> bodyParts;

  // end class vars

  // 
  // Default constructor
  //
  public Skeleton(SimpleOpenNI _context)
  {
    bodyParts = new ArrayList<BodyPart>();
    context = _context;
  }

  // 
  // Constructor with id
  //
  public Skeleton(SimpleOpenNI _context, int _id)
  {
    id = _id;
    context = _context;
    bodyParts = new ArrayList<BodyPart>();
  }

  

  ////////////////////////////////////////
  // update internal vars
  //

  public Skeleton update()
  {
    // draw the skeleton if it's available
    if (calibrated && context.isTrackingSkeleton(id))
    {  
      for (BodyPart bp : bodyParts)
      {
        bp.update();
      }
    }
    
    // return reference to this object
    return this;
  } 

  // end class Skeleton
}

