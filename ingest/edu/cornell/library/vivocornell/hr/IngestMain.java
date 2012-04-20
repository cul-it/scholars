package edu.cornell.library.vivocornell.hr;

import java.util.Scanner;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.ResourceFactory;

//import edu.cornell.mannlib.vivo.hr.HRUpdateTest20getPosnSubclasses;

public class IngestMain {

	/* HR Ingest main class
	 * note, not static
	 */
	//set up constants for fileIO

	public static String fileRDFPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATErdfdump\\";
	public static String fileQryPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATEqueries\\";     
	// added to band-aid title/position subclass mapping.  TODO: make this a reader and open/close via in the read method.
	//public static String titleMapFile = fileRDFPath + "jobtitles5.csv";
	
	public final Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
	public final Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
	
	
	// originally, we thought we could run these queries against production Joseki, let's not do that anymore
	// public static Boolean useProductionVIVO = false;
	
	//set up logging for this class
    private static final Logger logger = Logger.getLogger(IngestMain.class);

	
	public static void main(String[] args) throws Exception {
		/** main method does the following: 
		 * setup logging
		 * read and process commandline args
		 * fire CreateNewHrisPersonList()
		 *      generates list of HRIS uri's 
		 * fire IterateThroughHrisPersonList()
		 *      iterates through list and fires processNewVivoPerson()
		 *            determines which HRIS not in VIVO, prepares RDF for basic addition
		 *      writes rdf to file?      
		 * if mdlAllUrisAdded !empty, pause to allow user to add them via add/remove interface before proceeding
		 *      else skip the pause and continue with update
		 * fire CreateAllVIVOPersonList()
		 *      builds list of all VIVO persons with netId or emplID
		 * fire IterateThroughVivoPersonList()
		 *      iterates over list of VIVO persons and fires processVivoPerson() for each
		 *           processes each one for HRIS updates to VIVO data, generates RDF
		 *      writes RDF
		 * TODO: then what? are there useful checksums or reports here?      
		 *      
		*/
	    try {	
		// setup logging	
		PropertyConfigurator.configure(fileQryPath + "loggercfg.txt");
		logger.info("Entering application.");
		String VivoUriFilename = null;
		CreateModel cm = new CreateModel();
		IteratorMethods im = new IteratorMethods();
		
		try {
		if (args.length != 0)  {
			logger.debug("args is not null");
			VivoUriFilename = cm.readFromFile(args);
		} else {
		logger.debug("no commandline args.");
		}
		} catch ( Exception e ){
			logger.error("Something didn't work while reading from file.  Error" , e );
		} 

		// future development: would we ever need to work from a list of HRIS uris?
		String HrisUriFilename = null;

 		String allNEWAdditionsFileName = fileRDFPath + "allNEWAdditions.nt";		
       
		// generate a model of all HRIS uris , check against VIVO model
		Model mdlAllNewHrisPerson = cm.CreateNewHrisPersonList(HrisUriFilename);
		logger.info("New HRIS person queries complete.  Iterating over results...");
		
		Model mdlAllUrisAdded = im.IterateThroughHrisPersonList(mdlAllNewHrisPerson);
		logger.info("New HRIS person additions complete.");
		
	    // pause for user input to allow loading of New Person RDF
		long totalHRISAdditions = mdlAllUrisAdded.size();
		if (totalHRISAdditions != 0) {
			logger.info("Pausing for user input - load RDF for " + totalHRISAdditions + " new HRIS persons and hit ENTER..." );
			Scanner sc = new Scanner(System.in);
		    while(!sc.nextLine().equals(""));	
		} else {
			logger.info("No new HRIS persons to add!" );
		}

		
        //  get a model of all (eligible) persons in VIVO
        Model mdlAllVIVOPerson = cm.CreateAllVIVOPersonList(VivoUriFilename);
		logger.info("VIVO query complete.  Iterating over results...");
		
		// iterate through model and update as needed, and return a model consisting of updated URIs 
		Model mdlVivoURIsUpdated = im.IterateThroughVivoPersonList(mdlAllVIVOPerson);
		logger.info("VIVO update complete.");
		

		} catch ( Exception e ){
			logger.error("Something got messed up while iterating over the person list.  Error" , e );

		} finally {
			//logger.info("done looking at all " + numHRISNewPersons + " VIVO persons.");
		}
	}

}
