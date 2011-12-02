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
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;



public class HRIngestSelectQuery27 {

	//setup constants for fileIO - MAKE CONSTANTS
	public static final String fileRDFPath = "C:\\Users\\cmw48\\workspace\\newhringest\\rdfdump\\";
	public static final String fileQryPath = "C:\\Users\\cmw48\\workspace\\newhringest\\queries\\";     

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

	public static String ConcatQueryString(String args[]) throws Exception {
		String queryStringAFile = args[0];
		String varValue = args[1];
		String queryStringBFile = args[2];
		
		String qStrA = ReadQueryString(fileQryPath + queryStringAFile);
		String qStrB = ReadQueryString(fileQryPath + queryStringBFile);
		String qStrConcat = qStrA + varValue + qStrB;
		return qStrConcat; 
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
		 *          -  implement log4j
		 *          -  continue to break up main into functional methods
		 */

	     // BasicConfigurator replaced with PropertyConfigurator.
	     PropertyConfigurator.configure(fileQryPath + "loggercfg.txt");
	     Logger logger = Logger.getLogger(HRIngestSelectQuery27.class);
	     logger.info("Entering application.");
		
		// pull all emplIds from VIVO service
		//read query string from text file 
		String qStrVIVOEmplId = ReadQueryString(fileQryPath + "qStrVIVOEmplId.txt");
		String vivoemplIdFileName = fileRDFPath + "vivoEmplIdTEST01.nt";
		System.out.println("creating model with all VIVO emplIds...");
		Model mdlVIVOemplId = MakeNewModelCONSTRUCT(qStrVIVOEmplId);
		WriteRdf(vivoemplIdFileName, mdlVIVOemplId, "N-TRIPLE");
		System.out.println("all done writing VIVO emplIds to nt file.");


		// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
		// keep original HRIS URI for diff process
		String qStrHRISmatchVIVO = ReadQueryString(fileQryPath + "qStrHRISmatchVIVO.txt"); 
		String HRISMatchFileName = fileRDFPath + "hrisMatchEmplId.nt";
		System.out.println("creating model where HRIS matches VIVO emplIds..");
		Model mdlHRISMatch = MakeNewModelCONSTRUCT(qStrHRISmatchVIVO);   
		System.out.println("constructed model from query, writing...");                   
		WriteRdf(HRISMatchFileName, mdlHRISMatch, "N-TRIPLE");
		System.out.println("created model named mdlHRISmatch and wrote to file.");


		// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
		// and align URIs so that new HRIS model URIs match the VIVO model URIs
		//GetHRISinVIVOemplId();
		String qStrHRISinVIVO = ReadQueryString(fileQryPath + "qStrHRISinVIVO.txt");
		String HRISVIVOFileName = fileRDFPath + "hrisInVIVOEmplId.nt";
		System.out.println("creating model with HRIS emplIds and VIVO uris...");
		Model mdlHRISVIVO = MakeNewModelCONSTRUCT(qStrHRISinVIVO);                 
		WriteRdf(HRISVIVOFileName, mdlHRISVIVO, "N-TRIPLE");
		System.out.println("created model named mdlHRISinVIVO.");


		//  gather ALL HRIS emplIds in a model 
		String qStrAllHRIS =  ReadQueryString(fileQryPath + "qStrAllHRIS.txt");
		String allHRISFileName = fileRDFPath + "allHRISEmplId.nt";
		System.out.println("creating model with ALL HRIS emplIds...");
		Model mdlAllHRIS = MakeNewModelCONSTRUCT(qStrAllHRIS);                                
		WriteRdf(allHRISFileName, mdlAllHRIS, "N-TRIPLE");
		System.out.println("querying HRISsource and populating Model mdlAllHRIS...");


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

		// example read: create mdlHRISMatch from existing nt file
		/*
		String HRISMatchfilename = fileRDFPath + "hrisMatchEmplId.nt";
		String readnamespace  = "http://vivo.cornell.edu/";
		String readfileformat = "N-TRIPLE";
		String[] readargs = {HRISMatchfilename, readnamespace, readfileformat};
		Model mdlHRISMatch = ReadRdf(readargs);
		System.out.println("read in Model mdlHRISMatch from file hrisMatchEmplId.nt...");
		 */


		/** Diff allHRIS and HRISmatch models to create a model with 
		 *    HRIS emplIds that do not exist in VIVO
		 *   Model difference(model1, model2)
		 *  remember we are diffing: HRISall - HRISmatch
		 */

		Model mdlHRISDiff = mdlAllHRIS.difference(mdlHRISMatch);

		// write diff RDF model to file
		String HRISDiffFilename = fileRDFPath + "hrisDiffEmplId.nt";
		WriteRdf(HRISDiffFilename, mdlHRISDiff, "N-TRIPLE");
		System.out.println("mdlHRISDiff now contains emplIds for HRIS not in VIVO .");

		//use Diff emplIds to construct all HRIS ADD RDF to make new persons in VIVO
		/** 
		 * Use DiffRDF to construct all NEW PERSON RDF
		 *     use Diff emplIds to construct all HRIS ADD RDF to make new persons in VIVO
		 *      writing HRIS ADD RDF for New Persons in HRIS not in VIVO.
		 *              edit this to query models directly if I can find out how
		 *              query string will take emplID from DiffRDF
		 *      (or HRIS rdf, if constructing Change RDF)
		 *
		 *  TODO: read in models, fix query, RDFWriter.
		 */                

		try {  // begin try for gathering new person RDF

			// begin while loop for iterating through list of emplIds not in VIVO
			// create models to hold all the accumulated RDF for all new people
			// this needs to be outside the while{} since it is the cumulative list
			Model mdlAllNewPeopleRDF = ModelFactory.createDefaultModel();
			// create models to hold the generated lists of positions and orgs as we go
			Model mdlAllNewPositionList = ModelFactory.createDefaultModel();
			Model mdlAllNewOrgList = ModelFactory.createDefaultModel();

			// iterate through list of new emplIds
			NodeIterator iter = mdlHRISDiff.listObjects(  );
			while (iter.hasNext(  )) {
				String NewPersonId = iter.next(  ).toString(  );

				// build query strings with each emplId in list of new people
				String[] strs = {"qStrNewPersonRDFa.txt", NewPersonId, "qStrNewPersonRDFb.txt"};
				String qStrNewPersonRDF = ConcatQueryString(strs); 

				String[] strs1 = {"qStrNewPositionLista.txt", NewPersonId, "qStrNewPositionListb.txt"};
				String qStrNewPositionList = ConcatQueryString(strs1); 

				/* FOR TESTING: when vivo joseki not available, temporarily hijack the VIVO query and 
                insert a single static emplId */
				//String qStrNewPersonRDF = qStrNewPersonRDFa + "1915368" + qStrNewPersonRDFb;
				
				try {  // with emplId in query, create CONSTRUCT rdf and push to HRIS model 

					// execute queries and populate model for new person RDF
					System.out.println("generating RDF for " + NewPersonId + " , adding to output model");
					Model mdlNewPersonRDF = MakeNewModelCONSTRUCT(qStrNewPersonRDF);    
					System.out.println("person RDF query complete.");

					// create model with position uri(s)
					System.out.println("finding positions for " + NewPersonId + "...");
					Model mdlNewPositionList = MakeNewModelCONSTRUCT(qStrNewPositionList);    
					System.out.println("positionlist query complete.");

					//inside new person model , look at and/or manipulate data
					try {
						// list the statements in the Model
						StmtIterator stmtiter = mdlNewPersonRDF.listStatements();
						System.out.println("analyzing statements in person RDF...");
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
							
							System.out.println(" .");
							
							// conditionals here to modify RDF before rewriting to model
							// create a SELECT CASE style list of things to to do person RDF
							
							// this one fixes space in label 
							if ((strPredicate).equals("http://www.w3.org/2000/01/rdf-schema#label")) {

								String delimiter = "\\,";
								String[] labelParts;
								labelParts = strObject.split(delimiter);
								String newLabel = labelParts[0] + ", " + labelParts[1];

								System.out.print(strSubject);
								System.out.print(" " + strPredicate + " ");
								System.out.print(" \"" + newLabel + "\"");

								// put the new value back in the model after modification  
								mdlNewPersonRDF.remove(subject, predicate, object);
								mdlNewPersonRDF.add(subject, predicate, newLabel);
							}    		
							
						}  // end while for person rdf statement iteration
						
					} catch ( Exception e ) {
                    
					} finally {
						System.out.println("done manipulating statments.");
					}	
					
					//write rdf from single new person query to file
					try {  // write N3 to console and append to output model
						System.out.println("found RDF for " + NewPersonId + " , adding to output model");
						mdlNewPersonRDF.write(System.out, "N3");
						mdlAllNewPeopleRDF.add(mdlNewPersonRDF);
						System.out.println("done writing to person RDF output model");
						
						// REMOVE: this will usually be only one or two positions, not necessary to write to console
						//mdlNewPositionList.write(System.out, "N3");

						// add any position ID's we collected to the master list
						System.out.println("found position for " + NewPersonId + " , adding to output model");
						mdlAllNewPositionList.add(mdlNewPositionList);
						System.out.println("done writing to position output model");

					} catch (Exception e)   {
						System.out.println("exception writing New Person RDF!  Error" + e);
					} finally {
						System.out.println("done processing " + NewPersonId + ".");
					}

				} catch (Exception e)   {
					System.out.println("exception while creating the output model!  Error" + e);
				} finally {

				}
			}    // end while loop for node iterator, all done checking people from emplId list
			
			// write allNewPersonRDF model to file
			String allNewHRISPersonFileName  = fileRDFPath + "allNewPersonRDFADD.n3";
			WriteRdf(allNewHRISPersonFileName, mdlAllNewPeopleRDF, "N3");

			// write allNewPositionList model to file
			String allNewHRISPositionListFileName  = fileRDFPath + "allNewPositionList.n3";
			WriteRdf(allNewHRISPositionListFileName, mdlAllNewPositionList, "N-TRIPLE");

			// now that all relevant person nodes have been processed, setup try for creating position RDF
			//   declaring mdlAllNewPositionRDF outside the try...
			Model mdlAllNewPositionRDF = ModelFactory.createDefaultModel();
			try {
				// list the statements in the position list Model (each individual position ID)
				NodeIterator posniter = mdlAllNewPositionList.listObjects(  );
				while (posniter.hasNext(  )) {
					String NewPositionId = posniter.next(  ).toString(  );

					//with every position Id in the list, generate appropriate RDF
					String[] strs4 = {"qStrNewPositionRDFa.txt", NewPositionId, "qStrNewPositionRDFb.txt"};
					String qStrNewPositionRDF = ConcatQueryString(strs4); 
					Model mdlNewPositionRDF = MakeNewModelCONSTRUCT(qStrNewPositionRDF); 
					mdlNewPositionRDF.write(System.out, "N3");
					mdlAllNewPositionRDF.add(mdlNewPositionRDF);

                    // with position ID in hand, generate a list of orgs
					String[] strs2 = {"qStrNewOrgLista.txt", NewPositionId, "qStrNewOrgListb.txt"};
					String qStrNewOrgList = ConcatQueryString(strs2); 
					Model mdlNewOrgList = MakeNewModelCONSTRUCT(qStrNewOrgList);    
					mdlNewOrgList.write(System.out, "N3");
					mdlAllNewOrgList.add(mdlNewOrgList);
				}  // end while for position node iterator

				//Remove after testing: 
				String allOrgFileName = fileRDFPath + "allOrgList.nt";
				WriteRdf(allOrgFileName, mdlAllNewOrgList, "N-TRIPLE");
				System.out.println("did orglist query");
				System.out.println(" .");

			} catch ( Exception e ) {

			} finally {
			}	//end try for 


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
	    logger.info("Exiting application.");
	}
}
