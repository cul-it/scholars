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
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.RDFWriter;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;


public class HRIngestSelectQuery25 {


	public static Model MakeNewModelCONSTRUCT(String strQueryString) throws Exception {
		/**
		 * Takes a String strqueryString and returns a generic Model
		 *   model is written to RDF file for future use
		 *
		 *   TODO
		 *   create functionality for SELECT
		 *   implement log4j
		 *   continue to break up 
		 */

		Model mdlNewModel = ModelFactory.createDefaultModel();
		try {
			// load vivo emplIDs into a model, then write RDF to file                

			Query qryNewQuery = QueryFactory.create(strQueryString);
			QueryExecution qexecNewQuery = QueryExecutionFactory.create(qryNewQuery, mdlNewModel);
			try {
				System.out.println("querying source and populating Model...");

				//query VIVOsource for emplId and populate Model
				// execute queries and populate model
				// create CONSTRUCT rdf and push to HRIS model /
				qexecNewQuery.execConstruct(mdlNewModel);

			} catch (Exception e) { 

				System.out.println("problem writing the new model!  Error" + e);

			}  finally {
				//close query execution
				qexecNewQuery.close();
			}                

		} catch (Exception e) { 
			System.out.println("exception creating the VIVO model!  Error" + e);

		} finally {
			System.out.println("created new model...");
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
					System.out.println("problem with write process?, Error" + e);

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
			System.out.println(" Successfully read in the nt data from hrisMatchEmplId.nt");
		}  //end try for read hrisEmplId
		return mdlReadModel;
	}

	public static String ReadQueryString(String filePath) throws IOException {
		StringBuffer fileData = new StringBuffer(1000);
		BufferedReader reader = new BufferedReader(
				new FileReader(filePath));
		char[] buf = new char[1024];
		int numRead=0;
		while((numRead=reader.read(buf)) != -1){
			fileData.append(buf, 0, numRead);
		}
		reader.close();
		return fileData.toString();
	}

