import beads.*;
import java.util.*;
import processing.serial.*;
import cc.arduino.*;
import java.applet.*;
import java.io.*;
import java.net.*;
import javax.sound.sampled.*;

ArrayList<Note> notes = new ArrayList<Note>();
int[] timeAtPlay = new int[12];
boolean drumming = false;

Arduino arduino;
Serial port;

int Tval = -1;
int Vval = -1;
int Pval = -1;
int last;
String in;
String in2;
int inVal;
int timer = 0;
boolean[] buttons = new boolean[64];
boolean[] Wasbuttons = new boolean[64];
boolean lookBack = false;
String inBack = "";

float[] hzs;








final int SAMPLE_RATE = 44100;

final int BYTES_PER_SAMPLE = 2;                // 16-bit audio
final int BITS_PER_SAMPLE = 16;                // 16-bit audio
final double MAX_16_BIT = Short.MAX_VALUE;     // 32,767
final int SAMPLE_BUFFER_SIZE = 4096;


SourceDataLine line1;   // to play the sound
byte[] buffer;         // our internal buffer
int bufferSize = 0;    // number of samples currently in internal buffer
















int N = (int) (44100.00 * .1);


color hue1 = color(160);
color hue2 = color(160);
color hue3 = color(160);
boolean createNote = false;
boolean endIt = false;
int place = 0;
int pitch = 200;
int vol = 200;
float gainValue = 0;
float distMax, distMin = 0;
float distVal = 50;
float LFOval = 50;
float LFOmod = 0;
float maxAmp = 0;
float maxPit = 0;
boolean change = false;
float octo = 5;
boolean distort = false;
boolean doLFO = false;
boolean LFOdown = true;
int LFOmode = 1; //0 for Trem, 1 for Bass

PImage conor = new PImage();
int move = 0;
int m = 0;

boolean doTheThing = false;

double a2[];

double sendToArd = 0;
float halfStep = 0;
float stepCount = 12;

void setup() {
  begin();
  size(1000, 700);
  background(20, 70, 200);
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);  //other inputs
  port = new Serial(this, Arduino.list()[2], 9600);  //trellis
  conor = loadImage("maliha.jpg");
}

