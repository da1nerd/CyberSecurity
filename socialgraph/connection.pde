/* this class defines a inter-person connection 
 *
 */
class Connection {
	private int _id;
	private boolean _visible;
	
	Connection(int id, boolean visible) {
		_id = id;
		_visible = visible;
	}
	
	/* get id of person to connect with
	 *
	 */
	public int getID() {
		return _id;
	}
	
	/* check if this connection should be displayed
	 *
	 */
	public boolean isVisible() {
		return _visible;
	}
}