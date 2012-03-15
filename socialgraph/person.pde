//
// Class holding one person
//
public class Person {
  
  private int _id;
  private String _name;
  private ArrayList _connections = new ArrayList<Integer>();
  private Particle _p;
  public boolean selected;

  public Person(int id, String name, ArrayList<Integer> con) {
    _id = id;
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
  
}