void draw() {
  timer++;
  background(20, 70, 200);
  stroke(0);
  fill(0);
  rect(0, 300, 1000, 400);
  fill(255);
  rect(300, 0, 700, 300);
  fill(0);
  text((int)(16.35*pow((pitch/30.0)/12.0+octo, 2)), 500, 20);
  text(gainValue, 500, 40);
  //text(dist.getMaximum(), 500, 60);
  text(LFOmod, 500, 80);



  if (mouseX < 150 && mouseX > 50 && mouseY < 150 && mouseY > 50) {
    hue1 = color(200);
  } else {
    hue1 = color(160);
  }

  if (mouseX < 100 && mouseX > 50 && mouseY < 250 && mouseY > 200) {
    hue2 = color(200);
  } else {
    hue2 = color(160);
  }


  if (mouseX < 150 && mouseX > 100 && mouseY < 250 && mouseY > 200) {
    hue3 = color(200);
  } else {
    hue3 = color(160);
  }

  LFOmod = map(LFOval, 0, 300, .1, 0);



  pitch = arduino.analogRead(3);
  vol = arduino.analogRead(0);
  distVal = arduino.analogRead(1);
  //LFOval = arduino.analogRead(0);


  if (createNote) {
    if (endIt == false) {
      for (int i = 0; i < 13; i++) {
        notes.add(new Note(new double[N+1], false, i));
      }
      createNote = false;
      endIt = true;
    } else if (endIt) {
      notes.clear();
      endIt = false;
      createNote = false;
    }
  }

  // if (arduino.digitalRead(7) == Arduino.HIGH) {
  //   //    /println("touched"+millis());
  //   change = true;
  // }

  // if (change) {
  //   //createNote = true;
  //   change = false;
  // }

  //arduino.tone(9, 500);

  //halfStep = 16.35*pow((pitch/30.0)/12+octo, 2) * 2 =  16.35*pow((pitch/30.0+halfStep*12.0)/12+octo, 2)

  halfStep = 1.0/stepCount * (sqrt(2) * sqrt(pow((pitch/30.0), 2.0)+stepCount*2 * (pitch/30.0) * octo+stepCount*stepCount * pow(octo, 2.0))-(pitch/30.0)-stepCount * octo);



  distMax = map(distVal, 0, 1024, 1, 0);
  distMin = -distMax;

  if (doLFO == false) {
    gainValue = map(vol, 1024, 0, 0, .8);
  }

  //println(distVal+"   "+distMax+"    "+distMin);

  if (endIt) {

    if (doLFO) {
      if (LFOmode == 0) {
        if (LFOdown) {
          gainValue -= LFOmod;
        } else if (LFOdown == false) {
          gainValue += LFOmod;
        }

        if (gainValue < 0) {
          LFOdown = false;
        } else if (gainValue > maxAmp) {
          LFOdown = true;
        }
      } else if (LFOmode == 1) {
        if (LFOdown) {
          pitch -= map(LFOval, 0, 300, 250, 0);
        } else if (LFOdown == false) {
          pitch += map(LFOval, 0, 300, 250, 0);
        }

        if (16.35*pow((pitch/30.0)/12.0+octo, 2) < 50) {
          LFOdown = false;
        } else if (16.35*pow((pitch/30.0)/12.0+octo, 2) > maxPit) {
          LFOdown = true;
          //pitch -= 101;
        }
      }
    }

    hzs = new float[notes.size()];

    for (int j = 0; j < 13; j++) {
      hzs[j] = (16.35*pow(((pitch/30.0)+(halfStep*(float)j))/12.0+octo, 2));
    }

    for (int m = 0; m < 13; m++) {
      if (notes.get(m).getStatus()) {
        double[] a1 = new double[N + 1];
        for (int i = 0; i <= N; i++) {
          for (int j = 0; j < notes.size(); j++) {
            //        if (i < N/4.0)
            //          y+=.0001;
            //        else 
            //          y-=.000025;
            a1[i] += (Math.sin(2 * Math.PI * i * hzs[j] / 44100.00) * gainValue);
          }
          //          if (distort) {
          //            if (a1[i] > distMax)
          //              a1[i] = distMax;
          //            else if (a1[i] < distMin)
          //              a1[i] = distMin;
          //          } 

          //point(map(i, 0, N, 300, 1000), map((float)a1[i], -2, 2, 0, 300));
          //arduino.analogWrite(9, (int)map((float)a1[i], -1, 1, 0, 1024));
          //println((int)map((float)a1[i], -2, 2, 0, 1024));
        }
        notes.get(m).setSine(a1);
      } //else
      //notes.get(j).setFrequency(0);
    }

    //    if (timer > timeAtPlay[0] + 120) {
    //      drumming = false;
    //      drums1.clear();
    //    }

    //    if (drumming == false) {
    //      //drums1.setValue(0);
    //    }
    //    drums1.setValue(gainValue);
    //dist.setRange(distMin, distMax);
    //}

    //if (endIt) {
    double[] a2 = new double[N + 1];

    for (int i = 0; i <= N; i++) {
      for (int j = 0; j < 13; j++) {
        a2[i]+=notes.get(j).getSine()[i];
      }
    }
    play(a2);

    //println(hz1);
    //createNote = true;
  }
  // arduino.tone(9, outPut);

  //if (doTheThing) {
  //  arduino.analogWrite(9, (int)map((float)a2[m], -1, 1, 0, 1024));
  //  m++;
  //  if (m >= a2.length) {
  //    m = 0;
  //  }


  //println(a2[m]);
  //}

  //  if (arduino.digitalRead(4) == Arduino.HIGH) {
  //    plays[7] = true;
  //  } else if (arduino.digitalRead(4) == Arduino.LOW) {
  //    plays[7] = false;
  //  }
  //
  //  if (arduino.digitalRead(3) == Arduino.HIGH) {
  //    plays[5] = true;
  //  } else if (arduino.digitalRead(3) == Arduino.LOW) {
  //    plays[5] = false;
  //  }
  //
  //  if (arduino.digitalRead(2) == Arduino.HIGH) {
  //    plays[4] = true;
  //  } else if (arduino.digitalRead(2) == Arduino.LOW) {
  //    plays[4] = false;
  //  }
  //
  //  if (arduino.digitalRead(1) == Arduino.HIGH) {
  //    plays[2] = true;
  //  } else if (arduino.digitalRead(1) == Arduino.LOW) {
  //    plays[2] = false;
  //  }
  //
  //  if (arduino.digitalRead(0) == Arduino.HIGH) {
  //    plays[0] = true;
  //  } else if (arduino.digitalRead(0) == Arduino.LOW) {
  //    plays[0] = false;
  //  }
  //println(arduino.digitalRead(4));











  /* if (port.available() > 0) {
   
   String tempIn = "";
   
   in = port.readString();
   
   
   if (in.length() == 4) {
   println(in+"  in");
   for (int i = 0; i < in.length(); i++) {
   if (in.substring(i, i+1).equals(null));
   else {
   tempIn += in.substring(i, i+1);
   }
   }
   Tval = Integer.parseInt(tempIn);
   } 
   
   if (lookBack) {
   for (int i = 0; i < in.length(); i++) {
   inBack += in.substring(i, i+1)+"";
   }
   lookBack = false;
   println(inBack+"    inBack");
   for (int i = 0; i < inBack.length(); i++) {
   if (inBack.substring(i, i+1).equals(null));
   else {
   tempIn += inBack.substring(i, i+1);
   }
   }
   Tval = Integer.parseInt(tempIn);
   }
   
   if (in.length() != 0 && in.length() < 4) {
   lookBack = true;
   inBack = in;
   }
   }
   
   for (int i = 0; i < buttons.length; i++) {
   if (i == Tval) {
   buttons[i] = true;
   Wasbuttons[i] = true;
   } else {
   if (timer % 20 == 0) {
   Wasbuttons[i] = false;
   buttons[i] = false;
   }
   }
   }  */





  float Vmapped = map(map(vol, 1024, 0, 0, .8), 0, .8, 0, 2*(float)Math.PI);
  float Pmapped = map((int)(16.35*pow((pitch/30.0)/12.0+octo, 2)), 0, 2000, 0, 2*(float)Math.PI);


  textAlign(CENTER);

  stroke(43, 153, 224);
  line(400, 380, 400, 370);
  for (float i = 0; i < Vmapped; i+=.01) {
    point(-30.0*sin(i) + 400, 30.0*cos(i) + 350);
  }

  for (float i = 0; i < Vmapped; i+=.01) {
    point(-20.0*sin(i) + 400, 20.0*cos(i) + 350);
  }

  line(-30.0*sin(Vmapped) + 400, 30.0*cos(Vmapped) + 350, 
  -20.0*sin(Vmapped) + 400, 20.0*cos(Vmapped) + 350);

  fill(43, 153, 224);
  text(map(vol, 1024, 0, 0, .8), 400, 350);
  text("Volume", 400, 315);


  line(300, 380, 300, 370);
  for (float i = 0; i < Pmapped; i+=.01) {
    point(-30.0*sin(i) + 300, 30.0*cos(i) + 350);
  }

  for (float i = 0; i < Pmapped; i+=.01) {
    point(-20.0*sin(i) + 300, 20.0*cos(i) + 350);
  }

  line(-30.0*sin(Pmapped) + 300, 30.0*cos(Pmapped) + 350, 
  -20.0*sin(Pmapped) + 300, 20.0*cos(Pmapped) + 350);

  fill(43, 153, 224);
  text((int)(16.35*pow((pitch/30.0)/12.0+octo, 2)), 300, 350);
  text("Pitch", 300, 315);

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
    rect(map(i-(16*x), 0, 15, 40, 450), 300+y, 20, 20);
  }



  stroke(0);
  fill(hue1);
  rect(50, 50, 100, 100);
  fill(hue2);
  rect(50, 200, 50, 50);
  fill(hue3);
  rect(100, 200, 50, 50);
  //image(conor, 50, 50, 100, 118);
  fill(160);
  rect(200, 0, 50, 300);
  rect(250, 0, 50, 300);
  rect(300, 0, 50, 300);
  rect(350, 0, 50, 300);
  fill(0);
  rectMode(CENTER);
  rect(225, map(pitch, 0, 1024, 0, 300), 25, 25);
  rect(275, map(vol, 0, 1024, 0, 300), 25, 25);
  rect(325, map(distVal, 0, 1024, 0, 300), 25, 25);
  rect(375, map(LFOval, 0, 1024, 0, 300), 25, 25);
  rectMode(CORNER);


  gainValue = 0;
}

