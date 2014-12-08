import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.util.Random;
import controlP5.*;

ControlP5 cp5;
Slider redSlider;
DropdownList list;

Minim minim;
AudioPlayer sandRush;
AudioPlayer waterRush;
AudioOutput out;
PinkNoise pn;

Element[][] elements;
int id = 0;
int brushType = 0;
int playing;

int red;
int blue;
int green;

float cur_amp=.2;
/*
Brush types:
 0: Sand
 1: Water
 2: Wall
 3: Eraser
 */
void setup()
{
  frameRate(120);    //set this to slow things down
  size(600, 500);
  elements = new Element[501][501];
  cp5 = new ControlP5(this);
  // create a DropdownList
  list = cp5.addDropdownList("Material")
     .setPosition(500, 20);
  cp5.addSlider("red")
     .setPosition(510,130)
     .setSize(20,200)
     .setValue(237)
     .setRange(0,255)
     .setColorForeground(color(200, 0, 0))
     .setColorActive(color(200, 0, 0));
  cp5.addSlider("green")
     .setPosition(540,130)
     .setSize(20,200)
     .setValue(200)
     .setRange(0,255)
     .setColorForeground(color(0, 200, 0))
     .setColorActive(color(0, 200, 0));
   cp5.addSlider("blue")
     .setPosition(570,130)
     .setSize(20,200)
     .setValue(83)
     .setRange(0,255)
     .setColorForeground(color(0, 0, 200))
     .setColorActive(color(0, 0, 200));
  list.setBackgroundColor(color(190));
  list.setItemHeight(20);
  list.setBarHeight(15);
  list.captionLabel().set("Material");
  list.captionLabel().style().marginTop = 3;
  list.captionLabel().style().marginLeft = 3;
  list.valueLabel().style().marginTop = 3;
  list.addItem("Sand", 0);
  list.addItem("Water", 1);
  list.addItem("Wall", 2);
  list.addItem("Eraser", 3);
  list.setColorBackground(color(60));
  list.setColorActive(color(255, 128));

  minim = new Minim(this);
  sandRush = minim.loadFile("sandrush.mp3", 2048);
  waterRush = minim.loadFile("waterrush.mp3", 2048);
  playing = -1;
}

