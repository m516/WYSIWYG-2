//Menu programming
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
