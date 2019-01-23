//Block mechanics
final int PLAYER = 255, 
  GENERIC = 0, 
  GOAL = 3, 
  ROTATE_LEFT = 1, 
  ROTATE_RIGHT = 2, 
  ANTIGRAVITY = 4;


//The Block class is fairly simple, but contains numerous 
//helpful block-specific methods
class Block {
  float x, y, z;//position
  int t;//type
  //Constructor
  Block(float x, float y, float z, int type) {
    this.x=x;
    this.y=y;
    this.z=z;
    t=type;
  }
  //Copies the location of another block
  void copyLocationOf(Block other) {
    x=other.x;
    y=other.y;
    z=other.z;
  }
  //Copies the location of a vector
  void copyLocationOf(PVector other) {
    x=other.x;
    y=other.y;
    z=other.z;
  }
  //Returns the position of the block as a vector
  PVector getPositionVector() {
    return new PVector(x, y, z);
  }
  //Screen flattening method
  float screenX() {
    return x*cos(view_rotation.y)+z*sin(view_rotation.y);
  }
  //Screen flattening method
  float screenY() {
    return y*cos(view_rotation.x)+sin(view_rotation.x)*(x*sin(view_rotation.y)-z*cos(view_rotation.y));
  }
  //Returns true of it looks rouughly the same as the other block
  boolean looksTheSameAs(Block other) {
    return abs(screenX()-other.screenX())+abs(screenY()-other.screenY())<0.4;
  }
  boolean isAbove(Block other) {
    return antigravityEnabled?x==other.x&&y-1==other.y&&z==other.z:x==other.x&&y+1==other.y&&z==other.z;
  }
  Block findFloor(Block[] blocks) {
    //Create a phantom block below this one (or above if antigravity is enabled)
    Block tempBlock = new Block(x, y+(antigravityEnabled?-1:1), z, GENERIC);
    //Create a block that will be returned by the end of this method
    Block retBlock = null;
    for (Block floor : blocks) {
      //Don't deal with nonexistent blocks
      if (floor==null)continue;
      //Searcg for potential floors
      if (tempBlock.looksTheSameAs(floor)) {
        if (retBlock == null)retBlock=floor;
        else if (render.screenZ(floor.x, floor.y, floor.z)<render.screenZ(retBlock.x, retBlock.y, retBlock.z))retBlock=floor;
      }
    }
    //Don't do anything else if there is no potential floor cube
    if (retBlock==null)return null;
    //Look for blocks above the potential floor
    for (Block b : blocks) {
      //Don't allow a block to phase through a wall
      if (b.isAbove(retBlock))return null;
    }
    return retBlock;
  }
  PImage getSideImage() {
    switch(t) {
    case PLAYER:
      return sprite_player_shaded;
    case GOAL:
      return sprite_goal_shaded;
    case ROTATE_RIGHT:
      return sprite_rotate_right_shaded;
    case ROTATE_LEFT:
      return sprite_rotate_left_shaded;
    case ANTIGRAVITY:
      return sprite_antigravity_shaded;
    default:
      return sprite_generic_shaded;
    }
  }
  PImage getTopImage() {
    switch(t) {
    case PLAYER:
      return sprite_player;
    case GOAL:
      return sprite_goal;
    case ROTATE_RIGHT:
      return sprite_rotate_right;
    case ROTATE_LEFT:
      return sprite_rotate_left;
    case ANTIGRAVITY:
      return sprite_antigravity;
    default:
      return sprite_generic;
    }
  }
  color getColor() {
    switch(t) {
    case PLAYER:
      return color_player;
    case GOAL:
      return color_goal;
    case ROTATE_RIGHT:
      return color_rotate_right;
    case ROTATE_LEFT:
      return color_rotate_left;
    case ANTIGRAVITY:
      return color_antigravity;
    default:
      return color_generic;
    }
  }
}

//Parse a block from a string
Block parseBlock(String s) {
  try {
    String[] data = s.split(" ");
    return new Block(Float.parseFloat(data[0]), 
      Float.parseFloat(data[1]), 
      Float.parseFloat(data[2]), 
      Integer.parseInt(data[3]));
  }
  catch(Exception e) {
    return null;
  }//This is usually a parsing error, so don't make a new block
}

