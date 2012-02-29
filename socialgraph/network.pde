import traer.physics.*;

final float NODE_SIZE = 10;
final float EDGE_LENGTH = 20;
final float EDGE_STRENGTH = 0.02;
final float SPACER_STRENGTH = 100;

ParticleSystem physics;
float scale = 1;
float centroidX = 0;
float centroidY = 0;

int selectedParticle = -1;
float tollerance = 0.9;
// TODO: we need to find out where the particle positions are changed, so that we can use their real positions after they are moved by physics.
void drawNetwork(boolean click, float mx_raw, float my_raw)
{     
  // adjust mouse coordinates to match particle coordinates
  float mx = (mx_raw - width/2.0) / scale;
  float my = (my_raw - height/2.0) / scale;
  float adjustedTollerance = tollerance  * scale + NODE_SIZE/ (2.0 * scale);
  
  if(click == true) {selectedParticle = -1;}
  
  // draw vertices
  fill( 160 );
  noStroke();
  for ( int i = 0; i < physics.numberOfParticles(); ++i )
  {
    Particle v = physics.getParticle( i );
    if(click == true) {
      println(selectedParticle + " - " + abs(v.position().x() - mx) + " : " + abs(v.position().y() - my) + " _ " + adjustedTollerance);
      if(selectedParticle == -1) {
        // look for the particle
        if(abs(v.position().x() - mx) < adjustedTollerance  && abs(v.position().y() - my) < adjustedTollerance)
        {
          println("selected particle " + i);
          selectedParticle = i;
        //  v.makeFixed();
        } else {
          
         // println("cendroidx: " + centroidX + " centroidY: " + centroidY + " mousex: " + mx + " mousey: " + my + " nodex: " + v.position().x() + " nodey: " + v.position().y());
      }
      } else if(selectedParticle == i) {
        // update position of selected particle
       // println(v.isFixed());
       // v.position().set( mx , my, 0 );
      }
    } else if(drag == false && selectedParticle != -1) {
      // reset selected particle
    //  physics.getParticle(selectedParticle).makeFree();
     // selectedParticle = -1;
    } 
    if(selectedParticle == i) {
      fill(255,0,0);
    } else {
      fill(150);
    }
    
    ellipse( v.position().x(), v.position().y(), NODE_SIZE, NODE_SIZE );
  }

  // draw edges 
  stroke( 0 );
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

void initializeNetwork()
{
  physics.clear();
  physics.makeParticle();
}

void addNode()
{ 
  Particle p = physics.makeParticle();
  Particle q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
  while ( q == p )
    q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
  addSpacersToNode( p, q );
  makeEdgeBetween( p, q );
  p.position().set( q.position().x() + random( -1, 1 ), q.position().y() + random( -1, 1 ), 0 );
}
