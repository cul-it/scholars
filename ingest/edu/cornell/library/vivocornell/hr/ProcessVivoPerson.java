package edu.cornell.library.vivocornell.hr;

import java.io.FileInputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.skife.csv.CSVReader;
import org.skife.csv.SimpleReader;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.vocabulary.RDF;
import com.hp.hpl.jena.vocabulary.RDFS;

public class ProcessVivoPerson extends IteratorMethods {

	public final Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
	public final Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 

	public static final Property JOB_TITLE = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#hrJobTitle");
	public static final Property PERSON_IN_POSN = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#personInPosition");
	public static final Property POSN_FOR_PERSON = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionForPerson");
	public static final Property POSITION_IN_ORGANIZATION = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionInOrganization");
	public static final Property ORGANIZATION_FOR_POSITION = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#organizationForPosition");
	public static final Property HEAD_IND = ResourceFactory.createProperty("http://vivoweb.org/ontology/newhr#headInd");
	public static final Property PRIMARY_WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle");

	public static final Resource ORGANIZATION = ResourceFactory.createProperty("http://vivoweb.org/ontology/foaf#Organization");

	public static final Resource POSITION_TYPE = ResourceFactory.createResource("http://vivoweb.org/ontology/core#Position");
	public static final Resource THING_TYPE = ResourceFactory.createResource("http://www.w3.org/2002/07/owl#Thing");
	public static final Resource MOST_SPECIFIC_TYPE = ResourceFactory.createResource("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#mostSpecificType");
	public static final Resource MAN_CURATED_TYPE = ResourceFactory.createResource("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#ManuallyCurated");

	private final Logger logger = Logger.getLogger(this.getClass());

	public String titleMapFile = IngestMain.fileRDFPath + "jobtitles5.csv";
	//CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();