/**
 * Load the blocks from a file
 * 
 * Each file contains a list of rows with four numbers separated by spaces
 * Each row represents a single block
 * The numbers correspond to these values:
 *   1) the x-value
 *   2) the y-value
 *   3) the z value
 *   4) the type of the block
 **/
void loadLevel(String filename) {
  player = new Block(0, 0, 0, PLAYER);
  String[] lines = loadStrings(filename);
  if (lines==null) {
    level=1;
    lines = loadStrings("level1.lvl");
  }
  blocks = new Block[lines.length];
  for (int i = 0; i < lines.length; i ++) {
    blocks[i]=parseBlock(lines[i]);
  }
}

float getXOnScreen(Block b) {
  return b.x*cos(view_rotation.y)+b.z*sin(view_rotation.y);
}
float getYOnScreen(Block b) {
  return b.y*cos(view_rotation.x)+sin(view_rotation.x)*(b.x*sin(view_rotation.y)-b.z*cos(view_rotation.y));
}
float getXOnScreen(float x, float z) {
  return x*cos(view_rotation.y)+z*sin(view_rotation.y);
}
float getYOnScreen(float x, float y, float z) {
  return y*cos(view_rotation.x)+sin(view_rotation.x)*(x*sin(view_rotation.y)-z*cos(view_rotation.y));
}
boolean looksTheSame(Block a, Block b) {
  return abs(getXOnScreen(a)-getXOnScreen(b))+abs(getYOnScreen(a)-getYOnScreen(b))<0.4;
}





//Soft camera movement variables and functions
//Desired camera position and angle when rotating
PVector desired_translation = new PVector();
PVector desired_rotation = new PVector();
float desired_zoom = 1.0;

//Camera's target--usually the player block
Block cameraTarget = new Block(0, 0, 0, GENERIC);

//The stickiness of camera movements. Lower numbers make the camera move faster.
float translation_tolerance = 8.0;
float rotation_tolerance = 12.0;
float zoom_tolerance = 8.0;

void updateView() {
  //Change desired zoom based on mouse coordinate
  desired_zoom=(height-mouseY)*0.8/height+1.2;

  //Camera translation may have changed. Update it accordingly
  desired_translation.x=-getXOnScreen(cameraTarget);
  desired_translation.y=-getYOnScreen(cameraTarget);
  desired_translation.z=0;

  //If the camera is moving
  if (cameraIsMoving(0.2)) {
    //Let the camera move
    view_translation.x=(view_translation.x*(translation_tolerance-1.0)+desired_translation.x)/translation_tolerance;
    view_translation.y=(view_translation.y*(translation_tolerance-1.0)+desired_translation.y)/translation_tolerance;
    view_translation.z=(view_translation.z*(translation_tolerance-1.0)+desired_translation.z)/translation_tolerance;
    //Update camera rotation as well
    view_rotation.x=(view_rotation.x*(rotation_tolerance-1.0)+desired_rotation.x)/rotation_tolerance;
    view_rotation.y=(view_rotation.y*(rotation_tolerance-1.0)+desired_rotation.y)/rotation_tolerance;
    view_rotation.z=(view_rotation.z*(rotation_tolerance-1.0)+desired_rotation.z)/rotation_tolerance;
  } else if (cameraIsTurning(0.2)) {
    //Update camera rotation
    view_rotation.x=(view_rotation.x*(rotation_tolerance-1.0)+desired_rotation.x)/rotation_tolerance;
    view_rotation.y=(view_rotation.y*(rotation_tolerance-1.0)+desired_rotation.y)/rotation_tolerance;
    view_rotation.z=(view_rotation.z*(rotation_tolerance-1.0)+desired_rotation.z)/rotation_tolerance;
    //Camera translation has changed due to rotation. Update the new desired translation
    desired_translation.x=-getXOnScreen(cameraTarget);
    desired_translation.y=-getYOnScreen(cameraTarget);
    desired_translation.z=0;
    //Match camera translation with desired translation so "stickiness" is overridden
    view_translation.x=desired_translation.x;
    view_translation.y=desired_translation.y;
    view_translation.z=desired_translation.z;
  } else {
    //Let the camera move
    view_translation.x=(view_translation.x*(translation_tolerance-1.0)+desired_translation.x)/translation_tolerance;
    view_translation.y=(view_translation.y*(translation_tolerance-1.0)+desired_translation.y)/translation_tolerance;
    view_translation.z=(view_translation.z*(translation_tolerance-1.0)+desired_translation.z)/translation_tolerance;
    //Update camera rotation as well
    view_rotation.x=(view_rotation.x*(rotation_tolerance-1.0)+desired_rotation.x)/rotation_tolerance;
    view_rotation.y=(view_rotation.y*(rotation_tolerance-1.0)+desired_rotation.y)/rotation_tolerance;
    view_rotation.z=(view_rotation.z*(rotation_tolerance-1.0)+desired_rotation.z)/rotation_tolerance;
  }
  //Change the zoom, which isn't affected by and doesn't affect any other parameter so far
  setZoom((desired_zoom+(zoom*(zoom_tolerance-1)))/zoom_tolerance);
}

