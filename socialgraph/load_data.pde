

PFont font;

// define lists for all entities, the links between the
// persons and the links from cities to countries and a list for
// the assignment of the persons to a city
ArrayList nodeArray = new ArrayList();
ArrayList linksArray = new ArrayList();
ArrayList peopleCityLinksArray = new ArrayList();


void setup_old() {
  size( 1200, 700 );
  
  String fileEntities = dataPath("Entities_Table.txt");
  nodeArray = loadEntities(fileEntities);
  
  String fileLinks = dataPath("Links_Table.txt");
  linksArray = loadConnections(fileLinks);
  
  String filePCLinks = dataPath("People-Cities.txt");
  peopleCityLinksArray = loadPersonCityConnection(filePCLinks);
  
  font = loadFont("ArialMT-10.vlw");
  textFont (font);
}

// draw all nodes with their random x and y coordinates
// on the screen and their connections
void draw() {
  colorMode(RGB, 255);
  background (255,255,255);
  
  // draw nodes
  colorMode(HSB, 100);
  for(int i = 0; i < nodeArray.size(); ++i)
  {
    Node node = (Node)nodeArray.get(i);
    
    fill(i%100, 100, 100);
    stroke(i%100, 100, 100);
    
    ellipse(node.x, node.y, 3, 3);
    //text(node._name, node.x, node.y);
  }
  
  // draw connections
  colorMode(RGB, 256);
  for(int i = 0; i < linksArray.size(); ++i)
  {
    Connection con = (Connection)linksArray.get(i);
    Node node1 = (Node)nodeArray.get(con._node1-1);
    Node node2 = (Node)nodeArray.get(con._node2-1);
    
    stroke(10, 10, 10, 100);
    line(node1.x, node1.y, node2.x, node2.y);
  }
 
}


// Class holding one network node
class Node { 
  int _id;
  String _name;
  String _type;
  int x, y;
  boolean enabled;

  Node(int id, String name, String type) { 
    _id = id;
    _name = name;
    _type = type;
    
    enabled = true;
    
    // Test: place randomly to x and y
    x = (int)random(1200);
    y = (int)random(700);
  }
}

// Class to define one connection between persons or 
// assign a city to a country
class Connection {
  int _node1;
  int _node2;
  boolean enabled;
 
  Connection(int node1, int node2)
  {
    _node1 = node1;
    _node2 = node2;
    
    enabled = true;
  } 
}

// Class to define one connection
class PCConnection {
  int _pnode;
  int _cnode;
  String _cityName;
  boolean enabled;
 
  PCConnection(int person, String cityName)
  {
    _cityName = cityName;
    _pnode = person;
    
    // TODO: extract the node number of the city
    _cnode = 1;
    
    enabled = true;
  } 
}


// Load all entities and return an ArrayList with nodes
ArrayList loadEntities(String filename)
{
  
  ArrayList entities = new ArrayList();
  try {
    BufferedReader reader = new BufferedReader (new FileReader (filename)) ;
    
    int LineCount = 0;
    while (true)
    {
      String lineIn = reader.readLine() ;
      
      if (lineIn == null) break;
      
      // skip the first two lines
      if (LineCount > 1)
      {
        String[] pieces = split(lineIn, "\t");
        
        int id = Integer.parseInt(pieces[0]);
        String name = pieces[1];
        String type = pieces[2];
        
        entities.add( new Node(id, name, type) );
      }
      
      LineCount += 1;
    }
  } catch (Exception e) {
    println("--file error-- ");
    e.printStackTrace();
  }
  
  return entities;
}

// Load all connections and return them in an ArrayList
ArrayList loadConnections(String filename)
{
  
  ArrayList connections = new ArrayList();
  try {
    BufferedReader reader = new BufferedReader (new FileReader (filename)) ;
    
    int LineCount = 0;
    while (true)
    {
      String lineIn = reader.readLine() ;
      
      if (lineIn == null) break;
      
      // skip the first two lines
      if (LineCount > 1)
      {
        String[] pieces = split(lineIn, "\t");
        
        int node1 = Integer.parseInt(pieces[0]);
        int node2 = Integer.parseInt(pieces[1]);
        
        connections.add( new Connection(node1, node2) );
      }
      
      LineCount += 1;
    }
  } catch (Exception e) {
    println("--file error-- ");
    e.printStackTrace();
  }
  
  return connections;
}

// Load all person-city connections and return them in an ArrayList
ArrayList loadPersonCityConnection(String filename)
{
  
  ArrayList connections = new ArrayList();
  try {
    BufferedReader reader = new BufferedReader (new FileReader (filename)) ;
    
    int LineCount = 0;
    while (true)
    {
      String lineIn = reader.readLine() ;
      
      if (lineIn == null) break;
      
      // skip the first two lines
      if (LineCount > 1)
      {
        String[] pieces = split(lineIn, "\t");
        
        int person = Integer.parseInt(pieces[0]);
        String city = pieces[1];
        
        connections.add( new PCConnection(person, city) );
        
        println(LineCount + ": " + person + ", " + city);
      }
      
      LineCount += 1;
    }
  } catch (Exception e) {
    println("--file error-- ");
    e.printStackTrace();
  }
  
  return connections;
}
