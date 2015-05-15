
import processing.serial.*;

import cc.arduino.*;

Serial port;
Arduino arduino;

color off = color(4, 79, 111);
color on = color(84, 145, 158);

int Tval = -1;
int Vval = -1;
int Pval = -1;
int last;
String in;
int inVal;
int timer = 1;

boolean eState = false;

boolean[] buttons = new boolean[64];

int[] values = { 
  Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, 
  Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, 
  Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW
};

void setup() {
  size(500, 400);
  textAlign(CENTER);
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

  if (port.available() > 0) {
    in = port.readString();

    println(in);

    if (in.length() >= 6) {
      if (in.charAt(0) == 'T') {
        try {
          Tval = Integer.parseInt(in.substring(1, 5));
          last = Tval;
        } 
        catch (NumberFormatException e) {
          println("------\nERROR    " + in + "------");
          if (buttons[last] == true) {
            buttons[last] = false;
          } else
            eState = true;
        }
      } else if (in.charAt(0) == 'V') {
        Vval = Integer.parseInt(in.substring(1, 5));
      } else if (in.charAt(0) == 'P') {
        Pval = Integer.parseInt(in.substring(1, 5));
      }
    }
  }


  if (eState == false) {
    if (Tval > -1) {
      if (buttons[Tval]) {
        buttons[Tval] = false;
      } else {
        buttons[Tval] = true;
      }
    }
  } else {
    if (Tval != -1)
      eState = false;
  }

  float Vmapped = map(Vval, 0, 1023, 0, 2*(float)Math.PI);
  float Pmapped = map(Pval, 0, 1023, 0, 2*(float)Math.PI);

  stroke(43, 153, 224);
  line(400, 80, 400, 70);
  for (float i = 0; i < Vmapped; i+=.01) {
    point(-30.0*sin(i) + 400, 30.0*cos(i) + 50);
  }

  for (float i = 0; i < Vmapped; i+=.01) {
    point(-20.0*sin(i) + 400, 20.0*cos(i) + 50);
  }

  line(-30.0*sin(Vmapped) + 400, 30.0*cos(Vmapped) + 50, 
  -20.0*sin(Vmapped) + 400, 20.0*cos(Vmapped) + 50);

  fill(43, 153, 224);
  text(Vval, 400, 50);
  text("Volume", 400, 15);


  line(300, 80, 300, 70);
  for (float i = 0; i < Pmapped; i+=.01) {
    point(-30.0*sin(i) + 300, 30.0*cos(i) + 50);
  }

  for (float i = 0; i < Pmapped; i+=.01) {
    point(-20.0*sin(i) + 300, 20.0*cos(i) + 50);
  }

  line(-30.0*sin(Pmapped) + 300, 30.0*cos(Pmapped) + 50, 
  -20.0*sin(Pmapped) + 300, 20.0*cos(Pmapped) + 50);

  fill(43, 153, 224);
  text(Pval, 300, 50);
  text("Pitch", 300, 15);

  noStroke();

  Tval = -1;

  int y = 150;
  int x = -1;
  for (int i = 0; i < buttons.length; i++) {

    if (i % 16 == 0) {
      y+=50;
      x++;
    }
    if (buttons[i])
      fill(255);
    else 
      fill(50);
    rect(map(i-(16*x), 0, 15, 50, width-50), y, 20, 20);
  }

  //println(val); //print it out in the console
}


void keyReleased() {
  if (key == '1') {
    port.write("T0001X");
  } else if (key == '2') {
    port.write("T0002X");
  } else if (key == '3') {
    port.write("T0003X");
  } else if (key == '4') {
    port.write("T0004X");
  } else if (key == '5') {
    port.write("T0005X");
  }
}
