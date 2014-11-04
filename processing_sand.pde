ArrayList<Element> elements;
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
   elements.add(new Element(mouseX, mouseY));  //Each mouse press adds a new Element based on what's selected (this is just generic for now)
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
  
  Element(int xP, int yP) 
  {
    xPos = xP;
    yPos = yP;
  }
  
  void display()
  {
    stroke(0);
    fill(0);
    rectMode(CENTER);
    rect(xPos,yPos,1,1);
  }
  
  void gravity() 
  { //This is about where any issues I'm having are, this part handles both the falling of blocks and their collision.
    if(!settled)
    { 
      yPos = yPos + gSpeed;
    }
    if(!settledF)
    {
      for(int i = 0; i < elements.size()-1; i++)
      {
        if(yPos == elements.get(i).yPos && xPos == elements.get(i).xPos)
        { 
         System.out.println("meows");
         yPos-=1;
         settledF = true;
         settled = true;
        }
      }
    } 
    if(yPos >= height-1)
      settled = true;
  }
}