void mouseReleased() {
  if (mouseX < 150 && mouseX > 50 && mouseY < 150 && mouseY > 50) {
    createNote = true;
  } else if (mouseX < 100 && mouseX > 50 && mouseY < 250 && mouseY > 200) {
    if (distort) {
      distort = false;
      //ac.out.removeAllConnections(dist);
      //ac.out.addInput(gain);
    } else if (distort == false) {
      //distort = true;
      //ac.out.removeAllConnections(gain);
      //ac.out.addInput(dist);
    }
  } else if (mouseX < 150 && mouseX > 100 && mouseY < 250 && mouseY > 200) {
    if (doLFO) 
      doLFO = false; 
    else {
      doLFO = true;
      //maxAmp = gain.getGain();
      //maxPit = 16.35*pow((pitch/30.0)/12.0+octo, 2);
      println(maxPit);
    }
  }
}

void mouseDragged() {
  if (mouseX < 250 && mouseX > 200) {
    pitch = mouseY;
  } else  if (mouseX < 300 && mouseX > 250) {
    vol = mouseY;
  } else  if (mouseX < 350 && mouseX > 300) {
    distVal = map(mouseY, 0, 1024, 0, 300);
  } else  if (mouseX < 400 && mouseX > 350) {
    LFOval = map(mouseY, 0, 1024, 0, 300);
  }
}

