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
  size(500,500);
  elements = new Element[502][502];
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
      switch(brushType){
        case 0:  elements[mouseX+random][mouseY] = new Element(mouseX+random, mouseY, id++);  //sand
                  break;
        case 1:  elements[mouseX][mouseY] = new Water(mouseX, mouseY, id++);  //water
                  break;
        case 2:  elements[mouseX][mouseY] = new Wall(mouseX, mouseY, pmouseX, pmouseY, id++);  //wall
                  break;
        case 3:  //eraser
                  break;
      }
    }
  }
  else if(playing)
  {
    sandRush.play();
    playing = false;
  }
  for(int i = 0; i < 501; i++)
  {
    for(int j = 500; j >= 0; j--)
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
    print(brushType);
  }else{
    print(theEvent.getGroup().toString());
  }
}

class Element //Elements are each block. Just a generic block here, figured we could add inherited objects for the different types
{
  color c;
  int xPos;
  int yPos;
  int gSpeed = 2;
  boolean settled;
  boolean settledF;
  int identification;
  
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
      int oldyPos = yPos;
      yPos = yPos + gSpeed;
      elements[xPos][yPos] = elements[xPos][oldyPos];
      elements[xPos][oldyPos] = null;
    }
    if(!settledF) //Final settle after colliding with another block
    {
      if(elements[xPos][yPos]!=null)
      {
        Element ele = elements[xPos][yPos];
        if(ele.settled && identification != ele.identification)
        {
          int randomDir = random.nextInt(7) - 3;
          boolean stick=false;
          boolean stickReverse = false;
          if(randomDir != 0){
            if(elements[xPos+randomDir][yPos]!=null && elements[xPos+randomDir][yPos].settled)
              stick = true;
            else if(elements[xPos-randomDir][yPos]!=null && elements[xPos-randomDir][yPos].settled)
              stickReverse = true;
          }else{
            stick = true;
            stickReverse = true;
          }
          if(!stick){
            int oldxPos = xPos;
            xPos+=randomDir;
            elements[xPos][yPos] = elements[oldxPos][yPos];
            elements[oldxPos][yPos] = null;
          }else if(!stickReverse){
            int oldxPos = xPos;
            xPos-=randomDir;
            elements[xPos][yPos] = elements[oldxPos][yPos];
            elements[oldxPos][yPos] = null;
          }else{
            int oldyPos = yPos;
            yPos -= 1;
            elements[xPos][yPos] = elements[xPos][oldyPos];
            elements[xPos][oldyPos] = null;
            settledF = true;
            settled = true;
          }
        }else{
          //remove the element?
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
    settledF = true;
  }
}

class Water extends Element
{
  Water(int xP, int yP, int ident)
  {
    super(xP,yP,ident);
  }
