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
  final float TOLLERANCE = 0.1;
    
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
  void addPerson(Person pers, int bubble_id, boolean update_connections) {
    
    // create new particle
    Particle p = physics.makeParticle();
    
    // search the bubbles position to init node at this position
    int i = searchBubbleByID(bubble_id);
    PVector position = new PVector( random( -1, 1 ), random( -1, 1 ) );
    if(i >= 0) {
      position.add(bubbles.get(i).getPosition());
    }
    p.position().set( position.x, position.y, 0 );
    
    // add the person to the network
    pers.setParticle( p );
    persons.add( pers );
    
    // add the person to a bubble
    addPerson2Bubble(pers, bubble_id);
    
    // update all connections
    if(update_connections)
      updateConnections();
  }
  
  /* Find the index of a person
  * 
  */
  private int findPersonIndex(int id) {
    for(int i = 0; i < persons.size(); ++i)
    {
      if(persons.get(i).getID() == id)
        return i;
    }
    return -1;
  }
  
  /* Update the connections of the whole network
  * --> Very slow but does everything
  * 
  */
  public void updateConnections() {
    
    println("update all connections");
   
    for(int i = 0; i < persons.size(); ++i)
    {
      Particle p1 = persons.get(i).getParticle();
      ArrayList<Connection> con = persons.get(i).getConnections();
      
      // get springs and attractions connected to node 1
      ArrayList<Spring> springs = getSpringsConnected2Particle(p1);
      ArrayList<Attraction> attractions = getAttractionsConnected2Particle(p1);
      
      for(int k = 0; k < persons.size(); ++k)
      {
        Particle p2 = persons.get(k).getParticle();
        
        // search if there is already a spring between the two particles
        int existing_spring = -1;
        for(int l = 0; l < springs.size(); ++l) {
          if((springs.get(l).getOneEnd() == p1 && springs.get(l).getTheOtherEnd() == p2) ||
             (springs.get(l).getOneEnd() == p2 && springs.get(l).getTheOtherEnd() == p1)) {
            existing_spring = l;
            break;
          }
        }
        
        // search if there is already an attraction between the twwo particles
        int existing_attraction = -1;
        for(int l = 0; l < attractions.size(); ++l) {
          if((attractions.get(l).getOneEnd() == p1 && attractions.get(l).getTheOtherEnd() == p2) ||
             (attractions.get(l).getOneEnd() == p2 && attractions.get(l).getTheOtherEnd() == p1)) {
            existing_attraction = l;
            break;
          }
        }
        
        // check if the two nodes have a connection
        boolean connect = false;
        for(int j = 0; j < con.size(); ++j)
        {
          if( (con.get(j).getID() == persons.get(k).getID()) && con.get(j).isVisible() ) {
            connect = true;
            break;
          }
        }
        
        // if yes, then connect them
        if( connect )
        {
          // if no spring exists create one
          if( existing_spring == -1 ) {
            physics.makeSpring( p1, p2, EDGE_STRENGTH, EDGE_STRENGTH,
              EDGE_LENGTH + pow(persons.get(i).getNodeDrawSize(), 1.3) );
          }
          // if there is repulsion remove it
          if( existing_attraction >= 0) {
            physics.removeAttraction( attractions.get(existing_attraction) );
          }            
        }
        // otherwise disconnect them
        else
        {
          // if repulsion doesn't exists create one
          if( existing_attraction == -1 ) {
            physics.makeAttraction( p1, p2, -SPACER_STRENGTH, 20 );
          }
          // if there is a spring remove it
          if( existing_spring >= 0) {
            physics.removeSpring( springs.get(existing_spring) );
          }
        }
      }
    }
  }
  
 /* Get the springs connected to a particle
  * 
  */
  private ArrayList<Spring> getSpringsConnected2Particle(Particle p) {
    ArrayList<Spring> springs = new ArrayList();
    for ( int l = 0; l < physics.numberOfSprings(); ++l )
    {
      Spring e = physics.getSpring( l );
      if( e.getOneEnd() == p || e.getTheOtherEnd() == p)
        springs.add(e);
    }
    return springs;
  }
  
 /* Get the attractions connected to a particle
  * 
  */  
  private ArrayList<Attraction> getAttractionsConnected2Particle(Particle p) {
    ArrayList<Attraction> attractions = new ArrayList();
    for ( int l = 0; l < physics.numberOfAttractions(); ++l )
    {
      Attraction e = physics.getAttraction( l );
      if( e.getOneEnd() == p || e.getTheOtherEnd() == p)
        attractions.add(e);
    }
    return attractions;
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
        addPerson(p, id, false);
      }
    }
    updateConnections();
    println("Network:updateFilters complete");
    fm.makeClean();
  }
  
  private PVector adjustMouseCoords(PVector pos) {
    return adjustMouseCoords(pos.x, pos.y);
  }
  
  private PVector adjustMouseCoords(float mx, float my) {
    PVector pos = new PVector(
      (mx - width/2.0 - panning.x) / scale,
      (my - height/2.0 - panning.y) / scale
    );
    return pos;
  }
  
  
 /* Check if the given coordinates match a node
  * 
  */
  int checkNodeHit(float mx_raw, float my_raw) {
    
    PVector m_pos = adjustMouseCoords(mx_raw, my_raw);
    
    for ( int i = 0; i < persons.size(); ++i )
    {
      Person pers = (Person)persons.get(i);
      Particle v = pers.getParticle();
      float adjToll = (1+TOLLERANCE) + pers.getNodeDrawSize() / 2.;
      
      PVector pos = new PVector(v.position().x(), v.position().y());
      pos.sub(m_pos);
      
      if( pos.mag() < adjToll )
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
    if( i >= 0) {
      Person p = persons.get(i);
      persons.remove(i);
      p.selected = true;
      persons.add(p);
    }
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
    
    PVector m_pos = adjustMouseCoords(mx_raw, my_raw);
    
    if(last_selection >= 0)
    {
      Person pers = (Person)persons.get(last_selection);
      Particle v = pers.getParticle();
      v.position().set(m_pos.x, m_pos.y, 0);
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
  void drawNetwork(float mx_raw, float my_raw) {
    
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
    
    PVector m_pos = adjustMouseCoords(mx_raw, my_raw);
    
    for ( int i = 0; i < bubbles.size(); ++i )
    {
      Bubble b = bubbles.get(i);
      float adjToll = (1+TOLLERANCE) * b.getSize() / 2.0;
      PVector pos = b.getPosition();
      pos.sub(m_pos);
      Particle p = b.getParticle();
      
      fill( color(0, 255, 0, 60) );
      noStroke();
      
      if( b.isSelected() ) {
        fill( color(0, 255, 0, 90) );
      }
      if( pos.mag() <= adjToll && shft_pressed )
      {
        strokeWeight(5);
        stroke(0, 255, 0, 100);
      }

      ellipse( p.position().x(), p.position().y(), b.getSize(), b.getSize() );
      
      if( pos.mag() <= adjToll && shft_pressed )
      {
        textAlign( CENTER );
        textFont( font2 );
        stroke( 0 );
        fill( 0 );
        text( "" + b.getGraphFilter()._name , p.position().x(), p .position().y() );
      }
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
    PVector m_pos = adjustMouseCoords(mx_raw, my_raw);

    // draw vertices
    fill( 160 );
    for ( int i = 0; i < persons.size(); ++i )
    {
      Person pers = (Person)persons.get(i);
      Particle v = pers.getParticle();
      
      float adjToll = (1+TOLLERANCE) + pers.getNodeDrawSize() / 2.;
      PVector pos = new PVector( v.position().x(), v.position().y() );
      pos.sub(m_pos);
      
      strokeWeight(0.5);
      boolean hover = false;
      stroke(255, 255, 255);
      if( pos.mag() < adjToll )
      {
        hover = true;
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
        
      ellipse( v.position().x(), v.position().y(), pers.getNodeDrawSize(), pers.getNodeDrawSize() );
      
      fill( 0 );
      stroke( 0 );
      if( pers.selected || hover ) {
        noStroke();
        fill(235, 235, 235, 210);
        rect(v.position().x() + pers.getNodeDrawSize()/2, v.position().y() - 20, 80, 24);
        
        textAlign( LEFT );
        textFont( font2 );
        stroke( 0 );
        fill( 0 );
        text( "" + pers.getDegree() , v.position().x() + pers.getNodeDrawSize()/2 + 2, v.position().y() - 9 );
        text( "" + pers.getName() , v.position().x() + pers.getNodeDrawSize()/2 + 2, v.position().y()  );
      }
    }
  }
  
  
  //
  // BUBBLE HANDLING STUFF
  //
     
 /* Select bubble
  * 
  */
  private int checkBubbleHit(float mx_raw, float my_raw) {
    
    PVector m_pos = adjustMouseCoords(mx_raw, my_raw);
    
    for ( int i = 0; i < bubbles.size(); ++i )
    {
      Bubble b = bubbles.get(i);
      Particle v = b.getParticle();
      float adjToll = (1+TOLLERANCE) + b.getSize() / 2.;
      
      PVector pos = new PVector( v.position().x(), v.position().y() );
      pos.sub(m_pos);
      
      
      if( pos.mag() < adjToll )
      {
        return i;
      }
    }
    return -1;
  }
     
 /* Select bubble
  * 
  */
  public void selectBubble(float mx_raw, float my_raw) {
    
    for ( int i = 0; i < bubbles.size(); ++i )
      bubbles.get(i).resetSelected();
      
    int i = checkBubbleHit(mx_raw, my_raw);
    if(i >= 0 && shft_pressed )
    {
      bubbles.get(i).setSelected();
      ff.show( bubbles.get(i).getGraphFilter() );
    }
  }
  
 /* Create a new bubble
  * 
  */
  public int createBubble(GraphFilter _gf) {
    
    PVector mean = new PVector(0, 0);
    float x_max = 0;
    for(int i = 0; i < bubbles.size(); ++i) {
      PVector pos = bubbles.get(i).getPosition();
      mean.add(pos);
      
      if( x_max < pos.x )
        x_max = pos.x;
    }
    if( bubbles.size() > 0 ) {
      mean.div( bubbles.size() );
      x_max += 300;
    }
    
    Particle c = physics.makeParticle();
    c.position().set(x_max, mean.y, 0);
    Bubble b = new Bubble(c, _gf);
    bubbles.add( b );
    
    PVector mean_new = new PVector(0, 0);
    for(int i = 0; i < bubbles.size(); ++i) {
      mean_new.add(bubbles.get(i).getPosition());
    }
    mean_new.div( bubbles.size() );
    mean_new.mult(-1);
    
    panning.set( mean_new );
    tmp_panning.set( mean_new );
    
    return b.getID();
  }
  
  public int searchBubbleByID(int id) {
    int index = -1;
    for(int i = 0; i < bubbles.size(); ++i)
    {
      if( ((Bubble)bubbles.get(i)).getID() == id ) {
        index = i;
        break;
      }
    }
    return index;
  }
  
 /* Add person to a bubble
  * 
  */
  public void addPerson2Bubble(Person p, int bubble_id) {
    
    int i = searchBubbleByID(bubble_id);
    if(i >= 0) {
      Particle c = bubbles.get(i).getParticle();
      physics.makeSpring( p.getParticle(), c, 0.001, 0.001, 50);
    }
  }
  
  int last_bubble_selection = -1;
  void selectDragBubble(float mx_raw, float my_raw) {
    int i = checkBubbleHit(mx_raw, my_raw);
    last_bubble_selection = i;
  }

 /* Drag a node
  * 
  */
  void dragBubble(float mx_raw, float my_raw) {
    
    PVector m_pos = adjustMouseCoords(mx_raw, my_raw);
    
    if(last_bubble_selection >= 0)
    {
      Particle v = bubbles.get(last_bubble_selection).getParticle();
      v.position().set(m_pos.x, m_pos.y, 0);
    }
  }

}

