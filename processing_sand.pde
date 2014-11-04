ArrayList<Element> elements;
int id = 0;
void setup()
{
  size(500,500);
  
  elements = new ArrayList<Element>();
}

void draw()
{
  background(255);
  if (mousePressed)
  {
   elements.add(new Element(mouseX, mouseY, id++));  //Each mouse press adds a new Element based on what's selected (this is just generic for now)
  }
  for(int i = 0; i < elements.size(); i++)
    {
      Element ele = elements.get(i);
      ele.gravity();
      ele.display();
    }
}

class Element //Elements are each block. Just a generic block here, figured we could add inherited objects for the different types
{
  color c;
  float xPos;
  float yPos;
  float gSpeed = 1;
  boolean settled;
  boolean settledF;
  int identification;
  
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
    if(!settled) //Moves the block down at gSpeed's speed
    { 
      yPos = yPos + gSpeed;
    }
    if(!settledF) //Final settle after colliding with another block
    {
      for(int i = 0; i < elements.size()-1; i++)
      {
        if(identification != elements.get(i).identification && yPos == elements.get(i).yPos && xPos == elements.get(i).xPos)
        { 
         yPos-=1;
         settledF = true;
         settled = true;
        }
      }
    } 
    if(yPos >= height-1) //Stops a block if it hits the bottom of the screen
      settled = true;
  }
}
