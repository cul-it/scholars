/** HRIS Ingest Test v10
* methods to create RDF for HRIS adds and changes
* cmw48  Oct 2011
*  TODO:
*  
*   build netId match to find HRIS that should already be in VIVO
*   lots of work in ConstructHRISRDFData
*   implement log4j
*    
*    Learn how to pass Jena models between methods, or make them available to multiple methods
*      current workaround is to query from services and writing RDF to files
*      read files into model whenever they are needed
*      - allows re-use of RDF files for different tasks
*      - provides a baseline history for the state of add/retract based on emplId iso at time of ingest
*/    


package edu.cornell.mannlib.vivo.hr;

import java.util.Iterator;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFactory;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.RDFWriter;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.util.ResourceUtils;

import java.util.regex.*;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;


public class HRIngestSelectQuery40 {

	
	//setup constants for fileIO - MAKE CONSTANTS
	public static String fileRDFPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\rdfdump\\";
	public static String fileQryPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\queries\\";     
	public static Boolean useProductionVIVO = false;
	
	
	
    // BasicConfigurator replaced with PropertyConfigurator.

    static final Logger logger = Logger.getLogger(HRIngestSelectQuery40.class);
	
	public static Model MakeNewModelCONSTRUCT(String strQueryString) throws Exception {
		/**
		 * Takes a String strqueryString and returns a generic Model
		 *   model is written to RDF file for future use
		 *
		 *   TODO
		 *   create functionality for SELECT
		 */

		Model mdlNewModel = ModelFactory.createDefaultModel();
		try {
			// load vivo emplIDs into a model, then write RDF to file                

			Query qryNewQuery = QueryFactory.create(strQueryString, Syntax.syntaxARQ);
			QueryExecution qexecNewQuery = QueryExecutionFactory.create(qryNewQuery, mdlNewModel);
			try {
				logger.debug("querying source and populating Model...");

				//query VIVOsource for emplId and populate Model
				// execute queries and populate model
				// create CONSTRUCT rdf and push to HRIS model /
				qexecNewQuery.execConstruct(mdlNewModel);

			} catch (Exception e) { 

				logger.error("problem writing the new model!  Error" + e);

			}  finally {
				//close query execution
				qexecNewQuery.close();
			}                

		} catch (Exception e) { 
			logger.error("exception creating the VIVO model!  Error" + e);

		} finally {
			logger.debug("created new model...");
		}
		return mdlNewModel;
	}

	public static void WriteRdf(String filename, Model model, String RDFFormat) throws IOException  {
		//now, use RDFWriter to write the VIVO emplIDs to N-TRIPLES file
		FileOutputStream fstream = null;
		try {
			fstream = new FileOutputStream(filename);
			model.write(fstream, RDFFormat);
		} catch (Exception e) { 
			// do we have file exists/overwrite/backup logic to insert here?
					logger.error("problem with write process?, Error" + e);

		} finally {
			// close filestream
			if (fstream != null) {
				fstream.flush();
				fstream.close();

			}
		}
	}

	public static Model ReadRdf(String args[]) throws IOException {
		String filename = args[0];
		String basename = args[1];
		String readformat = args[2];
		
		Model mdlReadModel = ModelFactory.createDefaultModel();
		// now read in the HRIS emplID model
		FileInputStream readstream = null;
		try {
			readstream = new FileInputStream(filename);
			mdlReadModel.read(readstream, basename, readformat);
		} finally {
			if (readstream != null) {
				//            readstream.flush();
				readstream.close();
			}
			logger.debug(" Successfully read in the nt data from " + filename);
		}  //end try for read hrisEmplId
		return mdlReadModel;
	}

	public static String ReadQueryString(String filePath) throws IOException {
		String queryString = "";
		String serviceVIVO = "";
		String modifiedString = "";
				
		try {
		StringBuffer fileData = new StringBuffer(1000);
		BufferedReader reader = new BufferedReader(new FileReader(filePath));
		char[] buf = new char[1024];
		int numRead=0;
		while((numRead=reader.read(buf)) != -1){
			fileData.append(buf, 0, numRead);
		}
		reader.close();
		queryString = fileData.toString();
		
        // look for 
		
			if (useProductionVIVO) {
				serviceVIVO = "http://vivoprod01.library.cornell.edu:2020/sparql"; 
			} else {
				serviceVIVO = "http://bailey.mannlib.cornell.edu:2520/sparql"; 
			}
			

    	   String substring = "VIVOSERV";
		        
			
			if (queryString.contains(substring)) {
			  String [] replArgs = {queryString, "VIVOSERV", serviceVIVO };
			  modifiedString = ReplaceRegex(replArgs);
			  queryString = modifiedString;
			} else {
				System.out.print("...");
			}
		
		} catch (Exception e) {
			logger.error("whoops.  What happened?  " + e);
		} finally {

		}
		return queryString;
	}

