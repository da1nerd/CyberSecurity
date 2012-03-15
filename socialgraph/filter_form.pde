class FilterForm implements ControlListener {
  private ControlWindow ctrlwindow;
  private Textlabel labelTotal, labelToPrev, labelFromPrev;
  private Textfield fieldMinDeg, fieldMaxDeg, fieldMinDegToPrev, fieldMaxDegToPrev, fieldMinDegFromPrev, fieldMaxDegFromPrev;
  private controlP5.Button okButton, cancelbutton, resetbutton;
  private boolean updateExisting;
  private GraphFilter existingFilter;
  
  
  FilterForm(int p1, int p2, int p3, int p4, int p5, int p6) {  
	int h = 300;
	int w = 300;
    ctrlwindow = controlP5.addControlWindow("newFilterWindow",screen.width/2-w/2,screen.height/2-h/2,w,h);
    ctrlwindow.hideCoordinates();
    ctrlwindow.hide();
    
    // total degree
    labelTotal = controlP5.addTextlabel("labeltotal", "Total degree",10,10);
    labelTotal.setColorValue(color(255));
    labelTotal.setWindow(ctrlwindow);
    
    fieldMinDeg = controlP5.addTextfield("minDegree",10,25,30,20);
    fieldMinDeg.setLabel("min");
    fieldMinDeg.setText("" + p1);
    fieldMinDeg.setWindow(ctrlwindow);
    
    fieldMaxDeg = controlP5.addTextfield("maxDegree",100,25,30,20);
    fieldMaxDeg.setLabel("max");
    fieldMaxDeg.setText("" + p2);
    fieldMaxDeg.setWindow(ctrlwindow);
    
    // degree to previous
    labelToPrev = controlP5.addTextlabel("labeltoprev", "Degree to the previous filtered set",10,75);
    labelToPrev.setColorValue(color(255));
    labelToPrev.setWindow(ctrlwindow);
    
    fieldMinDegToPrev = controlP5.addTextfield("minDegreeToPrev",10,90,30,20);
    fieldMinDegToPrev.setLabel("min");
    fieldMinDegToPrev.setText("" + p3);
    fieldMinDegToPrev.setWindow(ctrlwindow);
    
    fieldMaxDegToPrev = controlP5.addTextfield("maxDegreeToPrev",100,90,30,20);
    fieldMaxDegToPrev.setLabel("max");
    fieldMaxDegToPrev.setText("" + p4);
    fieldMaxDegToPrev.setWindow(ctrlwindow);
    
    // degree from previous
    labelFromPrev = controlP5.addTextlabel("labelfromprev", "Degree from the previous filtered set",10,140);
    labelFromPrev.setColorValue(color(255));
    labelFromPrev.setWindow(ctrlwindow);
    
    fieldMinDegFromPrev = controlP5.addTextfield("minDegreeFromPrev",10,155,30,20);
    fieldMinDegFromPrev.setLabel("min");
    fieldMinDegFromPrev.setText("" + p5);
    fieldMinDegFromPrev.setWindow(ctrlwindow);
    
    fieldMaxDegFromPrev = controlP5.addTextfield("maxDegreeFromPrev",100,155,30,20);
    fieldMaxDegFromPrev.setLabel("max");
    fieldMaxDegFromPrev.setText("" + p6);
    fieldMaxDegFromPrev.setWindow(ctrlwindow);
    
    // buttons
    
    okButton = controlP5.addButton("newFilterOKButton");
    okButton.setSize(50, 20);
    okButton.setPosition(10, 235);
    okButton.setLabel("OK");
    okButton.setWindow(ctrlwindow);
    okButton.addListener(this);
  
    cancelbutton = controlP5.addButton("newFilterCancelButton");
    cancelbutton.setSize(50, 20);
    cancelbutton.setPosition(95, 235);
    cancelbutton.setLabel("Cancel");
    cancelbutton.setWindow(ctrlwindow);
    cancelbutton.addListener(this);
    
    resetbutton = controlP5.addButton("newFilterResetButton");
    resetbutton.setSize(50, 20);
    resetbutton.setPosition(180, 235);
    resetbutton.setLabel("Reset");
    resetbutton.setWindow(ctrlwindow);
    resetbutton.addListener(this);
  }
  
  // show the form for creating a new filter
  public void show() {
    ctrlwindow.setTitle("Create a new filter");
    updateExisting = false;
    ctrlwindow.show();
  }
  
  // show the form for updating an existing filter
  public void show(GraphFilter graphfilter) {
    ctrlwindow.setTitle("Update a filter");
    updateExisting = true;
    existingFilter = graphfilter;
    
    // pre-populate fields
    fieldMinDeg.setText("" + existingFilter._min_degree);
    fieldMaxDeg.setText("" + existingFilter._max_degree);
    fieldMinDegToPrev.setText("" + existingFilter._min_degree_curr_to_prev);
    fieldMaxDegToPrev.setText("" + existingFilter._max_degree_curr_to_prev);
    fieldMinDegFromPrev.setText("" + existingFilter._min_degree_curr_from_prev);
    fieldMaxDegFromPrev.setText("" + existingFilter._max_degree_curr_from_prev);
    
    ctrlwindow.show();
  }
  
  public void controlEvent(ControlEvent theEvent) {
    if(theEvent.controller().name() == "newFilterOKButton") {
      if(updateExisting) {
        // update existing filter
        loadFilter(existingFilter);
      } else {
        // create new filter
        fm.addFilter();
        loadFilter(fm.get(fm.size()-1));
      }
    } else if(theEvent.controller().name() == "newFilterCancelButton") {
      // hide the form,it gets trashed and remade when it is opened again.
      ctrlwindow.hide();
    } else if(theEvent.controller().name() == "newFilterResetButton") {
      fieldMinDeg.setText("-1");
      fieldMaxDeg.setText("-1"); 
      fieldMinDegToPrev.setText("-1"); 
      fieldMaxDegToPrev.setText("-1"); 
      fieldMinDegFromPrev.setText("-1"); 
      fieldMaxDegFromPrev.setText("-1");
    }
  }
  
  private void loadFilter(GraphFilter gf) {
    // TODO: error check
    gf.load(parseInt(fieldMinDeg.getText()),parseInt(fieldMaxDeg.getText()),parseInt(fieldMinDegToPrev.getText()),parseInt(fieldMaxDegToPrev.getText()),parseInt(fieldMinDegFromPrev.getText()),parseInt(fieldMaxDegFromPrev.getText()));
    fm._updated = true;
    ctrlwindow.hide();
  }
}
