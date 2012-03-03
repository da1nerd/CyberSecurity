import java.io.*;
import de.bezier.data.sql.*;

private SQLite db;

/*
NOTES:
trust the input does not have quotes
*/

// overload
void connectDB(String db_path) {
  connectDB(db_path, false);
}

// overload
void connectDB(String db_path, Boolean rebuild)
{
    /* PREPARE DATABASE */
    File f;
    f = new File(db_path);
    if(!f.exists()) {
      // new database
      println("creating new database [" + f.getPath() + "]");
      try {
        f.createNewFile();
      } catch(IOException ex) {
        println("ERROR CREATING DATABASE " + db_path);
      }
    } else if(rebuild) {
      // rebuild existing database
      println("rebulding database [" + f.getPath() + "]");
      try {
        f.delete();
        f.createNewFile();
      } catch(IOException ex) {
        println("ERROR REBUILDING DATABASE " + db_path);
      }
    }
    
    // open database file
    db = new SQLite( this, db_path ); 
    if ( db.connect() )
    {
        // reload the database if nessesary
        if(rebuild) { initDB(db); }
    } else {
      println("FAILED CONNECTING TO DATABASE " + db_path);
      // DIE!
      exit();
    }
}

void insertPerson(String name, int id) {
  db.execute("INSERT INTO 'person' (id, name) values (" + id + ", \""  + name + "\");");
}

void insertCity(String name, int id) {
  db.execute("INSERT INTO 'city' (id, name) values (" + id + ", \""  + name + "\");");
}

void insertCountry(String name, int id) {
  db.execute("INSERT INTO 'country' (id, name) values (" + id + ", \""  + name + "\");");
}

void insertPersonPersonLnk(int id_from, int id_to) {
  db.execute("INSERT INTO 'person_person_link' (person_id, contact_id) values (" + id_from + ", "  + id_to + ");");
}

void insertPersonCityLink(int id_from, int id_to) {
  db.execute("INSERT INTO 'person_city_link' (person_id, city_id) values (" + id_from + ", "  + id_to + ");");
}

int getCityByName(String name) {
  db.query("SELECT id FROM city WHERE name=\"" + name + "\";");
  if(db.next()) {
    return db.getInt("id");
  }
  return -1;
}

// initialize the database
private void initDB(SQLite database) {
  // create tables
  database.execute( "CREATE TABLE 'person' ('id' INTEGER PRIMARY KEY, 'name' TEXT, UNIQUE(name));" );
  database.execute( "CREATE TABLE 'city' ('id' INTEGER PRIMARY KEY, 'name' TEXT, UNIQUE(name));" );
  database.execute( "CREATE TABLE 'country' ('id' INTEGER PRIMARY KEY, 'name' TEXT, UNIQUE(name));" );
  database.execute( "CREATE TABLE 'person_city_link' ('person_id' INTEGER, 'city_id' INTEGER, FOREIGN KEY(person_id) REFERENCES person(id), FOREIGN KEY(city_id) REFERENCES city(id));" );
  database.execute( "CREATE TABLE 'person_person_link' ('person_id' INTEGER, 'contact_id' INTEGER, FOREIGN KEY(person_id) REFERENCES person(id), FOREIGN KEY(contact_id) REFERENCES person(id));" );
}


