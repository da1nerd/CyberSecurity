import controlP5.*;

ControlP5 controlP5;
DBManager dbm = new DBManager(this);
FilterManager fm = new FilterManager();

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
  // add a new controller window
  ControlWindow cw = controlP5.addControlWindow("win" ,250, 250);
  cw.setLocation(100,100);
  // begin a new group of auto-arranged controllers
  ControlGroup cg = controlP5.addGroup("controls",30,30);
  cg.moveTo(cw);
  controlP5.begin(cg,0,10);
  controlP5.addButton("Add_Filter").linebreak();
  //controlP5.addButton("Load_Data").linebreak();
  //controlP5.addSlider("Min_Connections",100,200,128,10,60,100,10);
  controlP5.end();
  
  
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
    createDummyNetwork();
    return;
  }
  
  if ( key == ' ' )
  {
    addRandomNode();
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
  }
  return;
}


void keyReleased()
{
  ctrl_pressed = false;
}

void mouseWheel(int delta) {  
  if(delta > 0)
    network.zoomOut();
  else
    network.zoomIn();
}

public void Add_Filter(int v) {
  //addRandomNode();
  GraphFilter f1 = fm.addFilter();
  f1.load(25,35,-1,-1,-1,-1); 
  fm._updated = true;
}

//public void Load_Data(int v) {
//  load_data();
//}
