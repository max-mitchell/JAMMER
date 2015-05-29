public class Note {

  private double[] vals;
  private boolean atak, decay, sus, fade;
  private int state;
  private int button;
  private float gain;


  public Note (double[] a, int c) {
    vals = new double[a.length];
    for (int i = 0; i < vals.length; i++) {
      vals[i] = a[i];
    }
    gain = 0;
    button = c;
    state = 0;
  }

  public double[] getSine() {
    return vals;
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

