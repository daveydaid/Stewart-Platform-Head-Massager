import processing.serial.*; //<>//

import peasy.*; //<>//
import controlP5.*;
import oscP5.*;
import netP5.*;

float MAX_TRANSLATION = 40;
float MAX_ROTATION = PI/3;    //60 degrees either direction (doesn't change the sim?)

int counter = 0;

ControlP5 cp5;
PeasyCam camera;
Platform mPlatform;

OscP5 oscP5;

Serial arduino;  // setting a serial port
String val;

// since we're doing serial handshaking, 
// we need to check if we've heard from the microcontroller
boolean firstContact = true;

float posX=0, posY=0, posZ=0, rotX=0, rotY=0, rotZ=0, speed=0.01;
float modeCounter = 0, radiusCounter = 0.004;
int dir = 1;
int test_flag0 = 0, test_flag1 = 0;
int modeSelect = 0;
int moveSelect = 0;
int storedMove = 1;
boolean ctlPressed = false;

void setup() {
  size(1024, 768, P3D);
  smooth();
  frameRate(60);
  textSize(20);
  
  //println(Serial.list());  //Temp debug: For checking COM list
  //boolean i = true;
  //while(i){
  //}
  
  //Config the serial port
  arduino = new Serial(this, Serial.list()[1], 500000);  //the [] is based on array... So if "COM3 COM4 COM5" for COM4 it would be [1]
  delay(500);
  arduino.bufferUntil('\n'); 

  camera = new PeasyCam(this, 666);
  camera.setRotations(-1.0, 0.0, 0.0);
  camera.lookAt(8.0, -50.0, 80.0);

  mPlatform = new Platform(1);
  mPlatform.applyTranslationAndRotation(new PVector(), new PVector());

  cp5 = new ControlP5(this);

  //Add slider bars --------------------
  cp5.addSlider("posX")
    .setPosition(20, 20)
    .setSize(180, 40).setRange(-1, 1);
  cp5.addSlider("posY")
    .setPosition(20, 70)
    .setSize(180, 40).setRange(-1, 1);
  cp5.addSlider("posZ")
    .setPosition(20, 120)
    .setSize(180, 40).setRange(-1, 1);

  cp5.addSlider("rotX")
    .setPosition(width-220, 20)
    .setSize(180, 40).setRange(-1, 1);
  cp5.addSlider("rotY")
    .setPosition(width-220, 70)
    .setSize(180, 40).setRange(-1, 1);
  cp5.addSlider("rotZ")
    .setPosition(width-220, 120)
    .setSize(180, 40).setRange(-1, 1);
    
  cp5.addSlider("speed")
    .setPosition(width-220, 175)
    .setSize(180, 40).setRange(0, 0.1);  

 //Add buttons to enable modes --------------------
 cp5.addButton("Reset")
    .setPosition(275,20)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);   
    
 cp5.addButton("Curve")
    .setPosition(375,20)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);   
    
 cp5.addButton("Combo")
    .setPosition(375,70)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);     
    
 cp5.addButton("Planar_Circle")
    .setPosition(475,20)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);     

 cp5.addButton("Vertical")
    .setPosition(575,20)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);
    
 cp5.addButton("Helical")
    .setPosition(575,70)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);  
    
 cp5.addButton("RAPID")
    .setPosition(575,120)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);     

 cp5.addButton("Twist")
    .setPosition(675,20)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);
    
 cp5.addButton("Planar_Eight")
    .setPosition(475,70)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);  
    
 cp5.addButton("Spiral")
    .setPosition(475,120)
    .setSize(40, 40)
    .activateBy(ControlP5.PRESS);      

  cp5.setAutoDraw(false);
  camera.setActive(true);
}

