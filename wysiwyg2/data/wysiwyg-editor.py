#!/usr/bin/python3
# The level editor for WYSIWYG

# import necessary utilities
print ('Initializing')
import pygame, sys, math, random
from pygame.locals import *


print ('Starting Pygame engine')
# Graphics variables and functions
pygame.init()
game_screen = pygame.display.set_mode((200,200))
screen_size = game_screen.get_size()
clock = pygame.time.Clock()
game_font = pygame.font.Font('freesansbold.ttf', 14)
pygame.display.set_caption('WYSIWYG')
color_background      = (32, 32,  32)
color_player          = (10 ,180,255)
color_block_floor     = (150,150,150)
color_block_rotate_c  = (200,120,0  )
color_block_rotate_cc = (255,0  ,0  )
color_block_tilt      = (0  ,180,180)
color_block_goal      = (0  ,255,0  )
color_text            = (255,128,0  )
print ('Defining variables and functions')
def color_multiply(color,factor):
        return (int(color[0]*factor),
                int(color[1]*factor),
                int(color[2]*factor))


# Game machanics variables and functions

pi = 3.1415926535898
thetaX  = 3*pi/2
thetaY  = -pi/2
thetaDX = 9*pi/4
thetaDY = 0.625
vertical_rotation_positions = (-pi/2, -0.625, 0, 0.625, pi/2)
# For all positions and locations,
# the x-coordinate is the zeroth index,
# the y-coordinate is the first index,
# and the z-coordinate (if exists)
# is the second index.
view_position = [0,0]      #Position of view, used when drawing on the screen
player_position = [0,0,0]  #Position of player in 3D space
player_type = 0
level = 1
#Blocks contain a 3D position and a type
#       [x,y,z,t]
#Type can be any of the following:
#0: floor
#1: rotate clockwise
#2: rotate counter-clockwise
blocks = [[0,1,0,0]]
block_size = int(min(screen_size[0],screen_size[1])/10)

def reset():
    global thetaX, thetaY, thetaDX, thetaDY, player_position
    thetaX  = 0
    thetaY  = -pi/8
    thetaDX = pi/4
    thetaDY = 0.625
    player_position = [0,0,0]

def loadLevel(level):
    global blocks
    blocks = []
    reset()
    try:
        level = open('level{0}.lvl'.format(level), 'r')
        for line in level:
            vals = line.split()
            block = []
            for val in vals:
                block.append(int(val))
            blocks.append(block)
        level.close()
    except Exception as e:
        print (e)
        blocks = [[0,1,0,0]]

def tilt(up):
    global thetaDY
    p = vertical_rotation_positions.index(thetaDY)
    if p==-1:
        thetaDY = vertical_rotation_positions[3]
    elif up and p<4:
        thetaDY = vertical_rotation_positions[p+1]
    elif not up and p>0:
        thetaDY = vertical_rotation_positions[p-1]

def get_projected_position(position):
        x,y,z = position[:3]
        sx = math.sin(thetaX)
        cx = math.cos(thetaX)
        sy = math.sin(thetaY)
        cy = math.cos(thetaY)
        return [x*cx+z*sx,
                y*cy+sy*(x*sx-z*cx),
                y*sy+cy*(z*cx-x*sx)]

def get_projected_positions(positions):        
        sx = math.sin(thetaX)
        cx = math.cos(thetaX)
        sy = math.sin(thetaY)
        cy = math.cos(thetaY)
        temp = []
        for position in positions:
            x,y,z = position[:3]
            temp.append([x*cx+z*sx,
                y*cy+sy*(x*sx-z*cx),
                y*sy+cy*(z*cx-x*sx)])
        return temp;

def get_view_position(position):
        p = get_projected_position(position)
        return [p[0]*block_size-view_position[0]+screen_size[0]/2,
                p[1]*block_size-view_position[1]+screen_size[1]/2]

def get_view_positions(positions):
    points = get_projected_positions(positions)
    temp = []
    for p in points:
        temp.append([p[0]*block_size-view_position[0]+screen_size[0]/2,
                p[1]*block_size-view_position[1]+screen_size[1]/2])
    return temp

