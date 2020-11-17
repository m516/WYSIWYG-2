# So how does it work?
This is a [Processing sketch](https://processing.org/), using the Java mode. I created the assets by hand with the [GIMP](https://www.gimp.org/).

This game was developed _on_ a Raspberry Pi _for_ a Raspberry Pi, but it can be run on every operating system that can run Java.

## Overview
The components of this game are split into seven files. Note that in Processing, files are used for orgainizing code, and at compile-time they are all combined under one Wysiwyg2 class.
1. [config](wysiwyg2/config.pde) contains settings with default values. They can be changed at runtime in the menu.
2. [engine](wysiwyg2/engine.pde) describes how to render everything *besides* the UI.
3. [game](wysiwyg2/game.pde) contains high-level game behavior, like how levels are organized.
4. [globals](wysiwyg2/globals.pde) contains global variables for the game, like sprite and game data. It also contains a method that loads this data from files in the repository.
5. [mechanics](wysiwyg2/mechanics.pde) is the file holding more nitty-gritty details about the game mechanics, like camera behavior and how levels are loaded.
6. [ui](wysiwyg2/ui.pde) has everything related to the menu system. 
7. [wysiwyg2](wysiwyg2/wysiwyg2.pde) contains all the methods that are built into Processing and used in this sketch: `setup`, `draw()`,
`mousePressed`, and `mouseReleased`.


## Rendering Pipeleine
The rendering pipeline has four phases outlined below. The entire pipeline is under the *engine* file.
1. The **animated background** is a shader written in GLSL and rendered on a PGraphics object in 2D mode called `background`.
2. Above that is the **game renderer**. This is where all the blocks and lights are rendered. It's a PGraphics object in 3D mode called `render`.
3. Above that is the **post processing pipeline** responsible for motion blur (if enabled). It's a PGraphics object in 2D mode called `postProcessing`.
4. The top layer is the **menu graphics**. All menu buttons are rendered here. It's a PGraphics object in 2D mode called `menuGraphics`.

