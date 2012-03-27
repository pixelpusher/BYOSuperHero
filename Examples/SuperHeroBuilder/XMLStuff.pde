void readJointsXML()
{
  readJointsXML(null);
}


void readJointsXML(String filename)
{
  BufferedReader reader = null;

  if (filename == null)
    filename = jointsXMLFile;

  reader = createReader(filename);

  if (reader == null)
  {
    println("No xml file found:" + filename);
    exit();
  }

  if (joints != null) joints.clear();

  joints = new ArrayList<Joint>();

  XML jointsXML = new XML (reader);

  XML jointNodes[] = jointsXML.getChildren("skeleton/joint");

  println("XML: Found " + jointNodes.length + " joints nodes");

  //
  // HANDLE joints
  //   
  for (int i=0; i < jointNodes.length; ++i)
  {
    XML node = jointNodes[i];

    String name = node.getString("id");
    float x = node.getFloat("x");
    float y = node.getFloat("y");
    float z = node.getFloat("z");

    int OpenNIID = jointStringToInt( name );
    Joint joint = new Joint(name, OpenNIID);
    joint.set(x, y, z);

    joints.add( joint );      
    println("Joint name:" + name);
  }
  
  currentSkeleton.update( joints);
}