def is_equal_3d(pos1, pos2):
        return abs(pos1[0]-pos2[0])+abs(pos1[1]-pos2[1])+abs(pos1[2]-pos2[2])<0.1

def is_equal_2d(pos1, pos2):
        return abs(pos1[0]-pos2[0])+abs(pos1[1]-pos2[1])<0.1


def terminate():
        pygame.mixer.music.stop()
        print ('Quitting')
        pygame.quit()
        sys.exit()

def drawDotAt(position):
    x,y = get_view_position(position)
    pygame.draw.circle(game_screen,
                       color_player,
                       (int(x),int(y)),
                       3)
def drawText(text, position):
    scoreSurf = game_font.render(text, True, color_text)
    scoreRect = scoreSurf.get_rect()
    scoreRect.topleft = position
    game_screen.blit(scoreSurf, scoreRect)

def drawValue(value, position):
    drawText('%s' % (value), position)

def printBlocks():
    global blocks, level
    out = open('level{0}.lvl'.format(level),'w')
    for block in blocks:
        for i in block:
            out.write('%s' % (i))
            out.write(' ')
        out.write('\n')
    out.close()
    print('Printed to "level{0}.lvl"'.format(level))
    

def drawBlock(position, color):
    x,y,z = position[:3]
    
    #Get useful points on the screen
    aaa,aab,aba,abb,baa,bab,bba,bbb = get_view_positions(
        ((x,  y,  z  ),
        (x,  y,  z+1),
        (x,  y+1,z  ),
        (x,  y+1,z+1),
        (x+1,y,  z  ),
        (x+1,y,  z+1),
        (x+1,y+1,z  ),
        (x+1,y+1,z+1)))
    #Draw faces
    if thetaY>=0:
        pygame.draw.polygon(game_screen, color, (aaa,aab,bab,baa))#Draw top square
    else:
        pygame.draw.polygon(game_screen, color_multiply(color,0.2), (aba,abb,bbb,bba))#Draw bottom square
    if thetaX<=pi/2 or thetaX>=3*pi/2:
        pygame.draw.polygon(game_screen, color_multiply(color,0.7), (aaa,baa,bba,aba))#Draw front square
    else:
        pygame.draw.polygon(game_screen, color_multiply(color,0.4), (aab,bab,bbb,abb))#Draw back square
    if thetaX<=pi:
        pygame.draw.polygon(game_screen, color_multiply(color,0.5), (baa,bab,bbb,bba))#Draw right square
    else:
        pygame.draw.polygon(game_screen, color_multiply(color,0.5), (aaa,aab,abb,aba))#Draw left square


def drawBlocks():
    global blocks, player_position
    player_projection  = get_projected_position(player_position)
    #Sort blocks by distance if the camera is rotating
    if(abs(thetaX-thetaDX)+abs(thetaY-thetaDY)>0.1):
        projectedPositions = get_projected_positions(blocks)
        if len(blocks)!=len(projectedPositions): print ('Dimensions do not match!')
        temp = []
        while len(blocks)>0:
            farthestBlock = 0
            farthestDistance = -10000
            for i in range(len(blocks)):
                if projectedPositions[i][2]>=farthestDistance:
                    farthestBlock = i
                    farthestDistance = projectedPositions[i][2]
            projectedPositions.pop(farthestBlock)
            temp.append(blocks.pop(farthestBlock))
        blocks = temp
    projectedPositions = get_projected_positions(blocks)
    hasDrawnPlayer = False
    #Draw blocks
    for i in range(len(blocks)):
        block = blocks[i]
        #Draw the player if it is farther away
        #(i.e. it has a larger z-value) than
        #the block at the given index
        if(player_projection[2]>projectedPositions[i][2] and not hasDrawnPlayer):
            hasDrawnPlayer = True
            drawBlock(player_position, color_player)
        #Color picker
        color = (255,0,255)
        if block[3]==0: color = color_block_floor
        if block[3]==1: color = color_block_rotate_c
        if block[3]==2: color = color_block_rotate_cc
        if block[3]==3: color = color_block_goal
        if block[3]==4: color = color_block_tilt
        drawBlock(block, color)
    #Draw the player if it hasn't been drawn yet
    if not hasDrawnPlayer:
        hasDrawnPlayer = True
        drawBlock(player_position, color_player)