	public static String ConcatQueryString(String args[]) throws Exception {

		String qStrConcat = "";
		try {
		String queryStringAFile = args[0];
		String varValue = args[1];
		String queryStringBFile = args[2];
		String qStrA = ReadQueryString(fileQryPath + queryStringAFile);
		String qStrB = ReadQueryString(fileQryPath + queryStringBFile);
		qStrConcat = qStrA + varValue + qStrB;
		} catch (Exception e) {
			logger.error("whoops.  Tossed error " + e);
		} finally {

		}
		return qStrConcat;
	}
	

	public static Model CreateAllHRIS(boolean readFromFile) throws Exception {
		Model mdlAllHRISPerson = ModelFactory.createDefaultModel();
		
		if (readFromFile) {
			// optional functionality :create separate logic for reading RDF from existing files 
			// instead of querying services.  Useful?  Maybe when services are down...
			// following commented code is an example read: create mdlHRISMatch from existing nt file
			/*
			String HRISMatchfilename = fileRDFPath + "hrisMatchEmplId.nt";
			String readnamespace  = "http://vivo.cornell.edu/";
			String readfileformat = "N-TRIPLE";
			String[] readargs = {HRISMatchfilename, readnamespace, readfileformat};
			Model mdlHRISMatch = ReadRdf(readargs);
			logger.debug("read in Model mdlHRISMatch from file hrisMatchEmplId.nt...");
			 */
		} else {	
			try {
			//  gather ALL HRIS emplIds in a model 
			String qStrAllHRISPerson=  ReadQueryString(fileQryPath + "qStrAllHRISPerson.txt");
			String allHRISFileName = fileRDFPath + "allHRISPersonURI.nt";
			logger.debug("creating model with ALL HRIS URIs...");
			logger.debug(qStrAllHRISPerson);
			mdlAllHRISPerson = MakeNewModelCONSTRUCT(qStrAllHRISPerson);                            
			WriteRdf(allHRISFileName, mdlAllHRISPerson, "N-TRIPLE");
			logger.debug("querying HRISsource and populating Model mdlAllHRISPerson...");
			
			} catch ( Exception e ) {
			    logger.error("exception writing All HRIS!  Error" + e);
		    } finally {

		    }
	    }
		return mdlAllHRISPerson;
    }
	

