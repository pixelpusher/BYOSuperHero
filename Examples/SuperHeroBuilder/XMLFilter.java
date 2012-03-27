
import java.io.File;
import javax.swing.*;
import javax.swing.filechooser.*;

public class XMLFilter extends FileFilter {
 
    //Accept all directories and all gif, jpg, tiff, or png files.
    public boolean accept(File f) {
        if (f.isDirectory()) {
            return true;
        }

        return f.getPath().toLowerCase().endsWith("xml");
    }
 
    //The description of this filter
    public String getDescription() {
        return "XML files";
    }
}