void draw() {
  background(200);
  mPlatform.applyTranslationAndRotation(PVector.mult(new PVector(posX, posY, posZ), MAX_TRANSLATION), 
    PVector.mult(new PVector(rotX, rotY, rotZ), MAX_ROTATION));
  mPlatform.draw();
  
  // Mode Selects from Buttons ------------------
  switch (modeSelect) {
    case 0:
      // NOTHING
      break;
    case 1:
      // Curve ting
      if (modeCounter <= 360)
      {
        rotX = (0.3*sin(modeCounter));
        rotY = (0.3*cos(modeCounter));
               
        modeCounter = modeCounter + speed;
      }
      break;    
    case 2:
      // Planar_Circle ting
      if (modeCounter <= 360)
      {
        posX = (1.5*sin(modeCounter));
        posY = (1.5*cos(modeCounter));
        
        modeCounter = modeCounter + speed;
      }
      break;  
    case 3:
      // Vertical ting
      if (modeCounter <= 360)
      {
        posZ = (0.65*cos(modeCounter));
        
        modeCounter = modeCounter + speed;
      }
      break;  
    case 4:
      // Twist ting
      if (modeCounter <= 360)
      {
        rotZ = (1*sin(modeCounter));
        
        modeCounter = modeCounter + speed;
      }
      break;
    case 5:
      // Planar_Eight ting
      if (modeCounter <= 360)
      {
        posX = (1.2*sin(2*modeCounter));
        posY = (1.2*cos(modeCounter));
        
        modeCounter = modeCounter + speed;
      }
      break;
    case 6:
      // Spiral ting
      if (modeCounter <= 360)
      {
        posX = (radiusCounter*sin(modeCounter));
        posY = (radiusCounter*cos(modeCounter));
        
        modeCounter = modeCounter + speed;
        radiusCounter = radiusCounter + (0.002 * dir);
      }
      break; 
    case 7:
      // Helical ting
      if (modeCounter <= 360)
      {
        posX = (0.75*sin(modeCounter));
        posY = (0.75*cos(modeCounter));
        posZ = (0.6*cos(modeCounter/9));        
        
        modeCounter = modeCounter + speed;
      }
      break;
    case 8:
      // Vertical ting - RAPID
      if (modeCounter <= 360)
      {
        posZ = (0.125*cos(modeCounter));
        
        //rotY = (-0.1*cos(modeCounter*2.5));
        
        modeCounter = modeCounter + (speed*2.5);
      }
      break;
    case 9:
      // COMBO TING
      if (modeCounter <= 360)
      {
        switch (moveSelect) {
          case 0:  // Normal - middle
          rotX = 0;
          rotY = 0;
          posZ = (0.125*cos(modeCounter));
          modeCounter = modeCounter + (speed*2);
          break;
          
          case 1:  // LEFT
          rotX = (-0.05*cos(modeCounter));
          posZ = (0.125*cos(modeCounter));
          modeCounter = modeCounter + (speed*2);
          break;   
          
          case 2:  // RIGHT
          rotX = (0.05*cos(modeCounter));
          posZ = (0.125*cos(modeCounter));
          modeCounter = modeCounter + (speed*2);
          break;
          
          case 3:  // FORWARD
          rotY = (0.05*cos(modeCounter));
          posZ = (0.125*cos(modeCounter));
          modeCounter = modeCounter + (speed*2);
          break;    
          
          case 4:  // BACKWARD
          rotY = (-0.05*cos(modeCounter));
          posZ = (0.125*cos(modeCounter));
          modeCounter = modeCounter + (speed*2);
          break;             
          
          default:
          //NOTHING
          break;    
        }
      }
      break;       
    default:
      //NOTHING
      break;    
  }
  
  //DEBUG PRINTS
  //print("modeCounter: ");
  //println(modeCounter);
    
  // Ensure circle reset  
  if (modeCounter >= 360)
  {
    modeCounter = 0;
  }
  
  // For "COMBO ting" mode
  if ((floor(modeCounter) % 9) == 0)
  {
    if (storedMove == moveSelect)
    {
      //NOTHING
    }
    else
    {
      moveSelect++;
      storedMove = moveSelect;
    }
  }
  else
  {
    storedMove++;
  }
    
  //DEBUG PRINTS
  //print("moveSelect: ");
  //println(moveSelect);
   
  // Ensure moveSelect is reset  
  if (moveSelect > 4)
  {
    moveSelect = 0;
  }
  
  if (radiusCounter >= 1.5)
  {
//    println("Resetting radiusCounter");
//    radiusCounter = 0;
    dir = -1;
  }
  
  if (radiusCounter <= 0)
  {
    //println("Resetting radiusCounter");
    //radiusCounter = 0;
    dir = 1;
  }   
  
  hint(DISABLE_DEPTH_TEST);
  camera.beginHUD();
  cp5.draw();
  camera.endHUD();
  hint(ENABLE_DEPTH_TEST);  
}