	public static Model CheckForNetID(Model mdlAllHRISPerson) throws Exception {
		 
		// pull all emplIds from VIVO service
		//read query string from text file 
		String qStrVIVOEmplIdAndNetID = ReadQueryString(fileQryPath + "qStrVIVOEmplIdAndNetId.txt");
		String vivoemplIdFileName = fileRDFPath + "vivoEmplIdAndNetId.nt";
		logger.debug("creating model with all VIVO emplIds...");
		Model mdlVIVOemplId = MakeNewModelCONSTRUCT(qStrVIVOEmplIdAndNetID);
		WriteRdf(vivoemplIdFileName, mdlVIVOemplId, "N-TRIPLE");
		logger.debug("all done writing VIVO emplIds to nt file.");          
		 
		
		
		Model mdlAlreadyInVIVO = ModelFactory.createDefaultModel();
		Model mdlNotAlreadyInVIVO = ModelFactory.createDefaultModel();
		Integer personCount = 0; 
		Integer netIdMatchCount = 0; 
		try {	
			// with HRISDiff, check netId to see if they exist in VIVO but don't have emplID
			NodeIterator netIditer = mdlAllHRISPerson.listObjects(  );
			logger.debug("checking diff list for netIds already in VIVO...");
			while (netIditer.hasNext(  )) {
			  String NewPersonId = netIditer.next(  ).toString(  );
			  //read query string from text file 
			  // build query strings with each emplId in list of new people
			  String qStrNetId = ReadQueryString(fileQryPath + "qStrCheckForNetId.txt");
			  String[] netIdstrs = {qStrNetId, "VARVALUE",  NewPersonId};
			  String qStrNetIdMatchRDF = ModifyQuery(netIdstrs); 

			  Model mdlVIVONetIdRDF = MakeNewModelCONSTRUCT(qStrNetIdMatchRDF);

			  long netIdTotal = mdlVIVONetIdRDF.size();

			  if (netIdTotal != 0) {
			    mdlAlreadyInVIVO.add(mdlVIVONetIdRDF);
			    netIdMatchCount++;
			  }
			  personCount++;	
			}    // end while loop for node iterator, all done checking people from emplId list		
			mdlNotAlreadyInVIVO = mdlAllHRISPerson.difference(mdlAlreadyInVIVO);

			// write diff RDF model to file
			String NotAlreadyInVIVOFilename = fileRDFPath + "NotAlreadyInVIVOEmplId.nt";
			WriteRdf(NotAlreadyInVIVOFilename, mdlNotAlreadyInVIVO, "N-TRIPLE");
			logger.debug("mdlNotAlreadyInVIVO now contains emplIds for HRIS not in VIVO .");
			} catch ( Exception e ){
			logger.error("exception writing NotAlreadyInVIVO!  Error" + e);
		} finally {
			String vivonetIdFileName = fileRDFPath + "NetIDAlreadyInVIVORDF.nt";
			WriteRdf(vivonetIdFileName, mdlAlreadyInVIVO, "N-TRIPLE");
			logger.debug("checked " + personCount + " HRIS diff records for netId matches, found " + netIdMatchCount +".");
			logger.debug("wrote emplId's for netId matches to nt file.");    
		}
		
		return mdlNotAlreadyInVIVO; 
	}
	

	
	public static Model CreateHRISDiff(Model mdlAllHRISPerson ) throws Exception {
		Model mdlHRISDiff = ModelFactory.createDefaultModel();
		Model mdlHRISAllMatch = ModelFactory.createDefaultModel();
		
		// create separate logic for reading RDF from existing files instead of querying services.

			try {	
     			// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
				// keep original HRIS URI for diff process
				String qStrHRISmatchVIVOEmplId = ReadQueryString(fileQryPath + "qStrHRISmatchVIVOEmplId.txt"); 
				String HRISMatchFileName = fileRDFPath + "hrisMatchEmplId.nt";
				logger.debug("creating model where HRIS matches VIVO emplIds..");
				logger.debug(qStrHRISmatchVIVOEmplId);
				Model mdlHRISMatchEmplId = MakeNewModelCONSTRUCT(qStrHRISmatchVIVOEmplId);   
				logger.debug("constructed model from query, writing...");                   
				WriteRdf(HRISMatchFileName, mdlHRISMatchEmplId, "N-TRIPLE");
				logger.debug("created model named mdlHRISmatch and wrote to file.");
				mdlHRISAllMatch.add(mdlHRISMatchEmplId);
				
     			// pull all HRIS netIDs from HRIS service WHERE HRIS.netId matches a VIVO.netId
				// keep original HRIS URI for diff process
				String qStrHRISmatchVIVONetId = ReadQueryString(fileQryPath + "qStrHRISmatchVIVONetId.txt"); 
				String HRISMatchNetIdFileName = fileRDFPath + "hrisMatchNetId.nt";
				logger.debug("creating model where HRIS matches VIVO netIds..");
				logger.debug(qStrHRISmatchVIVONetId);
				Model mdlHRISMatchNetId = MakeNewModelCONSTRUCT(qStrHRISmatchVIVONetId);   
				logger.debug("constructed model from query, writing...");                   
				WriteRdf(HRISMatchNetIdFileName, mdlHRISMatchNetId, "N-TRIPLE");
				logger.debug("created model named mdlHRISMatchNetId and wrote to file.");
				
				mdlHRISAllMatch.add(mdlHRISMatchNetId);




				/** 
				 * CHECK - 
				 * now we have: 
				 *   read VIVOemplId list into Model mdlVIVOemplId
				 *   read HRIS emplIds that exist in VIVO into Model mdlHRISmatch
				 *   read HRISemplId list (with VIVO URIs) into model mdlHRISinVIVO
				 *   written all models to corresponding nt files
				 *   
				 *   next up, 
				 *   (recreate models from files if desired?)
				 *   perform HRISDiff.difference(allHRIS - HRISmatch)
				 *     with emplId from diff, populate new model with all relevant HRIS 
				 *       data needed for Additions 
				 *     write diff model to RDF file for future use
				 *   
				 *   for operations on CHANGES, use HRISinVIVO, since URIs are 
				 *     aligned with VIVO
				 *   for ADD operations, use HRISmatch
				 *     
				 */

				/** Diff allHRIS and HRISmatch models to create a model with 
				 *    HRIS emplIds that do not exist in VIVO
				 *   Model difference(model1, model2)
				 *  remember we are diffing: HRISall - HRISmatch
				 */

				mdlHRISDiff = mdlAllHRISPerson.difference(mdlHRISAllMatch);
				
				//NOTE this only gives us HRIS not in VIVO based solely on EmplId
				

				// write diff RDF model to file
				String HRISDiffFilename = fileRDFPath + "hrisDiffEmplId.nt";
				WriteRdf(HRISDiffFilename, mdlHRISDiff, "N-TRIPLE");
				logger.debug("mdlHRISDiff now contains emplIds for HRIS not in VIVO .");

			} catch ( Exception e ) {
				logger.error("exception writing HRIS Diff!  Error" + e);
			} finally {

			}
		return mdlHRISDiff;
	}
	
