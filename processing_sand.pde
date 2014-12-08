import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.util.Random;
import controlP5.*;

ControlP5 cp5;
DropdownList list;

Minim minim;
AudioPlayer sandRush;

Element[][] elements;
int id = 0;
int brushType = 0;
boolean playing;
/*
Brush types:
0: Sand
1: Water
2: Wall
3: Eraser
*/
void setup()
{
  //frameRate(10);    //set this to slow things down
  size(500,500);
  elements = new Element[501][501];
  cp5 = new ControlP5(this);
  // create a DropdownList
  list = cp5.addDropdownList("Material")
          .setPosition(400, 20);
          
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
  playing = false;
}

void draw()
{
  /*for(int i = 0; i < sandRush.bufferSize() - 1; i++)
  {
    line(i, 50 + sandRush.left.get(i)*50, i+1, 50 + sandRush.left.get(i+1)*50);
    line(i, 150 + sandRush.right.get(i)*50, i+1, 150 + sandRush.right.get(i+1)*50);
  }*/
  background(255);
  if (mousePressed)
  {
    if(mouseY > 0 && mouseX > 0 && mouseY < 500 && mouseX < 500)
    {
      if(!playing && brushType == 0)
      {
        sandRush.loop();
        playing = true;
      }
      int random = (int )(Math.random() * 10 - 5);
      if((mouseX + random) > 0)
      {

        switch(brushType){
          case 0:  elements[mouseX+random][mouseY] = new Element(mouseX+random, mouseY, id++);  //sand
                    break;
          case 1:  elements[mouseX][mouseY] = new Water(mouseX+(random/2), mouseY, id++);  //water
                    break;
          case 2:  elements[mouseX][mouseY] = new Wall(mouseX, mouseY, pmouseX, pmouseY, id++);  //wall
                    break;
          case 3:  elements[mouseX][mouseY] = null;  //eraser
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
  }
  else if(playing)
  {
    sandRush.play();
    playing = false;
  }
  for(int i = 0; i < 500; i++)
  {
    for(int j = 499; j >= 0; j--)
    {
      if(elements[i][j]!=null)
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

class Element //Elements are each block. Just a generic block of sand type
{
  color c;
  int xPos;
  int yPos;
  int gSpeed = 1;
  boolean settled;
  int identification;
  int frictionConstant = 3;
  
  Element()
  {
  }
  
  Element(int xP, int yP, int ident)
  {
    xPos = xP;
    yPos = yP;
    identification = ident;
  }
  
  void display()
  {
    stroke(0);
    fill(0);
    rectMode(CENTER);
    rect(xPos,yPos,1,1);
  }
  
  void gravity() 
  { 
    if(!settled && yPos >= height-1) //Stops a block if it hits the bottom of the screen
    {
      settled = true;
    }
    //print(brushType);
    Random random = new Random();
    if(!settled) //Moves the block down at gSpeed's speed
    { 
      int newyPos = yPos + gSpeed;
      if(elements[xPos][newyPos] == null)    //There is free space directly below the block.
      {
        elements[xPos][newyPos] = elements[xPos][yPos];
        elements[xPos][yPos] = null;
        yPos = newyPos;
      }
      else  //There is a block directly below the block
      {
        Element ele = elements[xPos][newyPos];    //this is the block that we're in conflict with.
        if(ele.settled)    //the block directly below our block is settled.  Since we're processing one block at a time, this is important
        {
          int randomDir = random.nextInt(frictionConstant*2+1) - frictionConstant;    //we can go left or right by 3.
          boolean stick=false;
          boolean stickReverse = false;
          if(randomDir != 0){    //if randomDir is 0, then we'd go straight down
            if((xPos+randomDir) > 0 && (xPos+randomDir) < 500 && elements[xPos+randomDir][newyPos]!=null && elements[xPos+randomDir][newyPos].settled)
              stick = true;
            if((xPos-randomDir) > 0 && (xPos-randomDir) < 500 && elements[xPos-randomDir][newyPos]!=null && elements[xPos-randomDir][newyPos].settled)
              stickReverse = true;
          }else{
            stick = true;
            stickReverse=true;
          }
          if(!stick){
            int oldxPos = xPos;
            xPos+=randomDir;
            elements[xPos][newyPos] = elements[oldxPos][yPos];
            elements[oldxPos][yPos] = null;
            yPos = newyPos;
          }else if(!stickReverse){
            int oldxPos = xPos;
            xPos-=randomDir;
            elements[xPos][newyPos] = elements[oldxPos][yPos];
            elements[oldxPos][yPos] = null;
            yPos = newyPos;
          }else{
            settled = true;
          }
        }
      }
    }
  }
}

class Wall extends Element
{
  float xEndPos;
  float yEndPos;
  Wall(int xP, int yP, int x2P, int y2P, int ident)
  {
    xPos = xP;
    yPos = yP;
    xEndPos = x2P;
    yEndPos = y2P;
    identification = ident;
  }
  void display()
  {
    stroke(255, 0, 0);
    fill(0);
    line(xPos,yPos,xEndPos,yEndPos);
  }
  void gravity() 
  {
    settled = true;
  }
}

class Water extends Element
{
  int frictionConstant = 12;
  Water(int xP, int yP, int ident)
  {
    super(xP,yP,ident);
  }
}