loadLevel(level)
while True:
    # event handling
    for event in pygame.event.get():
        if event.type == QUIT:
            terminate()
        elif event.type == KEYDOWN:
            if event.key in (K_UP, K_w):
                player_position[2]+=1
            elif event.key in (K_DOWN, K_s):
                player_position[2]-=1
            elif event.key in (K_LEFT, K_a):
                player_position[0]-=1
            elif event.key in (K_RIGHT, K_d):
                player_position[0]+=1
            elif event.key == K_q:
                player_position[1]-=1
            elif event.key == K_e:
                player_position[1]+=1
            elif event.key == K_j:
                thetaDX -= pi/2
            elif event.key == K_k:
                thetaDX += pi/2
            elif event.key == K_i:
                level += 1
                loadLevel(level)
            elif event.key == K_u and level>1:
                level -= 1
                loadLevel(level)
            elif event.key == K_n:
                tilt(True)
            elif event.key == K_m:
                tilt(False)
            elif event.key == K_1:
                player_type = 0;
            elif event.key == K_2:
                player_type = 1;
            elif event.key == K_3:
                player_type = 2;
            elif event.key == K_4:
                player_type = 3;
            elif event.key == K_5:
                player_type = 4;
            elif event.key == K_r:
                reset()
            elif event.key == K_c:
                blocks = [[0,1,0,0]]
                reset()
            elif event.key == K_BACKSPACE:
                i = len(blocks)-1
                while i>=0:
                    if is_equal_3d(blocks[i],player_position):
                        del blocks[i]
                    i-=1
            elif event.key == K_SPACE:
                blocks.append(player_position+[player_type])
            elif event.key == K_p:
                printBlocks()
                print('Level saved in tempLevel.lvl')
        elif event.type == KEYUP:
            if event.key == K_ESCAPE:
                terminate()
    
    #Follow the block while the camera is
    #not none rotating
    if not (abs(thetaX-thetaDX)+abs(thetaY-thetaDY)<0.1):
        player_projection = get_projected_position(player_position)
        view_position[0] = player_projection[0]*block_size
        view_position[1] = player_projection[1]*block_size
    #Constrain camera directions, for
    #if thetaX is not between 0 and 2*pi
    #and thetaY is not between +-pi/2,
    #the 'drawBlock()' function will
    #not work properly
    if thetaX>2*pi:
        thetaX -= 2*pi
        if thetaDX>2*pi: thetaDX -= 2*pi
    if thetaX<0:
        thetaX += 2*pi
        if thetaDX<0: thetaDX += 2*pi
    if thetaY<-pi/2: thetaY = -pi/2
    elif thetaY>pi/2: thetaY = pi/2
    if thetaDY<-pi/2: thetaDY = -pi/2
    elif thetaDY>pi/2: thetaDY = pi/2
    
    #Shift the camera to follow the player
    #Change the direction of the camera
    thetaX = (thetaX*7+thetaDX)/8.0
    thetaY = (thetaY*7+thetaDY)/8.0
    #Change the position of the camera
    player_projection = get_projected_position(player_position)
    view_position[0] = (view_position[0]*7+player_projection[0]*block_size)/8.0
    view_position[1] = (view_position[1]*7+player_projection[1]*block_size)/8.0
    game_screen.fill(color_background)
    drawBlocks()
    drawValue(round(thetaX,2), (0,0))
    drawValue(round(thetaY,2), (0,14))
    drawValue(player_position, (0,28))
    
    #Color picker
    color = (255,0,255)
    if player_type==0: color = color_block_floor
    elif player_type==1: color = color_block_rotate_c
    elif player_type==2: color = color_block_rotate_cc
    elif player_type==3: color = color_block_goal
    elif player_type==4: color = color_block_tilt
    pygame.draw.rect(game_screen, color, Rect(40,10,16,16))
    
    drawValue(level, (0,46))
    pygame.display.update()
    clock.tick(24)
