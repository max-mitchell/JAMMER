import beads.*;
import java.util.*;
import processing.serial.*;
import cc.arduino.*;

ArrayList<WavePlayer> notes = new ArrayList<WavePlayer>();
AudioContext ac = new AudioContext();
Gain gain = new Gain(ac, 1, .3);
Clip dist = new Clip(ac, 1);

Arduino arduino;
Serial port;

int Tval = -1;
int Vval = -1;
int Pval = -1;
int last;
String in;
int inVal;
int timer = 1;
boolean[] buttons = new boolean[64];




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
boolean[] plays = new boolean[13];
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
  size(1000, 700);
  background(20, 70, 200);
  ac.out.addInput(gain);
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[2], 9600);
  port = new Serial(this, Arduino.list()[1], 9600);  
  arduino.pinMode(7, Arduino.INPUT);
  arduino.pinMode(4, Arduino.INPUT);
  arduino.pinMode(3, Arduino.INPUT);
  arduino.pinMode(2, Arduino.INPUT);
  arduino.pinMode(1, Arduino.INPUT);
  arduino.pinMode(0, Arduino.INPUT);
  arduino.pinMode(9, Arduino.OUTPUT);
  conor = loadImage("maliha.jpg");
}

void draw() {
  background(20, 70, 200);
  stroke(0);
  fill(0);
  rect(0, 300, 1000, 400);
  fill(255);
  rect(300, 0, 700, 300);
  fill(0);
  text((int)(16.35*pow((pitch/30.0)/12.0+octo, 2)), 500, 20);
  text(gain.getGain(), 500, 40);
  text(dist.getMaximum(), 500, 60);
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
  //distVal = arduino.analogRead(1);
  //LFOval = arduino.analogRead(0);
  
  println(pitch);

  if (createNote) {
    if (endIt == false) {
      for (int i = 0; i < plays.length; i++) {
        notes.add(new WavePlayer(ac, 0, Buffer.SINE));
      }
      for (int i = 0; i < place+plays.length; i++) {
        gain.removeAllConnections(notes.get(i));
      }
      for (int i = 0; i < plays.length; i++) {
        gain.addInput(notes.get(place+i));
      }

      dist.addInput(gain);
      println(gain.getIns());
      ac.start();
      createNote = false;
      endIt = true;
    } else if (endIt) {
      ac.stop();
      //notes.remove(place); 
      place++;
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



  distMax = map(distVal, 50, 300, 1, 0);
  distMin = -distMax;

  if (doLFO == false) {
    gainValue = map(vol, 300, 0, 0, .8);
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

        if (gain.getGain() < 0) {
          LFOdown = false;
        } else if (gain.getGain() > maxAmp) {
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

    for (int j = 0; j < plays.length; j++) {
      if (plays[j]) {
        notes.get(place+j).setFrequency(16.35*pow(((pitch/30.0)+(halfStep*(float)j))/12.0+octo, 2));
      } else
        notes.get(place+j).setFrequency(0);
    }

    gain.setGain(gainValue);
    dist.setRange(distMin, distMax);
    //}

    //if (endIt) {
    Set<UGen> waves = new HashSet<UGen>();
    waves = gain.getConnectedInputs();
    float[] hzs = new float[notes.size()];
    double ouPut = 0;
    for (int i = 0; i < notes.size (); i++) {
      for (Iterator<UGen> it = waves.iterator (); it.hasNext(); ) {
        UGen f = it.next();
        if (f.equals(notes.get(i))) {
          hzs[i] = notes.get(i).getFrequency();
        }
      }
    }
    int N = (int) (44100.00 * .1);
    double[] a1 = new double[N + 1];
    a2 = new double[N + 1];
    for (int i = 0; i <= N; i++) {
      for (int j = 0; j < hzs.length; j++) {
        a1[i] += (Math.sin(2 * Math.PI * i * hzs[j] / 44100.00) * gain.getGain());
      }
      if (distort) {
        if (a1[i] > distMax)
          a1[i] = distMax;
        else if (a1[i] < distMin)
          a1[i] = distMin;
      } 

      point(map(i, 0, N, 300, 1000), map((float)a1[i], -2, 2, 0, 300));
      //arduino.analogWrite(9, (int)map((float)a1[i], -1, 1, 0, 1024));
      //println((int)map((float)a1[i], -2, 2, 0, 1024));
    }

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











  if (port.available() > 0) {
    in = port.readString();

    //println(in);

    if (in.length() >= 6) {
      if (in.charAt(0) == 'T') {
        try {
          Tval = Integer.parseInt(in.substring(1, 5));
          last = Tval;
        } 
        catch (NumberFormatException e) {
          println("------\nERROR    " + in + "------");
        }
      }
    }
  }

  for (int i = 0; i < buttons.length; i++) {
    if (i == Tval) {
      buttons[i] = true;
    } else {
      buttons[i] = false;
    }
  }  





  float Vmapped = map(arduino.analogRead(0), 0, 1023, 0, 2*(float)Math.PI);
  float Pmapped = map(arduino.analogRead(3), 0, 1023, 0, 2*(float)Math.PI);

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
  text(Vval, 400, 350);
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
  text(Pval, 300, 350);
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
  rect(225, pitch, 25, 25);
  rect(275, vol, 25, 25);
  rect(325, distVal, 25, 25);
  rect(375, LFOval, 25, 25);
  rectMode(CORNER);
}

void mouseReleased() {
  if (mouseX < 150 && mouseX > 50 && mouseY < 150 && mouseY > 50) {
    createNote = true;
  } else if (mouseX < 100 && mouseX > 50 && mouseY < 250 && mouseY > 200) {
    if (distort) {
      distort = false;
      ac.out.removeAllConnections(dist);
      ac.out.addInput(gain);
    } else if (distort == false) {
      distort = true;
      ac.out.removeAllConnections(gain);
      ac.out.addInput(dist);
    }
  } else if (mouseX < 150 && mouseX > 100 && mouseY < 250 && mouseY > 200) {
    if (doLFO) 
      doLFO = false; 
    else {
      doLFO = true;
      maxAmp = gain.getGain();
      maxPit = 16.35*pow((pitch/30.0)/12.0+octo, 2);
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
    distVal = mouseY;
  } else  if (mouseX < 400 && mouseX > 350) {
    LFOval = mouseY;
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
    plays[0] = true;
  } else if (key == 'e') {
    plays[1] = true;
  } else if (key == 'd') {
    plays[2] = true;
  } else if (key == 'r') {
    plays[3] = true;
  } else if (key == 'f') {
    plays[4] = true;
  } else if (key == 'g') {
    plays[5] = true;
  } else if (key == 'y') {
    plays[6] = true;
  } else if (key == 'h') {
    plays[7] = true;
  } else if (key == 'u') {
    plays[8] = true;
  } else if (key == 'j') {
    plays[9] = true;
  } else if (key == 'i') {
    plays[10] = true;
  } else if (key == 'k') {
    plays[11] = true;
  } else if (key == 'l') {
    plays[12] = true;
  }
}

void keyReleased() {
  if (key == 's') {
    plays[0] = false;
  } else if (key == 'e') {
    plays[1] = false;
  } else if (key == 'd') {
    plays[2] = false;
  } else if (key == 'r') {
    plays[3] = false;
  } else if (key == 'f') {
    plays[4] = false;
  } else if (key == 'g') {
    plays[5] = false;
  } else if (key == 'y') {
    plays[6] = false;
  } else if (key == 'h') {
    plays[7] = false;
  } else if (key == 'u') {
    plays[8] = false;
  } else if (key == 'j') {
    plays[9] = false;
  } else if (key == 'i') {
    plays[10] = false;
  } else if (key == 'k') {
    plays[11] = false;
  } else if (key == 'l') {
    plays[12] = false;
  } else if (key == CODED) {
    if (keyCode == UP) {
      octo++;
    } else if (keyCode == DOWN) {
      octo--;
    }
  }
}
