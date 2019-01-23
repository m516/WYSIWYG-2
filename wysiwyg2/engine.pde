//Not sure who made the blur filter, but it has been very helpful. //<>//
//See the shader blur example in Processing for more details.
PShader blur;
//Animated background shader, see the loaded .glsl file for more information
PShader backgroundShader;
//Background graphics
PGraphics background;
//Block-rendering graphics
PGraphics render;
//Post-processing filter
PGraphics postProcessing;
//Menu graphics
PGraphics menuGraphics;

void initializeEngine() {
  //Create the graphics
  render = createGraphics(width, height, P3D);
  postProcessing = createGraphics(width, height, P2D);
  background = createGraphics(width, height, P2D);
  menuGraphics = createGraphics(width, height, P2D);

  //Load the shaders
  blur = loadShader("blur.glsl"); 
  blur.set("texOffset", 16.0, 16.0);
  blur.set("brightness", 0.0);
  backgroundShader = loadShader("clouds.glsl");
  backgroundShader.set("u_resolution", float(width/2), float(height/2));
  backgroundShader.set("backColor", red(back_color_a)/255.0, green(back_color_a)/255.0, blue(back_color_a)/255.0);
  backgroundShader.set("frontColor", red(back_color_b)/255.0, green(back_color_b)/255.0, blue(back_color_b)/255.0);

  //Resize the blocks to fit the screen
  block_size = min(width, height)/10.0;

  //Render the background for the first time
  //This way, a cloudy background still exists even if enableBackground is disabled
  renderBackground();
}

//Render the contents of the screen
void render() {
  //Render the animated background if desired
  if (enableBackground)renderBackground();
  //Render post processing if desired
  if (enablePostProcessing)postProcessing();
  //Render the scene
  renderScene();
  //Get ready to put the contents of each graphics object onto the screen
  blendMode(BLEND);
  noTint();
  //draw the background
  image(background, 0, 0);
  //draw blocks
  image(render, 0, 0);
  //draw post processing
  if (enablePostProcessing) {
    blendMode(ADD);
    image(postProcessing, 0, 0);
  }
  //Render the menu if one exists
  if(enabledButtons!=null){
    //Begin drawing by chaning visual settings
    blendMode(BLEND);
    menuGraphics.beginDraw();
    menuGraphics.blendMode(REPLACE);
    //Draw the background
    menuGraphics.background(255,64);
    //Draw each menu item on the menu graphics context
    for(ConfigurationItem i:enabledButtons)i.render(menuGraphics);
    //Stop drawing to finish the menu image
    menuGraphics.endDraw();
    //Draw the menu on the screen
    image(menuGraphics, 0, 0);
  }
}

//Render the animated background and place it on the "background" graphics object
void renderBackground() {
  //Start drawing
  background.beginDraw();
  //Configure the shader
  backgroundShader.set("u_time", millis() / 1000.0);
  backgroundShader.set("translation", view_translation.x/width/-1.5, 
    view_translation.y/height/1.5);
    //Render the shader
  background.shader(backgroundShader);
  //Put its contents on the graphics object
  background.rect(0, 0, width, height);
  //Stop drawing
  background.endDraw();
}

//Render the blocks
void renderScene() {
  //Start drawing
  render.beginDraw();

  //Configure the renderer
  render.noStroke();
  render.ortho(-width/2, width/2, -height/2, height/2, -256*block_size, 256*block_size);

  //Reset the transformation matrix
  //render.resetMatrix();

  //Create a transparent canvas to draw on
  render.blendMode(REPLACE);
  render.background(0, 0);
  render.blendMode(BLEND);

  //Lighting
  //TODO The Raspi seems to be unable to support most lights here. 
  //They need testing on a computer with more complete graphics capabilities
  switch (lights) {
  case 1://Ambient light and material generation
    render.ambientLight(64, 64, 74);
    render.specular(255, 255, 255);
    render.shininess(5.0);
  case 2://Directional light from upper left hand corner (warmer)
    render.directionalLight(180, 170, 160, 200, 200, -100);
  case 3://Directional light from top (neutral)
    render.directionalLight(160, 160, 160, 0, 200, -100);
  case 4://Directional light from bottom right hand corner (cooler)
    render.directionalLight(100, 80, 80, -200, -200, -100);
  case 5://Directional light from right (warm)
    render.directionalLight(50, 50, 30, 200, 0, -20);
  case 6://Point light where the player is
    render.pointLight(255, 255, 255, cameraTarget.x*block_size, cameraTarget.y*block_size, cameraTarget.z*block_size);
  case 7://Light falloff
    render.lightFalloff(1.0, 0.1, 0.01);
  }

  //Rotate and translate the view until the boxes are in the right place
  render.translate(width/2, height/2, 0);
  render.scale(block_size, block_size, block_size);
  render.translate(view_translation.x, view_translation.y, view_translation.z);
  render.rotateX(view_rotation.x); 
  render.rotateY(view_rotation.y);

  //Draw the cubes
  renderBlocks();

  //Stop drawing
  render.endDraw();
}

