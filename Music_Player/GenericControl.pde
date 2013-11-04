public abstract class GenericControl{
  // Window size and position;
  protected PVector myPos;
  protected PVector mySize;
  
  // =====  Abstract Methods  =====
  // Devine the method that inits this control window
  public abstract void init();
  // Define the method that runs for this control window
  // Make sure to draw the indow position at the window
  public abstract void display(); 
 
 
  // =====  Implemented Methods  =====
  public PVector getControlPosition(){
    return myPos;
  }
  
  public void setControlPosition(int x, int y){
    myPos = new PVector(x,y);
  }
  
  public PVector getControlSize(){
    return mySize;
  }
  
  public void setControlSize(int x, int y){
    mySize = new PVector(x,y);
  }
 
}
