public class Note {

  private double[] vals;
  private RingBuffer buffer;
  private boolean atak, decay, sus, fade;
  private int state;
  private int count = 0;
  private int size;
  private int button;
  private float gain;
  private double freq;


  public Note (double[] a, double hz, int c) {
    buffer = new RingBuffer(a.length);
    for (int i = 0; i < a.length; i++) {
      buffer.enqueue(a[i]);
    }
    size = a.length;
    gain = 0;
    freq = hz;
    button = c;
    state = 0;
  }

  public String out() {
    return buffer.out();
  }


  public void load() {
    while (buffer.size () > 0) {
      buffer.dequeue();
    }
    for (int i = 0; i < size; i++) {
      buffer.enqueue(Math.sin(2 * Math.PI * i * freq / 44100.0));
    }
    //println("pluck  "+buffer.size());
  }

  public void tic() {
    count++;
    double f1;
    double toLast;

    buffer.dequeue();
    f1 = buffer.peek();


    toLast = f1;//Math.sin(2 * Math.PI * (last+1) * freq / 44100.0);
    buffer.enqueue(toLast);
  }

  public double sample() {
    return buffer.peek();
  }


  public double[] getSine() {
    return vals;
  }

  public int size() {
    return size;
  }

  public double getSine(int b) {
    return vals[b];
  }

  public int getStatus() {
    return state;
  }

  public float getGain() {
    return gain;
  }

  public int getButton() {
    return button;
  }

  public void setSine(double[] a) {
    vals = new double[a.length];
    for (int i = 0; i < vals.length; i++) {
      vals[i] = a[i];
    }
  }

  public void setSine(double a, int b) {
    if (b < vals.length) {
      vals[b] = a;
    }
  }

  public void setStatus(int b) {
    state = b;
  }

  public void setGain(float b) {
    gain = b;
  }

  public void setButton(int c) {
    button = c;
  }
}