//Process the current image
void postProcessing() {
  //Start drawing
  postProcessing.beginDraw();
  //Configure post processing
  postProcessing.blendMode(BLEND);
  //Create a semitransparent background
  //This is a workaround to the not-working background() method
  //postProcessing.fill(0,16);
  //postProcessing.noStroke();
  //postProcessing.rect(0,0,width,height);

  postProcessing.tint(64, 64);
  postProcessing.image(background, 0, 0);
  //Draw the cubes
  postProcessing.noTint();
  postProcessing.image(render, 0, 0);
  //Blur the contents of this graphics object
  postProcessing.filter(blur);
  //Stop drawing
  postProcessing.endDraw();
}

//Textured cube from https://processing.org/examples/texturecube.html
//Modified to support two textures by Micah Mundy
void drawTexturedCube(PImage tex, PImage tex_shaded) {
  //Change the size of the boxes, for these have a RADIUS of 1
  //and normal boxes have a DIAMETER of 1.
  render.pushMatrix();
  render.scale(0.5*0.97);

  //Render textures
  render.textureMode(NORMAL);
  render.beginShape(QUADS);
  render.texture(tex_shaded);

  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)

  // +Z "front" face
  render.vertex(-1, -1, 1, 0, 0);
  render.vertex( 1, -1, 1, 1, 0);
  render.vertex( 1, 1, 1, 1, 1);
  render.vertex(-1, 1, 1, 0, 1);

  // -Z "back" face
  render.vertex( 1, -1, -1, 0, 0);
  render.vertex(-1, -1, -1, 1, 0);
  render.vertex(-1, 1, -1, 1, 1);
  render.vertex( 1, 1, -1, 0, 1);


  // +X "right" face
  render.vertex( 1, -1, 1, 0, 0);
  render.vertex( 1, -1, -1, 1, 0);
  render.vertex( 1, 1, -1, 1, 1);
  render.vertex( 1, 1, 1, 0, 1);

  // -X "left" face
  render.vertex(-1, -1, -1, 0, 0);
  render.vertex(-1, -1, 1, 1, 0);
  render.vertex(-1, 1, 1, 1, 1);
  render.vertex(-1, 1, -1, 0, 1);

  //Start a new "shape" with the unshaded faces
  render.endShape();
  render.beginShape(QUADS);
  render.texture(tex);

  // +Y "bottom" face
  render.vertex(-1, 1, 1, 0, 0);
  render.vertex( 1, 1, 1, 1, 0);
  render.vertex( 1, 1, -1, 1, 1);
  render.vertex(-1, 1, -1, 0, 1);

  // -Y "top" face
  render.vertex(-1, -1, -1, 0, 0);
  render.vertex( 1, -1, -1, 1, 0);
  render.vertex( 1, -1, 1, 1, 1);
  render.vertex(-1, -1, 1, 0, 1);

  render.endShape();

  render.popMatrix();
}

//Renders a textured cube with only one image
void drawTexturedCube(PImage tex) {
  drawTexturedCube(tex, tex);
}

//Renders the blocks onto the "render" graphics object
void renderBlocks() {
  if(enableBorders)
    render.strokeWeight(1.0/block_size);
  for (Block block : blocks) {
    //Don't do anything if this block doesn't exist
    if (block == null) continue;
    render.pushMatrix();
    render.translate(block.x, block.y, block.z);
    if (enableTextures) drawTexturedCube(block.getTopImage(), block.getSideImage());
    else {
      render.fill(block.getColor());
      if(enableBorders)render.stroke(block.getColor());
      render.box(0.97);
    }
    render.popMatrix();
  }

  //Render the player
  render.pushMatrix();
  render.translate(player.x, player.y, player.z);
  if (enableTextures) drawTexturedCube(player.getTopImage(), player.getSideImage());
  else {
    render.fill(player.getColor());
    if(enableBorders)render.stroke(player.getColor());
    render.box(0.97);
  }
  render.popMatrix();
}

//Adjusts zoom and block size in one method
void setZoom(float newZoom) {
  zoom = newZoom;
  block_size = min(width, height)/10.0*zoom;
}