	/**
	 * 
	 * createGetHRISVIVOISO
	 * 
	 * 				// THIS SHOULD MOVE TO GETHRISISO 
				// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
				// and align URIs so that new HRIS model URIs match the VIVO model URIs
				//GetHRISinVIVOemplId();
				String qStrHRISinVIVO = ReadQueryString(fileQryPath + "qStrHRISinVIVO.txt");
				String HRISVIVOFileName = fileRDFPath + "hrisInVIVOEmplId.nt";
				logger.debug("creating model with HRIS emplIds and VIVO uris...");
				logger.debug(qStrHRISinVIVO);
				Model mdlHRISVIVO = MakeNewModelCONSTRUCT(qStrHRISinVIVO);                 
				WriteRdf(HRISVIVOFileName, mdlHRISVIVO, "N-TRIPLE");
				logger.debug("created model named mdlHRISinVIVO.");
	 * 
	 */


	
	

	public static String ReplaceRegex(String[] args) 
	                         throws Exception {
		    String returnString = "";
	    	String startString = args[0];
	    	String findString = args[1];
	    	String replString = args[2];
	    	
	    	String finishString = "";

	        // Create a pattern to match FindString
	        Pattern p = Pattern.compile(findString);
	        // Create a matcher with an input string
	        Matcher m = p.matcher(startString);
	        StringBuffer sb = new StringBuffer();
	        boolean result = m.find();
	        boolean found = false; 
	        // Loop through and create a new String 
	        // with the replacements
	        while(result) {
	            m.appendReplacement(sb, replString);
	            result = m.find();
	            found = true;
	        }
	        // Add the last segment of input to 
	        // the new String
	        m.appendTail(sb);
	        finishString = (sb.toString());
	        if (!found) {
	        	System.out.println(findString + " not found.");
	            returnString = startString;
	        } else {
	        	returnString = finishString;
	        }
			return returnString;
	    }

	public static String ModifyQuery(String[] args) throws Exception {
		String modifiedString = "";
		String interimString = "";	    		 
		// baseQuery is original query string from text file
        String baseQuery = args[0];

		try {
			if (args.length == 5) {
				//two replacements to be done, use 3,4
				String[] replArgs = {baseQuery, args[3], args[4]};
				interimString = ReplaceRegex(replArgs);
			} else {
				// only one replacement, use 1,2
				interimString = baseQuery;
			}
			String[] replArgs = {interimString, args[1], args[2]};
			String tempString = ReplaceRegex(replArgs);
            modifiedString = tempString;
		} catch (Exception e) {
			logger.error("whoops.  Query mod threw error " + e);
		} finally {

		}

		return modifiedString;
	}
	
