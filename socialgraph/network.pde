import traer.physics.*;


//
// Class holding the whole network
//
class Network {
 
  // color definitions
  final color NODE_COLOR = color(150);
  final color ACTIVE_NODE_COLOR = color(255, 60, 60);
  final color SELECTED_NODE_COLOR = color(255, 0, 0);
  final color CONNECTION_COLOR = color(0, 0, 0);
  final color SELECTED_CONNECTION_COLOR = color(255, 128, 0);
  
  final float NODE_SIZE = 10;
  final float EDGE_LENGTH = 20;
  final float EDGE_STRENGTH = 0.02;
  final float SPACER_STRENGTH = 120;
  
  // panning attributes
  PVector panning = new PVector(0,0);
  PVector tmp_panning = new PVector(0,0);
  
  ParticleSystem physics = new ParticleSystem( 0, 0.1 );
  
  ArrayList<Person> persons = new ArrayList<Person>();
  ArrayList<Bubble> bubbles = new ArrayList<Bubble>();
  
  float scale = 1; 
  float tollerance = 0.9;
    
 /* Constructor
  * 
  */
  Network() {
    println("instantiate network");
    clearNetwork();
    
    physics.setIntegrator( ParticleSystem.RUNGE_KUTTA );
   // physics.setIntegrator( ParticleSystem.MODIFIED_EULER );
  }
  
  
  //
  // PERSON HANDLING
  //
  
 /* Add a person to the network
  * 
  */
  void addPerson(Person pers, int bubble_id) {
  
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
    
    // add the person to a bubble
    addPerson2Bubble(pers, bubble_id);
  }
  
 /* Delete a person from the network by its ID
  * 
  */
  public void removePersonByID(int id) {
    for ( int i = 0; i < persons.size(); ++i ) {
      if( ((Person)persons.get(i)).getID() == id ) {
        removePerson(i);
        break;
      }
    }
  }
  
 /* Delete a person from the network
  * 
  */
  private void removePerson(int index) {
    
    Particle p = ((Person)persons.get(index)).getParticle();
    
    // search for springs connected to this particle
    ArrayList<Spring> springs_to_remove = new ArrayList();
    for ( int i = 0; i < physics.numberOfSprings(); ++i )
    {
      Spring e = physics.getSpring( i );
      if( e.getOneEnd() == p || e.getTheOtherEnd() == p)
        springs_to_remove.add(e);
    }
    
    for ( int i = 0; i < springs_to_remove.size(); ++i )
      physics.removeSpring( (Spring)springs_to_remove.get(i) );
    
    
    // search for attractions connected to this particle
    ArrayList<Attraction> attractions_to_remove = new ArrayList();
    for ( int i = 0; i < physics.numberOfAttractions(); ++i )
    {
      Attraction e = physics.getAttraction( i );
      if( e.getOneEnd() == p || e.getTheOtherEnd() == p)
        attractions_to_remove.add(e);
    }
    
    for ( int i = 0; i < attractions_to_remove.size(); ++i )
      physics.removeAttraction( (Attraction)attractions_to_remove.get(i) );
    
    physics.removeParticle( p );
    persons.remove(index);
  }
    
 /* Delete a person from the network
  * 
  */
  public void deleteSelectedNodes() {
    for ( int i = 0; i < persons.size(); ++i )
    {
      if( ((Person)persons.get(i)).selected )
        removePerson(i);
    }
  }  
  
 /* Add a spacer between nodes
  * 
  */
  private void addSpacersToNode( Particle p, Particle r )
  {
    for ( int i = 0; i < physics.numberOfParticles(); ++i )
    {
      Particle q = physics.getParticle( i );
      if ( p != q && p != r )
        physics.makeAttraction( p, q, -SPACER_STRENGTH, 20 );
    }
  }
  
 /* Create edge between nodes
  * 
  */
  private void makeEdgeBetween( Particle a, Particle b )
  {
    physics.makeSpring( a, b, EDGE_STRENGTH, EDGE_STRENGTH, EDGE_LENGTH );
  }
  