boolean cameraIsTurning(float tolerance) {
  return abs(view_rotation.x-desired_rotation.x)+
    abs(view_rotation.y-desired_rotation.y)+
    abs(view_rotation.z-desired_rotation.z)>tolerance;
}
boolean cameraIsMoving(float tolerance) {
  return abs(view_translation.x-desired_translation.x)+
    abs(view_translation.y-desired_translation.y)+
    abs(view_translation.z-desired_translation.z)>tolerance;
}







//Menu programming
//Menu panel TODO
ArrayList<ConfigurationItem> enabledButtons;
class ConfigurationItem {
  float x, y, w, h; //Units expressed in pixels
  boolean isEnabled = true;
  Runnable onClicked;
  String message;
  ConfigurationItem(float x, float y, float w, float h) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
  }
  ConfigurationItem(float x, float y, float w, float h, String message) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.message=message;
  }
  boolean isInside(float x, float y) {
    return x>=this.x&&x<=this.x+w&&y>=this.y&&y<=this.y+h;
  }
  boolean isBelowMouse() {
    return isInside(mouseX, mouseY);
  }
  //Use this template for Java 1.7
  /*
  setOnClicked(new Runnable(){
   public void run(){
   return;//ICH
   }
   });
   */
  void setOnClicked(Runnable function) {
    onClicked = function;
  }
  void render(PGraphics canvas) {
    //Draw the frame
    if(isEnabled)canvas.fill(0, 180);
    else canvas.fill(64,0,0, 180);
    canvas.stroke(220);
    if(isBelowMouse()&&isEnabled) canvas.strokeWeight(8);
    else canvas.strokeWeight(2);
    canvas.rect(x+8, y+8, w-16, h-16,min(width,height)/16.0);
    
    //Draw the text
    canvas.textAlign(CENTER, CENTER);
    canvas.textSize(h/3);
    canvas.fill(220);
    canvas.text(message, x+w/2, y+h/2);
  }
}
void resetMenu() {
  gameEnabled = true;
  enabledButtons = null;
}


