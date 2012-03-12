

// handles importing raw file data into the database

// load the data
public void load_data() {
  loadEntities(dataPath("Entities_Table.txt"));
  println("loaded entities");
  
  loadConnections(dataPath("Links_Table.txt"));
  println("loaded connections");
  
  loadPersonCityConnection(dataPath("People-Cities.txt"));
  println("loaded links");
}

// Load all entities and return an ArrayList with nodes
private void loadEntities(String filename)
{
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
        
      //  println(id + ":" + name + ":"+ type);
        
        // insert entities into database
        if(type.equals("person")) {
          dbm.insertPerson(name, id);
        } else if(type.equals("city")) {
          dbm.insertCity(name, id);
        } else if(type.equals("country")) {
          dbm.insertCountry(name, id);
        } else {
          println("INVALID ENTITY TYPE " + type);
        }
      }
      
      LineCount += 1;
    }
  } catch (Exception e) {
    println("--file error-- ");
    e.printStackTrace();
  }
}

// Load all connections and return them in an ArrayList
private void loadConnections(String filename)
{
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
        
        // connections file contains both person to person connections and city to country links.
        if(dbm.isCity(node1)) {
          // insert city country links into database
          dbm.insertCityCountryLink(node1, node2);
        } else {
          // insert person connections into database
          dbm.insertPersonPersonLnk(node1, node2);
        }
      }
      
      LineCount += 1;
    }
  } catch (Exception e) {
    println("--file error-- ");
    e.printStackTrace();
  }
}

// Load all person-city connections and return them in an ArrayList
private void loadPersonCityConnection(String filename)
{
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
        
        // insert the city links into the database
        int city_id = dbm.getCityByName(city);
        dbm.insertPersonCityLink(person, city_id);
      }
      
      LineCount += 1;
    }
  } catch (Exception e) {
    println("--file error-- ");
    e.printStackTrace();
  }
  
  /* Filters */
}
