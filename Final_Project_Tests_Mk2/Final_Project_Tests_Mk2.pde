import java.util.*;
import processing.serial.*;
import cc.arduino.*;
import java.applet.*;
import java.io.*;
import java.net.*;
import javax.sound.sampled.*;

ArrayList<Music> notes = new ArrayList<Music>();
ArrayList<Music> strings = new ArrayList<Music>();
ArrayList<Double> rec = new ArrayList<Double>();
ArrayList<Double[]> stored = new ArrayList<Double[]>();
ArrayList<Boolean> stoPlay = new ArrayList<Boolean>();
ArrayList<Integer> playCount = new ArrayList<Integer>();
int[] timeAtPlay = new int[12];
boolean drumming = false;

boolean recording = false;
int recCount = 0;

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

double lastSamp = 0;








final int SAMPLE_RATE = 44100;

final int BYTES_PER_SAMPLE = 2;                // 16-bit audio
final int BITS_PER_SAMPLE = 16;                // 16-bit audio
final double MAX_16_BIT = Short.MAX_VALUE;     // 32,767
final int SAMPLE_BUFFER_SIZE = 4096;


SourceDataLine line1;   // to play the sound
byte[] buffer;         // our internal buffer
int bufferSize = 0;    // number of samples currently in internal buffer
double noteTime = .03;
int N = (int) (44100.00 * noteTime);



int soundMode = 0;

float stringFade = .99;


color hue1 = color(160);
color hue2 = color(160);
color hue3 = color(160);
color stro1 = color(220);
color stro2 = color(220);
color stro3 = color(220);
color stro4 = color(220);
boolean createNote = true;
boolean endIt = false;
int place = 0;
int pitch = 200;
int vol = 200;
float gainValue = 0;
float distMax, distMin = 0;
float distVal = 50;
float LFOval = 50;
float LFOlow = .3;
float LFOmod = 0;
boolean LFOdown = false;
float maxAmp = 0;
float maxPit = 0;
boolean change = false;
float octo = 0;
boolean distort = false;
boolean doLFO = false;
int LFOmode = 0; //0 for Trem, 1 for Bass

PImage conor = new PImage();
int move = 0;
int m = 0;

boolean doTheThing = false;

double a2[];

String keyboard = "q2we4r5ty7u8i9op-[=zxdcfvgbnjmk,.;/' ";
String nums = "1234567890";

double sendToArd = 0;
float halfStep = 0;
float stepCount = 12;

void setup() {
  begin();
  size(1000, 700);
  background(21, 190, 22);
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);  //other inputs
  port = new Serial(this, Serial.list()[2], 9600);  //trellis
  //conor = loadImage("maliha.jpg");
  //frameRate(200);
}

