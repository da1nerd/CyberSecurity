class GraphFilter {
  String _name; // name of filter
  int _order; // order amongst other filters (0...n)
  private ArrayList<Person> _people; // people collected by this filter
  // range of total degree
  int _min_degree = -1; 
  int _max_degree = -1;
  // range of degree to previous filtered set.
  int _min_degree_curr_to_prev = -1;
  int _max_degree_curr_to_prev = -1;
  // range of degree from previous filtered set.
  int _min_degree_curr_from_prev = -1;
  int _max_degree_curr_from_prev = -1;
  
  GraphFilter(String name, int order) {
    _name = name;
    _order = order;
    _people = new ArrayList<Person>();
  }
  
  public void load(int min_degree, int max_degree, int min_degree_curr_to_prev, int max_degree_curr_to_prev, int min_degree_curr_from_prev, int max_degree_curr_from_prev) {
   GraphFilter prev_filter = null;;
   _min_degree = min_degree;
   _max_degree = max_degree;
   _min_degree_curr_to_prev = min_degree_curr_to_prev;
   _max_degree_curr_to_prev = max_degree_curr_to_prev;
   _min_degree_curr_from_prev = min_degree_curr_from_prev;
   _max_degree_curr_from_prev = max_degree_curr_from_prev;
   
   // look up the previous filter
   if((_min_degree_curr_to_prev != -1 && _max_degree_curr_to_prev != -1) || (_min_degree_curr_from_prev != -1 && _max_degree_curr_from_prev != -1)) {
     for(int i = 0; i < fm._filters.size(); i ++) {
       if(fm._filters.get(i)._order == _order -1); {
         prev_filter = fm._filters.get(i);
       }
     }
   }
   
   // query the database
   _people = dbm.peopleWithConnections(_min_degree,_max_degree, false);
  }
  
  // get a person. return null if index is invalid
  public Person get(int index) {
    if(index < _people.size() && index >= 0) {
      return _people.get(index);
    } else {
      return null;
    }
  }
  
  // return how many people are in this filter
  public int size() {
    return _people.size();
  }
}


/* Class to handle the filters
 *
 */
class FilterManager {
  private ArrayList<GraphFilter> _filters;
  Boolean _updated;
  
  FilterManager() {
    _filters = new ArrayList<GraphFilter>();
    _updated = false;
  }
  
  // create a new empty filter
  public void addFilter() {
    // initialize new filter with default name and order
    _filters.add(new GraphFilter("filter " + _filters.size(), _filters.size()));
  }
  
  // return number of filters
  public int size() {
    
    return _filters.size();
  }
  
  // get a filter
  public GraphFilter get(int index) {
    return _filters.get(index);
  }
}