//Create the main menu, as seen when the user presses the screen for 3+ seconds
void createMainMenu() {
  //Disable game logic
  gameEnabled = false;
  //Create a new list of buttons on the screen
  enabledButtons=new ArrayList<ConfigurationItem>();
  
  //Create the "continue" button
  ConfigurationItem item = new ConfigurationItem(0, 0, width, height/4, "Continue");
  item.setOnClicked(new Runnable() {
    public void run() {
      resetMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  
  //Create the "restart" button
  item = new ConfigurationItem(0, height/4, width, height/4, "Restart level "+level);
  item.setOnClicked(new Runnable() {
    public void run() {
      resetMenu();
      resetLevel();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "settings" button
  item = new ConfigurationItem(0, height/2, width, height/4, "Settings");
  item.setOnClicked(new Runnable() {
    public void run() {
      createSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "reset game" button
  item = new ConfigurationItem(0, 3*height/4, width, height/4, "Reset game");
  item.setOnClicked(new Runnable() {
    public void run() {
      createResetMenu();
    }
  }
  );
  enabledButtons.add(item);
}


//Generates the first setting menu, shown when the user presses the 
//"settings" button on the main screen
void createSettingsMenu() {
  //Disable the game logic
  gameEnabled = false;
  //Create a new list of menu buttons
  enabledButtons=new ArrayList<ConfigurationItem>();
  
  //Create the "textures" button
  ConfigurationItem item = new ConfigurationItem(0, height/4, width, height/4, enableTextures?"Render solid colors":"Render Textures");
  item.setOnClicked(new Runnable() {
    public void run() {
      enableTextures=!enableTextures;
      createSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "post processing" button
  item = new ConfigurationItem(0, height/2, width, height/4, enablePostProcessing?"Disable post-processing":"Enable post-processing");
  item.setOnClicked(new Runnable() {
    public void run() {
      enablePostProcessing = !enablePostProcessing;
      createSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "background" button
  item = new ConfigurationItem(0, 3*height/4, width, height/4, enableBackground?"Disable background":"Enable background");
  item.setOnClicked(new Runnable() {
    public void run() {
      enableBackground = !enableBackground;
      createSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "back" button
  item = new ConfigurationItem(0, 0, width/2, height/4, "Back");
  item.setOnClicked(new Runnable() {
    public void run() {
      createMainMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "next" button
  item = new ConfigurationItem(width/2, 0, width/2, height/4, "Next...");
  item.setOnClicked(new Runnable() {
    public void run() {
      createAlternateSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
}



//Create the alternate settings menu, shown when the user presses the
//"next" button in the settings menu
void createAlternateSettingsMenu() {
  //Disable game logic
  gameEnabled = false;
  //Create a new list of active buttons
  enabledButtons=new ArrayList<ConfigurationItem>();
  
  //Create the "borders" button
  ConfigurationItem item = new ConfigurationItem(0, height/4, width, height/4, enableBorders?"Disable borders":"Render borders");
  if(enableTextures)item.isEnabled=false;
  item.setOnClicked(new Runnable() {
    public void run() {
      enableBorders=!enableBorders;
      resetMenu();
      createAlternateSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the light control buttons
  item = new ConfigurationItem(0, height/2, width, height/4, "More lights ("+lights+")");
  if(lights>=7) item.isEnabled=false;
  item.setOnClicked(new Runnable() {
    public void run() {
      lights++;
      resetMenu();
      createAlternateSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  item = new ConfigurationItem(0, 3*height/4, width, height/4, "Less lights");
  if(lights<=0) item.isEnabled=false;
  item.setOnClicked(new Runnable() {
    public void run() {
      lights--;
      resetMenu();
      createAlternateSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the back button
  item = new ConfigurationItem(0, 0, width, height/4, "Back");
  item.setOnClicked(new Runnable() {
    public void run() {
      resetMenu();
      createSettingsMenu();
    }
  }
  );
  enabledButtons.add(item);
}

//Create the reset menu, shown when the user presses the
//"next" button in the settings menu
void createResetMenu() {
  //Disable game logic
  gameEnabled = false;
  //Create a new list of active buttons
  enabledButtons=new ArrayList<ConfigurationItem>();
  
  //Create the "yes" button
  ConfigurationItem item = new ConfigurationItem(0, 0, width, height/2, "Yes, I'm done");
  item.setOnClicked(new Runnable() {
    public void run() {
      level = 1;
      loadLevel("level1.lvl");
      createMainMenu();
    }
  }
  );
  enabledButtons.add(item);
  
  //Create the "no" button
  item = new ConfigurationItem(0, height/2, width, height/2, "ACK! Not yet!");
  if(lights>=7) item.isEnabled=false;
  item.setOnClicked(new Runnable() {
    public void run() {
      createMainMenu();
    }
  }
  );
  enabledButtons.add(item);
}