void draw() {
  timer++;
  background(21, 190, 22);
  stroke(0);
  fill(0);
  rect(0, 300, 1000, 400);
  fill(255);
  rect(300, 0, 700, 300);
  fill(0);
  text((440.0+pitch)*pow(1.05956, (12*octo)-12), 500, 20);
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


  LFOmod = map(LFOval, 0, 1024, .5, 0);



  pitch = arduino.analogRead(0);
  vol = arduino.analogRead(1);
  //distVal = arduino.analogRead(2);
  //LFOval = arduino.analogRead(3);
  //stringFade = map(arduino.analogRead(4), 0, 1024, .99, 1.0);
  //LFOlow = map(arduino.analogRead(5), 0, 1024, .5, 0);


  if (createNote) {
    if (endIt == false) {

      hzs = new float[16];

      for (int j = 0; j < hzs.length; j++) {
        hzs[j] = (440.0+pitch)*pow(1.05956, j-12);//((pitch/30.0)+(halfStep*(float)j))/12.0, 2));
      }

      for (int i = 0; i < 16; i++) {
        notes.add(new Note(new double[(int)(44100.0/hzs[i])+1], hzs[i], i));
        notes.get(i).pluck();
        strings.add(new GuitarString(hzs[i], i, stringFade));
        strings.get(i).pluck();
        //println(notes.get(i).out());
      }




      /*for (int i = 0; i <= N; i++) {
       for (int j = 0; j < 13; j++) {
       notes.get(j).setSine(Math.sin(2 * Math.PI * i * hzs[j] / 44100.0), i);
       if (i == 0)
       println(notes.get(j).getSine(i)+"  at 0");
       else if (i == N)
       println(notes.get(j).getSine(i)+"  at "+N);
       }
       }*/


      createNote = false;
      endIt = true;
    } else if (endIt) {
      notes.clear();
      endIt = false;
      createNote = false;
    }
  }

  // *don't do away with*  halfStep = 16.35*pow((pitch/30.0)/12+octo, 2) * 2 =  16.35*pow((pitch/30.0+halfStep*12.0)/12+octo, 2)

  halfStep = 1.0/stepCount * (sqrt(2) * sqrt(pow((pitch/30.0), 2.0)+stepCount*2 * (pitch/30.0) * octo+stepCount*stepCount * pow(octo, 2.0))-(pitch/30.0)-stepCount * octo);



  distMax = map(distVal, 0, 1024, 1, 0);

  if (doLFO == false) {
    gainValue = map(vol, 1024, 0, 0, .8);
  } else {
    maxAmp =  map(vol, 1024, 0, 0, .8);
  }


  if (endIt) {

    //println(soundMode);


    hzs = new float[16];

    for (int j = 0; j < hzs.length; j++) {
      hzs[j] = (440.0+pitch)*pow(1.05956, (j+12*octo)-12);//(440.0*pow(((pitch/30.0)+(halfStep*(float)j))/12.0+octo, 2));
    }



    if (doLFO) {
      if (LFOmode == 0) {
        if (LFOdown) {
          gainValue -= LFOmod;
        } else if (LFOdown == false) {
          gainValue += LFOmod;
        }

        if (gainValue < LFOlow) {
          LFOdown = false;
          gainValue = LFOlow;
        } else if (gainValue > maxAmp) {
          LFOdown = true;
          gainValue = maxAmp;
        }
      }
    }

    for (int m = 0; m < notes.size (); m++) {





      if (strings.get(m).getStatus() == 1) {
        strings.set(m, new GuitarString(hzs[m], m+16, stringFade));
        strings.get(m).pluck();
        strings.get(m).setStatus(3);
        strings.get(m).setGain(gainValue);
      }


      //


      else if (strings.get(m).getStatus() == 3) {
        if (doLFO)
          notes.get(m).setGain(gainValue);
      }

      if (notes.get(m).getStatus() == 1) {
        notes.set(m, new Note(new double[(int)(44100.0/hzs[m])+1], hzs[m], m));
        notes.get(m).pluck();
        notes.get(m).setStatus(10);
      }

      //


      else if (notes.get(m).getStatus() == 10) {
        notes.get(m).setGain(notes.get(m).getGain()+gainValue*.4);
        if (notes.get(m).getGain() >= gainValue+gainValue*.2)
          notes.get(m).setStatus(2);
      }


      //


      else if (notes.get(m).getStatus() == 2) {
        notes.get(m).setGain(notes.get(m).getGain()-gainValue*.2);
        if (notes.get(m).getGain() <= gainValue)
          notes.get(m).setStatus(3);
      }


      //


      else if (notes.get(m).getStatus() == 3) {
        notes.get(m).setGain(gainValue);
      } 

      //

      else if (notes.get(m).getStatus() == 4) {
        notes.get(m).setGain(notes.get(m).getGain()-gainValue*.3);
        if (notes.get(m).getGain() <= 0) {
          notes.get(m).setStatus(0);
          notes.get(m).setGain(0);
        }
      }


      //


      else if (notes.get(m).getStatus() == 0) {
        if (soundMode == 0)
          notes.get(m).setGain(0);
      }


      //

      // println(notes.get(m).getStatus());
    }




    for (int i = 0; i <= N; i++) {
      double a2 = 0;
      for (int m = 0; m < notes.size (); m++) {

        if (distort) {
          if ((notes.get(m).sample() * notes.get(m).getGain()) > distMax) {
            a2+=distMax;
          } else if ((notes.get(m).sample() * notes.get(m).getGain()) < -distMax) {
            a2+=-distMax;
          } else 
            a2+=notes.get(m).sample() * notes.get(m).getGain();



          if (strings.get(m).sample() * strings.get(m).getGain() > distMax) {
            a2+=distMax;
          } else if (strings.get(m).sample() * strings.get(m).getGain() < -distMax) {
            a2+=-distMax;
          } else 
            a2+=strings.get(m).sample() * strings.get(m).getGain();
        } else {
          a2+=notes.get(m).sample() * notes.get(m).getGain();
          a2+=strings.get(m).sample() * strings.get(m).getGain();
        }
      }

      for (int j = 0; j < stored.size (); j++) {
        if (stoPlay.get(j) == true) {
          if (i+playCount.get(j) < stored.get(j).length) {
            a2+=stored.get(j)[i+playCount.get(j)];
          } else {
            stoPlay.set(j, false);
            break;
          }
        }
      }



      play(a2);

      if (recording) {
        rec.add(a2);
      }

      if (i % 5 == 0 && i > 0) {
        line(map(i, 0, N, 300, 1000), map((float)a2, -1, 1, 0, 300), 
        map(i-5, 0, N, 300, 1000), map((float)lastSamp, -1, 1, 0, 300));

        lastSamp = a2;
      }

      for (int m = 0; m < notes.size (); m++) {
        notes.get(m).tic();
        strings.get(m).tic();
      }
      //println(notes.get(12).out());
    }
    for (int j = 0; j < stored.size (); j++) {
      if (stoPlay.get(j) == true) {
        playCount.set(j, playCount.get(j)+N);
      }
    }



    if (port.available() > 0) {
      in = port.readString();
      String tempIn = "";
      //println(in + "|" + in.length());
      for (int i = 0; i < in.length (); i++) {
        if (nums.indexOf(in.charAt(i)) != -1) {
          tempIn+=in.substring(i, i+1);
        }
      }
      if (tempIn.length() == 2) {
        Tval = Integer.parseInt(tempIn);
      }
    }
  }

  for (int i = 0; i < buttons.length; i++) {
    if (i == Tval) {
      buttons[i] = true;
      Wasbuttons[i] = true;
    } else {
      if (timer % 4 == 0) {
        if (Wasbuttons[i])
          Wasbuttons[i] = false;
        else
          buttons[i] = false;
      }
    }
  }





  float Vmapped = map(gainValue, 0, .8, 0, 2*(float)Math.PI);
  float Pmapped = map(440.0*pow(1.05956, (12*octo)-12), 0, 2000, 0, 2*(float)Math.PI);


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
  text(gainValue, 400, 350);
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
  text((int)(440.0*pow(1.05956, (12*octo)-12)), 300, 350);
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
    if (endIt) {
      if (buttons[i]) {
        if (i < 16) {
          if (notes.get(i).getStatus() == 0 || notes.get(i).getStatus() == 4)
            notes.get(i).setStatus(1);
        } else if (i < 32) {
          if (strings.get(i-16).getStatus() == 0 || strings.get(i-16).getStatus() == 4)
            strings.get(i-16).setStatus(1);
        } else if (i < 32 + stored.size()) {
          stoPlay.set(i-32, true);
          playCount.set(i-32, 0);
        }
        fill(255);
      } else {
        if (i < 16) {
          notes.get(i).setStatus(4);
        } else if (i < 32) {
          strings.get(i-16).setStatus(4);
        }
        fill(50);
      }
    } else 
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
  text("On/Off", 100, 100);
  text("Distort", 75, 225);
  text("Tremolo", 125, 225);
  rectMode(CENTER);
  stroke(220);
  rect(225, map(pitch, 0, 1024, 0, 300), 25, 25);
  rect(275, map(vol, 0, 1024, 0, 300), 25, 25);
  rect(325, map(distVal, 0, 1024, 0, 300), 25, 25);
  rect(375, map(LFOval, 0, 1024, 0, 300), 25, 25);
  stroke(0);
  rectMode(CORNER);
  if (recording)
    fill(255, 0, 0);
  else 
    fill(0);
  ellipse(40, 330, 20, 20);
  text("REC", 65, 330);
  if (doLFO)
    fill(0, 0, 255);
  else 
    fill(21, 190, 22);
  ellipse(160, 225, 10, 10);
  if (distort)
    fill(0, 0, 255);
  else 
    fill(21, 190, 22);
  ellipse(40, 225, 10, 10);
  if (endIt)
    fill(255, 0, 0);
  else 
    fill(21, 190, 22);
  ellipse(40, 60, 10, 10);
}

