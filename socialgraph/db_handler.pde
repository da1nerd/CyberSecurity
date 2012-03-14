
/* class to handle the database interaction.
 *
 */
class DBManager {
  // import libraries here so nothing else has raw access to it.
  import java.io.*;
  import de.bezier.data.sql.*;
  
  PApplet parent;
  private MySQL db; //SQLite db;
  
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
  
  /* connect to a database. set rebuild to true start from scratch. (rebuild takes about 6 minutes)
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
    db = new MySQL(parent, "localhost", "socialgraph", "root", ""); //db = new SQLite( parent , db_path ); 
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
  private void initDB(MySQL database) { //SQLite database) {
    println("Initializing database: " + database.database);
    database.execute("DROP TABLE IF EXISTS person");
    database.execute("DROP TABLE IF EXISTS city");
    database.execute("DROP TABLE IF EXISTS country");
    database.execute("DROP TABLE IF EXISTS person_city_link");
    database.execute("DROP TABLE IF EXISTS person_person_link");
    database.execute("DROP TABLE IF EXISTS city_country_link");
    database.execute("CREATE TABLE IF NOT EXISTS person (id INT, name VARCHAR(60));");
    database.execute("CREATE TABLE IF NOT EXISTS city (id INT, name  VARCHAR(60));");
    database.execute("CREATE TABLE IF NOT EXISTS country (id INT, name  VARCHAR(60));");
    database.execute("CREATE TABLE IF NOT EXISTS person_city_link (person_id INT, city_id INT);");
    database.execute("CREATE TABLE IF NOT EXISTS person_person_link (person_id INT, contact_id INT);");
    database.execute("CREATE TABLE IF NOT EXISTS city_country_link (city_id INT, country_id INT);");
  }
  
  // insertions
  
  void insertPerson(String name, int id) {
    db.execute("INSERT INTO person (id, name) VALUES (" + id + ", \""  + name + "\");");
  }
  
  void insertCity(String name, int id) {
    db.execute("INSERT INTO city (id, name) VALUES (" + id + ", \""  + name + "\");");
  }
  
  void insertCountry(String name, int id) {
    db.execute("INSERT INTO country (id, name) VALUES (" + id + ", \""  + name + "\");");
  }
  
  void insertPersonPersonLnk(int origin_id, int target_id) {
    // connections are two-way so we need two insertions.
    db.execute("INSERT INTO person_person_link (person_id, contact_id) VALUES (" + origin_id + ", "  + target_id + ");");
    db.execute("INSERT INTO person_person_link (person_id, contact_id) VALUES (" + target_id + ", "  + origin_id + ");");
  }
  
  void insertPersonCityLink(int person_id, int city_id) {
    db.execute("INSERT INTO person_city_link (person_id, city_id) VALUES (" + person_id + ", "  + city_id + ");");
  }
  
  void insertCityCountryLink(int city_id, int country_id) {
    db.execute("INSERT INTO city_country_link (city_id, country_id) VALUES (" + city_id + ", "  + country_id + ");");
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
  
  // return a list of people that have at least total_degree connections.
  // TODO: verify that these queries are accurate (there is a discrepancy between the fast and slow one, that causes me to question the validity of each.
  ArrayList<Person> peopleWithConnections(int min_degree, int max_degree, Boolean exhaustive) {
    ArrayList<Person> personList = new ArrayList<Person>();
    ArrayList<Integer> contactList = new ArrayList<Integer>();
    int currPerson = -1;
    String currName = "";
    
    if(exhaustive) {
      println("performing exhaustive query");
      // this takes a long time because we collect all of their connections
      db.query("SELECT pcount.person_id, p.name, ppl.contact_id FROM (SELECT person_id, COUNT(contact_id) as 'count' FROM person_person_link GROUP BY person_id) AS pcount INNER JOIN person_person_link as ppl ON ppl.person_id = pcount.person_id INNER JOIN person as p ON p.id = pcount.person_id WHERE count >= "+min_degree+" AND count <= " + max_degree);
    } else {
      println("performing quick query");
      // this is faster because we only select the local connections   
      db.query("SELECT person_id, person.name AS 'name', b.contact_id FROM (SELECT pcount.person_id AS 'person_id', ppl.contact_id AS 'contact_id' FROM (SELECT person_id, COUNT(contact_id) as 'count' FROM person_person_link GROUP BY person_id) as pcount INNER JOIN person_person_link as ppl ON ppl.person_id = pcount.person_id WHERE pcount.count >= "+min_degree+" AND pcount.count <= "+max_degree+") AS a INNER JOIN (SELECT pfilter.person_id, contact_filter.contact_id FROM (SELECT person_id as 'contact_id', COUNT(contact_id) as 'count' FROM person_person_link GROUP BY person_id) AS contact_filter INNER JOIN person_person_link as pfilter on pfilter.contact_id = contact_filter.contact_id WHERE contact_filter.count >= "+min_degree+" AND contact_filter.count <= "+max_degree+") AS b USING (person_id, contact_id) INNER JOIN person ON person.id = b.person_id");
    }
    int count = 0;
    while(db.next()) {
      // init and new person
      if(currPerson == -1 || currPerson != db.getInt("person_id")) {
        // just a new person
        if(currPerson != -1 && currPerson != db.getInt("person_id")) {
          personList.add(new Person(currPerson, currName, contactList));
        }
        count = 0;
        currPerson = db.getInt("person_id");
        currName = db.getString("name");
        contactList = new ArrayList<Integer>();
      }
      // build the contact list
      count ++;
      contactList.add(db.getInt("contact_id"));
    }  
    return personList;
  }
}

