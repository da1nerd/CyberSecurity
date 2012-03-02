import controlP5.*;

ControlP5 controlP5;

boolean drag = false;

// PROCESSING /////////////////////////////////////

void setup()
{
  // files
    String fileEntities = dataPath("Entities_Table.txt");
  nodeArray = loadEntities(fileEntities);
  
  String fileLinks = dataPath("Links_Table.txt");
  linksArray = loadConnections(fileLinks);
  
  String filePCLinks = dataPath("People-Cities.txt");
  peopleCityLinksArray = loadPersonCityConnection(filePCLinks);
  
  font = loadFont("ArialMT-10.vlw");
  textFont (font);
  
  
  size( 800, 400 );
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
  controlP5.end();
  
  //
  // Physics
  //
  smooth();
  strokeWeight( 2 );
  ellipseMode( CENTER );       
  
  physics = new ParticleSystem( 0, 0.1 );
  
  // Runge-Kutta, the default integrator is stable and snappy,
  // but slows down quickly as you add particles.
  // 500 particles = 7 fps on my machine
  
  // Try this to see how Euler is faster, but borderline unstable.
  // 500 particles = 24 fps on my machine
  //physics.setIntegrator( ParticleSystem.MODIFIED_EULER ); 
  
  // Now try this to see make it more damped, but stable.
  //physics.setDrag( 0.2 );
  
  
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


