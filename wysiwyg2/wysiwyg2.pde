void setup() {
  fullScreen(P2D);
  //noSmooth();
  //if(!debug)noCursor();
  initializeEngine();
  initializeGlobals();
}

void draw() {
  act();
  render();
}

void mousePressed(){
  mousePressedGameBehavior();
  if(enabledButtons!=null)for(ConfigurationItem i: enabledButtons)if(i.onClicked!=null&&i.isBelowMouse()&&i.isEnabled)i.onClicked.run();
}
void mouseReleased(){
  mouseReleasedGameBehavior();
}
