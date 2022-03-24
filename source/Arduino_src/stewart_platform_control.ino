/*
 * Example showing how to send positions to multiple AX-12A motors
 */

#include "Project.h"
#include "Arduino.h"
#include "AX12A.h"

#define DEBUG_PRINTS 0

#define MOTOR_DIRECTION_PIN  10
#define MOTOR_BAUDRATE      1000000
#define MOTOR_1_ID    1     //Default direction = Left
#define MOTOR_2_ID    2     //Default direction = Right
#define MOTOR_3_ID    3     //Default direction = Left
#define MOTOR_4_ID    4     //Default direction = Right
#define MOTOR_5_ID    5     //Default direction = Left
#define MOTOR_6_ID    6     //Default direction = Right

#define NUMBER_OF_MOTORS  6

#define processing3 Serial3

String str; // Data received from the serial port

char *strings[6]; // an array of pointers to the pieces of data we dervie after strtok()
char *ptr = NULL;

float servoAngles[5] = {};
int scaledServoAngles[5] = {};

void setup()
{

  Serial.begin(115200);
  delay(1000); //To avoid initial garbage prints
  Serial.println("Application starting");

  Serial.print("Baud rate:");
  Serial.println(MOTOR_BAUDRATE);

  //Open connection with P3
  processing3.begin(500000);    

  //Open connection with servo "bus"
  ax12a.begin(MOTOR_BAUDRATE, MOTOR_DIRECTION_PIN, &Serial1); //TX1 - 18, RX1 - 19
  delay(1000);

  //Test basic connections to each motor
  for(int i = 1; i < NUMBER_OF_MOTORS+1; i++)
  {
    basicPingandStatus(i);
  }   
}

void basicPingandStatus(unsigned char MOTORID)
{
  Serial.println("------------------------------------------");
  
  //Test connection with ping
  if (ax12a.ping(MOTORID))
  {
      Serial.print("[ID:"); Serial.print(MOTORID);
      Serial.println("] ping Failed............... stopping here");
      while(1);        
  }
  else
  {
      Serial.print("[ID:"); Serial.print(MOTORID);
      Serial.println("] ping Succeeded! ");   

      // Turn on-board LED ON
      ax12a.ledStatus(MOTORID, ON);
  }

  delay(250);

  printEEPROMArea(MOTORID);
}

void printEEPROMArea(unsigned char ID_NUMBER)
{
  // Print entire EEPROM Area (https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/)
  
  Serial.print("AX_MODEL_NUMBER_L: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_MODEL_NUMBER_L, AX_DOUBLE_BYTE_READ));

  Serial.print("AX_VERSION: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_VERSION, AX_BYTE_READ));

  Serial.print("AX_ID: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_ID, AX_BYTE_READ));

  Serial.print("AX_BAUD_RATE: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_BAUD_RATE, AX_BYTE_READ));

  Serial.print("AX_RETURN_DELAY_TIME: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_RETURN_DELAY_TIME, AX_BYTE_READ));

  Serial.print("AX_CW_ANGLE_LIMIT_L: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_CW_ANGLE_LIMIT_L, AX_DOUBLE_BYTE_READ));

  Serial.print("AX_CCW_ANGLE_LIMIT_L: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_CCW_ANGLE_LIMIT_L, AX_DOUBLE_BYTE_READ));

  Serial.print("AX_LIMIT_TEMPERATURE: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_LIMIT_TEMPERATURE, AX_BYTE_READ));

  Serial.print("AX_DOWN_LIMIT_VOLTAGE: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_DOWN_LIMIT_VOLTAGE, AX_BYTE_READ));

  Serial.print("AX_UP_LIMIT_VOLTAGE: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_UP_LIMIT_VOLTAGE, AX_BYTE_READ));

  Serial.print("AX_MAX_TORQUE_L: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_MAX_TORQUE_L, AX_DOUBLE_BYTE_READ)); 

  Serial.print("AX_RETURN_LEVEL: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_RETURN_LEVEL, AX_BYTE_READ)); 

  Serial.print("AX_ALARM_LED: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_ALARM_LED, AX_BYTE_READ)); 

  Serial.print("AX_ALARM_SHUTDOWN: ");
  Serial.println(ax12a.readRegister(ID_NUMBER, AX_ALARM_SHUTDOWN, AX_BYTE_READ));                           

  delay(500);  
}

void loop()
{
#if DEBUG_PRINTS     
  digitalWrite(LED_BUILTIN, HIGH);    // turn the LED on (HIGH is the voltage level)
  delay(250);                         // wait for a 1/2 second
  digitalWrite(LED_BUILTIN, LOW);     // turn the LED off by making the voltage LOW
  delay(250);                         // wait for a 1/2 second
#endif

  clearInputBuffer(processing3);
  processing3.println("GIVE ME NEW DATA");
  delay(20);

  if (processing3.available()) 
  { //If data is available to read,

    //Data from P3 is passed as single String
    str = processing3.readStringUntil('\n');

    //Convert to cstring (arrayed char)
    char receivedChars[str.length() + 1] = {};
    strcpy(receivedChars, str.c_str());

    //Split the cstring using the ',' as separator 
    byte index = 0;
    ptr = strtok(receivedChars, ",");
    while (ptr != NULL)
    {
      strings[index] = ptr;
      index++;
      ptr = strtok(NULL, ",");
    }

    //Convert and assign the floats
    for(int i = 0; i < 6; i++)
    {
      servoAngles[i] = atof(strings[i]);
#if DEBUG_PRINTS      
      Serial.println(servoAngles[i]);
#endif      

      if ((i % 2) == 0) //if even number
      {
//        scaledServoAngles[i] = scale(servoAngles[i], -79, 91, 0, 410); //For right facing
        scaledServoAngles[i] = scale(servoAngles[i], -79, 91, 0, 512); //For right facing                
      }
      else
      {
//        scaledServoAngles[i] = scale(servoAngles[i], 91, -79, 614, 1023); //For left facing
        scaledServoAngles[i] = scale(servoAngles[i], 91, -79, 512, 1023); //For left facing        
      }
      
#if DEBUG_PRINTS
      Serial.print("Servo "); Serial.print(i+1); Serial.print(" scaled: ");
      Serial.println(scaledServoAngles[i]);
#endif

      ax12a.moveSpeed(i+1, scaledServoAngles[i], 250);               
    }     
  }

#if DEBUG_PRINTS
  Serial.println("----------- End of one loop -----------");
#endif     
  delay(20);
}

void clearInputBuffer(HardwareSerial port) {
  while (port.available() > 0) {
    port.read();
  }
}

//Derived from: https://writingjavascript.com/scaling-values-between-two-ranges
int scale(float value, float inMin, float inMax, int outMin, int outMax) {
  const float result = (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;

  if (result < outMin) {
    return outMin;
  } else if (result > outMax) {
    return outMax;
  }

  return int(result);
}
