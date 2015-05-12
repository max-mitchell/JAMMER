
import processing.serial.*;

import cc.arduino.*;

Serial port;
Arduino arduino;

color off = color(4, 79, 111);
color on = color(84, 145, 158);

int val;
int timer = 1;

int[] values = { 
  Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, 
  Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, 
  Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW
};

void setup() {
  size(470, 200);
  println(Arduino.list());
  //arduino = new Arduino(this, Arduino.list()[1], 9600);
  port = new Serial(this, Arduino.list()[1], 9600);

  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);

  // Set the Arduino digital pins as outputs.
  //for (int i = 0; i <= 13; i++)
  // arduino.pinMode(i, Arduino.OUTPUT);
}

void draw() {

  background(0);

  //val = port.readStringUntil("/n");        // read it and store it in val

//  for (int i = 0; i <= 9; i++) {
//    port.write(i+48);
//    //port.read();
//
//    while (timer < 30) {
//      timer++;
//    }
//    timer = 1;
//  }


     text((int)(port.read()-'0'), 100+5*port.read(), 100); 

  //println(val); //print it out in the console
}


void keyReleased(){
 if (key == '1'){
  port.write('T1');
 } 
  
}
