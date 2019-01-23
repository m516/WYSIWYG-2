//View parameters
PVector view_translation = new PVector();
PVector view_rotation = new PVector();
float zoom;
float block_size = 64.0;

//Background colors
color back_color_a = color(16,16,16);
color back_color_b = color(32,32,32);

//Blocks
Block player;
Block[] blocks;


//Images for blocks
PImage sprite_player;
PImage sprite_player_shaded;
PImage sprite_generic;
PImage sprite_generic_shaded;
PImage sprite_goal;
PImage sprite_goal_shaded;
PImage sprite_antigravity;
PImage sprite_antigravity_shaded;
PImage sprite_rotate_left;
PImage sprite_rotate_left_shaded;
PImage sprite_rotate_right;
PImage sprite_rotate_right_shaded;

//Colors if images don't work
color color_player       = color(10 ,180,255);
color color_generic      = color(150,150,150);
color color_goal         = color(0  ,255,0  );
color color_rotate_left  = color(200,120,0  );
color color_rotate_right = color(255,0  ,0  );
color color_antigravity  = color(0  ,180,180);

//Current level
int level = 1;

void initializeGlobals(){
  //Load images
  sprite_player = loadImage("Block-Player-Unshaded.png");
  sprite_player_shaded = loadImage("Block-Player.png");
  sprite_generic = loadImage("Block-Generic-Unshaded.png");
  sprite_generic_shaded = loadImage("Block-Generic.png");
  sprite_goal = loadImage("Block-Goal-Unshaded.png");
  sprite_goal_shaded = loadImage("Block-Goal.png");
  sprite_rotate_left = loadImage("Block-Rotate-Left-Unshaded.png");
  sprite_rotate_left_shaded = loadImage("Block-Rotate-Left.png");
  sprite_rotate_right = loadImage("Block-Rotate-Right-Unshaded.png");
  sprite_rotate_right_shaded = loadImage("Block-Rotate-Right.png");
  sprite_antigravity = loadImage("Block-Antigravity-Unshaded.png");
  sprite_antigravity_shaded = loadImage("Block-Antigravity.png");
  
  //Initialize the player
  player = new Block(0,0,0,PLAYER);
  
  //Load the first level
  loadLevel("level1.lvl");
}