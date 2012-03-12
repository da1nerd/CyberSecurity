import traer.physics.*;

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

//
// dummy network
//
void createDummyNetwork() {
  network.clearNetwork();
  Iterator itr = dbm.peopleWithConnections(25,35, false).iterator();
  
  while(itr.hasNext()) {
    network.addPerson((Person)itr.next());
  }
  
  
 /*   
  network.addPerson( new Person(1, "aaa", new ArrayList( Arrays.asList(2, 3) ) ) );
  network.addPerson( new Person(2, "bbb", new ArrayList( Arrays.asList(1) ) ) );
  network.addPerson( new Person(3, "ccc", new ArrayList( Arrays.asList(2, 1) ) ) );
  
  network.addPerson( new Person(4, "ddd", new ArrayList( Arrays.asList(6) ) ) );
  network.addPerson( new Person(5, "ddd", new ArrayList( Arrays.asList(3,4,5) ) ) );
  network.addPerson( new Person(6, "ddd", new ArrayList( Arrays.asList(1) ) ) );
  */
}

void addRandomNode() {
  ArrayList links = new ArrayList<Integer>();
  int num_links = (int)random( 1, network.persons.size() );
  num_links = num_links > 5 ? 5 : num_links;
  
  for(int i = 0; i < num_links; ++i)
  {
    int link_to = 0;
    boolean again = false;
    do {
      link_to = (int)random( 0, network.persons.size() );
      again = false;
      for(int j = 0; j < links.size(); ++j)
      {
        if((Integer)links.get(j) == link_to)
          again = true;
      }
      
    } while(again);
    //println("Link " + i + " to " + link_to);
    links.add(link_to);
  }
  
  network.addPerson( new Person(network.persons.size() + 1, "ddd", links ) );
}

//
// Class holding the whole network
//
class Network {
 
  final color NODE_COLOR = color(150);
  final color ACTIVE_NODE_COLOR = color(255, 60, 60);
  final color SELECTED_NODE_COLOR = color(255, 0, 0);
  
  final color CONNECTION_COLOR = color(0, 0, 0);
  
  ArrayList persons = new ArrayList<Person>();
    
  Network() {
    clearNetwork();
  }
  
  void addPerson(Person pers) {
    persons.add( pers );
    
    // add particle
    pers._p = physics.makeParticle();
    
    // add connections
    boolean update_success = true;
    for(int i = 0; i < pers._connections.size(); ++i)
    {
      for(int j = 0; j < persons.size(); ++j)
      {
        if( (Integer)((pers._connections).get(i)) == ((Person)persons.get(j))._id )
        {
          //println("add connections: " +  pers._id + " to " + ((Person)persons.get(j))._id);
          addSpacersToNode( pers._p, ((Person)persons.get(j))._p );
          makeEdgeBetween( pers._p, ((Person)persons.get(j))._p );
        }
      }
    }
    pers._p.position().set( random( -1, 1 ), random( -1, 1 ), 0 );
  }
  
  void removePerson(int i) {
    
  }
  
  void clearNetwork() {
    persons.clear();
    physics.clear();
  }
  
  
  void drawNetwork(boolean click, float mx_raw, float my_raw) {
    
    physics.tick(); 
    if ( physics.numberOfParticles() > 1 )
      updateCentroid();
    
    pushMatrix();
    translate( width/2 , height/2 );
    scale( scale );
    translate( -centroidX, -centroidY );
    
    drawParticles(click, mx_raw, my_raw);    
    popMatrix();
  }
  
  int checkNodeHit(float mx_raw, float my_raw) {
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0) / scale + centroidX;
    float my = (my_raw - height/2.0) / scale + centroidY;
    float adjustedTollerance = tollerance  * scale + NODE_SIZE/ (2.0 * scale);
    
