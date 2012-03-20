int jointStringToInt(String openNIString)
{  
  for ( Entry<Integer,String> entry : jointIDs.entrySet())
  {
    String NIString = entry.getValue();
    if (NIString.equals(openNIString))
    {
      return entry.getKey().intValue();
    }
  }
  // otherwise return false
  return -1;
}

void setupJointNames()
{
  JOINT_NAMES = new HashMap<Integer, String>();
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_HEAD), "head");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_NECK), "neck");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_TORSO), "torso");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_WAIST), "waist");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_COLLAR), "right collar");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_COLLAR), "left collar");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_SHOULDER), "right shoulder");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_SHOULDER), "left shoulder");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_ELBOW), "right elbow");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_ELBOW), "left elbow");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_WRIST), "right wrist");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_WRIST), "left wrist");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_HAND), "right hand");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_HAND), "left hand");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_FINGERTIP), "right fingertip");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_FINGERTIP), "left fingertip");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_HIP), "right hip");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_HIP), "left hip");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_KNEE), "right knee");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_KNEE), "left knee");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_ANKLE), "right ankle");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_ANKLE), "left ankle");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_RIGHT_FOOT), "right foot");
  JOINT_NAMES.put(new Integer(SimpleOpenNI.SKEL_LEFT_FOOT), "left foot");
  
  jointIDs = new HashMap<Integer, String>();
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_HEAD), "SKEL_HEAD");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_NECK), "SKEL_NECK");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_TORSO), "SKEL_TORSO");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_WAIST), "SKEL_WAIST");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_COLLAR), "SKEL_RIGHT_COLLAR");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_COLLAR), "SKEL_LEFT_COLLAR");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_SHOULDER), "SKEL_RIGHT_SHOULDER");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_SHOULDER), "SKEL_LEFT_SHOULDER");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_ELBOW), "SKEL_RIGHT_ELBOW");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_ELBOW), "SKEL_LEFT_ELBOW");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_WRIST), "SKEL_RIGHT_WRIST");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_WRIST), "SKEL_LEFT_WRIST");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_HAND), "SKEL_RIGHT_HAND");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_HAND), "SKEL_LEFT_HAND");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_FINGERTIP), "SKEL_RIGHT_FINGERTIP");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_FINGERTIP), "SKEL_LEFT_FINGERTIP");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_HIP), "SKEL_RIGHT_HIP");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_HIP), "SKEL_LEFT_HIP");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_KNEE), "SKEL_RIGHT_KNEE");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_KNEE), "SKEL_LEFT_KNEE");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_ANKLE), "SKEL_RIGHT_ANKLE");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_ANKLE), "SKEL_LEFT_ANKLE");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_RIGHT_FOOT), "SKEL_RIGHT_FOOT");
  jointIDs.put(new Integer(SimpleOpenNI.SKEL_LEFT_FOOT), "SKEL_LEFT_FOOT");
}