void draw()
{
  background(255);
  fill(0);
  rectMode(CORNER);
  rect(500, 0, 500,500);
  if (mousePressed)
  {
    if (mouseY > 0 && mouseX > 0 && mouseY < 500 && mouseX < 500 && !(mouseX > 400 && mouseY < 100))
    {
      if (playing== -1)
      {
        if (brushType == 0) {
          pn = new PinkNoise(cur_amp);
          out = minim.getLineOut();
          out.addSignal(pn);
          playing = 0;
        } else if (brushType == 1)
        {
          waterRush.loop();
          playing = 1;
        }
      }
      int random = (int )(Math.random() * 10 - 5);
      if ((mouseX + random) > 0 && (mouseX + random) < 500)
      {

        switch(brushType) {
        case 0:  
          if(elements[mouseX+random][mouseY] == null)
            elements[mouseX+random][mouseY] = new Sand(mouseX+random, mouseY, id++, 6, red, green, blue);  //sand
          break;
        case 1:  
          if(elements[mouseX+random][mouseY] == null)
          elements[mouseX+random][mouseY] = new Water((mouseX+random), mouseY, id++);  //water
          break;
        case 2:   
          if (pmouseX > 0 && pmouseX < 500 && pmouseY > 0 && pmouseY < 500)
            generateWall(mouseX, mouseY, pmouseX, pmouseY, id++);  //wall
          break;
        case 3:  
          elements[mouseX][mouseY] = null;  //eraser
          elements[mouseX+1][mouseY] = null; 
          elements[mouseX-1][mouseY] = null;
          elements[mouseX+1][mouseY+1] = null; 
          elements[mouseX-1][mouseY+1] = null;
          elements[mouseX+1][mouseY-1] = null; 
          elements[mouseX-1][mouseY-1] = null;    
          elements[mouseX][mouseY-1] = null; 
          elements[mouseX][mouseY+1] = null; 
          break;
        }
      }
    }
  } else if (playing >= 0)
  {
    if (playing == 0)
      out.clearSignals();
    else if (playing == 1)
      waterRush.play();
    playing = -1;
  }
  for (int i = 0; i < 500; i++)
  {
    for (int j = 499; j >= 0; j--)
    {
      if (elements[i][j]!=null)
      {
        Element ele = elements[i][j];
        ele.gravity();
        ele.display();
      }
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    brushType = (int) theEvent.getGroup().getValue();
  }
}

void generateWall(int beginX, int beginY, int endX, int endY, int id) {
  if (beginX > endX) {
    int tempX = endX;
    endX = beginX;
    beginX = tempX;
  }
  for (int x = beginX; x<=endX; x++) {
    int y;
    if (endX==beginX)
      y = beginY;
    else
      y = int((endY-beginY)/(endX-beginX))*(x-beginX)+beginY;

    elements[x][y] = new Wall(x, y, id);
    elements[x][y-1] = new Wall(x, y-1, id);
    elements[x-1][y-2] = new Wall(x-1, y-2, id);
  }
}

class Element //Elements are each block. Just a generic block of sand type
{
  color c;
  int xPos;
  int yPos;
  int gSpeed = 1;
  boolean settled;
  int identification;
  int frictionConstant;
  int red;
  int green;
  int blue;

  Element()
  {
  }

  Element(int xP, int yP, int ident, int fC)
  {
    xPos = xP;
    yPos = yP;
    identification = ident;
    frictionConstant = fC;
  }

  void display()
  {
    noStroke();
    fill(0);
    rectMode(CENTER);
    rect(xPos, yPos, 1, 1);
  }

  int getRandomMax()
  {
    Random random = new Random();
    return ceil(pow(random.nextInt(frictionConstant*(500-yPos)), .3));
  }
  void gravity() 
  {
    if (settled && yPos < height-1 && elements[xPos][(yPos+gSpeed)] == null)    //check for eraser
      settled = false;
    if (!settled && yPos >= height-1) //Stops a block if it hits the bottom of the screen
    {
      settled = true;
    }
    if (!settled) //Moves the block down at gSpeed's speed
    { 
      int newyPos = yPos + gSpeed;
      if (elements[xPos][newyPos] == null)    //There is free space directly below the block.
      {
        elements[xPos][newyPos] = elements[xPos][yPos];
        elements[xPos][yPos] = null;
        yPos = newyPos;
      } else  //There is a block directly below the block
      {
        Element ele = elements[xPos][newyPos];    //this is the block that we're in conflict with.
        if (ele.settled)    //the block directly below our block is settled.  Since we're processing one block at a time, this is important
        {
          int randomDirMax = getRandomMax();
          boolean negative = Math.random() < 0.5;
          boolean stick = true;
          boolean stickReverse = true;
          int randomDir = 0;
          if (randomDirMax != 0) {    //if randomDir is 0, then we'd go straight down
            if (negative)
            {
              randomDirMax*=-1;
              boolean canGoPositive = true;
              boolean canGoNegative = true;
              for (randomDir = 0; randomDir > randomDirMax; randomDir--) {
                if (canGoPositive && (xPos+randomDir) > 0 && (xPos+randomDir) < 500) {
                  if (elements[xPos+randomDir][newyPos]==null || !elements[xPos+randomDir][newyPos].settled)
                  {
                    stick = false;
                    break;
                  } else if (elements[xPos+randomDir][newyPos]!=null && cannotPass(elements[xPos+randomDir][newyPos].getClass().getName())) {    //we don't want to leak through walls
                    canGoPositive = false;
                  }
                }
                if (canGoNegative && (xPos-randomDir) > 0 && (xPos-randomDir) < 500) {
                  if (elements[xPos-randomDir][newyPos]==null || !elements[xPos-randomDir][newyPos].settled)
                  {
                    stickReverse = false;
                    break;
                  } else if (elements[xPos-randomDir][newyPos]!=null && cannotPass(elements[xPos-randomDir][newyPos].getClass().getName())) {
                    canGoNegative = false;
                  }
                }
              }
            } else
            {
              boolean canGoPositive = true;
              boolean canGoNegative = true;
              for (randomDir = 0; randomDir < randomDirMax; randomDir++) {
                if (canGoPositive && (xPos+randomDir) > 0 && (xPos+randomDir) < 500) {
                  if (elements[xPos+randomDir][newyPos]==null || !elements[xPos+randomDir][newyPos].settled)
                  {
                    stick = false;
                    break;
                  } else if (elements[xPos+randomDir][newyPos]!=null && cannotPass(elements[xPos+randomDir][newyPos].getClass().getName())) {    //we don't want to leak through walls
                    canGoPositive = false;
                  }
                }
                if (canGoNegative && (xPos-randomDir) > 0 && (xPos-randomDir) < 500) {
                  if (elements[xPos-randomDir][newyPos]==null || !elements[xPos-randomDir][newyPos].settled)
                  {
                    stickReverse = false;
                    break;
                  } else if (elements[xPos-randomDir][newyPos]!=null && cannotPass(elements[xPos-randomDir][newyPos].getClass().getName())) {
                    canGoNegative = false;
                  }
                }
              }
            }
          }
          if (!stick) {
            int oldxPos = xPos;
            xPos+=randomDir;
            elements[xPos][newyPos] = elements[oldxPos][yPos];
            elements[oldxPos][yPos] = null;
            yPos = newyPos;
          } else if (!stickReverse) {
            int oldxPos = xPos;
            xPos-=randomDir;
            elements[xPos][newyPos] = elements[oldxPos][yPos];
            elements[oldxPos][yPos] = null;
            yPos = newyPos;
          } else {
            settled = true;
          }
        }
      }
    }
  }
  boolean cannotPass(String className) {
    if (className == "processing_sand$Wall")
      return true;
    else
      return false;
  }
}

class Wall extends Element
{
  Wall(int xP, int yP, int ident)
  {
    super(xP, yP, ident, 0);
  }
  void display()
  {
    stroke(0);
    fill(120, 120, 120);
    rectMode(CENTER);
    rect(xPos, yPos, 1, 1);
  }
  void gravity() 
  {
    settled = true;
  }
}
class Sand extends Element
{
  Sand(int xP, int yP, int ident, int fC, int rV, int gV, int bV)
  {
    super(xP, yP, ident, fC);
    red = rV;
    green = gV;
    blue = bV;
  }
  void display()
  {
    noSmooth();
    noStroke();
    fill(red, green, blue);
    rectMode(CENTER);
    rect(xPos, yPos, 1, 1);
  }
}
class Water extends Element
{
  Water(int xP, int yP, int ident)
  {
    super(xP, yP, ident, 50);
  }
  void display()
  {
    noSmooth();
    noStroke();
    fill(0,0,255);
    rectMode(CENTER);
    rect(xPos, yPos, 1, 1);
  }
  boolean cannotPass(String className) {
    if (className == "processing_sand$Wall" || className == "processing_sand$Sand")
      return true;
    else
      return false;
  }
  int getRandomMax()
  {
    return 100;
  }
}
