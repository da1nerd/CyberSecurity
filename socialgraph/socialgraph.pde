import controlP5.*;
import java.awt.*;

Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();
ControlP5 controlP5;
DBManager dbm = new DBManager(this);
FilterManager fm = new FilterManager();
ControlWindow cw;
FilterForm ff;
String DBNAME = "socialgraph.mysql";

PFont font1;
PFont font2;

boolean shft_pressed = false;
boolean ctrl_pressed = false;
boolean drag_node = false;
boolean drag_bubble = false;
boolean pan_scene = false;

PVector last_mouse_pos = new PVector(0,0);

Network network;

void setup()
{
  int w = 800;
  int h = 600;
  size( w, h );

  dbm.connect(dataPath(DBNAME));

  //
  // Controls
  //
  controlP5 = new ControlP5(this);
 // controlP5.setControlFont(new ControlFont(createFont("Verdana",10), 10));
  controlP5.Button b = controlP5.addButton("Add_Filter");
  b.setPosition(65, 27);
  b.setSize(95, 20);
  b.setLabel("Add new filter (n)");
  
  controlP5.Button b2 = controlP5.addButton("Clear_Filters");
  b2.setSize(85, 20);
  b2.setPosition(165, 27);
  b2.setLabel("Clear Filters (c)");
  
	controlP5.Button b3 = controlP5.addButton("Update_Database");
  b3.setSize(85, 20);
  b3.setPosition(255, 27);
  b3.setLabel("Update Database");

  ff = new FilterForm(25,35,-1,-1,-1,-1); // set some default form values
  
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
  }}); 
  
  network = new Network();
  
  smooth();
  font1 = loadFont( "SansSerif-14.vlw" );
  font2 = loadFont( "Calibri-11.vlw" );
}

void draw()
{  
  if(fm._updated == true) {
    network.updateFilters(fm);
  }
  
  background( 255 );
  fill( 0 );
  textFont( font1 );
  textAlign( LEFT );
  text( "" + network.physics.numberOfParticles() + " PARTICLES\n" + (int)frameRate + " FPS", 10, 20 );
  network.drawNetwork(mouseX, mouseY);  
}

/* USER INTERACTION */

void mousePressed()
{
  if( mouseButton == LEFT )
  {
    if( mouseEvent.getClickCount() == 2 )
    {
      if( shft_pressed ) {
        network.selectBubble(mouseX, mouseY);
      } else {
        network.selectNode(ctrl_pressed, mouseX, mouseY);
      }
    }
    else
    {
      if( shft_pressed ) {
        network.selectDragBubble(mouseX, mouseY);
        drag_bubble = true;
      } else {
        network.selectDragNode(mouseX, mouseY);
        drag_node = true;
      }
    }
  }
  
  if( mouseButton == RIGHT )
  {
    last_mouse_pos = new PVector(mouseX, mouseY);
    pan_scene = true;
  }
}

void mouseDragged()
{
  if(drag_node)
    network.dragNode(mouseX, mouseY);
    
  if(drag_bubble)
    network.dragBubble(mouseX, mouseY);
    
  if(pan_scene)
    network.updatePanning(new PVector(mouseX-last_mouse_pos.x, mouseY-last_mouse_pos.y));
}

void mouseReleased() {
  network.releaseDragNode();
  drag_node = false;
  drag_bubble = false;
  
  if(pan_scene) {
    pan_scene = false;
    network.savePanning();
  }
}

void keyPressed()
{
  if ( key == 'c' )
  {
    fm.clear();
    return;
  }
  if ( key == 'n' )
  {
    ff.show();
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

public void Clear_Filters(int v) {
  fm.clear();
}

public void Update_Database(int v) {
	dbm.connect(dataPath(DBNAME), true);
  fm.clear();
	load_data();
}
