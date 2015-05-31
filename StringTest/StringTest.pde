import java.util.*;
import processing.serial.*;
import cc.arduino.*;
import java.applet.*;
import java.io.*;
import java.net.*;
import javax.sound.sampled.*;



//from
//http://www.cis.upenn.edu/~cis110/13sp/hw/hw07/guitar.shtml



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


GuitarString[] strings = new GuitarString[37];

String keyboard = "q2we4r5ty7u8i9op-[=zxdcfvgbnjmk,.;/' ";



void setup() {
  begin();

  strings[0] = new GuitarString(110.0);
  strings[0].pluck();
  double startPitch = 110.0;

  for (int i = 1; i < strings.length; i++) {
    startPitch *= Math.pow(2, 1.0/12.0);
    strings[i] = new GuitarString(startPitch);
    strings[i].pluck();
  }

  RingBuffer buffer = new RingBuffer(10);
  for (int i = 1; i <= 10; i++) {
    buffer.enqueue(i);
  }
  //println(buffer.out());
  double t = buffer.dequeue();
  buffer.enqueue(t);
  //println(buffer.out());
  println("Size after wrap-around is " + buffer.size());
  while (buffer.size () >= 2) {
    double x = buffer.dequeue();
    double y = buffer.dequeue();
    buffer.enqueue(x + y);
  }
  //println(buffer.out());
  println(buffer.peek());



  double[] samples = { 
    .2, .4, .5, .3, -.2, .4, .3, .0, -.1, -.3
  };  
  GuitarString testString = new GuitarString(samples);
  for (int i = 0; i < 25; i++) {
    int r = testString.time();
    double sample = testString.sample();
    System.out.printf("%6d %8.4f\n", r, sample);
    testString.tic();
  }
}


void draw() {
  // compute the superposition of samples
  for (int i = 0; i < N; i++) {
    double sample = 0;
    for (int m = 0; m < strings.length; m++) {
      sample += strings[m].sample();
    }
    play(sample);

    for (int m = 0; m < strings.length; m++) {
      strings[m].tic();
    }
  }
}


void keyPressed() {
  if (keyboard.indexOf(key) != -1)
    strings[keyboard.indexOf(key)].pluck();
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
