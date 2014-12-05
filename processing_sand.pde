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

ArrayList<Element> elements;
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
  elements = new ArrayList<Element>();
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
    if(!playing && brushType == 0)
    {
      sandRush.loop();
      playing = true;
    }
    int random = (int )(Math.random() * 10 - 5);
    switch(brushType){
      case 0:  elements.add(new Element(mouseX+random, mouseY, id++));  //sand
                break;
      case 1:  elements.add(new Water(mouseX+random, mouseY, id++));  //water
                break;
      case 2:  elements.add(new Wall(mouseX, mouseY, pmouseX, pmouseY, id++));  //wall
                break;
      case 3:  //eraser
                break;
    }
      
  }else if(playing)
  {
    sandRush.play();
    playing = false;
  }
  for(int i = 0; i < elements.size(); i++)
    {
      Element ele = elements.get(i);
      ele.gravity();
      ele.display();
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
  float xPos;
  float yPos;
  float gSpeed = 2;
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
    //print(brushType);
    Random random = new Random();
    if(!settled) //Moves the block down at gSpeed's speed
    { 
      yPos = yPos + gSpeed;
    }
    if(!settledF) //Final settle after colliding with another block
    {
      for(int i = 0; i < elements.size()-1; i++)
      {
        if(yPos == elements.get(i).yPos && xPos == elements.get(i).xPos && identification != elements.get(i).identification)
        {
          if(elements.get(i).settled)
          {
            int randomDir = random.nextInt(7) - 3;
            boolean stick=false;
            boolean stickReverse = false;
            if(randomDir != 0){
              for(int j = 0; j < elements.size()-1; j++)
              {
                if(elements.get(j).settled && yPos == elements.get(j).yPos)
                {
                  if((xPos+randomDir) == elements.get(j).xPos)
                    stick = true;
                  else if((xPos-randomDir) == elements.get(j).xPos)
                    stickReverse = true;
                }
              }
            }else{
              stick = true;
              stickReverse = true;
            }
            if(!stick){
              xPos+=randomDir;
            }else if(!stickReverse){
              xPos-=randomDir;
            }else{
              yPos-=1;
              settledF = true;
              settled = true;
            }
          }else{
            //remove the element?
          }
        }
      }
    } 
    if(yPos >= height-1) //Stops a block if it hits the bottom of the screen
      settled = true;
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
    stroke(0);
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

}