void mousePressed() {
  if (mouseX < 250 && mouseX > 200) {
    pitch = mouseY;
  } else if (mouseX < 300 && mouseX > 250) {
    vol = mouseY;
  }
}

void keyPressed() {
  if (key == 's') {
    notes.get(0).setStatus(true);
  } else if (key == 'e') {
    notes.get(1).setStatus(true);
  } else if (key == 'd') {
    notes.get(2).setStatus(true);
  } else if (key == 'r') {
    notes.get(3).setStatus(true);
  } else if (key == 'f') {
    notes.get(4).setStatus(true);
  } else if (key == 'g') {
    notes.get(5).setStatus(true);
  } else if (key == 'y') {
    notes.get(6).setStatus(true);
  } else if (key == 'h') {
    notes.get(7).setStatus(true);
  } else if (key == 'u') {
    notes.get(8).setStatus(true);
  } else if (key == 'j') {
    notes.get(9).setStatus(true);
  } else if (key == 'i') {
    notes.get(10).setStatus(true);
  } else if (key == 'k') {
    notes.get(11).setStatus(true);
  } else if (key == 'l') {
    notes.get(12).setStatus(true);
  }
}

void keyReleased() {
  if (key == 's') {
    notes.get(0).setStatus(false);
  } else if (key == 'e') {
    notes.get(1).setStatus(false);
  } else if (key == 'd') {
    notes.get(2).setStatus(false);
  } else if (key == 'r') {
    notes.get(3).setStatus(false);
  } else if (key == 'f') {
    notes.get(4).setStatus(false);
  } else if (key == 'g') {
    notes.get(5).setStatus(false);
  } else if (key == 'y') {
    notes.get(6).setStatus(false);
  } else if (key == 'h') {
    notes.get(7).setStatus(false);
  } else if (key == 'u') {
    notes.get(8).setStatus(false);
  } else if (key == 'j') {
    notes.get(9).setStatus(false);
  } else if (key == 'i') {
    notes.get(10).setStatus(false);
  } else if (key == 'k') {
    notes.get(11).setStatus(false);
  } else if (key == 'l') {
    notes.get(12).setStatus(false);
  } else if (key == CODED) {
    if (keyCode == UP) {
      octo++;
    } else if (keyCode == DOWN) {
      octo--;
    }
  }
}


void begin() {
  try {
    // 44,100 samples per second, 16-bit audio, mono, signed PCM, little Endian
    AudioFormat format = new AudioFormat((float) SAMPLE_RATE, BITS_PER_SAMPLE, 1, true, false);
    DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);

    line1 = (SourceDataLine) AudioSystem.getLine(info);
    line1.open(format, SAMPLE_BUFFER_SIZE * BYTES_PER_SAMPLE);

    // the internal buffer is a fraction of the actual buffer size, this choice is arbitrary
    // it gets divided because we can't expect the buffered data to line up exactly with when
    // the sound card decides to push out its samples.
    buffer = new byte[SAMPLE_BUFFER_SIZE * BYTES_PER_SAMPLE/3];
  } 
  catch (Exception e) {
    System.out.println(e.getMessage());
    System.exit(1);
  }

  // no sound gets made before this call
  line1.start();
}


void play(double in) {

  // clip if outside [-1, +1]
  if (in < -1.0) in = -1.0;
  if (in > +1.0) in = +1.0;

  // convert to bytes
  short s = (short) (MAX_16_BIT * in);
  buffer[bufferSize++] = (byte) s;
  buffer[bufferSize++] = (byte) (s >> 8);   // little Endian

  // send to sound card if buffer is full        
  if (bufferSize >= buffer.length) {
    line1.write(buffer, 0, buffer.length);
    bufferSize = 0;
  }
}

void play(double[] input) {
  for (int i = 0; i < input.length; i++) {
    play(input[i]);
  }
}
