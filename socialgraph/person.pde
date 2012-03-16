//
// Class holding one person
//
public class Person {
  
  private int _id;
  private String _name;
  private ArrayList _connections = new ArrayList<Integer>();
  private Particle _p;
  private int _degree;
  
  public boolean selected;

  public Person(int id, int degree, String name, ArrayList<Integer> con) {
    _id = id;
		_degree = degree;
    _name = name;
    _connections = con;
    selected = false;
  }
  
  public int getID() {
    return _id;
  }
  
  public Particle getParticle() {
    return _p;
  }
  
  public ArrayList<Integer> getConnections() {
    return _connections;
  }
  
  public int getDegree() {
    return _degree;
  }
  
}
