class GraphFilter {
  String _name; // name of filter
  int _order; // order amongst other filters (0...n)
  ArrayList<Person> _people; // people collected by this filter
  // parameters used to build database query
  int _min_degree = -1; 
  int _max_degree = -1;
  // other parameters...
  
  GraphFilter(String name, int order) {
    _name = name;
    _order = order;
  }
  
  public void load(int min_degree, int max_degree) {
   _min_degree = min_degree;
   _max_degree = max_degree;
   _people = dbm.peopleWithConnections(_min_degree,_max_degree, false);
  }
}


/* Class to handle the filters
 *
 */
class FilterManager {
  ArrayList<GraphFilter> _filters;
  Boolean _updated;
  
  FilterManager() {
    _filters = new ArrayList<GraphFilter>();
    _updated = false;
  }
  
  // create a new empty filter
  public GraphFilter addFilter() {
    // initialize new filter with default name and order
    GraphFilter f1 = new GraphFilter("filter " + _filters.size(), _filters.size());
    _filters.add(f1);
    return f1;
  }
}
