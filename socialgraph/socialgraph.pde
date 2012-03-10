import controlP5.*;

ControlP5 controlP5;
DBManager dbm = new DBManager(this);

boolean drag = false;

void setup()
{
  size( 800, 400 );
  
  dbm.connect(dataPath("socialgraph.sqlite"), true);
  
  
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
  
  //
  // Physics
  //
  smooth();
  strokeWeight( 2 );
  ellipseMode( CENTER );       
  physics = new ParticleSystem( 0, 0.1 );
  
  textFont( loadFont( "SansSerif-14.vlw" ) );
  
  initializeNetwork();
}

void draw()
{
  physics.tick(); 
  if ( physics.numberOfParticles() > 1 )
    updateCentroid();
  background( 255 );
  fill( 0 );
  text( "" + physics.numberOfParticles() + " PARTICLES\n" + (int)frameRate + " FPS", 10, 20 );
  translate( width/2 , height/2 );
  scale( scale );
  translate( -centroidX, -centroidY );
 
  drawNetwork(drag, mouseX, mouseY);  
}

void mousePressed()
{
  drag = true;
}

void mouseDragged()
{
  drag = true;
}

void mouseReleased() {
  drag = false;
}

void keyPressed()
{
  if ( key == 'c' )
  {
    initializeNetwork();
    return;
  }
  
  if ( key == ' ' )
  {
    addNode();
    return;
  }
}

// link load data button to file chooser
public void Button1(int v) {  
  addNode();
}

public void Load_Data(int v) {
  load_data();
}
