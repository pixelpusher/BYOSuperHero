
class Skeleton
{
  // the userid from OpenNI
  int id = 1;
  
  // are we calibrated and ready to draw?
  boolean calibrated = false;

  // relevant skeleton positions from our Kinect in screen coordinates:

  PVector facePos = new PVector();
  PVector neckPos = new PVector();
  PVector torsoPos = new PVector();

  PVector leftHandPos = new PVector();
  PVector rightHandPos = new PVector();

  PVector leftElbowPos = new PVector();
  PVector rightElbowPos = new PVector();

  PVector rightShoulderPos = new PVector();
  PVector leftShoulderPos = new PVector();

  PVector rightHipPos = new PVector();
  PVector leftHipPos = new PVector();

  PVector leftKneePos = new PVector();
  PVector rightKneePos = new PVector();

  PVector leftFootPos = new PVector();
  PVector rightFootPos = new PVector();


  // in the Kinect camera's coordinate system:

  PVector facePosWorld = new PVector();
  PVector neckPosWorld = new PVector();
  PVector torsoPosWorld = new PVector();

  PVector leftHandPosWorld = new PVector();
  PVector rightHandPosWorld = new PVector();

  PVector leftElbowPosWorld = new PVector();
  PVector rightElbowPosWorld = new PVector();

  PVector rightShoulderPosWorld = new PVector();
  PVector leftShoulderPosWorld = new PVector();

  PVector rightHipPosWorld = new PVector();
  PVector leftHipPosWorld = new PVector();

  PVector leftKneePosWorld = new PVector();
  PVector rightKneePosWorld = new PVector();

  PVector leftFootPosWorld = new PVector();
  PVector rightFootPosWorld = new PVector();


  // end class vars

  // 
  // Default constructor
  //
  Skeleton()
  { }

  // 
  // Constructor with id
  //
  Skeleton(int _id)
  {
    id = _id;
  }


  ////////////////////////////////////////
  // update internal vars
  //

  Skeleton update(SimpleOpenNI context)
  {
    // draw the skeleton if it's available
    if (context.isTrackingSkeleton(id))
    { 
      // get joint positions in 3D world for the tracked limbs
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_HEAD, facePosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_NECK, neckPosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_TORSO, torsoPosWorld);

      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPosWorld);

      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbowPosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbowPosWorld);

      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulderPosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulderPosWorld);

      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_HIP, leftHipPosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_HIP, rightHipPosWorld);

      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_KNEE, leftKneePosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_KNEE, rightKneePosWorld);

      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_FOOT, leftFootPosWorld);
      context.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_FOOT, rightFootPosWorld);


      // convert to screen coordinates
      context.convertRealWorldToProjective(leftShoulderPos, leftShoulderPosWorld);
      context.convertRealWorldToProjective(rightShoulderPos, rightShoulderPosWorld);

      context.convertRealWorldToProjective(rightHipPos, rightHipPosWorld);
      context.convertRealWorldToProjective(leftHipPos, leftHipPosWorld);

      context.convertRealWorldToProjective(neckPos, neckPosWorld);
      context.convertRealWorldToProjective(facePos, facePosWorld);      

      context.convertRealWorldToProjective(rightHandPos, rightHandPosWorld);
      context.convertRealWorldToProjective(leftHandPos, leftHandPosWorld);

      context.convertRealWorldToProjective(leftFootPos, leftFootPosWorld);
      context.convertRealWorldToProjective(rightFootPos, rightFootPosWorld);
    }
    // return reference to this object
    return this;
  }  
  
// end class Skeleton  
}

