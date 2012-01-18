package edu.cornell.mannlib.vivo.hr;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.vocabulary.RDF;
import com.hp.hpl.jena.vocabulary.RDFS;
import com.novell.ldap.LDAPAttribute;
import com.novell.ldap.LDAPConnection;
import com.novell.ldap.LDAPConstraints;
import com.novell.ldap.LDAPEntry;
import com.novell.ldap.LDAPException;
import com.novell.ldap.LDAPSearchResults;



public class HRUpdateTest05 {

	//set up constants for fileIO

	public static String fileRDFPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATErdfdump\\";
	public static String fileQryPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATEqueries\\";     
	public static Boolean useProductionVIVO = false;
	public static Boolean readFromFile = false;


	public static final Property PRIMARY_JOBCODE_LDESC = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc");
	public static final Property PRIMARY_WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle");
	public static final Property WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#WorkingTitle");
	public static final Property AIUSER = ResourceFactory.createProperty("http://vivoweb.org/ontology/activity-insight#aiUser");	   
	public static final Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
	//set up logging
	static final Logger logger = Logger.getLogger(HRUpdateTest05.class);


	//methods for creating models, file i/o, etc

	public static OntModel MakeNewModelCONSTRUCT(String strQueryString) throws Exception {
		/**
		 * Takes a String strqueryString and returns a generic Model
		 *   model is written to RDF file for future use
		 *
		 *   TODO
		 *   create functionality for SELECT
		 */

		OntModel mdlNewModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		try {
			// load vivo emplIDs into a model, then write RDF to file                

			Query qryNewQuery = QueryFactory.create(strQueryString, Syntax.syntaxARQ);
			QueryExecution qexecNewQuery = QueryExecutionFactory.create(qryNewQuery, mdlNewModel);
			try {
				//logger.debug("querying source and populating Model...");

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
			//logger.debug("created new model...");
		}
		return mdlNewModel;
	}

	public static void LogRDF(Model model, String RDFFormat) throws IOException  {
		//now, use RDFWriter to write the VIVO emplIDs to N-TRIPLES file

		try {

			logger.debug(model);
		} catch (Exception e) { 
			// do we have file exists/overwrite/backup logic to insert here?
			logger.error("problem with write process?, Error" + e);

		} finally {

		}
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
			logger.debug(findString + " not found." + "\n");
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

	// methods for doing specific tasks

	public static Model CreateAllVIVOPersonList(boolean readFromFile) throws Exception {
		Model mdlAllVIVOPerson = ModelFactory.createDefaultModel();

		if (readFromFile) {
			// optional functionality :create separate logic for reading RDF from existing files 
			// instead of querying services.  Useful?  Maybe when services are down...
			// following commented code is an example read: create mdlHRISMatch from existing nt file
			/*
			String VIVOMatchfilename = fileRDFPath + "VIVOMatchEmplId.nt";
			String readnamespace  = "http://vivo.cornell.edu/";
			String readfileformat = "N-TRIPLE";
			String[] readargs = {VIVOMatchfilename, readnamespace, readfileformat};
			Model mdlVIVOMatch = ReadRdf(readargs);
			logger.debug("read in Model mdlVIVOMatch from file VIVOMatchEmplId.nt...");
			 */
		} else {	
			try {
				//  gather ALL VIVO person (with either netId or emplId) in a model 
				String qStrAllVIVOPerson=  ReadQueryString(fileQryPath + "qStrAllVIVOPerson.txt");
				String allVIVOFileName = fileRDFPath + "allVIVOPersonURI.nt";
				logger.info("creating VIVO model...");
				logger.debug("using this query: \n" + qStrAllVIVOPerson);
				mdlAllVIVOPerson = MakeNewModelCONSTRUCT(qStrAllVIVOPerson);                            
				WriteRdf(allVIVOFileName, mdlAllVIVOPerson, "N-TRIPLE");
				logger.debug("querying VIVOsource and populating Model mdlAllVIVOPerson...");

			} catch ( Exception e ) {
				logger.error("exception writing All VIVO!  Error" + e);
			} finally {

			}
		}
		return mdlAllVIVOPerson;
	}

	public static String makeLdapSearchFilter(String fullname){
		int comma = fullname.indexOf(','),space1=-1,space2=-1;
		if(comma<0){
			logger.debug("name lacks a comma: " + fullname + "\n");
			return null;
		}
		StringBuffer filter=new StringBuffer("(&(!(type=student*))(!(type=alumni*))"); //no students or alumni from ldap
		String cn=null, strictGivenNames=null, looseGivenNames=null;
		String first=null,middle=null,last=null; 
		last=fullname.substring(0,comma).trim();
		space1=fullname.indexOf(' ',comma+1);
		space2=fullname.indexOf(' ',space1+1);
		if(space2 < 0){ //nothing after first name
			first=fullname.substring(space1).trim();
		}else{ //there is a middle name there
			first=fullname.substring(space1,space2).trim();
			middle=fullname.substring(space2+1).trim();
		}

		if(first!=null && first.indexOf('(')>0)
			first=first.replace('(',' ');
		if(first!=null && first.indexOf(')')>0)
			first=first.replace(')',' ');

		if(middle!=null && middle.indexOf('(')>0)
			middle=middle.replace('(',' ');		
		if(middle!=null && middle.indexOf(')')>0)
			middle=middle.replace(')',' ');

		if(first!=null) //check for initials
			if(first.indexOf('.')>0)
				first=first.replace('.','*');
			else
				first=first+"*";

		if(middle!=null) //check for initials
			if( middle.indexOf('.')>0)
				middle=middle.replace('.','*');
			else
				middle=middle+"*";

		cn="(cn="; //put together common name query
		if(first!=null){
			if(middle!=null)
				cn=cn+first+middle;
			else
				cn=cn+first;
		}
		cn=cn+last+")";
		filter.append(cn);		

		filter.append(")");		
		return filter.toString();
	}

	public static LDAPSearchResults searchLdap(String searchFilter)throws LDAPException{

		int WAIT_LIMIT = 6000; // ms
		int HOP_LIMIT = 0;  // no limit
		int ldapPort = LDAPConnection.DEFAULT_PORT;
		int searchScope = LDAPConnection.SCOPE_SUB;
		int ldapVersion  = LDAPConnection.LDAP_V3;        
		String ldapHost = "directory.cornell.edu";
		String loginDN  = ""; //no login id needed
		String password = "";// no password needed	  

		String searchBase = "o=Cornell University, c=US";
		String attributes[]={LDAPConnection.ALL_USER_ATTRS,"cn"};

		LDAPConnection lc = new LDAPConnection();
		LDAPSearchResults thisResult = null;
		try {
			lc.connect( ldapHost, ldapPort );

			LDAPConstraints constraints = new LDAPConstraints(WAIT_LIMIT,true,null,HOP_LIMIT);
			lc.bind( ldapVersion, loginDN, password, constraints );

			thisResult = lc.search(  searchBase, searchScope, searchFilter, attributes, false);
		} catch( LDAPException e ) {
			logger.debug( "error: " + e );
			String serverError = null;
			if( (serverError = e.getLDAPErrorMessage()) != null) 
				logger.debug("Server: " + serverError);
			return null;
		} finally {
			//lc.disconnect();  // can't disconnect before results are read 
		}
		return thisResult;
	}


	/**
	   tab delimited output string fomrat:	   
	   name	netId	deptHRcode	type	moniker	keywords	URL	anchor
	 */

	private static String ldapResult2String(LDAPSearchResults res, String orgName,String ldapFilter){
		/*the strings are ldap attribute names for tab field i*/
		String map[][]= {
				//	{"cn","displayName"}, //we'll use the original vivo name
				{"mail","uid"},       
				{"cornelledudeptname1","cornelledudeptname2"},
				{"cornelledutype","edupersonprimaryaffiliation"},
				{"cornelleduwrkngtitle1","cornelleduwrkngtitle2"},
				{},
				{"labeledUri"},
				{"description"},
				{"cornelledudeptname2"}};
		StringBuffer output=new StringBuffer("");
		output.append(orgName).append("\t"); //just stick the original name on the front.
		while(res.hasMoreElements()){
			LDAPEntry entry = null;
			Object obj = res.nextElement();
			if (obj instanceof LDAPException) {
				((LDAPException)obj).printStackTrace();
			} else {
				entry=(LDAPEntry)obj;	
			}			
			//for tab field i look in map[i] for ldap attribute names, output first non-null value
			for(int iField=0;iField<map.length;iField++){

				for(int iName=0;iName< map[iField].length; iName++){
					LDAPAttribute lAtt=entry.getAttribute(map[iField][iName]);

					if(lAtt!=null){
						String value=lAtt.getStringValue();
						if(value!=null && value.length()>0 ){
							output.append(value);
							break;
						}
					}
				}
				output.append("\t");
			}
			output.append(ldapFilter);
			if(res.hasMoreElements()){
				output.append("\n").append(orgName).append("\t");
			}
		}
		return output.toString();
	}

	//this is from the updateFromLDAP code
	// creating a class called OntResource
	// passing emailNetId string (in our case would be netId)
	// and ontModel, which should be the model of all persons (eligible persons?!?)

	/**
	  private OntResource getPersonResource(String emailNetId, OntModel ontModel) {
		    List<Resource> resList = ontModel.listSubjectsWithProperty(NETID, emailNetId).toList();
		    if (resList.size() == 0) {
		    	resList = ontModel.listSubjectsWithProperty(NETID, ontModel.createTypedLiteral(emailNetId)).toList();
		    }
		    if (resList.size() == 0) {
		    	return null;
		    }
		    if (resList.size() > 1) {
		    	logger.debug("More than one resource with netid " + emailNetId);
		    } 
		    if (resList.get(0).canAs(OntResource.class)) {    
		    	return (OntResource) resList.get(0).as(OntResource.class);
		    } else {
		    	throw new RuntimeException("Unable to return resource for person " + emailNetId + " as OntResource");
		    }
	 */


	private static Model blankify(Model m) { 

		// turn position objects into blank nodes
		//first, create a new model to hold the new blank nodes	
		Model blankedModel = ModelFactory.createDefaultModel();
		try {

			// create a hashmap named blankingMap 
			Map<Resource, Resource> blankingMap = new HashMap<Resource,Resource>();
			// create a list of all subjects in model m (with property "RDF.type" - all subjects?)
			List<Resource> resList = m.listSubjectsWithProperty(RDF.type).toList();
			// if a subject in the list is not null, stick it in the blanking map, and tie it to a new blanknode
			for (Resource res : resList) {
				if (res.getURI() != null) {
					blankingMap.put(res, blankedModel.createResource());
				}
			}
			// iterate through statements in model m 
			StmtIterator sit = m.listStatements();

			while(sit.hasNext()) {
				Statement s = sit.nextStatement();
				// for every statement
				// take the subject from the blankingMap and make new Resource named newSubjRes
				Resource newSubjRes = blankingMap.get(s.getSubject());

				// conditional operator: 
				//	make a new resource named newSubj, and (if newSubjRes is not null)
				// then set newSubj = newSubjRes
				// else
				// set newSubj = the subject in the current statement

				//Resource newSubj = (newSubjRes != null) ? newSubjRes : s.getSubject();

				Resource newSubj = blankedModel.createResource();

				//create a new RDF node named newObjRes and set it to null		
				RDFNode newObjRes = null;

				// determine if the object for the current statement is a resource
				if (s.getObject().isResource()) {
					// if yes, pull the resource from blankingMap that corresponds to the object in the current statement
					newObjRes = blankingMap.get((Resource) s.getObject());
				}
				// if no, (and newObjRes is not null) then 
				//   create an RDFNode named newObj and set = to newObjRes ((which, btw, is null, right??))
				// if no, (and newObjRes is not null) then 
				//   create an RDFNode named newObj and set = to the object in the current statement
				RDFNode newObj = (newObjRes != null) ? newObjRes : s.getObject();

				// if the predicate for the current statement is equal to "http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc" AND
				// the predicate for the current statement is equal to "http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle" then
				// add new statement in output model with newSubj, predicate from current statement, and newObj

				//since !this. won't work in my static method, include these vars

				blankedModel.add(newSubj, s.getPredicate(), newObj);
				/*if (PRIMARY_JOBCODE_LDESC.equals(s.getPredicate()) &&
        	    PRIMARY_WORKING_TITLE.equals(s.getPredicate()) ) {
        		   blankedModel.add(newSubj, s.getPredicate(), newObj);
        	}
				 */
				// if predicate for the current statement does not satisfy the conditions, don't add anything to blankedModel
			}

		} catch  ( Exception e ) {
			logger.error("Blankify is not happy. Error" + e + "\n");
		} finally {
			logger.debug("done with blankify method .");
		}
		return blankedModel;
	}

	// this doesn't work.  stick with > 127 method.
	private static boolean isPureAscii(String v) {
		CharsetEncoder asciiEncoder =  Charset.forName("US-ASCII").newEncoder(); // or "ISO-8859-1" for ISO Latin 1
		return asciiEncoder.canEncode(v);
	}

	private static String getLiteralValue(OntResource ontRes, Property property) {
		RDFNode vivoNode = ontRes.getPropertyValue(property);

		return (vivoNode != null && vivoNode.isLiteral() ) ? vivoNode.asLiteral().getLexicalForm() : null;
	}

	public static void main(String[] args) throws Exception {
		// setup logging
		PropertyConfigurator.configure(fileQryPath + "loggercfg.txt");
		logger.info("Entering application.");

		logger.info("querying VIVO service for a list of persons.  (wait time ~90 seconds)...");
		// generate a model of all VIVO uris that have either netId or HR emplId
		Model mdlAllVIVOPerson = ModelFactory.createDefaultModel();
		mdlAllVIVOPerson = CreateAllVIVOPersonList(readFromFile);
		logger.info("generated a model of all VIVO uris that have either netId or HR emplId");
		logger.info("found a total of " + mdlAllVIVOPerson.size() + " statements.");

		Model allRetractions = ModelFactory.createDefaultModel();
		String allRetractionsFileName = fileRDFPath + "allRetractions.nt";
		Model allAdditions = ModelFactory.createDefaultModel();
		String allAdditionsFileName = fileRDFPath + "allAdditions.nt";
		Model allNoHRISDataException = ModelFactory.createDefaultModel();
		String noHRISdataExFile = fileRDFPath + "noHRISdataEXCEPTION.nt";
		Model blankVIVOEmplIdException = ModelFactory.createDefaultModel();
		String blankVIVOEmplIdExFile = fileRDFPath + "blankVIVOEmplIdEXCEPTION.nt";

		// setup query for grabbing VIVO rdf
		String VIVORDFBaseQuery = ReadQueryString(fileQryPath + "qStrOnePersonVIVORDF.txt");
		String HRISRDFBaseQuery = ReadQueryString(fileQryPath + "qStrOnePersonHRISRDF.txt");
		Resource VIVOmatchURI = null;


		logger.info("VIVO query complete.  Iterating through results...");
		try {
			//create models for person RDF 

			//for every "eligible" Person in VIVO (must have netId OR emplId to play...) 
			ResIterator personiter = mdlAllVIVOPerson.listSubjects();
			// warning! model has 10,000+ items...
			while (personiter.hasNext(  )) {
				Model retractionsForPerson = ModelFactory.createDefaultModel();
				Model additionsForPerson = ModelFactory.createDefaultModel();
				// use Person URI to generate all relevant Person RDF via query
				String PersonId = personiter.next(  ).toString(  );

				logger.debug("\n\n constructing VIVO RDF for " + PersonId + "...");
				String[] VIVOqueryArgs = {VIVORDFBaseQuery, "VARVALUE", PersonId};
				String qStrOnePersonVIVORDF = ModifyQuery(VIVOqueryArgs);

				OntModel mdlOnePersonVIVORDF = MakeNewModelCONSTRUCT(qStrOnePersonVIVORDF); 
				//test size and continue if empty

				OntResource vivoIndiv = mdlOnePersonVIVORDF.getOntResource(PersonId);
				String vivoWorkingTitle = getLiteralValue(vivoIndiv, RDFS.label);
				String vivoLabel = getLiteralValue(vivoIndiv, WORKING_TITLE);

				Model CorrectedVIVOPersonRDF = ModelFactory.createDefaultModel();		
				Model CorrectedHRISPersonRDF = ModelFactory.createDefaultModel();	


				//mdlOnePersonVIVORDF.write(System.out, "N-TRIPLE");




				// conditionals here to modify RDF before rewriting to model
				// create a SELECT CASE style list of things to to do person RDF

				// check to see if we have a manually curated flag set for this node

				// we need the Subject of this node later for the renameResource
				// don't need this here
				//VIVOmatchURI = mdlOnePersonVIVORDF.getResource(subject.toString());


				// this one fixes space in label, but, since this won't happen in VIVO, repurpose this for JR SR III logic?
				// get emplId back out of model for this one person

				String vivoPersonEmplId = getLiteralValue(vivoIndiv, HR_EMPLID);
				logger.debug(vivoPersonEmplId + "\n");
				if (vivoPersonEmplId == null) {
					logger.debug("WARNING: blank VIVO emplID for " + VIVOmatchURI + " does not exist in HRIS data.");
					blankVIVOEmplIdException.add(CorrectedVIVOPersonRDF);
					continue;
				}
				// pass VIVO emplId to HRIS query to get HRIS RDF
				logger.debug("constructing HRIS RDF for " + PersonId + "...");
				String[] HRISqueryArgs = {HRISRDFBaseQuery, "VARVALUE", vivoPersonEmplId};
				String qStrOnePersonHRISRDF = ModifyQuery(HRISqueryArgs);
				//logger.debug(qStrOnePersonHRISRDF);
				OntModel mdlOnePersonHRISRDF = MakeNewModelCONSTRUCT(qStrOnePersonHRISRDF); 						

				try {
					StmtIterator testiter2 = mdlOnePersonHRISRDF.listStatements();

					while (testiter2.hasNext(  )) {

						Statement stmt      = testiter2.nextStatement();  // get next statement
						Resource  subject   = stmt.getSubject();     // get the subject
						Property  predicate = stmt.getPredicate();   // get the predicate
						RDFNode   object    = stmt.getObject();      // get the object

						// create strings for easier manipulation
						String strStmt = stmt.toString();
						String strSubject = subject.toString();
						String strPredicate = predicate.toString();
						String strObject = object.toString();

						//logger.debug(strStmt);
						//logger.debug(strSubject);
						//logger.debug(strPredicate);
						//logger.debug(strObject);

						// conditionals here to modify RDF before rewriting to model
						// create a SELECT CASE style list of things to to do person RDF

						// check to see if we have a manually curated flag set for this node

						// compare VIVO working title to HRIS 
						if ((strPredicate).equals("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#WorkingTitle")) {
							String HRISworkingTitle = strObject;
							if ((vivoWorkingTitle).equals(HRISworkingTitle)){
								logger.info("working titles match!");
							} else {
								logger.info("working titles don't match!");
								logger.info(vivoWorkingTitle + "," + HRISworkingTitle);
							}
						}

						// this one fixes space in label 
						if ((strPredicate).equals("http://www.w3.org/2000/01/rdf-schema#label")) {

							String delimiter = "\\,";
							String[] labelParts;
							String newLabel = "";
							labelParts = strObject.split(delimiter);
							if (labelParts[1].substring(0,1).equals(" ")) {
								newLabel = labelParts[0] + "," + labelParts[1];			
								logger.info("Already had a space in it.");
							} else {
								newLabel = labelParts[0] + ", " + labelParts[1];							  
							}
							//System.out.print(strSubject);
							//System.out.print(" " + strPredicate + " ");
							//System.out.print(" \"" + newLabel + "\"");
							//System.out.print("\n\n");
							//System.out.print(" \"" + strObject + "\"");
							try {
								CorrectedHRISPersonRDF.add(vivoIndiv, predicate, newLabel);
								CorrectedHRISPersonRDF.remove(subject, predicate, object);
							} catch ( Exception e ) {

							} finally {

							}

							// put the new value back in the model after modification  
							//logger.info("Here's where we would update the VIVO person model with stmt.changeObject, but that didn't work.");
							//stmt.changeObject(newLabel);

						} else { 		
							// add this unchanged statement to the corrected HRIS model
							CorrectedHRISPersonRDF.add(vivoIndiv, predicate, object);
						}// end if  
						testiter2.close();

						// all statements: 
						//Resource renameIt = CorrectedHRISPersonRDF.getResource(subject.toString());
						//ResourceUtils.renameResource( renameIt, VIVOmatchURI);
					}  // end while for HRIS person rdf statement iteration
				} catch  ( Exception e ) {
					logger.error("Rats.  Something happened while looking at HRIS person statements. Error" + e + "\n");
				} finally {
					logger.debug("done with statements for " + PersonId + ".");
				}



				WriteRdf(blankVIVOEmplIdExFile, blankVIVOEmplIdException, "N3");
				LogRDF(CorrectedVIVOPersonRDF, "N3");
				LogRDF(CorrectedHRISPersonRDF, "N3");
				Long numHRStatements = CorrectedHRISPersonRDF.size();
				if (numHRStatements < 1) {
					logger.info("No statements in HRIS for "+ VIVOmatchURI + ".  Does this person belong in VIVO?");
					allNoHRISDataException.add(CorrectedVIVOPersonRDF);
				}
				WriteRdf(noHRISdataExFile, allNoHRISDataException, "N3");
				//Property VIVO_EMPL = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#employeeOf"); 
				//boolean isEmeritus = personVIVOResource.hasProperty(VIVO_EMPL);
				//logger.debug(isEmeritus);

				// determine if isEmeritus

				// determine if isIgnore (based on ManuallyCurated)



				//pause 
				//Thread.currentThread().sleep(50);


				logger.info("HRISPerson");
				//mdlOnePersonHRISRDF.write(System.out, "N-TRIPLE");


				/* testing blankify
			    Model BlankPersonVIVORDF = blankify(mdlOnePersonVIVORDF);
				logger.info("******");
			    logger.info("BlankVIVOPerson");
				try {

				LogRDF(BlankPersonVIVORDF, "N-TRIPLE");

				} catch  ( Exception e ) {
					logger.error("Rats.  Something happened while writing the blankified model. Error" + e + "\n");
				} finally {
					//logger.debug("done with VIVO blankify. " + PersonId + ".");
				}
				 */
				// check to see if we have a manually curated flag set for this node
				boolean isManuallyCurated = mdlOnePersonVIVORDF.contains(null, AIUSER);
				logger.info("is this an AI user? " + isManuallyCurated);


				/* testing blankify
			    Model BlankPersonHRISRDF = blankify(mdlOnePersonHRISRDF);
				logger.info("******");
			    logger.info("BlankHRISPerson");
				try {
					LogRDF(BlankPersonVIVORDF, "N-TRIPLE");
				} catch  ( Exception e ) {
					logger.error("Rats.  Something happened while writing the blankified model. Error" + e + "\n");
				} finally {
					//logger.debug("done with HRIS blankify. " + PersonId + ".");
				}

				// testing blankify
			    Model BlankCorrectedVIVOPersonRDF = blankify(CorrectedVIVOPersonRDF);
				logger.info("******");
			    logger.info("BlankCorrectedVIVOPerson");
				try {
					LogRDF(BlankCorrectedVIVOPersonRDF, "N-TRIPLE");
					BlankCorrectedVIVOPersonRDF.write(System.out, "N-TRIPLE");
				} catch  ( Exception e ) {
					logger.error("Rats.  Something happened while writing the blankified model. Error" + e + "\n");
				} finally {
					//logger.debug("done with Corrected VIVO blankify. " + PersonId + ".");
				}				

				// testing blankify
			    Model BlankCorrectedHRISPersonRDF = blankify(CorrectedHRISPersonRDF);
				logger.info("******");
			    logger.info("BlankCorrectedHRISPerson");
				try {
					LogRDF(BlankCorrectedHRISPersonRDF, "N-TRIPLE");
					BlankCorrectedHRISPersonRDF.write(System.out, "N-TRIPLE");
				} catch  ( Exception e ) {
					logger.error("Rats.  Something happened while writing the blankified model. Error" + e + "\n");
				} finally {
					//logger.debug("done with Corrected HRIS blankify. " + PersonId + ".");
				}				
				 */

				// testing retractions and additions
				try {
					logger.info("***This is the retract/add section***");  
					if (!CorrectedVIVOPersonRDF.isIsomorphicWith(CorrectedHRISPersonRDF)) {
						logger.info("Corrected VIVO is NOT isomorphic with Corrected HRIS.");
						// do work to figure out what's different between models and act accordingly with non-blanknode statements.
						// take the difference between current and existing positions
						// if that .contains((Resource) null, this.PRIMARY_JOBCODE_LDESC, (RDFNode) null)) 
						// retractions.add(m.listStatements(personRes, MONIKER, (RDFNode) null));

						//	while (stmtIt.hasNext()) {
						//		Statement stmt = stmtIt.nextStatement();
						//		additions.add(stmt.getSubject(), MONIKER, stmt.getObject());

						retractionsForPerson.add(CorrectedVIVOPersonRDF.difference(CorrectedHRISPersonRDF));  
						if(retractionsForPerson.size() > 0) {
							logger.info("***" + retractionsForPerson.size() + " RETRACTIONS ***");  
							retractionsForPerson.write(System.out, "N3");

						}
						additionsForPerson.add(CorrectedHRISPersonRDF.difference(CorrectedVIVOPersonRDF));
						if(additionsForPerson.size() > 0) {
							logger.info("*** " + additionsForPerson.size() + " ADDITIONS ***");  
							additionsForPerson.write(System.out, "N3");                
						}

					} else {
						logger.info("");
						logger.info("VIVO is totally isomorphic with HRIS - so, no change necessary (?)");
						logger.info("");
					}


				} catch  ( Exception e ) {
					logger.error("Trouble adding RDF for this person to master add/retract model. Error" + e + "\n");
				} finally {
					logger.debug("done with retract/add for " + PersonId + "." + "\n");
				}


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



				/*
		    String[] HRISqueryArgs = {newPersonRDFBaseQuery, "VARVALUE", VIVOPersonNetId};
		    String qStrOnePersonHRISRDF = ModifyQuery(HRISqueryArgs);
		    logger.debug(qStrOnePersonHRISRDF);
		    //make model with one person RDF from HRIS
//NOTE fix query to accept emplId


		    Model mdlOnePersonHRISRDF = MakeNewModelCONSTRUCT(qStrOnePersonHRISRDF); 
				 */

				// test LDAP with label
				//String fullname = "Chiang, Kathy";

				String searchFilter = "";
				//rebuild serach filter to look at netID = uid first
				searchFilter = makeLdapSearchFilter(VIVOPersonlabel);
				logger.debug(searchFilter);
				/** turn this back on when LDAP is working
				LDAPSearchResults thisResult = searchLdap(searchFilter);
				String orgName = "orgName";
				String resultString = ldapResult2String(thisResult, orgName, searchFilter);
				logger.debug(resultString);
				 */
				allRetractions.add(retractionsForPerson);
				WriteRdf(allRetractionsFileName, allRetractions, "N-TRIPLE");
				allAdditions.add(additionsForPerson);
				WriteRdf(allAdditionsFileName, allAdditions, "N-TRIPLE");
				additionsForPerson.close();
				retractionsForPerson.close();
			} //end while for person iter
			logger.debug("finished with person. \n");
			personiter.close();
		} catch ( Exception e ){
			logger.error("Something got messed up while iterating through the person list.  Error" + e + "\n");

		} finally {
			logger.debug("done looking at all VIVO persons.");
		}

		// logic for making changes: 

		// compare VIVO foaf:lastName and HRIS foaf:lastName
		// if strings are equal, no action needed
		//   if VIVO foaf:lastName has diacritic characters, do not update
		//	   if no diacritics in VIVO and not strings are not equal, then retract VIVO foaf:lastName and add HRIS foaf:lastName 



		// compare VIVO foaf:firstName and HRIS foaf:firstName
		// if strings are equal, no action needed
		//   if VIVO foaf:firstName has diacritic characters, do not update
		//      if no diacritics in VIVO and not strings are equal, then retract VIVO foaf:firstName and add HRIS foaf:firstName 

		// compare VIVO core:middleName and HRIS core:middleName
		// if strings are equal, no action needed
		//   if VIVO core:middleName has diacritic characters, do not update
		//	    if no diacritics and strings not equal, then retract VIVO core:middleName and add HRIS core:middleName 

		// any time we change a name, 
		//  should we consider changing the label?
		//	  - we could concatenate name parts and compare to label
		//	  - but if HR lists me as Timothy and I have edited my label to Tim then an automated change would be trouble
		//  but we should output any name change to a log for human review.

		// hr:workingTitle is a property of foaf:Person
		// working title comes from HRIS data via prettyTitles mapping
		// if lexically = to VIVO hr:workingTitle:
		//   do nothing, else always use HRIS working title by way of map:prettyTitle
		//  HRIS job code ldesc and LDAP working title should agree?  
		//    if not, log it, but always use data from HRIS, not LDAP?

		// should we migrate anything from vitro:moniker or should it all get cleaned out?

		// vivo:employeeOf seems to be inconsistently populated among Cornell employees
		//  should we consider populating this person property in our automated ingest?
		//  also, get disposition on how vivo:PersonAffiliatedWithOrganizedEndeavor is populated
		// consider that emeritus may not have vivo:employeeOf and should have vivo:emeritusProfessorIn instead?
		//   - but only if retired and not currently an employee...

		//  we now link persons to department via position (via core:positionInOrganization)  
		//   Is there duplication on department pages when we also link via employeeOf and emeritusProfessorIn?
		//    (ref Johnson School emeritus concerns)


		// use HRIS emeritus list to create and manage retired emeritus profiles
		// according to data from the vivoemeritus HRIS table, emeritus designation is tied to foaf:Person (via netId)
		// is there a need to transfer emeritus status to position ?
		//   no, because position has core:hrJobTitle which should be "Prof Emeritus"
		// see individual22731 - it's possible to have 
		//   Working Title and Primary Working Title set to "Prof Emeritus"
		//   Preferred Title set to  "Cornell Emeritus Professor"
		//   PrimaryJobCodeLDesc set to "A W Olin Professor of Accounting"
		//   but PrimaryJobCodeLDesc does not appear in profile!

		//  question of emeritus types - which should we set with ingest?
		//    hr:Cornell Emeritus Professor
		//    vivo:Faculty Member Emeritus
		//    vivo:Professor Emeritus
		//  (are there others?)
		//  in D2R, if netId exists in vivoemeritus table, then assert one of these
		//  AND pass vivoemeritus title to hr:workingTitle via prettyTitle
		//  (you can be a Staff Emeritus)

		// if *retired emeritus*, create and set core:manuallyCurated as class for Person
		//   emeritus may be "active" and have a second (or third?) appointment that requires update
		// can you be "retired emeritus" from one appointment and still be an active employee in another?		


		// positions always get updated unless manually curated or emeritus
		// our new URI structure means that ALL positions in VIVO will get replaced?
		//  do we need a lexical comparison?  NO, because we are using isomorphic comparison
		//  consider if we need "prettyPosition" table to expand ugly/truncated JobCodeLDesc
		//  HRIS is *always* better source than LDAP for position data
		//  should we check LDAP and report if different?
		//  should we attempt to align position numbers/URIs?
		//  Still need Primary position logic  
		//    if only one position,  then it's primary (don't create secondary position RDF!) ?
		//    if two positions, then need to 
		//        pass P and S from HRIS D2R
		//        ensure that correct position gets into PrimaryJobCodeDesc and SecondaryJobCodeDesc?
		//        what about three positions?  one is primary, and both of the remaining are secondary?


		// go to LDAP for: 
		//  primaryWorkingTitle = UniversityTitle (contains Chair information)
		// core:Middle


		// non-academic? faculty? 





		// changing positions




	}  //end method

}  //end class