	public CumulativeDeltaModeler processVivoperson(String personId, CumulativeDeltaModeler cdm) throws Exception {

		/**
		 * 20120327: stable, appears to be working properly
		 * need to fix UNION working title issue (Magnus Assistant Prof) and recurring orgs not visible to VIVO models)
		 * see 2nd pass adds/retracts
		 */

		// create models for correction and retraction
		Model retractionsForPerson = ModelFactory.createDefaultModel();
		Model additionsForPerson = ModelFactory.createDefaultModel();
		Model retractionsForPosition = ModelFactory.createDefaultModel();
		Model additionsForPosition = ModelFactory.createDefaultModel();	
		Model retractionsForOrg = ModelFactory.createDefaultModel();
		Model additionsForOrg = ModelFactory.createDefaultModel();		

		Model allAdditions = ModelFactory.createDefaultModel();

		Model CorrectedVIVOPersonRDF = ModelFactory.createDefaultModel();	

		// initialize flags
		boolean ignoreDiffRetract = false;
		boolean ignoreDiffAdd = false;
		boolean ignorePosnDiffRetract = false;
		boolean ignorePosnDiffAdd = false;

		CreateModel cm = new CreateModel();
		ReadWrite rw = new ReadWrite(); 
		CorrectHrData chd = new CorrectHrData(); 
		//***CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();	
		// go get all RDF for this VIVO person
		OntModel mdlOnePersonVIVORDF = cm.CreateOnePersonVivoRDF(personId);

		// if model is empty, that person does not exist in vivo (or something is wrong) so, bail out, next person
		if (mdlOnePersonVIVORDF.size() > 0 ) {

			// with subject (personId), create OntResource named vivoIndiv with all statements for individual
			OntResource vivoIndiv = mdlOnePersonVIVORDF.getOntResource(personId);

			// use vivoIndiv to get vivoEmplID and vivoNetId
			String vivoPersonEmplId = rw.getLiteralValue(vivoIndiv, HR_EMPLID);
			String vivoPersonNetId = rw.getLiteralValue(vivoIndiv, HR_NETID);

			// log VIVO rdf with VIVO netId
			logger.debug("VIVO RDF for " + vivoPersonNetId);			
			rw.LogRDF(mdlOnePersonVIVORDF, "N-TRIPLES");

			if (vivoPersonEmplId.equals("")) {
				logger.warn("WARNING: blank VIVO emplID for " + vivoIndiv + " does not exist in HRIS data.");
				//blankVIVOEmplIdException.add(CorrectedVIVOPersonRDF);
			}
			if (vivoPersonNetId.equals("")) {
				logger.warn("WARNING: blank VIVO netId for " + vivoIndiv + " does not exist in HRIS data.");
				//blankVIVOEmplIdException.add(CorrectedVIVOPersonRDF);
			}
			logger.debug("vivoEmplId - " + vivoPersonEmplId);
			logger.debug("vivoNetId - " + vivoPersonNetId);


				OntModel mdlOnePersonHRISRDF = cm.CreateOnePersonHrisRDF(vivoIndiv, vivoPersonEmplId, vivoPersonNetId);
				logger.debug("HRIS RDF for " + vivoPersonNetId);			
				rw.LogRDF(mdlOnePersonHRISRDF, "N-TRIPLES");


				// send emplId and netId to getQueryArgs, if emplId is blank, then use netId.
				String qStrOnePersonHRISRDF = rw.ModifyQuery(rw.getQueryArgs(vivoIndiv, vivoPersonEmplId, vivoPersonNetId));
				logger.trace(qStrOnePersonHRISRDF);

				mdlOnePersonHRISRDF = cm.MakeNewModelCONSTRUCT(qStrOnePersonHRISRDF); 	
				logger.debug("VIVO model has " + mdlOnePersonVIVORDF.size() + " statements.");
				logger.debug("HRIS model has " + mdlOnePersonHRISRDF.size() + " statements.");
				if (!mdlOnePersonHRISRDF.isEmpty()) {

					//Model CorrectedHRISPersonRDF = ModelFactory.createDefaultModel();	
					Model CorrectedHRISPersonRDF = chd.processHRISCorrections(mdlOnePersonHRISRDF, vivoIndiv);
					logger.info("done correcting HRIS statements for " + personId + ".");

					//WriteRdf(blankVIVOEmplIdExFile, blankVIVOEmplIdException, "N3");
					logger.debug("VIVO RDF");
					rw.LogRDF(mdlOnePersonVIVORDF, "N3");
					logger.debug("CorrectedHRISPerson RDF");
					rw.LogRDF(CorrectedHRISPersonRDF, "N3");
					Long numHRStatements = CorrectedHRISPersonRDF.size();
					if (numHRStatements < 1) {
						logger.warn("No statements in HRIS for "+ vivoIndiv + " : " + vivoPersonEmplId + " : " + vivoPersonNetId + ".  Does this person belong in VIVO?");
						//allNoHRISDataException.add(CorrectedVIVOPersonRDF);
						//!!! DON'T RETRACT VIVO STATEMENTS !!!
						ignoreDiffRetract = true;
					}
					//WriteRdf(noHRISdataExFile, allNoHRISDataException, "N3");

					// determine if isIgnore (based on ManuallyCurated or isEmeritus)


					// determine if isEmeritus


					// check to see if we have a manually curated flag set for this node

					// check to see if we have an AI user property
					// why do we care if this person is an AI user or not?				
					//boolean isAIuser = mdlOnePersonVIVORDF.contains(null, AIUSER);
					//logger.info("AI user? " + isAIuser);

					// testing retractions and additions
					try {
						logger.info("preparing retract/add RDF");  
						// killed iso check in favor of straight diff
						//if (!mdlOnePersonVIVORDF.isIsomorphicWith(CorrectedHRISPersonRDF)) {
						//	logger.info("Corrected VIVO is NOT isomorphic with Corrected HRIS.");
						// do work to figure out what's different between models and act accordingly with non-blanknode statements.
						// take the difference between current and existing RDF models

						if (ignoreDiffRetract) {
							logger.debug("retract suppressed.");
						} else {
							retractionsForPerson.add(mdlOnePersonVIVORDF.difference(CorrectedHRISPersonRDF));  
							if(retractionsForPerson.size() > 0) {
								logger.info("***" + retractionsForPerson.size() + " PROFILE RETRACTIONS ***");  
								retractionsForPerson.write(System.out, "N3");   
								cdm.retractModel(retractionsForPerson);
								logger.trace(retractionsForPerson);
								rw.LogRDF(cdm.getRetractions(), "N3");

							} else  {
								logger.info("*** NO PROFILE RETRACTIONS ***");
							}
						} //endif for ignoreDiffRetract

						if (ignoreDiffAdd) {
							logger.debug("addition suppressed.");
						} else {
							additionsForPerson.add(CorrectedHRISPersonRDF.difference(mdlOnePersonVIVORDF));
							if(additionsForPerson.size() > 0) {
								logger.info("*** " + additionsForPerson.size() + " PROFILE ADDITIONS ***");  
								additionsForPerson.write(System.out, "N3");                
								cdm.addModel(additionsForPerson);
								logger.trace(additionsForPerson);
								rw.LogRDF(cdm.getAdditions(), "N3");
							} else  {
								logger.info("*** NO PROFILE ADDITIONS ***");
							}
						} //endif for ignoreDiffRetract

						// reset flags
						ignoreDiffRetract = false;
						ignoreDiffAdd = true;

					} catch  ( Exception e ) {
						logger.error("Trouble adding profile RDF for this person to master add/retract model. Error" + e + "\n");
					} finally {
						logger.info("done with profile retract/add for " + personId + "." + "\n");
					}


					/* LDAP COMPARISON (FUTURE DEVELOPMENT)
			// set this up to pass netId to LDAP for uid search string
			logger.debug("this is where we'll eventually compare to LDAP...");

			Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
			NodeIterator netIditer = mdlOnePersonVIVORDF.listObjectsOfProperty(HR_NETID);
			String VIVOPersonNetId = "";
			while (netIditer.hasNext(  )) {		
				VIVOPersonNetId = netIditer.next(  ).toString(  );
			}  //end while for netiditer

			logger.debug("searching LDAP for " + VIVOPersonNetId);


			// in the event that netID is blank, pass label to LDAP for uid search string
			Property HR_LABEL = ResourceFactory.createProperty("http://www.w3.org/2000/01/rdf-schema#label"); 
			NodeIterator labeliter = mdlOnePersonVIVORDF.listObjectsOfProperty(HR_LABEL);
			String VIVOPersonlabel = "";
			while (labeliter.hasNext(  )) {		
				VIVOPersonlabel = labeliter.next(  ).toString(  );
			}  //end while for labeliter

			logger.debug("label: " + VIVOPersonlabel);

			//NOTE fix query to accept emplId


			String searchFilter = "";
			//rebuild search filter to look at netID = uid first
			searchFilter = makeLdapSearchFilter(VIVOPersonlabel);
			logger.debug(searchFilter);
			// turn this back on when LDAP is working

			//LDAPSearchResults thisResult = searchLdap(searchFilter);
			//String orgName = "orgName";
			//String resultString = ldapResult2String(thisResult, orgName, searchFilter);
			//logger.debug(resultString);

					 */

					//setup jobFamilymapping
					// TODO: determine if this should be another Sesame map done via query?
					Map<String,String> title2family = new HashMap<String,String>();
					//File titleMapFile = new File(getServletContext().getRealPath(TITLE_MAP_PATH));
					FileInputStream fis = new FileInputStream(titleMapFile);
					CSVReader csvReader = new SimpleReader();
					List<String[]> fileRows = csvReader.parse(fis);
					for(String[] row : fileRows) {
						title2family.put(row[0], row[1]);
					}


					// RDF FOR POSITIONS
					// ^^^^^  THIS NEEDS REPAIR 
					// now, look at positions for this person and compare VIVO positions with HRIS positions
					// first, set up VIVO positions
					String vivoPersonURI = vivoIndiv.getURI();
					// take a VIVO URI and modify query to return all position RDF (less org links)
					String vivoPersonURIString = ("<" + vivoPersonURI + ">");
					String vivoPosnQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrVIVOPositionDesc.txt");
					String[] queryArg2 = {vivoPosnQuery, "VARVALUE" , vivoPersonURIString};
					String qStrVIVOPositionRDF = rw.ModifyQuery(queryArg2); 
					logger.trace(qStrVIVOPositionRDF);
					long startTime = System.currentTimeMillis();

					// now, mdlVIVOPosnRDF holds all the position information about this VIVO person
					OntModel mdlVIVOPosnRDF = cm.MakeNewModelCONSTRUCT(qStrVIVOPositionRDF); 
					//OntModel mdlCorrectedVIVOPosnRDF = MakeNewModelCONSTRUCT(qStrVIVOPositionRDF);
					Model mdlCorrectedVIVOposnRdf = ModelFactory.createDefaultModel();
					logger.debug("VIVOposn link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");		

					String vivoHRJobTitle = null;

					// with each statement in VIVO position rdf that is a core:hrJobTitle, 
					List<Statement> vivoPosnList = mdlVIVOPosnRDF.listStatements((Resource) null, JOB_TITLE, (RDFNode) null).toList();
					Integer numVIVOPosn = vivoPosnList.size();

					for (Statement stmt : vivoPosnList ) {
						logger.info("number of VIVO positions: " + numVIVOPosn);

						/// are HRISPositionLabel and VIVOPosnTitle the same idea?  FIX THIS

						// prettify existing job title (if not already pretty)
						RDFNode VIVOPosnTitle = stmt.getObject();

						if (VIVOPosnTitle.isLiteral()) {
							// now we need the label from the position, because we need to prettify it
							vivoHRJobTitle = VIVOPosnTitle.asLiteral().getLexicalForm();
						} else {
							logger.debug("why is this not a literal? " + VIVOPosnTitle.toString() + " - " + stmt.getSubject().getURI());
							continue;
						}


						// this try added 02/14 as bandaid fix for position subclass

						try {
							Resource positionType = chd.getPositionType(vivoHRJobTitle, title2family);
							logger.debug("getPositionType is changing " + vivoHRJobTitle + " to " + positionType);
							//mdlVIVOPosnRDF.add(stmt.getSubject(),  RDF.type, positionType );
							mdlCorrectedVIVOposnRdf.add(stmt.getSubject(),  RDF.type, positionType );
							Resource employeeType = chd.getEmployeeType(positionType);
							mdlCorrectedVIVOposnRdf.add(stmt.getSubject(),  RDF.type, employeeType );
							//	mdlVIVOPosnRDF.add(stmt2.getSubject(),  RDF.type, positionType );
							//}				

						} catch  ( Exception e ) {
							logger.error("problem getting position subclass. Error", e );
						} 	


					}

					// this is all existing VIVO position RDF - will be retracted!
					logger.debug("*VIVO position RDF* \n");
					rw.LogRDF(mdlVIVOPosnRDF, "N-TRIPLES");

					// TODO consider renaming to MakeNewModel, parse as describe first?


					// now setup HRIS positions
					String hrisPosnQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrHRISPositionDesc.txt");

					//  get D2R person URI and pass to HRIS position query
					Resource hrisURI = mdlOnePersonHRISRDF.listSubjects().toList().get(0);
					String hrisURIString = ("<" + hrisURI.getURI() + ">");
					String[] queryArg3 = {hrisPosnQuery, "VARVALUE" , hrisURIString};
					String qStrHRISPositionRDF = rw.ModifyQuery(queryArg3); 
					// construct model with all hris position RDF for one person

					logger.trace(qStrHRISPositionRDF);
					startTime = System.currentTimeMillis();
					OntModel mdlHRISPosnRDF = cm.MakeNewModelCONSTRUCT(qStrHRISPositionRDF); 	
					rw.LogRDF(mdlHRISPosnRDF, "N3");
					logger.debug("\nHRISposn link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	

					List<Statement> hrisPosnList = mdlHRISPosnRDF.listStatements((Resource) null, RDFS.label, (RDFNode) null).toList();
					Integer numHRISPosn = hrisPosnList.size();
					logger.debug("number of HRIS positions: " + numHRISPosn);
					String hrisPosnLabel = null;
					String prettyTitle = null;
					Model mdlCorrectedHRISposnRdf = ModelFactory.createDefaultModel();
					//iterate through all statements in the hrisPositionRdf

					for (Statement stmt1 : hrisPosnList ) {
						RDFNode hrisLabelObject = stmt1.getObject();
						String headIndValue = null;
						if (hrisLabelObject.isLiteral()) {
							// now we need the label from the position, because we need to prettify it
							hrisPosnLabel = hrisLabelObject.asLiteral().getLexicalForm();
						} else {
							logger.debug("why is this not a literal? " + hrisLabelObject.toString() + " - " + stmt1.getSubject().getURI());
							continue;
						}

						try {
							//String hrisPosnLabel = getLiteralValue(hrisLabelObject, RDFS.label);
							prettyTitle = chd.getPrettyTitle(hrisPosnLabel);

							mdlHRISPosnRDF.remove(stmt1);
							mdlHRISPosnRDF.add(stmt1.getSubject(), RDFS.label, ResourceFactory.createPlainLiteral(prettyTitle));

						} catch  ( Exception e ) {
							logger.error("problem getting pretty title for posn. Error", e );
						} 		

						// this try added 02/14 as bandaid fix for position subclass

						try {
							Resource positionType = chd.getPositionType(prettyTitle, title2family);

							logger.debug("HRIS Position Type from pretty Title: " + positionType);
							//mdlVIVOPosnRDF.add(stmt.getSubject(),  RDF.type, positionType );
							List<Statement> checkPrimaryPosn = mdlHRISPosnRDF.listStatements(stmt1.getSubject(), HEAD_IND, (RDFNode) null).toList();
							for (Statement stmt9 : checkPrimaryPosn ) {
								//logger.info("PRIMARY? : " + stmt9);
								headIndValue = stmt9.getObject().toString();
								//mdlHRISPosnRDF.remove(stmt3);
								//mdlHRISPosnRDF.add(stmt3.getSubject(), POSN_FOR_PERSON, vivoIndiv );
							}

							if (positionType != null) {
								mdlCorrectedHRISposnRdf.add(stmt1.getSubject(),  RDF.type, positionType );

								if (headIndValue.equals("P")) {

									Resource employeeType = chd.getEmployeeType(positionType);
									mdlCorrectedHRISposnRdf.add(vivoIndiv,  RDF.type, employeeType );
									mdlCorrectedHRISposnRdf.add(vivoIndiv, PRIMARY_WORKING_TITLE, prettyTitle);
									// can we put PrimaryUnitID in here?
								}

								//List<Statement> changePosnRDFType = mdlVIVOPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
								//for (Statement stmt2 : changePosnRDFType ) {
								//mdlVIVOPosnRDF.remove(stmt2);

								//	mdlVIVOPosnRDF.add(stmt2.getSubject(),  RDF.type, positionType );
								//}				
								if (mdlCorrectedHRISposnRdf.isEmpty()) {
									logger.debug("*NO Position Type From Pretty Title* \n\n");
								} else {
									logger.debug("*Here is Position Type From Pretty Title* \n\n");
									mdlCorrectedHRISposnRdf.write(System.out, "N-TRIPLE");
								} 
							}  // if positionType is null, what do we do?

						} catch  ( Exception e ) {
							logger.error("problem getting position subclass. Error", e );
						} 	

						List<Statement> changePersInPosn = mdlHRISPosnRDF.listStatements((Resource) null, PERSON_IN_POSN, (RDFNode) null).toList();
						for (Statement stmt2 : changePersInPosn ) {
							mdlHRISPosnRDF.remove(stmt2);
							mdlHRISPosnRDF.add(vivoIndiv, PERSON_IN_POSN, stmt2.getObject() );
						}

						List<Statement> changePosnForPerson = mdlHRISPosnRDF.listStatements((Resource) null, POSN_FOR_PERSON, (RDFNode) null).toList();
						for (Statement stmt3 : changePosnForPerson ) {
							mdlHRISPosnRDF.remove(stmt3);
							mdlHRISPosnRDF.add(stmt3.getSubject(), POSN_FOR_PERSON, vivoIndiv );
						}
						/// TROUBLE - removed for testing


						try {
							logger.debug("*HRIS position RDF BEFORE corrections* \n");
							rw.LogRDF(mdlHRISPosnRDF, "N-TRIPLES");

							mdlHRISPosnRDF.add(mdlCorrectedHRISposnRdf);

							List<Statement> changePosnRDFType = mdlHRISPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
							for (Statement stmt4 : changePosnRDFType ) {

								// for each statement in HRIS model, remove rdf:type
								//mdlHRISPosnRDF.remove(stmt4);
								// add back rdf:type core:Position
								mdlHRISPosnRDF.add(stmt4.getSubject(),  RDF.type, POSITION_TYPE );
								// add back rdf:type core:Position with vivoURI?
								//mdlHRISPosnRDF.add(vivoIndiv,  RDF.type, POSITION_TYPE );
							}				
							// this is all HRIS position information minus org links - 
							logger.debug("*HRIS position RDF after corrections* \n");
							rw.LogRDF(mdlHRISPosnRDF, "N-TRIPLES");

						} catch  ( Exception e ) {
							logger.error("problem getting position subclass. Error", e );
						} 					

					} //end for stmt hris posn list





					// figure out whether these new HR positions have links to existing VIVO orgs or need new orgs minted
					try {
						// look at D2R position and search VIVO for pre-existing organization
						//desired behavior: always use the VIVO org if we have it, else use the D2R org
						// get org links from VIVO
						// if empty, add org links from HRIS
						// if !empty, then we want to use the VIVO org that corresponds to the HRIS D2R generated one, so, 
						// take the unit and dept ID and search through VIVO for it
						// if you find a match, use it in place of the D2R org
						// if !match, then use org generated by D2R

						logger.debug("**mdlVIVOPosnRDF:\n");
						rw.LogRDF(mdlVIVOPosnRDF, "N3");
						//TODO: this depends on rdf:type Position being in the model.  FIX THIS!
						//mdlHRISPosnRDF.add(cm.getVivoOrgLinks(mdlVIVOPosnRDF));
						//after VIVO org addition
						//logger.debug("*added VIVO orgs to position RDF* \n\n");
						//mdlHRISPosnRDF.write(System.out, "N-TRIPLE");


						// look at D2R position and generate D2R URI for orgs that don't appear in VIVO
						// query contains all D2R RDF for the orgs in question

						//String hrisPosnQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrGetPosnForOneHrisPerson.txt");
						String hrisOrgQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrGetPosnOrgForOneHrisPerson.txt");
						String[] queryArg4 = {hrisOrgQuery, "VARVALUE" , hrisURIString};
						String qStrmdlHRISOrgRDF = rw.ModifyQuery(queryArg4); 
						logger.trace("This is the query for getting all the Orgs for one person: \n");
						logger.trace(qStrmdlHRISOrgRDF);
						startTime = System.currentTimeMillis();
						OntModel mdlHRISOrgRDF = cm.MakeNewModelCONSTRUCT(qStrmdlHRISOrgRDF); 	
						logger.debug("Here's the list of D2R orgs attached to this position.");
						rw.LogRDF(mdlHRISOrgRDF, "N3");
						logger.debug("\nHRISposn org link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	

						//was Model mdlHRISOrgRDF = cm.getHRISOrgLinks(mdlHRISPosnRDF);
						if (!mdlHRISOrgRDF.isEmpty()) {
							// with each statement in mdlHRISOrgRDF, get full position data
							String hrisOrgVivoUriQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrGetHRISOrgRDFWithVivoUri.txt");
							String hrisOrgHrisUriQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrGetHRISOrgRDF.txt");		
							List<Statement> hrisOrgList = mdlHRISOrgRDF.listStatements((Resource) null, POSITION_IN_ORGANIZATION, (RDFNode) null).toList();
							Integer numHRISOrg = hrisOrgList.size();
							logger.debug("there are " + numHRISOrg + " orgs for this person.");
							for (Statement stmt5 : hrisOrgList ) {

								Resource positionUri = stmt5.getSubject();
								String positionUriString = positionUri.toString();
								RDFNode hrisOrgUri = stmt5.getObject();
								String hrisOrgUriString = hrisOrgUri.toString();
								hrisOrgUriString = "<" + hrisOrgUriString + ">";

								// does this HRIS org exist in VIVO? 

								String[] queryArg5 = {hrisOrgVivoUriQuery, "VARVALUE" , hrisOrgUriString};	
								String qStrmdlHRISOneOrgRDF = rw.ModifyQuery(queryArg5); 
								logger.debug("Here is the query for oneorg: \n\n" + qStrmdlHRISOneOrgRDF);
								startTime = System.currentTimeMillis();
								OntModel mdlHRISOneOrgRDF = cm.MakeNewModelCONSTRUCT(qStrmdlHRISOneOrgRDF); 
								Resource orgVivoUri = null;
								if (mdlHRISOneOrgRDF.isEmpty()) {
									// if nothing in model, then that Org is not in VIVO.  Add with HRIS URI
									String[] queryArg6 = {hrisOrgHrisUriQuery, "VARVALUE" , hrisOrgUriString};
									qStrmdlHRISOneOrgRDF = rw.ModifyQuery(queryArg6); 		
									logger.debug("Organization not in VIVO; revised query for oneorg: \n\n" + qStrmdlHRISOneOrgRDF);
									mdlHRISOneOrgRDF = cm.MakeNewModelCONSTRUCT(qStrmdlHRISOneOrgRDF); 	

								} else {
									// that org does exist in VIVO, so add the RDF that we got from the first query
									// and retract the HRIS org URIs info
									List<Statement> changeOrgLinks = mdlHRISOneOrgRDF.listStatements((Resource) null, RDF.type , (RDFNode) null).toList();
									for (Statement stmt7 : changeOrgLinks ) {
										orgVivoUri = stmt7.getSubject();

										mdlHRISPosnRDF.remove((Resource) hrisOrgUri, ORGANIZATION_FOR_POSITION, positionUri);
										mdlHRISPosnRDF.remove(positionUri, POSITION_IN_ORGANIZATION, hrisOrgUri);

										mdlHRISPosnRDF.add(orgVivoUri, ORGANIZATION_FOR_POSITION, positionUri );
										mdlHRISPosnRDF.add(positionUri, POSITION_IN_ORGANIZATION, orgVivoUri );
									}
								}	
								logger.debug("RDF for HRIS org.");
								rw.LogRDF(mdlHRISOneOrgRDF, "N3");
								logger.debug("\nHRISOneOrg link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	
								logger.debug("we have the person's VIVO URI:" + vivoPersonURIString +"\n");
								logger.debug("we have the person' D2R URI:" + hrisURIString +"\n");
								logger.debug("we have the D2R org URI:" + hrisOrgUriString +"\n");	
								logger.debug("we have the VIVO org URI:" + orgVivoUri +"\n");




								mdlHRISPosnRDF.add(mdlHRISOneOrgRDF);
								logger.info("Added RDF to mdlHRISPosnRDF.");
							}


							//after HRIS org addition
							logger.debug("*added HRIS orgs to position RDF* \n\n");
							mdlHRISPosnRDF.write(System.out, "N-TRIPLE");

						} 
						//additionsForPosn.add(mdlHRISPosnRDF);

						/*
					try {
						//remove inferred classes from vivo model before diff
						List<Statement> removeVIVORDFType = mdlVIVOPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
						for (Statement stmt5 : removeVIVORDFType ) {
							logger.info("*VIVO RDF stmt: \n" + stmt5);	
							logger.info(stmt5.getObject().toString());
							if (stmt5.getObject().toString().equals(THING_TYPE.toString())){
								mdlVIVOPosnRDF.remove(stmt5);
								logger.info("*removed vivo core:thing" + stmt5);	
							}
							if (stmt5.getObject().toString().equals(POSITION_TYPE.toString())){
								mdlVIVOPosnRDF.remove(stmt5);
								logger.info("*removed vivo core:position" + stmt5);
							}				
							if (stmt5.getObject().toString().equals(MOST_SPECIFIC_TYPE.toString())){
								mdlVIVOPosnRDF.remove(stmt5);
								logger.info("*removed vivo vitro:mostSpecificType" + stmt5);
							}		
						}

						//allAdditions.add(additionsForPosn);
					} catch  ( Exception e ) {
						logger.error("problem with retracting  VIVO inferred types. Error", e );
					}
						 */

						/*
					try {
						//remove inferred classes from HRIS model before diff
						List<Statement> removeHRISRDFType = mdlHRISPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
						for (Statement stmt6 : removeHRISRDFType ) {
							logger.info("*HRIS RDF stmt: \n" + stmt6);	
							logger.info(stmt6.getObject().toString());
							if (stmt6.getObject().toString().equals(THING_TYPE.toString())){
								mdlHRISPosnRDF.remove(stmt6);
								logger.info("*removed HRIS core:thing" + stmt6);	
							}
							if (stmt6.getObject().toString().equals(POSITION_TYPE.toString())){
								mdlHRISPosnRDF.remove(stmt6);
								logger.info("*removed HRIS core:position" + stmt6);
							}		
							if (stmt6.getObject().toString().equals(MOST_SPECIFIC_TYPE.toString())){
								mdlHRISPosnRDF.remove(stmt6);
								logger.info("*removed vivo vitro:mostSpecificType" + stmt6);
							}		
						}				
						//allAdditions.add(additionsForPosn);
					} catch  ( Exception e ) {
						logger.error("problem with retracting  inferred types. Error", e );
					}
						 */

						//allAdditions.add(additionsForPosn);
					} catch  ( Exception e ) {
						logger.error("problem with making org models. Error", e );
					} 		
					mdlVIVOPosnRDF = removeInferredClasses(mdlVIVOPosnRDF);
					mdlHRISPosnRDF = removeInferredClasses(mdlHRISPosnRDF);

					logger.debug("look for manually curated flag on VIVO position");
					ignorePosnDiffRetract = false;
					ignorePosnDiffAdd = false;
					List<Statement> checkManCuratedPosn = mdlVIVOPosnRDF.listStatements((Resource) null, RDF.type, MAN_CURATED_TYPE).toList();
					logger.debug("mancurated? = " + checkManCuratedPosn.size());
					if (checkManCuratedPosn.size() > 0) {
						logger.info("position is manually curated.");
						ignorePosnDiffRetract = true;
						ignorePosnDiffAdd = true;
					}


					// testing retractions and additions
					try {
						logger.info("preparing retract/add RDF for positions");  
						//TODO before you diff, remove rdf:type Position from models?
						// killed iso check in favor of straight diff
						//if (!mdlOnePersonVIVORDF.isIsomorphicWith(CorrectedHRISPersonRDF)) {
						//	logger.info("Corrected VIVO is NOT isomorphic with Corrected HRIS.");
						// do work to figure out what's different between models and act accordingly with non-blanknode statements.
						// take the difference between current and existing RDF models

						logger.info("*HRIS position RDF BEFORE retract* \n");
						rw.LogRDF(mdlHRISPosnRDF, "N-TRIPLES");
						logger.info("*VIVO position RDF BEFORE retract* \n");
						rw.LogRDF(mdlVIVOPosnRDF, "N-TRIPLES");					

						if (ignorePosnDiffRetract) {
							logger.info("position retract suppressed.");
						} else {
							retractionsForPosition.add(mdlVIVOPosnRDF.difference(mdlHRISPosnRDF));  
							if(retractionsForPosition.size() > 0) {
								logger.info("***" + retractionsForPosition.size() + " POSITION RETRACTIONS ***");  
								retractionsForPosition.write(System.out, "N3");    
								cdm.retractModel(retractionsForPosition);
								logger.trace(retractionsForPosition);
							} else  {
								logger.info("*** NO POSITION RETRACTIONS ***");
							}
						} //endif for ignoreDiffRetract

						if (ignorePosnDiffAdd) {
							logger.info("position addition suppressed.");
						} else {
							additionsForPosition.add(mdlHRISPosnRDF.difference(mdlVIVOPosnRDF));  
							//additionsForPosition.add(mdlCorrectedVIVOposnRdf);
							if(additionsForPosition.size() > 0) {
								logger.info("*** " + additionsForPosition.size() + " POSITION ADDITIONS ***");  
								additionsForPosition.write(System.out, "N3"); 
								cdm.addModel(additionsForPosition);
								logger.trace(additionsForPosition);
							} else  {
								logger.info("*** NO POSITION ADDITIONS ***");
							}
						} //endif for ignoreDiffRetract
						//} else {
						//	logger.info("");
						//	logger.info("VIVO profile is totally isomorphic with HRIS profile - so, no profile change necessary (?)");
						//	logger.info("");
						//}
						// reset flags
						ignorePosnDiffRetract = false;
						ignorePosnDiffAdd = true;

					} catch  ( Exception e ) {
						logger.error("Trouble adding position RDF for this person to master add/retract model. Error" + e + "\n");
					} finally {
						logger.info("done with position retract/add for " + personId + "." + "\n");
					}

					/**
				allRetractions.add(retractionsForPerson);

				allAdditions.add(additionsForPerson);
					 **/
					// this needs to change to reflect a position diff.

					//allRetractions.add(retractionsForPosition);
					cdm.retractModel(retractionsForPosition);
					//allAdditions.add(additionsForPosition);
					cdm.addModel(additionsForPosition);

					additionsForPerson.close();
					retractionsForPerson.close();
					additionsForPosition.close();
					retractionsForPosition.close();
					allAdditions = cdm.getAdditions();

					/*
		// what's the subject for mdlVIVOPosnRDF? (vivoURIString?), create OntResource with all statements for individual
		Resource hrisPosnURI = mdlVIVOPosnRDF.listSubjects().toList().get(0);
		String hrisPosnURIString = ("<" + hrisPosnURI.getURI() + ">");
		logger.debug("hrisPosnURIString: " + hrisPosnURIString);
		OntResource vivoPosnIndiv = mdlVIVOPosnRDF.getOntResource(hrisPosnURIString);
        //  now what?  there may be more than one org in this resource, so should we iterate?  
		 logger.debug("vivoPosnIndiv: " + vivoPosnIndiv);

		StmtIterator orgIter = vivoPosnIndiv.listProperties(POSN_IN_ORG);		
		while (orgIter.hasNext()) {
			Statement stmt      = orgIter.nextStatement();  // get next statement
			Resource  subject   = stmt.getSubject();     // get the subject
			Property  predicate = stmt.getPredicate();   // get the predicate
			RDFNode   object    = stmt.getObject();      // get the object

			// create strings for easier manipulation
			String strSubject = subject.toString();
			String strPredicate = predicate.toString();
			String strObject = object.toString();

			System.out.print(strSubject);
			System.out.print(" " + strPredicate + " ");
			System.out.print(" \"" + strObject + "\"");
			System.out.print("\n\n");

		}
					 */

				} else {
					logger.warn("HRIS model is empty, meaning this emplId/netId does not exist in HR data. Log this in exception file, suppress retract/add and move to next person.");

				}  // endif for !HRISEmplId==null


		} else {
			logger.warn("VIVO model is empty for the URI " + personId + ", meaning this emplId/netId does not exist in VIVO data.");


		}  // endif empty VIVO model
		return cdm;
	}//end method

	public OntModel removeInferredClasses(OntModel mdlBeforeDiff) throws Exception {	

		try {
			//remove inferred classes from vivo model before diff
			//List<Statement> removeVIVORDFType = mdlBeforeDiff.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
			List<Statement> removeVIVORDFType = mdlBeforeDiff.listStatements().toList();
			for (Statement stmt : removeVIVORDFType ) {
				//logger.info("*RDF stmt: \n" + stmt);	
				//logger.info(stmt.getObject().toString());
				if (stmt.getObject().toString().equals(THING_TYPE.toString())){
					mdlBeforeDiff.remove(stmt);
					logger.debug("*removed core:thing" + stmt);	
				}
				if (stmt.getObject().toString().equals(POSITION_TYPE.toString())){
					mdlBeforeDiff.remove(stmt);
					logger.debug("*removed core:position" + stmt);
				}				
				if (stmt.getPredicate().toString().equals(MOST_SPECIFIC_TYPE.toString())){
					mdlBeforeDiff.remove(stmt);
					logger.debug("*removed vitro:mostSpecificType" + stmt);
				}		


			}		
			//allAdditions.add(additionsForPosn);
		} catch  ( Exception e ) {
			logger.error("problem with retracting inferred types. Error", e );
		}
		return mdlBeforeDiff; 
	}

} //end class


