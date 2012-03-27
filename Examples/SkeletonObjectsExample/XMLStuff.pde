

/*
 * XML file format:
 
 <?xml version="1.0" encoding="UTF-8"?>
 <skeletonData>
 	<skeleton id="1">
 		<jointsPositions>
 			<joint id="SKEL_HEAD" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_NECK" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_TORSO" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_WAIST" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_COLLAR" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_COLLAR" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_SHOULDER" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_SHOULDER" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_ELBOW" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_WRIST" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_WRIST" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_HAND" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_HAND" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_FINGERTIP" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_FINGERTIP" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_HIP" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_HIP" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_KNEE" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_ANKLE" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_RIGHT_FOOT" x="0.0" y="0.0" z="0.0" />
 			<joint id="SKEL_LEFT_FOOT" x="0.0" y="0.0" z="0.0" />
 		</jointsPositions>
 	</skeleton>
 </skeletonData>
 */


// root xml node for config data
XML jointsXML;

String jointsXMLFile = "data/joints.xml";


void writeXML(String name, XML theXml)
{
  PrintWriter xmlfile = createWriter(name);

  // DEBUG
  print("WRITING XML FILE: ");
  println(theXml.getName() + ":::::::::");
  println("::CONTENT::");
  println(theXml.getContent());
  println("::END CONTENT::");
  // END DEBUG

  // write file
  xmlfile.print(theXml.toString());
  xmlfile.flush();
  xmlfile.close();
}



XML createJointsXML()
{ 
  XML configXML = new XML("skeletonData");
  configXML.setString("updated", year()+"."+month()+"."+day()+"-"+hour()+":"+minute()+":"+second() );
  configXML.setFloat("version", 1.0);

  for (Skeleton skeleton : skeletons)
  {
    if (skeleton.calibrated )
    { 
      XML skeletonXML = configXML.addChild("skeleton");
      skeletonXML.setInt( "id", skeleton.id );

      for ( Entry<Integer,String> entry : JOINT_NAMES.entrySet())
      {
        int jointID = entry.getKey().intValue();

        String jointString = jointIDs.get(new Integer(jointID));
        PVector jointPoint = new PVector();
        context.getJointPositionSkeleton(skeleton.id, jointID, jointPoint);

        context.convertRealWorldToProjective(jointPoint, jointPoint);
         jointPoint.z = context.depthImage().width * ((Math.abs( jointPoint.z) < 1E-5) ? 0f : 525.0f/ jointPoint.z);
   

        XML jointXML = skeletonXML.addChild("joint");
        jointXML.setString("id", jointString);
        jointXML.setFloat("x", jointPoint.x);
        jointXML.setFloat("y", jointPoint.y);
        jointXML.setFloat("z", jointPoint.z);
      }
    }
  }

  println("CREATED XML:");
  println(configXML.toString());
  
  return configXML;
}

