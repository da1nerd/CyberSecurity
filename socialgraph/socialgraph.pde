import controlP5.*;

ControlP5 controlP5;

boolean ctrl_pressed = false;
boolean drag = false;

Network network;

void setup()
{
  size( 800, 600 );
  
  connectDB("socialgraph.db");
  
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
  controlP5.addButton("Button1").linebreak();
  controlP5.addButton("Load_Data").linebreak();
  //controlP5.addSlider("Min_Connections",100,200,128,10,60,100,10);
  controlP5.end();
  
  network = new Network();
  createDummyNetwork();
  
  smooth();
  textFont( loadFont( "SansSerif-14.vlw" ) );
}

void draw()
{
  background( 255 );
  fill( 0 );
  text( "" + network.physics.numberOfParticles() + " PARTICLES\n" + (int)frameRate + " FPS", 10, 20 );

  network.drawNetwork(drag, mouseX, mouseY);  
}

void mousePressed()
{
  if (mouseEvent.getClickCount() == 2) {
    network.selectNode(ctrl_pressed, mouseX, mouseY);
  } else {
    network.selectDragNode(mouseX, mouseY);
  }
  
  drag = true;
}

void mouseDragged()
{
  if(drag)
    network.dragNode(mouseX, mouseY);
}

void mouseReleased() {
  network.releaseDragNode();
  drag = false;
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

// link load data button to file chooser
public void Button1(int v) {
  addRandomNode();
}

public void Load_Data(int v) {
  load_data();
  //dumpDB();
}
