
/*************************************************************************
 * Name         : 
 * PennKey      : 
 * Recitation # :
 *
 * Dependencies :
 * Description  : 
 *  
 *  This is a template file for GuitarString.java. It lists the constructors
 *  and methods you need, along with descriptions of what they're supposed
 *  to do.
 *  
 *  Note: it won't compile until you fill in the constructors and methods
 *        (or at least commment out the ones whose return type is non-void).
 *
 *****************************************************************************/

public class GuitarString implements Music {

  private RingBuffer buffer; // ring buffer
  private int count = 0;
  private int size;
  private int button = 0;
  private float gain;
  private int status = 0;

  // create a guitar string of the given frequency
  public GuitarString(double frequency, int b) {
    buffer = new RingBuffer((int)(44100.0 / frequency)+1);
    size = (int)(44100.0 / frequency)+1;
    button = b;
  }

  // create a guitar string with size & initial values given by the array
  public GuitarString(double[] init) {
    buffer = new RingBuffer(init.length);
    for (int i = 0; i < init.length; i++) {
      buffer.enqueue(init[i]);
    }
  }

  public String out() {
    return buffer.out();
  }

  public int getStatus() {
    return status;
  }

  public void setStatus(int b) {
    status = b;
  }

  public float getGain() {
    return gain/5.0;
  }

  public void setGain(float b) {
    gain = b*5.0;
  }

  // pluck the guitar string by replacing the buffer with white noise
  public void pluck() {
    while (buffer.size () > 0) {
      buffer.dequeue();
    }
    for (int i = 0; i < size; i++) {
      buffer.enqueue((double)(random(-10, 10))/10.0);
    }
    //println("pluck  "+buffer.size());
  }

  // advance the simulation one time step
  public void tic() {
    count++;
    double f1;
    double f2;
    double toLast;

    f1 = buffer.peek();
    buffer.dequeue();
    f2 = buffer.peek();

    toLast = .5 * (f1+f2) * (double)map(size, 441, 0, .99, 1);//.994;
    buffer.enqueue(toLast);
  }

  // return the current sample
  public double sample() {
    return buffer.peek();
  }

  // return number of times tic was called
  public int time() {
    return count;
  }

  /* public static void main(String[] args) {
   int N = Integer.parseInt(args[0]);
   double[] samples = { .2, .4, .5, .3, -.2, .4, .3, .0, -.1, -.3 };  
   GuitarString testString = new GuitarString(samples);
   for (int i = 0; i < N; i++) {
   int t = testString.time();
   double sample = testString.sample();
   System.out.printf("%6d %8.4f\n", t, sample);
   testString.tic();
   }
   }*/
}
