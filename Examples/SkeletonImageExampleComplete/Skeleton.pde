
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
  {
  }

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
      context.convertRealWorldToProjective(leftShoulderPosWorld, leftShoulderPos);
      leftShoulderPos.z = worldDepthToScreen(leftShoulderPos.z);

      context.convertRealWorldToProjective(rightShoulderPosWorld, rightShoulderPos );
      rightShoulderPos.z = worldDepthToScreen(rightShoulderPos.z);

      context.convertRealWorldToProjective(rightHipPosWorld, rightHipPos);
      rightHipPos.z = worldDepthToScreen(rightHipPos.z);

      context.convertRealWorldToProjective(leftHipPosWorld, leftHipPos);
      leftHipPos.z = worldDepthToScreen(leftHipPos.z);

      context.convertRealWorldToProjective(neckPosWorld, neckPos);
      neckPos.z = worldDepthToScreen(neckPos.z);

      context.convertRealWorldToProjective(facePosWorld, facePos);      
      facePos.z = worldDepthToScreen(facePos.z);

      context.convertRealWorldToProjective(rightHandPosWorld, rightHandPos);
      rightHandPos.z = worldDepthToScreen(rightHandPos.z);

      context.convertRealWorldToProjective(leftHandPosWorld, leftHandPos);
      leftHandPos.z = worldDepthToScreen(leftHandPos.z);

      context.convertRealWorldToProjective(rightElbowPosWorld, rightElbowPos);
      rightElbowPos.z = worldDepthToScreen(rightElbowPos.z);

      context.convertRealWorldToProjective(leftElbowPosWorld, leftElbowPos);
      leftElbowPos.z = worldDepthToScreen(leftElbowPos.z);

      context.convertRealWorldToProjective(leftKneePosWorld, leftKneePos);
      leftKneePos.z = worldDepthToScreen(leftKneePos.z);

      context.convertRealWorldToProjective(rightKneePosWorld, rightKneePos);
      rightKneePos.z = worldDepthToScreen(rightKneePos.z);


      context.convertRealWorldToProjective(leftFootPosWorld, leftFootPos);
      leftFootPos.z = worldDepthToScreen(leftFootPos.z);

      context.convertRealWorldToProjective(rightFootPosWorld, rightFootPos);
      rightFootPos.z = worldDepthToScreen(rightFootPos.z);
    }
    // return reference to this object
    return this;
  }  


  float worldDepthToScreen(float z)
  {
    return (abs(z) < EPSILON) ? 0f : 525.0f/z;
  }

  // end class Skeleton
}

