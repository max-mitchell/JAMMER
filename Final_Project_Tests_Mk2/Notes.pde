public class Note {

  private double[] vals;
  private boolean play;
  private int button;


  public Note (double[] a, boolean b, int c) {
    vals = new double[a.length];
    for (int i = 0; i < vals.length; i++) {
      vals[i] = a[i];
    }
    play = b;
    button = c;
  }

  public double[] getSine() {
    return vals;
  }

  public boolean getStatus() {
    return play;
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

  public void setStatus(boolean b) {
    play = b;
  }

  public void setButton(int c) {
    button = c;
  }
}