	public static Model GetEmplIds(Model mdlHRISDiff) throws Exception {
		Model mdlNotAlreadyInVIVO = ModelFactory.createDefaultModel();
		String GetEmplIdsBaseQuery = ReadQueryString(fileQryPath + "qStrGetEmplIds.txt");

		try {
			ResIterator personURIiter = mdlHRISDiff.listSubjects();
			while (personURIiter.hasNext(  )) {
				String NewHRISPersonURI = personURIiter.next(  ).toString(  );
				
				String[] queryArg1 = {GetEmplIdsBaseQuery, "VARVALUE", NewHRISPersonURI};
				String qStrNewHRISEmplIds = ModifyQuery(queryArg1);
				Model mdlNewHRISEmplIds = MakeNewModelCONSTRUCT(qStrNewHRISEmplIds);    
				mdlNewHRISEmplIds.write(System.out, "N3");
				logger.debug("writing URI EmplId to master list " + NewHRISPersonURI + "...");
				mdlNotAlreadyInVIVO.add(mdlNewHRISEmplIds);  
				
				
			}
			//Remove after testing: 
			String NotAlreadyInVIVOFileName = fileRDFPath + "NOTAlreadyInVIVO.nt";
			WriteRdf(NotAlreadyInVIVOFileName, mdlNotAlreadyInVIVO, "N-TRIPLE");  
			logger.debug("all organizations written to orglist...");
		} catch (Exception e) {
			logger.error("whoops.  EmplId create threw error " + e);
		} finally {

		}

		return mdlNotAlreadyInVIVO;
	}
	

	
	public static void main(String[] args) throws Exception {
		/**
		 * main method - 
		 *   CreateAllHRIS() - get list of URIs from HRIS data
		 *   CreateHRISDiff() - query VIVO
		 *     create list of netIds that match VIVO
		 *     create list of emplIds that match VIVO
		 *     add the two models together to make a list of Persons already in VIVO
		 *     diff 
		 *   
		 * 
		 *   GetVIVOemplId() - get list of IDs from SERVICE for VIVO, contains URI, 
		 *                       vivoNetId and vivoemplId
		 *   GetHRISemplId() - get list of IDs from SERVICE for external data, where
		 *                      extID matches an ID in the VIVO SERVICE.
		 *                   - modify external data URIs so they match the VIVO uris
		 *   DiffHRISandVIVO - diff the external data with the VIVO data, such that 
		 *                       only external IDs not in VIVO remain.
		 *   ConstructHRISRDFData - use diff external IDs to generate relevant 
		 *                            Additions RDF for external resources
		 *   
		 *   future: use same ID lists to generate all relevant RDF for existing 
		 *   VIVO resources, and compare to external RDF where ID's match
		 *   
		 *   TODO:  - build switch to query vivoprod01.library.cornell.edu:2020 OR
		 *              vivomigrate joseki  
		 *          -  build test to see if all services are operating    
		 *          -  continue to break up main into functional methods
		 */
		PropertyConfigurator.configure(fileQryPath + "loggercfg.txt");
		logger.info("Entering application.");
		
		if (args.length == 2) {
		fileRDFPath = args[0];
		fileQryPath = args[1];
		}
        
		boolean ReadFromFile = false;
		Model mdlAllHRISPerson = CreateAllHRIS(ReadFromFile);
		
		Model mdlNotAlreadyInVIVO1 = CheckForNetID(mdlAllHRISPerson);
		
		Model mdlHRISDiff = CreateHRISDiff(mdlAllHRISPerson);

		Model mdlNotAlreadyInVIVO = GetEmplIds(mdlHRISDiff);
		
		System.out.print("all done creating diff model.");

		//use Diff emplIds to construct all HRIS ADD RDF to make new persons in VIVO
		/** 
		 * Use DiffRDF to construct all NEW PERSON RDF
		 *     use Diff emplIds to construct all HRIS ADD RDF to make new persons in VIVO
		 *      writing HRIS ADD RDF for New Persons in HRIS not in VIVO.
		 *              edit this to query models directly if I can find out how
		 *              query string will take emplID from DiffRDF
		 *      (or HRIS rdf, if constructing Change RDF)
		 *
		 *  TODO: optional read in models, fix URI generation issues.
		 */                

		try {  // begin try for gathering new person RDF

			// begin while loop for iterating through list of emplIds not in VIVO
			// create models to hold all the accumulated RDF for all new people
			
			// this needs to be outside the while{} since it is the cumulative list
			Model mdlAllNewPeopleRDF = ModelFactory.createDefaultModel();

			// create models to hold the generated lists of positions and orgs as we go
			Model mdlAllNewPositionList = ModelFactory.createDefaultModel();
			Model mdlAllPositionLinks = ModelFactory.createDefaultModel();
			Model mdlAllNewOrgList = ModelFactory.createDefaultModel();

			// iterate through list of new emplIds
			//NodeIterator iter = mdlHRISDiff.listObjects(  );
			NodeIterator iter = mdlNotAlreadyInVIVO.listObjects(  );
			String newPersonRDFBaseQuery = ReadQueryString(fileQryPath + "qStrNewPersonRDF.txt");
			String newPositionListBaseQuery = ReadQueryString(fileQryPath + "qStrNewPositionList.txt");
			String newPositionLinksBaseQuery = ReadQueryString(fileQryPath + "qStrPositionRelationships.txt");
			String newPositionRDFBaseQuery = ReadQueryString(fileQryPath + "qStrNewPositionRDF.txt");
			String newOrgListBaseQuery = ReadQueryString(fileQryPath + "qStrNewOrgList.txt");
			String newOrgRDFBaseQuery = ReadQueryString(fileQryPath + "qStrNewOrgRDF.txt");
	
			
			
			Integer personCount = 0; 
			while (iter.hasNext(  )) {
				String NewPersonId = iter.next(  ).toString(  );
				
				System.out.print("made it to next module.  Here's the first emplId: " + NewPersonId);
				// build query strings with each emplId in list of new people
	
				String[] queryArg1 = {newPersonRDFBaseQuery, "VARVALUE", NewPersonId};
				String qStrNewPersonRDF = ModifyQuery(queryArg1);
				//String qStrNewPersonRDF = ConcatQueryString(strs); 
				System.out.print(qStrNewPersonRDF);
				
				String[] queryArg2 = {newPositionListBaseQuery, "VARVALUE" , NewPersonId};
				String qStrNewPositionList = ModifyQuery(queryArg2); 
				
				String[] queryArg3 = {newPositionLinksBaseQuery, "VARVALUE", NewPersonId};
				String qStrPositionLinks = ModifyQuery(queryArg3); 
				

				System.out.print(qStrNewPositionList);

				/* FOR TESTING: if vivo joseki not available, temporarily hijack the VIVO query and 
                insert a single static emplId */
				//String qStrNewPersonRDF = qStrNewPersonRDFa + "1915368" + qStrNewPersonRDFb;

				try {  // with emplId in query, create CONSTRUCT rdf and push to HRIS model 

					// execute queries and populate model for new person RDF
					logger.debug("generating RDF for " + NewPersonId + " , adding to output model");
					//System.out.print(qStrNewPersonRDF);
					Model mdlNewPersonRDF = MakeNewModelCONSTRUCT(qStrNewPersonRDF);    
					logger.info("person RDF query complete.");

					// execute queries and populate model for position relationship RDF
					logger.debug("generating position links for " + NewPersonId + " , adding to output model");
					//System.out.print(qStrNewPersonRDF);
					Model mdlPositionLinks = MakeNewModelCONSTRUCT(qStrPositionLinks);    
					logger.info("person RDF query complete.");
					
					
					
					// create model with position uri(s)
					logger.debug("finding positions for " + NewPersonId + "...");
					logger.debug(qStrNewPositionList);
					Model mdlNewPositionList = MakeNewModelCONSTRUCT(qStrNewPositionList);    
					logger.info("positionlist query complete.");
					String resourceNewName = "";
					//inside new person model , look at and/or manipulate data
					try {
						// list the statements in the single person model
						StmtIterator stmtiter = mdlNewPersonRDF.listStatements();
						logger.debug("analyzing statements in person RDF...");
						// print out the predicate, subject and object of each statement

						while (stmtiter.hasNext()) {
							Statement stmt      = stmtiter.nextStatement();  // get next statement
							Resource  subject   = stmt.getSubject();     // get the subject
							Property  predicate = stmt.getPredicate();   // get the predicate
							RDFNode   object    = stmt.getObject();      // get the object

							// create strings for easier manipulation
							String strSubject = subject.toString();
							String strPredicate = predicate.toString();
							String strObject = object.toString();

							logger.debug(" .");

							// conditionals here to modify RDF before rewriting to model
							// create a SELECT CASE style list of things to to do person RDF

							// this one loads the new URI from a data property into a variable
							if ((strPredicate).equals("http://vivoweb.org/ontology/newhr#/uriDataProp")) {

								resourceNewName = strObject; 
							}
							// this one fixes space in label 
							if ((strPredicate).equals("http://www.w3.org/2000/01/rdf-schema#label")) {

								String delimiter = "\\,";
								String[] labelParts;
								labelParts = strObject.split(delimiter);
								String newLabel = labelParts[0] + ", " + labelParts[1];

								System.out.print(strSubject);
								System.out.print(" " + strPredicate + " ");
								System.out.print(" \"" + newLabel + "\"");
								System.out.print("\n\n");
								// put the new value back in the model after modification  
								mdlNewPersonRDF.remove(subject, predicate, object);
								mdlNewPersonRDF.add(subject, predicate, newLabel);
							}    		


						}  // end while for person rdf statement iteration

					} catch ( Exception e ) {

					} finally {
						logger.debug("done manipulating statments.");
					}	
					
					// tried to rename resource with URI from dataproperty
					// iterate over finished person statements and correct URI 
					/*ResIterator newpersoniter =mdlNewPersonRDF.listSubjects();
					while (newpersoniter.hasNext(  )) {
					  Resource renameIt = mdlNewPersonRDF.getResource(newpersoniter.toString());
					  ResourceUtils.renameResource( renameIt, resourceNewName);

					}*/

					//write rdf from single new person query to file
					try {  // write N3 to console and append to output model
						logger.debug("found RDF for " + NewPersonId + " , adding to output model");
						mdlNewPersonRDF.write(System.out, "N3");
						mdlAllNewPeopleRDF.add(mdlNewPersonRDF);
						logger.debug("done writing to person RDF output model");

						// REMOVE: this will usually be only one or two positions, not necessary to write to console
						//mdlNewPositionList.write(System.out, "N3");

						// add any position ID's we collected to the master list
						logger.debug("found position for " + NewPersonId + " , adding to output model");
						mdlAllNewPositionList.add(mdlNewPositionList);
						logger.debug("done writing to position output model");
						
						// add all position relationship data to the master list
						mdlAllPositionLinks.add(mdlPositionLinks);
						logger.debug("done writing to positionlink output model");

					} catch (Exception e)   {
						logger.error("exception writing New Person RDF!  Error" + e);
					} finally {
						logger.info("done processing " + NewPersonId + ".");
					}

				} catch (Exception e)   {
					logger.error("exception while creating the output model!  Error" + e);
				} finally {
					personCount++;
				}
			}    // end while loop for node iterator, all done checking people from emplId list
			logger.debug("counted " + personCount + " new people to be added.");
			// write allNewPersonRDF model to file
			String allNewHRISPersonFileName  = fileRDFPath + "allNewPersonRDFADD.n3";
			WriteRdf(allNewHRISPersonFileName, mdlAllNewPeopleRDF, "N3");

			// write allNewPositionList model to file
			String allNewHRISPositionListFileName  = fileRDFPath + "allNewPositionList.n3";
			WriteRdf(allNewHRISPositionListFileName, mdlAllNewPositionList, "N-TRIPLE");
			
			// write mdlAllPositionLinks to file
			String allPositionLinksFileName  = fileRDFPath + "allPositionRelationships.n3";
			WriteRdf(allPositionLinksFileName, mdlAllPositionLinks, "N3");

			// now that all relevant person nodes have been processed, setup try for creating position RDF
			//   declaring mdlAllNewPositionRDF outside the try...
			Model mdlAllNewPositionRDF = ModelFactory.createDefaultModel();
			try {
				// list the statements in the position list Model (each individual position ID)
				ResIterator posniter = mdlAllNewPositionList.listSubjects(  );
				//NodeIterator posniter = mdlHRISDiff.listObjects(  );
				Integer positionCount = 0; 
				while (posniter.hasNext(  )) {
					String NewPositionId = posniter.next(  ).toString(  );
					//with every position Id in the list, generate appropriate RDF
					logger.debug("constructing RDF for " + NewPositionId + "...");
					
					
					String[] queryArg4 = {newPositionRDFBaseQuery, "VARVALUE", NewPositionId};
					String qStrNewPositionRDF = ModifyQuery(queryArg4); 
					//remove when working
					logger.debug(qStrNewPositionRDF);
					Model mdlNewPositionRDF = MakeNewModelCONSTRUCT(qStrNewPositionRDF); 
					//System.out.print(qStrNewPositionRDF);
					logger.debug("writing RDF for " + NewPositionId + "...");
					mdlNewPositionRDF.write(System.out, "N3");
					mdlAllNewPositionRDF.add(mdlNewPositionRDF);
					logger.debug("done processing " + NewPositionId + ".");
					positionCount++; 
					logger.debug(positionCount + " of " + personCount);

					// with position ID in hand, generate a list of orgs
					logger.debug("generating list of orgs for " + NewPositionId + "...");
					
					String[] queryArg5 = {newOrgListBaseQuery, "VARVALUE", NewPositionId};
					String qStrNewOrgList = ModifyQuery(queryArg5); 
					Model mdlNewOrgList = MakeNewModelCONSTRUCT(qStrNewOrgList);    
					mdlNewOrgList.write(System.out, "N3");
					logger.debug("writing orgs to master list " + NewPositionId + "...");
					mdlAllNewOrgList.add(mdlNewOrgList);  
				}  // end while for position node iterator

				//Remove after testing: 
				String allOrgFileName = fileRDFPath + "allOrgList.nt";
				WriteRdf(allOrgFileName, mdlAllNewOrgList, "N-TRIPLE");  
				logger.debug("all organizations written to orglist...");

			} catch ( Exception e ) {
				logger.error("exception creating RDF for new positions...  Error" + e);
			} finally {
			}	//end try for position iterator

			String allNewHRISPositionFileName  = fileRDFPath + "allNewPositionRDFADD.n3";
			WriteRdf(allNewHRISPositionFileName, mdlAllNewPositionRDF, "N3");



			Model mdlAllNewOrgRDF = ModelFactory.createDefaultModel();
			try {
				// list the statements in the org list Model (each individual org ID)
				NodeIterator orgiter = mdlAllNewOrgList.listObjects(  );
				long orgTotal = mdlAllNewOrgList.size();
				int	orgCount = 0;
				while (orgiter.hasNext(  )) {
					String NewOrgId = orgiter.next(  ).toString(  );

					//with every org Id in the list, generate appropriate RDF
					//take 
					
					// TODO: don't just generate org, check against VIVO orgs and link positions
					
					logger.debug("constructing RDF for org " + NewOrgId + "...");
					String[] queryArg6 = {newOrgRDFBaseQuery, "VARVALUE" , NewOrgId};
					String qStrNewOrgRDF = ModifyQuery(queryArg6); 
					//logger.debug(qStrNewOrgRDF);

					Model mdlNewOrgRDF = MakeNewModelCONSTRUCT(qStrNewOrgRDF); 
					
					logger.debug("writing RDF for " + NewOrgId + "...");
					mdlNewOrgRDF.write(System.out, "N3");

					mdlAllNewOrgRDF.add(mdlNewOrgRDF);
					logger.debug("done processing org " + NewOrgId + ".");

					// compare orgId to VIVO, match up URIs
					// statement iterator goes here
					orgCount++;
					logger.debug("processed " + orgCount + " distinct(?) records of " + orgTotal);
				}  // end while for position node iterator

				//Remove after testing: 
				//String allOrgFileName = fileRDFPath + "allOrgList.nt";
				//WriteRdf(allOrgFileName, mdlAllNewOrgList, "N-TRIPLE");

				String allNewHRISOrgFileName  = fileRDFPath + "allNewOrgRDFADD.n3";
				WriteRdf(allNewHRISOrgFileName, mdlAllNewOrgRDF, "N3");
				logger.debug("wrote orglist file");


			} catch ( Exception e ) {
				logger.error("exception creating RDF for new orgs...  Error" + e);
			} finally {
			}	//end try for orgiter



		} catch (Exception e)   {
			logger.error("exception creating RDF ...  Error" + e);
		} finally {
			// wrap it up
		}
		// future methods: 
		//use HRIS emplIds to construct all RDF for people who already exist in VIVO

		logger.info("All done.");
		logger.info("Exiting application.");
	}
}