void mouseReleased() {
  if (mouseX < 150 && mouseX > 50 && mouseY < 150 && mouseY > 50) {
    createNote = true;
  } else if (mouseX < 100 && mouseX > 50 && mouseY < 250 && mouseY > 200) {
    if (distort) {
      distort = false;
    } else if (distort == false) {
      distort = true;
    }
  } else if (mouseX < 150 && mouseX > 100 && mouseY < 250 && mouseY > 200) {
    if (doLFO) 
      doLFO = false; 
    else {
      doLFO = true;
      maxAmp = gainValue;
      maxPit = (440.0+pitch)*pow(1.05956, (12*octo)-12);
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

void mouseWheel(MouseEvent event) {
  float a = event.getCount();
  if (mouseX < 250 && mouseX > 200) {
    if (a >= 0) 
      pitch += 50;
    else 
      pitch -= 50;
  } else  if (mouseX < 300 && mouseX > 250) {
    if (a >= 0) 
      vol += 50;
    else 
      vol -= 50;
  } else  if (mouseX < 350 && mouseX > 300) {
    if (a >= 0) 
      distVal += 50;
    else 
      distVal -= 50;
  } else  if (mouseX < 400 && mouseX > 350) {
    if (a >= 0) 
      LFOval += 50;
    else 
      LFOval -= 50;
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
  if (keyboard.indexOf(key) != -1) {
    if (soundMode == 0) {
      if (notes.get(keyboard.indexOf(key)).getStatus() == 0 || notes.get(keyboard.indexOf(key)).getStatus() == 4)
        notes.get(keyboard.indexOf(key)).setStatus(1);
    } else if (soundMode == 1) {
      if (notes.get(keyboard.indexOf(key)).getStatus() == 0 || notes.get(keyboard.indexOf(key)).getStatus() == 4)
        notes.get(keyboard.indexOf(key)).setStatus(1);
    }
  } else if (key == '!') {
    stoPlay.set(0, true);
    playCount.set(0, 0);
  } else if (key == '@') {
    stoPlay.set(1, true);
    playCount.set(1, 0);
  } else if (key == '#') {
    stoPlay.set(2, true);
    playCount.set(2, 0);
  }
}

void keyReleased() {
  if (keyboard.indexOf(key) != -1) {
    if (soundMode == 0) {
      notes.get(keyboard.indexOf(key)).setStatus(4);
    } else if (soundMode == 1) { 
      notes.get(keyboard.indexOf(key)).setStatus(4);
    }
  } else if (key == '?') {
    if (recording) {
      recording = false;
      stored.add(new Double[rec.size()]);
      stoPlay.add(false);
      playCount.add(0);
      for (int i = 0; i < rec.size (); i++) {
        stored.get(recCount)[i] = rec.get(i);
      }
      recCount++;
      rec.clear();
    } else {
      recording = true;
    }
  } else if (key == CODED) {
    if (keyCode == UP) {
      octo++;
    } else if (keyCode == DOWN) {
      octo--;
    } else if (keyCode == ALT) {
      if (soundMode == 0)
        soundMode = 1;
      else 
        soundMode = 0;
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
