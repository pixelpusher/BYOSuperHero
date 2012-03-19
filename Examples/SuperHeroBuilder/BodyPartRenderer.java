
//
// BASE INTERFACE
//

import processing.core.PGraphics;

public interface BodyPartRenderer
{
  // public PGraphics renderer;

  // public BodyPartRenderer(PGraphics g);


  /*
   * render a full skeleton, part-by-part
   */
  void render(Skeleton skeleton);
  /*
   * render a single body part
   */
  void render(BodyPart bodyPart);
}
