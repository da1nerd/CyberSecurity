import traer.physics.*;

static int bubble_id_counter = 0;

class Bubble {
  final int BELOW_Z_PLANE = 0;
  final int ABOVE_Z_PLANE = 1000;
	
  private int _id;
  private Particle _p;
  private GraphFilter _gf;
  private float _xpos;
  private float _ypos;
  private int _size;
  private boolean _selected;
  
  public Bubble(Particle p, GraphFilter gf) {
    _id = bubble_id_counter++;
    _gf = gf;
    
    _p = p;
    
    _size = 100;
    
    _xpos = random(-200, 200);
    _ypos = random(-200, 200);
    
    _p.makeFixed();
    _p.position().set(_xpos, _ypos, BELOW_Z_PLANE);
    
    _selected = false;
  }
  
  // raise the bubble above everything else so we can select it
  public void raise() {
	_p.position().set(_xpos, _ypos, ABOVE_Z_PLANE);
  }
  
  // lower the bubble so that it lies beneath everything else
  public void lower() {
	_p.position().set(_xpos, _ypos, BELOW_Z_PLANE);
  }
  
  public int getID() {
    return _id;
  }
  
  public Particle getParticle() {
    return _p; 
  }
  
  public boolean isSelected() {
    return _selected;
  }
  
  public void setSelected() {
    _selected = true;
  }
  
  public void resetSelected() {
    _selected = false;
  }
  
  public int getSize() {
    return _size;
  }
  
  public GraphFilter getGraphFilter() {
    return _gf; 
  }
}

