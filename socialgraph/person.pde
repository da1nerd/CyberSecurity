//
// Class holding one person
//
public class Person {
  
  private int _id;
  private String _name;
  private ArrayList<Connection> _connections = new ArrayList<Connection>();
  private Particle _p;
  private int _degree;
  private float _draw_size;
  private int _bubble_id;
  
  public boolean selected;

  public Person(int id, int degree, String name, ArrayList<Connection> con) {
    _id = id;
    _degree = degree;
    _name = name;
    _connections = con;
    selected = false;
    _bubble_id = -1;
    
    _draw_size = sqrt(6 * _degree);
  }
  
  public String getName() {
    return _name; 
  }
  
  public int getID() {
    return _id;
  }
  
  public void setParticle(Particle p) {
    _p = p; 
  }
  
  public Particle getParticle() {
    return _p;
  }
  
  public ArrayList<Connection> getConnections() {
    return _connections;
  }
  
  public int getDegree() {
    return _degree;
  }
  
  public float getNodeDrawSize() {
    return _draw_size; 
  }
  
  public void setBubbleID(int bubble_id) {
    _bubble_id = bubble_id;
  }
  
  public int getBubbleID() {
    return _bubble_id;
  }
  
}