 /* Delete the whole network
  * 
  */
  public void clearNetwork() {
    println("clear the whole network");
    persons.clear();
    bubbles.clear();
    physics.clear();
    System.gc();
  }
  
 /* Update changes from the filter
  * 
  */
  public void updateFilters(FilterManager fm) {
    
    clearNetwork();
    println("Network:updateFilters reloading filters");
    for(int i = 0; i < fm.size(); ++i)
    {
      GraphFilter gf = (GraphFilter)fm.get(i);
      int id = createBubble(gf);
      for(int j = 0; j < gf.size(); ++j)
      {
        Person p = (Person)gf.get(j);
        addPerson(p, id);
      }
    }
    fm.ready();
  }
  
 /* Check if the given coordinates match a node
  * 
  */
  int checkNodeHit(float mx_raw, float my_raw) {
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0 - panning.x) / scale;
    float my = (my_raw - height/2.0 - panning.y) / scale;
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
  
  
 /* Select a node
  * 
  */
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
  
 /* Drag a node
  * 
  */
  void dragNode(float mx_raw, float my_raw) {
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0 - panning.x) / scale;
    float my = (my_raw - height/2.0 - panning.y) / scale;
    float adjustedTollerance = tollerance  * scale + NODE_SIZE/ (2.0 * scale);
    
