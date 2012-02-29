import javax.swing.JFileChooser;

public void openFile()
{
  JFileChooser chooser = new JFileChooser();
  chooser.setFileFilter(chooser.getAcceptAllFileFilter());
  
  int returnVal = chooser.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) 
  {
    // open file
    File file = chooser.getSelectedFile(); 
    // just print the contents to the console 
    // note: loadStrings can take a Java File Object too 
    String lines[] = loadStrings(file); 
    for (int i = 0; i < lines.length; i++) { 
      println(lines[i]);  
    }
  } else { 
    println("Open command cancelled by user."); 
  } 
}

