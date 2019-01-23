//Current angle of view such that any value between 0 and 3 inclusive yields
//a different point of view that appears isometric
int angle = 2;
//Antigravity
boolean antigravityEnabled = false;
//The amount of milliseconds since the mouse was first pressed
//Used to determine whether or not the menu should be displayed
long pressTime;
//When false, this disables all game logic while still rendering. Ideal for menu screens
boolean gameEnabled = true;

//Called every frame by the main draw() method. All high-level game logic
//is here
void act() {
  //If there is no menu
  if (gameEnabled) {
    //If the screen is pressed for long enough, reset the level
    if (pressTime>=0 && millis()-pressTime>2000) {
      createMainMenu();
    }
    //Track the player
    cameraTarget.copyLocationOf(player);
  }
  //Update view parameters
  //Update the rotation based on the "angle" variable
  desired_rotation.x=antigravityEnabled?0.625:-0.625;
  while (desired_rotation.y<0&&view_rotation.y<0) {
    desired_rotation.y+=TAU;
    view_rotation.y+=TAU;
    angle+=4;
  }
  desired_rotation.y=float(angle)*PI/2.0+PI/4.0;
  if (desired_rotation.y>TAU&&view_rotation.y>TAU) {
    desired_rotation.y%=TAU;
    view_rotation.y%=TAU;
    angle%=4;
  }
  desired_rotation.z=0.0;
  if (!gameEnabled) {
    desired_rotation.y+=(mouseX-width/2)*TAU/width;
    desired_rotation.x+=(mouseY-height/2)*TAU/height;
  }
  updateView();
}

//Called every time mousePressed() is run
void mousePressedGameBehavior() {
  //Update pressTime
  pressTime = millis();
  //Don't do anything while the camera is turning.
  if (cameraIsTurning(0.5))return;
  //If the game is running
  if (gameEnabled) {
    //Get the quadrant of the location of the mouse when it is pressed.
    //0-upper left
    //1-upper right
    //2-lower right
    //3-lower left
    int quadrant = 0;
    if (mouseX>width/2&&mouseY<height/2)quadrant=1;
    else if (mouseX>width/2&&mouseY>height/2)quadrant=2;
    else if (mouseX<width/2&&mouseY>height/2)quadrant=3;
    //Change this value if antigravity is enabled
    if (antigravityEnabled) quadrant = 3-quadrant;
    //Get the desired direction based on view angle and mouse location
    int direction = (quadrant+angle)%4;
    switch(direction) {
    case 0:
      player.z-=1.0;
      break;
    case 1:
      player.x+=1.0;
      break;
    case 2:
      player.z+=1.0;
      break;
    case 3:
      player.x-=1.0;
      break;
    }
    //Find the new floor block for the player
    Block newFloor = player.findFloor(blocks);
    //If there is no floor, undo the previous move
    if (newFloor==null) {
      switch(direction) {
      case 0:
        player.z+=1.0;
        break;
      case 1:
        player.x-=1.0;
        break;
      case 2:
        player.z-=1.0;
        break;
      case 3:
        player.x+=1.0;
        break;
      }
    } else { //If there is a block beneath this new position
    //Move there
      player.x=newFloor.x;
      player.y=newFloor.y+(antigravityEnabled?1:-1);
      player.z=newFloor.z;
      //Do more based on which block was landed on
      switch(newFloor.t) {
      case GOAL:
        nextLevel();
        break;
      case ROTATE_RIGHT:
        angle -=1;
        break;
      case ROTATE_LEFT:
        angle +=1;
        break;
      case ANTIGRAVITY:
        antigravityEnabled = !antigravityEnabled;
        player.y+=(antigravityEnabled?2:-2);
        break;
      }
    }
  }
}

//Called every time mouseReleased() is run
void mouseReleasedGameBehavior() {
  pressTime = -1;
}

//Advanced the user to the next level
void nextLevel() {
  level++;
  resetLevel();
}

//Resets the level
void resetLevel() {
  loadLevel("level"+level+".lvl");
  angle = 2;
  antigravityEnabled = false;
}