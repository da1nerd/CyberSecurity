import controlP5.*;

ControlP5 controlP5;
DBManager dbm = new DBManager(this);
FilterManager fm = new FilterManager();
ControlWindow cw;
FilterForm ff;

boolean shft_pressed = false;
boolean ctrl_pressed = false;
boolean drag = false;
boolean pan_scene = false;

PVector last_mouse_pos = new PVector(0,0);

Network network;

void setup()
{
  size( 800, 600 );
  
  dbm.connect(dataPath("socialgraph.mysql"));
  
  
  //
  // Controls
  //
  controlP5 = new ControlP5(this);
 // controlP5.setControlFont(new ControlFont(createFont("Verdana",10), 10));
  controlP5.Button b = controlP5.addButton("Add_Filter");
  b.setSize(75, 20);
  b.setLabel("Add new filter");
  ff = new FilterForm();
  
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
  }}); 
  
  network = new Network();
  //createDummyNetwork();
  
  smooth();
  textFont( loadFont( "SansSerif-14.vlw" ) );
}

void draw()
{
  if(fm._updated == true) {
    network.updateFilters(fm);
  }
  
  background( 255 );
  fill( 0 );
  text( "" + network.physics.numberOfParticles() + " PARTICLES\n" + (int)frameRate + " FPS", 10, 20 );
  network.drawNetwork(drag, mouseX, mouseY);  
}

/* USER INTERACTION */

void mousePressed()
{
  if( mouseButton == LEFT )
  {
    if (mouseEvent.getClickCount() == 2) {
      network.selectNode(ctrl_pressed, mouseX, mouseY);
    } else {
      network.selectDragNode(mouseX, mouseY);
    }
    drag = true;
  }
  
  if( mouseButton == RIGHT )
  {
    last_mouse_pos = new PVector(mouseX, mouseY);
    pan_scene = true;
  }
}

void mouseDragged()
{
  if(drag)
    network.dragNode(mouseX, mouseY);
    
  if(pan_scene)
    network.updatePanning(new PVector(mouseX-last_mouse_pos.x, mouseY-last_mouse_pos.y));
}

void mouseReleased() {
  network.releaseDragNode();
  drag = false;
  
  if(pan_scene) {
    pan_scene = false;
    network.savePanning();
  }
}

void keyPressed()
{
  if ( key == 'c' )
  {
    network.clearNetwork();
    return;
  }
  if( key == DELETE)
  {
    network.deleteSelectedNodes(); 
  }
  if ( key == CODED ) {
    if ( keyCode == CONTROL ) {
      ctrl_pressed = true;
    } 
    if (keyCode == SHIFT ) {
      shft_pressed = true;
    }
  }
  return;
}


void keyReleased()
{
  ctrl_pressed = false;
  shft_pressed = false;
}

void mouseWheel(int delta) {  
  if(delta > 0)
    network.zoomOut();
  else
    network.zoomIn();
}

/* Displays a dialog for creating a new filter
 *
 */
public void Add_Filter(int v) {
  // create a new object to hold the filter form data.
  ff.show();
}


