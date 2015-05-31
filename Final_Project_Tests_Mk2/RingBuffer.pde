
/*************************************************************************
 * Name         : 
 * PennKey      : 
 * Recitation # :
 *
 * Dependencies :
 * Description  : 
 *  
 *  This is a template file for RingBuffer.java. It lists the constructors and
 *  methods you need, along with descriptions of what they're supposed to do.
 *  
 *  Note: it won't compile until you fill in the constructors and methods
 *        (or at least commment out the ones whose return type is non-void).
 *
 *****************************************************************************/

public class RingBuffer {
  private double[] rb;          // items in the buffer
  private int first;            // index for the next dequeue or peek
  private int last;             // index for the next enqueue
  private int size;             // number of items in the buffer

  // create an empty buffer, with given max capacity
  public RingBuffer(int capacity) {
    rb = new double[capacity];
    first = 0;
    last = 0;
    size = 0;
  }

  public String out() {
    String out = "";
    for (int i = 0; i < rb.length; i++) {
      out+=rb[i];
      if (i == last)
        out+=" (last)";
      if (i == first)
        out+=" (first)";
      out+=", ";
    } 
    return out;
  }

  public double[] getArray() {
    return rb;
  }

  // return number of items currently in the buffer
  public int size() {
    return size;
  }

  // is the buffer empty (size equals zero)?
  public boolean isEmpty() {
    if (size == 0)
      return true;
    return false;
  }

  // is the buffer full (size equals array capacity)?
  public boolean isFull() {
    if (size == rb.length)
      return true;
    return false;
  }

  // add item x to the end
  public void enqueue(double x) {
    if (isFull()) {
      throw new RuntimeException("Ring buffer overflow");
    }
    rb[last] = x;
    last++; 
    if (last == rb.length)
      last = 0;

    size++;
  }

  // delete and return item from the front
  public double dequeue() {
    if (isEmpty()) {
      throw new RuntimeException("Ring buffer underflow");
    }
    double x = rb[first];
    rb[first] = 0;
    if (size == rb.length)
      last = first;
    first++;
    if (first == rb.length)
      first = 0;
    size--;
    return x;
  }

  // return (but do not delete) item from the front
  public double peek() {
    if (isEmpty()) {
      throw new RuntimeException("Ring buffer underflow");
    }
    return rb[first];
  }
}