	public static void main(String[] args) throws Exception {
		/**
		 * main method - 
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
		 */

		//setup constants for fileIO - MAKE CONSTANTS
		String fileRDFPath = "C:\\Users\\cmw48\\workspace\\newhringest\\rdfdump\\";
		String fileQryPath = "C:\\Users\\cmw48\\workspace\\newhringest\\queries\\";             

		// pull all emplIds from VIVO service

		//read query string from text file 
		String qStrVIVOEmplId = ReadQueryString(fileQryPath + "qStrVIVOEmplId.txt");


		String vivoemplIdFileName = fileRDFPath + "vivoEmplIdTEST01.nt";
		Model mdlVIVOemplId = MakeNewModelCONSTRUCT(qStrVIVOEmplId);
		WriteRdf(vivoemplIdFileName, mdlVIVOemplId, "N-TRIPLE");
		System.out.println("all done with writing VIVO emplIds to nt file.");


		// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
		// keep original HRIS URI for diff process
		//GetHRISMatchEmplId();
		String qStrHRISmatchVIVO = ReadQueryString(fileQryPath + "qStrHRISmatchVIVO.txt"); 

		// remove after testing complete
		//System.out.println(qStrHRISmatchVIVO);

		String HRISMatchFileName = fileRDFPath + "hrisMatchEmplId.nt";
		Model mdlHRISmatch = MakeNewModelCONSTRUCT(qStrHRISmatchVIVO);                      
		WriteRdf(HRISMatchFileName, mdlHRISmatch, "N-TRIPLE");
		System.out.println("Done with method GetHRISMatchEmplId - Created model named mdlHRISmatch.");

		// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
		// and align URIs so that new HRIS model URIs match the VIVO model URIs
		//GetHRISinVIVOemplId();
		String qStrHRISinVIVO = ReadQueryString(fileQryPath + "qStrHRISinVIVO.txt");

		// remove after testing complete
		//System.out.println(qStrHRISinVIVO);

		String HRISVIVOFileName = fileRDFPath + "hrisInVIVOEmplId.nt";
		Model mdlHRISVIVO = MakeNewModelCONSTRUCT(qStrHRISinVIVO);                 
		WriteRdf(HRISVIVOFileName, mdlHRISVIVO, "N-TRIPLE");
		System.out.println("Done with GetVIVOemplId - Created model named mdlHRISinVIVO.");

		/** 
		 * CHECK - 
		 * now we have: 
		 *   read VIVOemplId list into Model mdlVIVOemplId
		 *   read HRIS emplIds that exist in VIVO into Model mdlHRISmatch
		 *   read HRISemplId list (with VIVO URIs) into model mdlHRISinVIVO
		 *   written all models to corresponding nt files
		 *   
		 *   next up, 
		 *   recreate models from files
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

		/* Diff allHRIS and HRISmatch models to create a model with 
		 * HRIS emplIds that do not exist in VIVO
		 */

		/**  
		 * Create RDF that is the difference between HRIS emplID and VIVO emplId
		 *   read  HRISemplId list into model
		 *            read VIVO emplId RDF into model  (there should be iso between a 
		 *      subset of the HRIS data)
		 *            diff the HRIS model with the VIVO model, leaving only HRIS emplIds 
		 *     that are not in VIVO.
		 *            write the diff model to an RDF file
		 *            PROBLEMS: 
		 *     find out how to pass in memory model?
		 *        OR, just read both the VIVO emplID model and the HRIS emplID 
		 *        model from RDF, then diff them here.
		 *        
		 *        TODO: EVERYTHING.
		 */
		String qStrAllHRIS =  ReadQueryString(fileQryPath + "qStrAllHRIS.txt");

		// remove after testing complete
		//System.out.println(qStrAllHRIS);

		String allHRISFileName = fileRDFPath + "allHRISEmplId.nt";
		Model mdlAllHRIS = MakeNewModelCONSTRUCT(qStrAllHRIS);                                
		WriteRdf(allHRISFileName, mdlAllHRIS, "N-TRIPLE");
		System.out.println("querying HRISsource and populating Model mdlAllHRIS...");


		String HRISMatchfilename = fileRDFPath + "hrisMatchEmplId.nt";
		String readnamespace  = "http://vivo.cornell.edu/";
		String readfileformat = "N-TRIPLE";
		String[] readargs = {HRISMatchfilename, readnamespace, readfileformat};
		Model mdlHRISMatch = ReadRdf(readargs);
		System.out.println("read in Model mdlHRISMatch from file hrisMatchEmplId.nt...");

		// diff process goes here
		//  Model difference(model1, model2)
		// remember we are diffing:
		//  HRISall - HRISmatch
		Model mdlHRISDiff = mdlAllHRIS.difference(mdlHRISMatch);
		// write diff RDF model to file
		String HRISDiffFilename = fileRDFPath + "hrisDiffEmplId.nt";
		WriteRdf(HRISDiffFilename, mdlHRISDiff, "N-TRIPLE");
		System.out.println("mdlHRISDiff now contains emplIds for HRIS not in VIVO .");

		// populate models with data from nt files

		//use Diff emplIds to construct all HRIS ADD RDF to make new persons in VIVO

		/** 
		 * Use DiffRDF to construct all NEW PERSON RDF
		 * 
		 *            writing HRIS ADD RDF for New Persons in HRIS not in VIVO.
		 *              (right now, this finds every statement where emplId matches.)
		 *    change it such that we feed it an emplId, and it generates all the 
		 *      relevant RDF for that person.
		 *              edit this to query models directly if I can find out how
		 *              query string will take emplID from DiffRDF
		 *      (or HRIS rdf, if constructing Change RDF)
		 *
		 *  TODO: read in models, fix query, RDFWriter.
		 */                

		String qStrNewPersonRDFa = ReadQueryString(fileQryPath + "qStrNewPersonRDFa.txt");
		// the middle part of the string will be the Diff EmplId
		String qStrNewPersonRDFb = ReadQueryString(fileQryPath + "qStrNewPersonRDFb.txt");
		
		String qStrNewPositionRDFa = ReadQueryString(fileQryPath + "qStrNewPositionRDFa.txt");
		// the middle part of the string will be the Diff EmplId
		String qStrNewPositionRDFb = ReadQueryString(fileQryPath + "qStrNewPositionRDFb.txt");		

		// load a model with the HRISDiff emplIds ( all emplIds in HRIS not in VIVO )
		// use newly created mdlHRISDiff
		// option to read hrisDiffEmplId.nt
		//ConstructHRISRDFData();         
		try {  // begin try for gathering new person RDF

			// begin while loop for iterating through list of emplIds not in VIVO

			//create model to hold all the accumulated RDF for all new people
			//
			// this needs to be outside the while{} since it is the cumulative list
			Model mdlAllNewPeopleRDF = ModelFactory.createDefaultModel();
			Model mdlAllNewPositionRDF = ModelFactory.createDefaultModel();
			Model mdlAllNewOrgsRDF = ModelFactory.createDefaultModel();
			
			NodeIterator iter = mdlHRISDiff.listObjects(  );
			while (iter.hasNext(  )) {
				String NewPersonId = iter.next(  ).toString(  );

				// insert diff emplId into query string 
				String qStrNewPersonRDF = qStrNewPersonRDFa + NewPersonId + qStrNewPersonRDFb;
				String qStrNewPositionRDF = qStrNewPositionRDFa + NewPersonId + qStrNewPositionRDFb;

				/* because of issues with vivo joseki, temporarily hijack the VIVO query and 
                                                                insert a single static emplId */
				//String qStrNewPersonRDF = qStrNewPersonRDFa + "1915368" + qStrNewPersonRDFb;
       
				// execute queries and populate model
				Model mdlNewPersonRDF = ModelFactory.createDefaultModel();
				Query qryNewPersonRDF = QueryFactory.create(qStrNewPersonRDF);
				QueryExecution qexecNewPersonRDF = QueryExecutionFactory.create(qryNewPersonRDF, mdlNewPersonRDF);

				Model mdlNewPositionRDF = ModelFactory.createDefaultModel();
				Query qryNewPositionRDF = QueryFactory.create(qStrNewPositionRDF);
				QueryExecution qexecNewPositionRDF = QueryExecutionFactory.create(qryNewPositionRDF, mdlNewPositionRDF);
				
				//FileOutputStream fstream = null;
				try {  // create CONSTRUCT rdf and push to HRIS model 
					qexecNewPersonRDF.execConstruct(mdlNewPersonRDF);
					System.out.println("did person RDF query");
					// conditionals here to modify RDF before rewriting to model
					qexecNewPositionRDF.execConstruct(mdlNewPositionRDF);
					System.out.println("did person RDF query");


					//inside new person model , look at and manipulate data
					try {
						// list the statements in the Model
						StmtIterator stmtiter = mdlNewPersonRDF.listStatements();

						// print out the predicate, subject and object of each statement
						while (stmtiter.hasNext()) {
							Statement stmt      = stmtiter.nextStatement();  // get next statement
							Resource  subject   = stmt.getSubject();     // get the subject
							Property  predicate = stmt.getPredicate();   // get the predicate
							RDFNode   object    = stmt.getObject();      // get the object
                            // once we have them, manipulate them
							String strSubject = subject.toString();
							String strPredicate = predicate.toString();
							String strObject = object.toString();
							
							if ((strPredicate).equals("http://www.w3.org/2000/01/rdf-schema#label")) {
						    	
						    	String delimiter = "\\,";
						    	String[] labelParts;
                                labelParts = strObject.split(delimiter);
                                String newLabel = labelParts[0] + ", " + labelParts[1];
                                
								System.out.print(strSubject);
							    System.out.print(" " + strPredicate + " ");
							    System.out.print(" \"" + newLabel + "\"");
							   /* if (object instanceof Resource) {
							    	System.out.print(strObject);
							    } else {
							    	// object is a literal
							    	System.out.print(" \"" + strObject + "\"");
                                 
							    	
							    }*/   
							    
							 // figure out how to put them back in the model afterwards  
							    mdlNewPersonRDF.remove(subject, predicate, object);
							    mdlNewPersonRDF.add(subject, predicate, newLabel);
							}    		
							System.out.println(" .");
						} 
					} catch ( Exception e ) {

					} finally {
					}	
					//write rdf from single new person query to file
					try {  // write N3 to console and append to output model

						mdlNewPersonRDF.write(System.out, "N3");
						mdlAllNewPeopleRDF.add(mdlNewPersonRDF);
						
						mdlNewPositionRDF.write(System.out, "N3");
						mdlAllNewPositionRDF.add(mdlNewPositionRDF);
						
					} catch (Exception e)   {
						System.out.println("exception writing New Person RDF!  Error" + e);
					} finally {
						System.out.println("found RDF for " + NewPersonId + " , adding to output model");
					}

				} catch (Exception e)   {
					System.out.println("exception while creating the output model!  Error" + e);
				} finally {
					qexecNewPersonRDF.close();
				}
			}    // end while loop for node iterator
			// write all RDF model to file
			String allNewHRISPersonFileName  = fileRDFPath + "allNewPersonRDFADD.n3";
			WriteRdf(allNewHRISPersonFileName, mdlAllNewPeopleRDF, "N3");
			
			String allNewHRISPositionFileName  = fileRDFPath + "allNewPositionRDFADD.n3";
			WriteRdf(allNewHRISPositionFileName, mdlAllNewPositionRDF, "N3");

		} catch (Exception e)   {
			System.out.println("exception creating RDF for new people...  Error" + e);
		} finally {
			// wrap it up
		}
		// future methods: 
		//use HRIS emplIds to construct all RDF for people who already exist in VIVO

		System.out.println("All done.");
	}
}
