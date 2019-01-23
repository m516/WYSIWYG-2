//Enables an animated cloudy background generated on a GPU via GLSL
//When disabled, the background renders only once.
boolean enableBackground = false;

//Enhances view experience with color manipulation and motion blur
boolean enablePostProcessing = false;

//Enables a three-point lighting system.
//NOTE: Disable this while playing on a Raspberry Pi with textures, for it
//causes the GPU to run out of memory. Also, the Pi can only handle two lights at most
int lights = 0;

//Renders blocks with textures rather than colors
boolean enableTextures = true;

//Renders colored borders around blocks.
//This only works when textures are disabled for now, though that 
//may change in the future
boolean enableBorders = false;