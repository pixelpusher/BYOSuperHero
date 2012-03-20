import controlP5.*;
import java.util.Map.Entry;

ControlP5 gui;

ControlWindow newBodyPartControlWindow;



void setupGui()
{
  gui = new ControlP5(this);

  int guiY = 20;
  int guiX = 5;

  gui.addSlider("offsetX", -1f, 1f, 0f, guiX, guiY, 200, 20);
  guiY += 24;
  gui.addSlider("offsetY", -1f, 1f, 0f, guiX, guiY, 200, 20);
  guiY += 24;
  gui.addSlider("paddingL", -1f, 1f, 0f, guiX, guiY, 200, 20);
  guiY += 24;
  gui.addSlider("paddingR", -1f, 1f, 0f, guiX, guiY, 200, 20);
  guiY += 24;
  gui.addSlider("paddingTop", -1f, 1f, 0f, guiX, guiY, 200, 20);
  guiY += 24;
  gui.addSlider("paddingBot", -1f, 1f, 0f, guiX, guiY, 200, 20);
  guiY += 24;

  Button b = gui.addButton("NewPart", 0, guiX, guiY, 80, 19);  
  b.setLabel("New Part");

  newBodyPartControlWindow = gui.addControlWindow("bodyPartWindow", 4, 4, 600, 300);
  newBodyPartControlWindow.setTitle("Create New Body Part:");

  DropdownList bodyPartsList = null;
  DropdownList jointsList = null;

  int dropdownWidth = 100;
  int dropdownHeight = 100;

  guiX = 4;
  guiY = 24;

  b = gui.addButton("CreateBodyPart", 0, guiX, guiY, 80, 19);  
  b.setLabel("Create!");
  b.moveTo(newBodyPartControlWindow);

  gui.addTextlabel("blabel", "body part:", guiX, guiY).moveTo(newBodyPartControlWindow);
  guiY+= 26;

  bodyPartsList = gui.addDropdownList("bodyPartsList", guiX, guiY, dropdownWidth, 200);
  bodyPartsList.moveTo(newBodyPartControlWindow);
  bodyPartsList.setItemHeight(20);
  bodyPartsList.setBarHeight(15);
  bodyPartsList.captionLabel().set("Body Part");
  bodyPartsList.captionLabel().style().marginTop = 3;
  bodyPartsList.captionLabel().style().marginLeft = 3;
  bodyPartsList.valueLabel().style().marginTop = 3;

  for (int i=0; i<4; i++)
  {
    int xpos = guiX+(i+1)*(dropdownWidth+4);

    gui.addTextlabel("jlabel"+i, "joint "+i, xpos, guiY-26).moveTo(newBodyPartControlWindow);

    jointsList = gui.addDropdownList("jointsList"+i, xpos, guiY, dropdownWidth, 200);
    jointsList.moveTo(newBodyPartControlWindow);
    jointsList.setItemHeight(20);
    jointsList.setBarHeight(15);
    jointsList.captionLabel().set("Joint");
    jointsList.captionLabel().style().marginTop = 3;
    jointsList.captionLabel().style().marginLeft = 3;
    jointsList.valueLabel().style().marginTop = 3;

    jointsList.addItem("NONE", -1);
  }

  for (int i=0; i <= BodyPart.OTHER; i++)
  {
    bodyPartsList.addItem(BodyPart.NAMES[i], i);
  }


  for (Entry<Integer, String> entry : JOINT_NAMES.entrySet() )
  {
    for (int i=0; i<4; i++)
    {
      jointsList = (DropdownList) (gui.getGroup("jointsList"+i));
      jointsList.addItem( entry.getValue(), entry.getKey().intValue());
    }
  }


for (int i=0; i<joints.size(); i++)
{
  Joint joint = joints.get(i);
    for (int ii=0; ii<4; ii++)
    {
      jointsList = (DropdownList) (gui.getGroup("jointsList"+ii));
      jointsList.addItem( joint.name, joint.id );
    }
}  

  guiY += 24;
  b.setPosition(guiX, guiY);  



  //gui.addSlider("boneDistFactor", 0.001, 1, 5, 5, 100, 20);
  //gui.addSlider("particleMassAttractFactor", 0.1, 40, 5, 25, 100, 20);
  //gui.addSlider("boneMinDist", 10*10, 200*200, 5, 45, 300, 20);
}

public void NewPart(int theValue) 
{
  newBodyPartControlWindow.show();
}

public void CreateBodyPart(int theValue) 
{
  newBodyPartControlWindow.hide();

  DropdownList bodyPartsList = (DropdownList) (gui.getGroup("bodyPartsList"));

  int bodyPartType = (int)(bodyPartsList.value());

  int jointTypes[] = {
    -1, -1, -1, -1
  }; // default to NONE
  int numJoints = 0; // number of joints they gave us

  for (int i=0; i<4; i++)
  {
    DropdownList jointsList = (DropdownList) (gui.getGroup("jointsList"+i));

    int jointType = (int)(jointsList.value());
    if (jointType > 0) 
    {
      jointTypes[numJoints] = jointType;
      numJoints++;
    }
  }

  switch(numJoints)
  {
  case 1:
    {
      int jointType = -1;
      int i=0;
      while (jointType == -1)
      {
        jointType = jointTypes[i++];
      }
      bodyPartFactory.createPartForSkeleton(currentSkeleton, jointType, bodyPartType);
    }
    break;

  case 2:
    {
      int jointTypes2[] = {
        -1, -1
      };
      int foundJoints = 0;
      int i=0;
      while (foundJoints < 2)
      {
        int jointType = jointTypes[i++];
        if (jointType > -1) 
        {
          jointTypes2[foundJoints] = jointType; 
          foundJoints++;
        }
      }

      bodyPartFactory.createPartForSkeleton(currentSkeleton, jointTypes2[0], jointTypes2[1], bodyPartType);
    }
    break;

  case 4:
    {
      int jointTypes2[] = {
        -1, -1, -1, -1
      };
      int foundJoints = 0;
      int i=0;
      while (foundJoints < 4)
      {
        int jointType = jointTypes[i++];
        if (jointType > -1) 
        {
          jointTypes2[foundJoints] = jointType; 
          foundJoints++;
        }
      }

      bodyPartFactory.createPartForSkeleton(currentSkeleton, jointTypes2[0], jointTypes2[1], 
      jointTypes2[1], jointTypes2[2], bodyPartType);
    }
    break;

  default:
    // do nothing
    break;
  }
}


void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) 
  {
    // check if the Event was triggered from a ControlGroup
    println("GROUP::" + theEvent.getGroup().getValue()+" from "+theEvent.getGroup());

    if (theEvent.getGroup().name().equals("savedFileNames") )
    {
    }
  }

  //  else if (theEvent.isController()) {
  //    println(theEvent.getController().getValue()+" from "+theEvent.getController());
  //  }
}

