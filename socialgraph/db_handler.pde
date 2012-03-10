
/* class to handle the database interaction.
 *
 */
class DBManager {
  // import libraries here so nothing else has raw access to it.
  import java.io.*;
  import de.bezier.data.sql.*;
  
  PApplet parent;
  private SQLite db;
  
  /* constructor
   *
   */
  DBManager(PApplet p) {
    parent = p;
  } 
  
  /* connect to a database
   * overload
   */
  Boolean connect(String db_path) {
    return connect(db_path, false);
  }
  
  /* connect to a database. set rebuild to true start from scratch.
   * overload
   */
  Boolean connect(String db_path, Boolean rebuild) {
    /* PREPARE DATABASE */
    File f;
    Boolean newdb = false;
    
    f = new File(db_path);
    if(!f.exists()) {
      // new database
      newdb=true;
      println("Creating new database: " + f.getPath());
      try {
        f.createNewFile();
      } catch(IOException ex) {
        println("ERROR CREATING DATABASE: " + db_path);
        return false;
      }
    } else if(rebuild) {
      // rebuild existing database
      println("Rebulding database: " + f.getPath());
      try {
        f.delete();
        f.createNewFile();
      } catch(IOException ex) {
        println("ERROR REBUILDING DATABASE: " + db_path);
        return false;
      }
    }
    
    // open database file
    db = new SQLite( parent , db_path ); 
    if ( db.connect() )
    {
        // reload the database if nessesary
        if(rebuild || newdb) { initDB(db); }
    } else {
      println("FAILED CONNECTING TO DATABASE " + db_path);
      // DIE!
      return false;
    }
    return true;
  }
  
  /* disconnect from the database
   *
   */
  void disconnect() {
    db.close();
  }
  
  /* initialize a database
   *
   */
  private void initDB(SQLite database) {
    println("Initializing database: " + database.database);
    database.execute("CREATE TABLE 'person' ('id' INTEGER, 'name' TEXT);");
    database.execute("CREATE TABLE 'city' ('id' INTEGER, 'name' TEXT);");
    database.execute("CREATE TABLE 'country' ('id' INTEGER, 'name' TEXT);");
    database.execute("CREATE TABLE 'person_city_link' ('person_id' INTEGER, 'city_id' INTEGER, FOREIGN KEY(person_id) REFERENCES person(id), FOREIGN KEY(city_id) REFERENCES city(id));");
    database.execute("CREATE TABLE 'person_person_link' ('person_id' INTEGER, 'contact_id' INTEGER, FOREIGN KEY(person_id) REFERENCES person(id), FOREIGN KEY(contact_id) REFERENCES person(id));");
    database.execute("CREATE TABLE 'city_country_link' ('city_id' INTEGER, 'country_id' INTEGER, FOREIGN KEY(city_id) REFERENCES city(id), FOREIGN KEY(country_id) REFERENCES country(id));");
  }
  
  // insertions
  
  void insertPerson(String name, int id) {
    db.execute("INSERT INTO 'person' (id, name) values (" + id + ", \""  + name + "\");");
  }
  
  void insertCity(String name, int id) {
    db.execute("INSERT INTO 'city' (id, name) values (" + id + ", \""  + name + "\");");
  }
  
  void insertCountry(String name, int id) {
    db.execute("INSERT INTO 'country' (id, name) values (" + id + ", \""  + name + "\");");
  }
  
  void insertPersonPersonLnk(int origin_id, int target_id) {
    // connections are two-way so we need two insertions.
    db.execute("INSERT INTO 'person_person_link' (person_id, contact_id) values (" + origin_id + ", "  + target_id + ");");
    db.execute("INSERT INTO 'person_person_link' (person_id, contact_id) values (" + target_id + ", "  + origin_id + ");");
  }
  
  void insertPersonCityLink(int person_id, int city_id) {
    db.execute("INSERT INTO 'person_city_link' (person_id, city_id) values (" + person_id + ", "  + city_id + ");");
  }
  
  void insertCityCountryLink(int city_id, int country_id) {
    db.execute("INSERT INTO 'city_country_link' (city_id, country_id) values (" + city_id + ", "  + country_id + ");");
  }
  
  // queries
  
  int getCityByName(String name) {
    db.query("SELECT id FROM city WHERE name=\"" + name + "\";");
    if(db.next()) {
      return db.getInt("id");
    }
    return -1;
  }
  
  Boolean isCity(int id) {
    db.query("SELECT * FROM city WHERE id=" + id + ";");
    if(db.next()) {
      return true;
    }
    return false;
  }
  
  int numConnections(int id) {
    db.query("SELECT COUNT(contact_id) as 'count' FROM person_person_link WHERE person_id=" + id);
    if(db.next()) {
      return db.getInt("count");
    } 
    return -1;
  }
  
  ArrayList peopleWithMinimumConnections(int minCount) {
    ArrayList<int> tmpList = new ArrayList<int>();
    db.query("SELECT person_id, count FROM (SELECT person_id, COUNT(contact_id) as 'count' FROM person_person_link GROUP BY person_id) WHERE count >= " + minCount);
    while(db.next()) {
      tmpList.add(db.getInt("person_id"); 
    }
    return tmpList;
  }
  // Filters
  
  ArrayList filter(int total_degree, int previous_degree, int matches) {
    // TODO: look up previous data set. (not completely efficient to do this each time but it will work for now.
    // TOOD: look up people that have the minimum degree.
    
    db.query("SELECT * FROM 'person' ");
    return new ArrayList();
  }
  
}