void controlEvent(ControlEvent theEvent) {
  camera.setActive(false);
}
void mouseReleased() {
  camera.setActive(true);
}

// Codes that are activated by button presses --------------------
public void Reset(){
  println("Reset button pressed (modeSelect = 0)");
  
  posX=0; posY=0; posZ=0; rotX=0; rotY=0; rotZ=0; speed=0.01;  
  
  modeCounter = 0;
  modeSelect = 0;
}

public void Curve(){
  println("Curve button pressed (modeSelect = 1)");
  modeSelect = 1;
}

public void Combo(){
  println("Combo button pressed (modeSelect = 9)");
  modeSelect = 9;
}

public void Planar_Circle(){
  println("Planar_Circle button pressed (modeSelect = 2)");
  modeSelect = 2;  
}

public void Vertical(){
  println("Vertical button pressed (modeSelect = 3)");
  modeSelect = 3;  
}

public void Twist(){
  println("Twist button pressed (modeSelect = 4)");
  modeSelect = 4;  
}

public void Planar_Eight(){
  println("Planar_Eight button pressed (modeSelect = 5)");
  modeSelect = 5;  
}

public void Spiral(){
  println("Spiral button pressed (modeSelect = 6)");
  modeSelect = 6;  
}

public void Helical(){
  println("Helical button pressed (modeSelect = 7)");
  modeSelect = 7;  
}

public void RAPID(){
  println("RAPID button pressed (modeSelect = 8)");
  modeSelect = 8;  
}

//void mouseDragged () {
//  if (ctlPressed) {
//    posX = map(mouseX, 0, width, -1, 1);
//    posY = map(mouseY, 0, height, -1, 1);
//  }
//}

void mouseDragged () {
  if (ctlPressed) {
    posZ = map(mouseX, 0, width, -1, 1);
  }
}

void keyPressed() {
  if (key == ' ') {
    camera.setRotations(-1.0, 0.0, 0.0);
    camera.lookAt(8.0, -50.0, 80.0);
    camera.setDistance(666);
  } else if (keyCode == CONTROL) {
    camera.setActive(false);
    ctlPressed = true;
  }
}

void keyReleased() {
  if (keyCode == CONTROL) {
    camera.setActive(true);
    ctlPressed = false;
  }
}

//Called whenever there is activity on the serial port
void serialEvent(Serial myPort) {
counter++;
//put the incoming data into a String - 
//the '\n' is our end delimiter indicating the end of a complete packet
val = myPort.readStringUntil('\n');
//make sure our data isn't empty before continuing
if (val != null) {
  //trim whitespace and formatting characters (like carriage return)
  val = trim(val);
  print(counter );
  println(val);

  //look for our 'A' string to start the handshake
  //if it's there, clear the buffer, and send a request for data
  if (firstContact == false) {
    if (val.equals("A")) {
      myPort.clear();
      firstContact = true;
      myPort.write("A");
      println("contact");
    }
  }
  else 
  { //if we've already established contact, keep getting and parsing data
    
    //Get current angles for all servos
    float[] angles = mPlatform.getAlpha();
  
    //println(angles);
    //println("---------------");
    //delay(10);
  
    //Check not out of bounds
    for (float f : angles) {
      if (Float.isNaN(f)) {
        return;
      }
    }
    
    //Convert from radians to degrees
    float[] anglesDegrees = {0,0,0,0,0,0};
    for(int i = 0; i < 6; i++)
    {
      anglesDegrees[i] = degrees(angles[i]);
    }
      
    // Join all values together and create a string for sending
    String combinedAnglesString = join(nf(anglesDegrees, 0, 2), ", "); 
    //println(combinedAnglesString);   
    //delay(10);  
    
    //Send data back
    myPort.write(combinedAnglesString);
    myPort.write('\n');       
    }
  }
}