    if(last_selection >= 0)
    {
      Person pers = (Person)persons.get(last_selection);
      Particle v = pers.getParticle();
      v.position().set(mx, my, 0);
    }
  }
    
 /* Release the current node from dragging mode
  * 
  */
  void releaseDragNode() {
      
    if(last_selection >= 0)
    {
      Person pers = (Person)persons.get(last_selection);  
      Particle v = pers.getParticle();
      v.makeFree();
    }
    
    last_selection = -1;
  }
    
 /* Reset selection in the whole network
  * 
  */
  void resetSelection() {
    for ( int i = 0; i < persons.size(); ++i )
      ((Person)persons.get(i)).selected = false;
  }

  
  //
  // VIEW HANDLING
  //
  
 /* zoom into
  * 
  */
  public void zoomIn() {
    scale *= 1.25;
  }
  
 /* zoom out
  * 
  */
  public void zoomOut() {
    scale *= 0.8;
  }
  
 /* update the panning while panning
  * 
  */
  public void updatePanning(PVector p) {
    panning.x = tmp_panning.x;
    panning.y = tmp_panning.y;
    panning.add(p);  
  }
  
 /* set the panning (when mouse released)
  * 
  */
  public void savePanning() {
    tmp_panning.x = panning.x;
    tmp_panning.y = panning.y;
  }
  
  
  
  //
  // DRAWING
  //
  
  
 /* Draw the network
  * 
  */
  void drawNetwork(boolean click, float mx_raw, float my_raw) {
    
    physics.tick(); 
    
    pushMatrix();
    translate( width/2 + panning.x , height/2 + panning.y );
    scale( scale );
   
    if(shft_pressed) {
      drawEdges();
      drawNodes(mx_raw, my_raw);
      drawBubbles(mx_raw, my_raw);
      
      // TODO: allow bubble selection 
      // TODO: display new dialog with filter controls.
      // display dialog with ff.show(filterObject);
    
    } else {
      drawBubbles(mx_raw, my_raw);
      drawEdges();
      drawNodes(mx_raw, my_raw);
    }
   
      
    popMatrix();
  }
  
  //
  // draw bubbles centers
  //
  private void drawBubbles(float mx_raw, float my_raw) {
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0 - panning.x) / scale;
    float my = (my_raw - height/2.0 - panning.y) / scale;
    
    
    for ( int i = 0; i < bubbles.size(); ++i )
    {
      Bubble b = bubbles.get(i);
      float adjustedTollerance = tollerance  * scale + b.getSize()/ (2.0 * scale);
      Particle p = b.getParticle();
      
      fill( color(0, 255, 0, 60) );
      noStroke();
      
      if( b.isSelected() ) {
        fill( color(0, 255, 0, 90) );
      }
      if(abs(p.position().x() - mx) < adjustedTollerance  && 
         abs(p.position().y() - my) < adjustedTollerance  && 
         shft_pressed )
      {
        strokeWeight(5);
        stroke(0, 255, 0, 100);
      }

      ellipse( p.position().x(), p.position().y(), 100, 100 );
    }
  }
  
  //
  // draw edges
  //
  private void drawEdges() {

    strokeWeight( 2 );
    beginShape( LINES );
    for ( int i = 0; i < physics.numberOfSprings(); ++i )
    {
      Spring e = physics.getSpring( i );
      Particle a = e.getOneEnd();
      Particle b = e.getTheOtherEnd();
      
      // check if the line is adjacent to a bubble center
      // if yes then don't draw the line
      boolean draw_line = true;
      for(int j = 0; j < bubbles.size(); ++j) {
        Particle c = ((Bubble)bubbles.get(j)).getParticle();
        if(a == c || b == c )
          draw_line = false;
      }
      
      // check if one adjacent node is a selected node
      // then change color
      stroke( CONNECTION_COLOR );
      for(int j = 0; j < persons.size(); ++j) {
        if(((Person)persons.get(j)).selected)
        {
          Particle c = ((Person)persons.get(j)).getParticle();
          if(a == c || b == c )
            stroke( SELECTED_CONNECTION_COLOR );
        }
      }
      
      // draw the line
      if(draw_line) {
        vertex( a.position().x(), a.position().y() );
        vertex( b.position().x(), b.position().y() );
      }
    }
    endShape();
  }

  //
  // draw nodes
  //
  private void drawNodes(float mx_raw, float my_raw) {

    ellipseMode( CENTER );
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0 - panning.x) / scale;
    float my = (my_raw - height/2.0 - panning.y) / scale;
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
      
      fill( 0 );
      stroke( 0 );
      if( pers.selected ) {
        textFont( font2 );
        text( "" + pers.getDegree() , v.position().x() + 5, v.position().y() );
      }
    }
  }
  
  
  //
  // BUBBLE HANDLING STUFF
  //
     
 /* Select bubble
  * 
  */
  void selectBubble(float mx_raw, float my_raw) {
    
    // adjust mouse coordinates to match particle coordinates
    float mx = (mx_raw - width/2.0 - panning.x) / scale;
    float my = (my_raw - height/2.0 - panning.y) / scale;
    
    for ( int i = 0; i < bubbles.size(); ++i )
    {
      Bubble b = bubbles.get(i);
      Particle p = b.getParticle();
      float adjustedTollerance = tollerance  * scale + b.getSize()/ (2.0 * scale);  
      
      if(abs(p.position().x() - mx) < adjustedTollerance  && 
         abs(p.position().y() - my) < adjustedTollerance  && 
         shft_pressed )
      {
        b.setSelected();
        ff.show( b.getGraphFilter() );
        
      } else {
        b.resetSelected();
      }
    }
  }
  
 /* Create a new bubble
  * 
  */
  public int createBubble(GraphFilter _gf) {
    Particle c = physics.makeParticle(1, 1.0,1.0,10.0);
    Bubble b = new Bubble(c, _gf);
    bubbles.add( b );
    return b.getID();
  }
  
 /* Add person to a bubble
  * 
  */
  public void addPerson2Bubble(Person p, int bubble_id) {
    
    int i = 0;
    for(; i < bubbles.size(); ++i)
    {
      if( ((Bubble)bubbles.get(i)).getID() == bubble_id )
        break;
    }
    
    Particle c = ((Bubble)bubbles.get(i)).getParticle();
    physics.makeSpring( p.getParticle(), c, 0.001, 0.001, 50);
  }
  
  int last_bubble_selection = -1;
  void selectDragBubble(float mx_raw, float my_raw) {
//    int i = checkNodeHit(mx_raw, my_raw);
//    if( i >= 0) ((Person)persons.get(i)).getParticle().makeFixed();
//    last_selection = i;
  }

}