    for ( int i = 0; i < persons.size(); ++i )
    {
      Person pers = (Person)persons.get(i);
      Particle v = pers.getParticle();

      if(abs(v.position().x() - mx) < adjustedTollerance  && 
         abs(v.position().y() - my) < adjustedTollerance)
      {
        return i;
      }
    }
    return -1;
  }
  
  
  void selectNode(boolean ctrl, float mx_raw, float my_raw) {
        
    if(!ctrl)
      resetSelection();

    int i = checkNodeHit(mx_raw, my_raw);
    if( i >= 0) ((Person)persons.get(i)).selected = true;
  }
  
  int last_selection = -1;
  void selectDragNode(float mx_raw, float my_raw) {
    int i = checkNodeHit(mx_raw, my_raw);
    if( i >= 0) ((Person)persons.get(i)).getParticle().makeFixed();
    last_selection = i;
  }
  
  void dragNode(float mx_raw, float my_raw) {
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0) / scale + centroidX;
    float my = (my_raw - height/2.0) / scale + centroidY;
    float adjustedTollerance = tollerance  * scale + NODE_SIZE/ (2.0 * scale);
    
    if(last_selection >= 0)
    {
      Person pers = (Person)persons.get(last_selection);
      Particle v = pers.getParticle();
      v.position().set(mx, my, 0);
    }
  }
  
  void releaseDragNode() {
      
    if(last_selection >= 0)
    {
      Person pers = (Person)persons.get(last_selection);  
      Particle v = pers.getParticle();
      v.makeFree();
    }
    
    last_selection = -1;
  }
  
  void resetSelection() {
    for ( int i = 0; i < persons.size(); ++i )
      ((Person)persons.get(i)).selected = false;
  }

 
  
  final float NODE_SIZE = 10;
  final float EDGE_LENGTH = 20;
  final float EDGE_STRENGTH = 0.02;
  final float SPACER_STRENGTH = 100;
  
  ParticleSystem physics = new ParticleSystem( 0, 0.1 );
  float scale = 1;
  float centroidX = 0;
  float centroidY = 0;
 
  float tollerance = 0.9;
  
  
  void drawParticles(boolean click, float mx_raw, float my_raw)
  { 
    
    //
    // draw edges
    //
    stroke( CONNECTION_COLOR );
    strokeWeight( 2 );
    beginShape( LINES );
    for ( int i = 0; i < physics.numberOfSprings(); ++i )
    {
      Spring e = physics.getSpring( i );
      Particle a = e.getOneEnd();
      Particle b = e.getTheOtherEnd();
      vertex( a.position().x(), a.position().y() );
      vertex( b.position().x(), b.position().y() );
    }
    endShape();
   
    //
    // draw nodes
    //
    ellipseMode( CENTER );
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0) / scale + centroidX;
    float my = (my_raw - height/2.0) / scale + centroidY;
    float adjustedTollerance = tollerance  * scale + NODE_SIZE/ (2.0 * scale);
    
    // draw vertices
    fill( 160 );
    for ( int i = 0; i < persons.size(); ++i )
    {
      Person pers = (Person)persons.get(i);
      Particle v = pers.getParticle();
      
      strokeWeight(0.5);
      stroke(255, 255, 255);
      if(abs(v.position().x() - mx) < adjustedTollerance  && abs(v.position().y() - my) < adjustedTollerance)
      {
        strokeWeight(1);
        stroke(255, 0, 0);
      }
      
      if( i == last_selection ) {
        fill( ACTIVE_NODE_COLOR );
      } else if( pers.selected ) {
        fill( SELECTED_NODE_COLOR );
      } else {
        fill( NODE_COLOR );
      }
      
      ellipse( v.position().x(), v.position().y(), NODE_SIZE, NODE_SIZE );
    }

  }
  
  void updateCentroid()
  {
    float 
      xMax = Float.NEGATIVE_INFINITY, 
      xMin = Float.POSITIVE_INFINITY, 
      yMin = Float.POSITIVE_INFINITY, 
      yMax = Float.NEGATIVE_INFINITY;
  
    for ( int i = 0; i < physics.numberOfParticles(); ++i )
    {
      Particle p = physics.getParticle( i );
      xMax = max( xMax, p.position().x() );
      xMin = min( xMin, p.position().x() );
      yMin = min( yMin, p.position().y() );
      yMax = max( yMax, p.position().y() );
    }
    float deltaX = xMax-xMin;
    float deltaY = yMax-yMin;
    
    centroidX = xMin + 0.5*deltaX;
    centroidY = yMin +0.5*deltaY;
      
    if ( deltaY > deltaX )
      scale = height/(deltaY+50);
    else
      scale = width/(deltaX+50);
      
    scale = scale > 4 ? 4 : scale;
  }
  
  void addSpacersToNode( Particle p, Particle r )
  {
    for ( int i = 0; i < physics.numberOfParticles(); ++i )
    {
      Particle q = physics.getParticle( i );
      if ( p != q && p != r )
        physics.makeAttraction( p, q, -SPACER_STRENGTH, 20 );
    }
  }
  
  void makeEdgeBetween( Particle a, Particle b )
  {
    physics.makeSpring( a, b, EDGE_STRENGTH, EDGE_STRENGTH, EDGE_LENGTH );
  }
  
  void addRandomNode()
  { 
    Particle p = physics.makeParticle();
    Particle q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
    while ( q == p )
      q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
    addSpacersToNode( p, q );
    makeEdgeBetween( p, q );
    p.position().set( q.position().x() + random( -1, 1 ), q.position().y() + random( -1, 1 ), 0 );
  }

}
