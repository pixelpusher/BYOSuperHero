// controlP5 gui utilities
// comment out as necessary

import controlP5.*;

ControlP5 gui;

void setupGUI()
{

  gui = new ControlP5(this);

  // these are for the particle renderer
  //
  gui.addSlider("boneDistFactor", 0.001, 1, 5, 5, 100, 20);
  gui.addSlider("particleMassAttractFactor", 0.1, 40, 5, 25, 100, 20);
  gui.addSlider("boneMinDist", 10*10, 200*200, 5, 45, 300, 20);
  gui.hide();
}

