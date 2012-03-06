package edu.cornell.mannlib.vivo.hr;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import oracle.sql.CHAR;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.ontology.OntProperty;
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

//added these four as part for the bandaid for position subclass mapping
import java.util.HashSet;
import java.util.Set; 

import org.skife.csv.CSVReader;
import org.skife.csv.SimpleReader; 


public class HRUpdateTest19getPosnSubclasses {

	//set up constants for fileIO

	public static String fileRDFPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATErdfdump\\";
	public static String fileQryPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATEqueries\\";     
	// added to band-aid title/position subclass mapping.  TODO: make this a reader and open/close via in the read method.
	public static String titleMapFile = fileRDFPath + "jobtitles2.csv";
	public static Boolean useProductionVIVO = false;



	public static final Property PRIMARY_JOBCODE_LDESC = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc");
	public static final Property PRIMARY_WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle");
	public static final Property WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#WorkingTitle");
	public static final Property AIUSER = ResourceFactory.createProperty("http://vivoweb.org/ontology/activity-insight#aiUser");	   
	public static final Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
	public static final Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
	public static final Property MAN_CURATED = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#ManuallyCurated"); 
	public static final Property EMERTI_PROF = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#EmeritusProfessor"); 
	public static final Property PERSON_AS_LISTED = ResourceFactory.createProperty("http://vivoweb.org/ontology/provenance-support#PersonAsListed"); 
	public static final Property PRETTY_TITLE = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/hr/titleMapping#titlemapping_modifiedTitleStr");
	public static final Property POSN_IN_ORG = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionInOrganization");
	public static final Property PERSON_IN_POSN = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#personInPosition");
	public static final Property POSN_FOR_PERSON = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionForPerson");
	public static final Property FIRST_NAME = ResourceFactory.createProperty("http://xmlns.com/foaf/0.1/firstName");
	public static final Property LAST_NAME = ResourceFactory.createProperty("http://xmlns.com/foaf/0.1/lastName");
	public static final Property JOB_TITLE = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#hrJobTitle");

	public static final Resource FACULTY_ADMINISTRATIVE_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#FacultyAdministrativePosition");
	public static final Resource FACULTY_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#FacultyPosition");
	public static final Resource LIBRARIAN_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#LibrarianPosition");
	public static final Resource ACADEMIC_STAFF_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonFacultyAcademicPosition");
	public static final Resource NONACADEMIC_STAFF_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonAcademicPosition");

	public static final Resource FACULTY = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellFaculty");
	public static final Resource LIBRARIAN = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellLibrarian");
	public static final Resource ACADEMIC_STAFF = ResourceFactory.createResource("http://vivo.library.cornell.edu/ns/0.1#CornellAcademicStaff");
	public static final Resource STAFF = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellNonAcademicStaff");

	public static final Resource THING_TYPE = ResourceFactory.createResource("http://www.w3.org/2002/07/owl#Thing");
	public static final Resource POSITION_TYPE = ResourceFactory.createResource("http://vivoweb.org/ontology/core#Position");

	public static Set<String> unrecognizedTitles = new HashSet<String>();	

	//set up logging
	static final Logger logger = Logger.getLogger(HRUpdateTest19getPosnSubclasses.class);

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

				try {
					qexecNewQuery.execDescribe(mdlNewModel);
				} catch (Exception e) {
					qexecNewQuery.execConstruct(mdlNewModel);
				} 

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


	public static OntModel QueryAgainstExistingModel(String strQueryString, Model existingModel) throws Exception {

		OntModel mdlNewModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		try {
			// load vivo emplIDs into a model, then write RDF to file                

			Query qryNewQuery = QueryFactory.create(strQueryString, Syntax.syntaxARQ);
			QueryExecution qexecNewQuery = QueryExecutionFactory.create(qryNewQuery, existingModel);
			try {
				//logger.debug("querying source and populating Model...");

				//query VIVOsource for emplId and populate Model
				// execute queries and populate model
				// create CONSTRUCT rdf and push to HRIS model /

				try {
					qexecNewQuery.execDescribe(mdlNewModel);
				} catch (Exception e) {
					qexecNewQuery.execConstruct(mdlNewModel);
				} 

			} catch (Exception e) { 
				logger.error("problem querying the existing model!  Error", e);
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

			logger.info(model);
			//model.write(System.out, "N-TRIPLE");
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
			logger.info(" Successfully read in the nt data from " + filename);
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
			logger.error("whoops.  Query mod threw error " , e);
		} finally {

		}

		return modifiedString;
	}

	// methods for doing specific tasks

	public static Model CreateAllVIVOPersonList(String readFromFile) throws Exception {
		Model mdlAllVIVOPerson = ModelFactory.createDefaultModel();

		if (readFromFile != null) {
			// optional functionality :create separate logic for reading RDF from existing files 
			// instead of querying services.  Useful?  Maybe when services are down...
			// following commented code is an example read: create mdlHRISMatch from existing nt file

			String VIVOMatchfilename = fileRDFPath + readFromFile;
			String readnamespace  = "http://vivo.cornell.edu/";
			String readfileformat = "N-TRIPLE";
			String[] readargs = {VIVOMatchfilename, readnamespace, readfileformat};
			mdlAllVIVOPerson = ReadRdf(readargs);
			logger.info("read in Model mdlAllVIVOPerson from file " + VIVOMatchfilename);

		} else {	
			try {
				//  gather ALL VIVO person (with either netId or emplId) in a model 
				String qStrAllVIVOPerson=  ReadQueryString(fileQryPath + "qStrAllVIVOPerson.txt");
				String allVIVOFileName = fileRDFPath + "allVIVOPersonURI.nt";
				logger.info("creating VIVO model...");
				logger.trace("using this query: \n" + qStrAllVIVOPerson);
				mdlAllVIVOPerson = MakeNewModelCONSTRUCT(qStrAllVIVOPerson);                            
				WriteRdf(allVIVOFileName, mdlAllVIVOPerson, "N-TRIPLE");
				logger.info("querying VIVOsource and populating Model mdlAllVIVOPerson...");

			} catch ( Exception e ) {
				logger.error("exception writing All VIVO!  Error" + e);
			} finally {

			}
		}
		return mdlAllVIVOPerson;
	}

	public static Model CreateNewHRISPersonList(String readFromFile) throws Exception {
		Model mdlAllHRISPerson = ModelFactory.createDefaultModel();
		Model mdlHRISDiff = ModelFactory.createDefaultModel();
		Model mdlHRISAllMatch = ModelFactory.createDefaultModel();

		if (readFromFile != null) {
			try {
				//  gather ALL HRIS emplIds in a model 
				String qStrAllHRISPerson=  ReadQueryString(fileQryPath + "qStrAllHRISPerson.txt");
				String allHRISFileName = fileRDFPath + "allHRISPersonURI.nt";
				logger.info("creating model with ALL HRIS URIs...");

				mdlAllHRISPerson = MakeNewModelCONSTRUCT(qStrAllHRISPerson);                            
				WriteRdf(allHRISFileName, mdlAllHRISPerson, "N-TRIPLE");
				logger.info("querying HRISsource and populating Model mdlAllHRISPerson...");

				// pull all HRIS emplIDs from HRIS service WHERE HRIS.emplId matches a VIVO.emplId
				// keep original HRIS URI for diff process
				String qStrHRISmatchVIVOEmplId = ReadQueryString(fileQryPath + "qStrHRISmatchVIVOEmplId.txt"); 
				String HRISMatchFileName = fileRDFPath + "hrisMatchEmplId.nt";
				logger.info("creating model where HRIS matches VIVO emplIds..");
				logger.trace(qStrHRISmatchVIVOEmplId);
				Model mdlHRISMatchEmplId = MakeNewModelCONSTRUCT(qStrHRISmatchVIVOEmplId);   
				logger.debug("constructed model from query, writing...");                   
				//WriteRdf(HRISMatchFileName, mdlHRISMatchEmplId, "N-TRIPLE");
				//logger.debug("created model named mdlHRISmatch and wrote to file.");
				mdlHRISAllMatch.add(mdlHRISMatchEmplId);

				// pull all HRIS netIDs from HRIS service WHERE HRIS.netId matches a VIVO.netId
				// keep original HRIS URI for diff process
				String qStrHRISmatchVIVONetId = ReadQueryString(fileQryPath + "qStrHRISmatchVIVONetId.txt"); 
				String HRISMatchNetIdFileName = fileRDFPath + "hrisMatchNetId.nt";
				logger.info("creating model where HRIS matches VIVO netIds..");
				logger.trace(qStrHRISmatchVIVONetId);
				Model mdlHRISMatchNetId = MakeNewModelCONSTRUCT(qStrHRISmatchVIVONetId);   
				logger.debug("constructed model from query, writing...");                   
				//WriteRdf(HRISMatchNetIdFileName, mdlHRISMatchNetId, "N-TRIPLE");
				//logger.debug("created model named mdlHRISMatchNetId and wrote to file.");

				mdlHRISAllMatch.add(mdlHRISMatchNetId);

				mdlHRISDiff = mdlAllHRISPerson.difference(mdlHRISAllMatch);

				// write diff RDF model to file
				String HRISDiffFilename = fileRDFPath + "hrisDiffEmplId.nt";
				WriteRdf(HRISDiffFilename, mdlHRISDiff, "N-TRIPLE");
				logger.debug("mdlHRISDiff now contains emplIds for HRIS not in VIVO .");

			} catch ( Exception e ) {
				logger.error("exception writing All HRIS!  Error" + e);
			} finally {

			}
		} else {
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

		}
		return mdlHRISDiff;

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
			logger.error( "error: " + e );
			String serverError = null;
			if( (serverError = e.getLDAPErrorMessage()) != null) 
				logger.error("Server: " + serverError);
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
	// creating an OntResource
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


	private static boolean containsUnicode(String s) {
		char[] asCharArr = s.toCharArray();
		for(int i=0;i <asCharArr.length;i++) {
			if (asCharArr[i] > 127) {
				return true;
			}
		}
		return false;   
	}

	/* was...
	 * private static String getLiteralValue(OntResource ontRes, Property property) {

		vivoNode = ontRes.getPropertyValue(property);
		return (vivoNode != null && vivoNode.isLiteral() ) ? vivoNode.asLiteral().getLexicalForm() : null;
	}
	 */


	private static String getLiteralValue(OntResource ontRes, Property property) throws Exception{
		RDFNode vivoNode = null; 
		String value = "";
		try {
			logger.debug("property " + property);	
			vivoNode = ontRes.getPropertyValue(property);
			if (vivoNode != null) {

				if (vivoNode.isLiteral() ) {
					value = vivoNode.asLiteral().getLexicalForm();
				}
			} else {
				//logger.debug("vivoNode is null.");
			}
			//logger.debug("node " + vivoNode);	
			return value;
		} catch ( Exception e ){
			logger.error("That didn't work- problem getting literal value.  Error" , e );
			throw e; 
		}
		// if vivoNode is not null AND vivoNode isLiteral, then return vivoNode.asLiteral.getLexicalForm else return null

	}

	private static String[] getQueryArgs(Resource vivoIndiv, String vivoPersonEmplId, String vivoPersonNetId) throws IOException  {
		// setup query for grabbing VIVO rdf

		String HRISRDFBaseQuery = ReadQueryString(fileQryPath + "qStrOnePersonHRISRDF.txt");
		String HRISRDFnetIdQuery = ReadQueryString(fileQryPath + "qStrOnePersonHRISNetIDRDF.txt");

		if (vivoPersonEmplId.equals(""))  {
			//String vivoPersonNetId = getLiteralValue(vivoIndiv, HR_NETID);
			// pass VIVO netID to HRIS query to get HRIS RDF
			logger.info("constructing HRIS RDF for " + vivoPersonNetId + "...");
			String[] temp =  {HRISRDFnetIdQuery, "VARVALUE", vivoPersonNetId};
			return temp;

		} else {
			// pass VIVO emplId to HRIS query to get HRIS RDF
			logger.info("constructing HRIS RDF for " + vivoPersonEmplId + "...");
			String[] temp = {HRISRDFBaseQuery, "VARVALUE", vivoPersonEmplId};
			return temp;


		}

	}

	public static Model getVivoOrgLinks(Model mdlHRISPosnRDF) throws Exception {

		try {
			String vivoOrgsQuery = ReadQueryString(fileQryPath + "qStrOrgLinkQueryVIVO.txt");
			long startTime = System.currentTimeMillis();
			Model mdlOrgPosnLinksVIVO = QueryAgainstExistingModel(vivoOrgsQuery, mdlHRISPosnRDF); 
			logger.debug("VIVO link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");		
			logger.trace(vivoOrgsQuery);
			logger.trace(mdlOrgPosnLinksVIVO);
			return mdlOrgPosnLinksVIVO;

		} catch ( Exception e ) {
			logger.error("problem creating VIVO orgLink RDF. Error" , e );
			throw e;
		} finally {
			logger.debug("vivoOrgLinks model created.");
		}

	}

	public static Model getHRISOrgLinks(Model mdlHRISPosnRDF) throws Exception {

		try {
			String hrisOrgsQuery = ReadQueryString(fileQryPath + "qStrOrgLinkQueryHRIS.txt");
			long startTime = System.currentTimeMillis();			
			Model mdlOrgPosnLinksHRIS = QueryAgainstExistingModel(hrisOrgsQuery, mdlHRISPosnRDF); 
			logger.debug("HRIS link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");		
			if (!mdlOrgPosnLinksHRIS.isEmpty()) {
				logger.trace(hrisOrgsQuery);
				logger.trace(mdlOrgPosnLinksHRIS);
			}  

			return mdlOrgPosnLinksHRIS;

		} catch ( Exception e ) {
			logger.error("problem creating VIVO orgLink RDF. Error" , e );
			throw e;
		} finally {
			//logger.debug("hrisOrgLinks model created.");
		}

	}

	public static String getPrettyTitle(String hrisWorkingTitle) throws Exception {	

		String prettyTitleQuery = ReadQueryString(fileQryPath + "qStrPrettyTitle.txt");
		String[] prettyTitleQueryArg = {prettyTitleQuery, "VARVALUE" , hrisWorkingTitle};
		String qStrPrettyTitleRDF = ModifyQuery(prettyTitleQueryArg); 
		String prettyTitle = "";

		//logger.trace(qStrPrettyTitleRDF);
		long startTime = System.currentTimeMillis();			
		OntModel mdlPrettyTitleRDF = MakeNewModelCONSTRUCT(qStrPrettyTitleRDF); 
		logger.debug("pretty title query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	
		if (mdlPrettyTitleRDF.isEmpty()) {
			logger.debug("no pretty title match for " + hrisWorkingTitle);
			//keep hrisWorkingTitle
			prettyTitle = hrisWorkingTitle;
		} else {

			Resource thisTitle = mdlPrettyTitleRDF.listSubjects().toList().get(0);
			String thisTitleString = thisTitle.toString();

			OntResource ontresPrettyTitle = mdlPrettyTitleRDF.getOntResource(thisTitleString);
			prettyTitle = getLiteralValue(ontresPrettyTitle, PRETTY_TITLE);
			logger.debug("changing " + hrisWorkingTitle + " to " + prettyTitle);

		}
		return prettyTitle;
	}

	public static Map<String, String> correctLabel(String correctThisLabel) throws Exception {
		// first, split on the comma
		String delimiterComma = "\\,";
		String[] labelParts;
		String[] leftSideParts;
		String[] rightSideParts;

		labelParts = correctThisLabel.split(delimiterComma);
		// split label at comma 


		// the first thing to the right is firstName
		// anything with a delimiter after firstName should be middleName
		String leftSide = labelParts[0];
		// everything to the right is lastname and suffix
		String rightSide = labelParts[1];

		//setup a hash to return all the parts we find
		Map<String, String> result = new HashMap<String, String>();

		if (rightSide.substring(0,1).equals(" ")) {
			// check to see if string already has a space between comma and right part
			result.put("newLabel", leftSide + "," + rightSide);			
			//logger.info("HRIS label not modified.");
		} else {
			// if not, add the space in the final label
			result.put("newLabel", leftSide + ", " + rightSide);
			//logger.info("HRIS label modified.");
		}
		String delimiterSpace = "\\ ";
		leftSideParts = leftSide.split(delimiterSpace);
		rightSideParts = rightSide.split(delimiterSpace);
		logger.debug("leftSide has " + leftSideParts.length + " parts.");
		logger.debug("rightSide has " + rightSideParts.length + " parts.");		

		return result;
	}

	public static Model processHRISCorrections(OntModel mdlOnePersonHRISRDF, OntResource vivoIndiv) throws Exception {

		// mdlOnePersonHRISRDF contains relevant HRIS RDF for this person so we can match against VIVO RDF.
		// things to do with hris model: 
		// see if vivoperson exists in hris data (if not, why not? are they CCE, or non-exempt?)
		// find a way to add prettytitle to model and/or update hrisWorkingTitle  ( DONE, but remove is not working so well.)
		// compare hrisWorkingTitle and vivoWorkingTitle, if no match, use hrisWorkingTitle
		// fix label comma space problem

		Model CorrectedHRISPersonRDF = ModelFactory.createDefaultModel();

		// initialize flags
		boolean manuallyCurated = false;
		boolean isEmeritus = false;


		try {
			String vivoLabel = getLiteralValue(vivoIndiv, RDFS.label);
			String vivoWorkingTitle = getLiteralValue(vivoIndiv, WORKING_TITLE);
			String vivoFirstName = getLiteralValue(vivoIndiv, FIRST_NAME);
			String vivoLastName = getLiteralValue(vivoIndiv, LAST_NAME);


			//mdlOnePersonVIVORDF.write(System.out, "N-TRIPLE");

			// conditionals here to modify RDF before rewriting to model
			// create a SELECT CASE style list of things to to do person RDF

			// check to see if we have a manually curated flag set for this node
			if (vivoIndiv.hasRDFType(EMERTI_PROF)) {
				logger.info("is Emeritus!");
				isEmeritus = true;
			}

			// check to see if we have a manually curated flag set for this person
			if (vivoIndiv.hasRDFType(MAN_CURATED)) {
				logger.info("Manually Curated!");
				manuallyCurated = true;
			}

			// check to see if we have a person as listed flag set for this person
			if (vivoIndiv.hasRDFType(PERSON_AS_LISTED)) {
				logger.info("Person As Listed!");
				manuallyCurated = true;
			}


			Resource hrisURI = mdlOnePersonHRISRDF.listStatements().nextStatement().getSubject();

			// fill up corrected HRIS model with all statements from original HRIS model
			StmtIterator hrisIter = mdlOnePersonHRISRDF.listStatements();
			while (hrisIter.hasNext()) {
				Statement stmt      = hrisIter.nextStatement();  // get next statement
				Resource  subject   = stmt.getSubject();     // get the subject
				Property  predicate = stmt.getPredicate();   // get the predicate
				RDFNode   object    = stmt.getObject();      // get the object
				CorrectedHRISPersonRDF.add(vivoIndiv, predicate, object);
			}

			// with subject (hrisURI), create OntResource with all statements for individual
			OntResource hrisIndiv = mdlOnePersonHRISRDF.getOntResource(hrisURI);

			String hrisWorkingTitle = getLiteralValue(hrisIndiv, WORKING_TITLE);
			String prettyTitle = getPrettyTitle(hrisWorkingTitle);

			// always compare VIVO working title to HRIS 

			if (vivoWorkingTitle != null) {
				logger.debug("pretty hrisWorkingTitle = " + prettyTitle);
				if (prettyTitle != null) {

					if ((vivoWorkingTitle).equals(prettyTitle)){
						logger.info("working titles match!");
						CorrectedHRISPersonRDF.remove(vivoIndiv, WORKING_TITLE, hrisIndiv.getPropertyValue(WORKING_TITLE));
						CorrectedHRISPersonRDF.add(vivoIndiv, WORKING_TITLE, prettyTitle);
					} else {
						logger.info("working titles don't match!");
						logger.info(vivoWorkingTitle + "," + prettyTitle);

						if (prettyTitle.equals("")) {
							logger.trace("keeping original working title.");
						} else {	

							try {
								CorrectedHRISPersonRDF.remove(vivoIndiv, WORKING_TITLE, hrisIndiv.getPropertyValue(WORKING_TITLE));
								CorrectedHRISPersonRDF.add(vivoIndiv, WORKING_TITLE, prettyTitle);

							} catch ( Exception e ) {
								logger.error("problem correcting pretty title RDF. Error" , e );
							} finally {
								logger.debug("title corrected");
							}
						}  //endif prettyTitle blank
					} // end if workingTitles match
				} else { 
					logger.info("vivoHRISTitle is null - use VIVO working title if it exists.");
				} // endif HRIS title null
			} else {
				logger.info("vivoWorkingTitle is null - use pretty HRIS working title if it exists.");
				CorrectedHRISPersonRDF.add(vivoIndiv, WORKING_TITLE, prettyTitle);
				//ignoreAddRetract
			} // end else 

			//if don't update profile data, then 
			// always fix label

			String hrisLabel = getLiteralValue(hrisIndiv, RDFS.label);
			String newLabel = null;
			//test vivoLabel for unicode
			if (containsUnicode(vivoLabel)) {
				logger.info("VIVO label contains unicode!  Don't overwrite with HRIS label.");
				try {
					CorrectedHRISPersonRDF.remove(vivoIndiv, RDFS.label, hrisIndiv.getPropertyValue(RDFS.label));
					CorrectedHRISPersonRDF.add(vivoIndiv, RDFS.label, vivoLabel);
				} catch ( Exception e ) {
					logger.error("problem correcting HRIS label RDF. Error" , e );
				} finally {

				}
			} else {

				//String delimiter = "\\,";
				//String[] labelParts;
				//String newLabel = "";
				//labelParts = hrisLabel.split(delimiter);
				//if (labelParts[1].substring(0,1).equals(" ")) {
				//	newLabel = labelParts[0] + "," + labelParts[1];			
				//logger.info("HRIS label not modified.");
				//} else {
				//	newLabel = labelParts[0] + ", " + labelParts[1];	
				//logger.info("HRIS label modified.");

				Map<String, String> labelHash = correctLabel(hrisLabel);
				newLabel = labelHash.get("newLabel");

			}

			//System.out.print(strSubject);
			//System.out.print(" " + strPredicate + " ");
			//System.out.print(" \"" + newLabel + "\"");
			//System.out.print("\n\n");
			//System.out.print(" \"" + strObject + "\"");
			try {
				CorrectedHRISPersonRDF.remove(vivoIndiv, RDFS.label, hrisIndiv.getPropertyValue(RDFS.label));
				CorrectedHRISPersonRDF.add(vivoIndiv, RDFS.label, newLabel);

			} catch ( Exception e ) {
				logger.error("problem correcting HRIS label RDF. Error" , e );
			} finally {

			}


			// TODO Consolidate these in a more efficient and effective method
			if (containsUnicode(vivoFirstName)) {
				logger.info("VIVO first name contains unicode!  Don't overwrite with HRIS first name.");
				try {
					CorrectedHRISPersonRDF.remove(vivoIndiv, FIRST_NAME, hrisIndiv.getPropertyValue(FIRST_NAME));
					CorrectedHRISPersonRDF.add(vivoIndiv, FIRST_NAME, vivoFirstName);
				} catch ( Exception e ) {
					logger.error("problem correcting HRIS firstname RDF. Error" , e );
				} finally {

				}
			}

			if (containsUnicode(vivoLastName)) {
				logger.info("VIVO last name contains unicode!  Don't overwrite with HRIS last name.");
				try {
					CorrectedHRISPersonRDF.remove(vivoIndiv, LAST_NAME, hrisIndiv.getPropertyValue(LAST_NAME));
					CorrectedHRISPersonRDF.add(vivoIndiv, LAST_NAME, vivoLastName);
				} catch ( Exception e ) {
					logger.error("problem correcting HRIS lastname RDF. Error" , e );
				} finally {

				}
			}


			// all statements: 
			//Resource renameIt = CorrectedHRISPersonRDF.getResource(subject.toString());
			//ResourceUtils.renameResource( renameIt, VIVOmatchURI);

		} catch  ( Exception e ) {

			logger.error("Rats.  Something happened while looking at HRIS person statements. Error" , e );
		} finally {
			logger.info("done with statements for " + vivoIndiv + ".");
		}
		return CorrectedHRISPersonRDF;

	}

	public static Model exceptionReport(Model exceptionRDF, String exceptionDesc) throws Exception {
		// TODO: create method to write pertinent RDF to a separate report based on a particular situation
		// i.e. VIVO people with no HRIS data - are they retracts?  or "terminatedPerson"?
		Model blankVIVOEmplIdException = ModelFactory.createDefaultModel();
		String blankVIVOEmplIdExFile = fileRDFPath + "blankVIVOEmplIdEXCEPTION.nt";
		Model allNoHRISDataException = ModelFactory.createDefaultModel();
		String noHRISdataExFile = fileRDFPath + "noHRISdataEXCEPTION.nt";
		return null;
	}

	// ***this section added to attempt adding in position subclasses.  lifted directly from BJL updateFromLDAP.jsp code***
	// TODO: evaluate the plan to dovetail this right into current workflow, or do we really need an LDAP check now?

	private static boolean isSpecialFacultyTitle(String jobtitle) {
		return (
				"Andrew D. White Prof-At-Large".equals(jobtitle) ||
				"Prof Assoc Vis".equals(jobtitle) ||
				"Prof Asst Visit".equals(jobtitle) ||
				"Prof Visiting".equals(jobtitle) ||
				"Prof Adj".equals(jobtitle) ||
				"Prof Adj Assoc".equals(jobtitle) ||
				"Prof Adj Asst".equals(jobtitle) ||
				"Prof Courtesy".equals(jobtitle) ||
				"Professor Associate Courtesy".equals(jobtitle) ||
				"Professor Assistant Courtesy".equals(jobtitle) );

	}

	private static Resource getPositionType(String jobtitle, Map<String,String> titlemap) {
		if (jobtitle == null ||  jobtitle.trim().length() == 0) {
			return null;
		}
		String family = titlemap.get(jobtitle);
		if (jobtitle.contains("Dean") || "Academic Administrative".equals(family)) {
			return FACULTY_ADMINISTRATIVE_POSITION;
		} else if ("Professorial".equals(family) || isSpecialFacultyTitle(jobtitle) 
				|| (jobtitle.contains("Prof") && !jobtitle.contains("Temp"))
				) {
			return FACULTY_POSITION;
		} else if ("Library - Academic".equals(family) || jobtitle.contains("Archiv") || jobtitle.contains("Librarian")) {
			return LIBRARIAN_POSITION;
		} else if (jobtitle.contains("Fellow") || jobtitle.contains("Lecturer") || "Scient Visit".equals(jobtitle) || jobtitle.contains("Chair") || "Academic Other".equals(family) || "Research/Extension".equals(family) || "Teaching".equals(family)) {
			//was return this.ACADEMIC_STAFF_POSITION; (why?)
			return ACADEMIC_STAFF_POSITION;

		} else if (!jobtitle.contains("Director") && !jobtitle.contains("Dir ") && !jobtitle.contains("- SP") && family == null) {
			unrecognizedTitles.add(jobtitle);
			return null;
		} else {
			return NONACADEMIC_STAFF_POSITION;
		}
	}

	// ***end position subclass section***   

	public static void processVIVOperson(String personId, Model allAdditions, Model allRetractions, Model exceptionRDF) throws Exception {

		// create models for correction and retraction
		Model retractionsForPerson = ModelFactory.createDefaultModel();
		Model additionsForPerson = ModelFactory.createDefaultModel();
		Model retractionsForPosition = ModelFactory.createDefaultModel();
		Model additionsForPosition = ModelFactory.createDefaultModel();	
		Model retractionsForOrg = ModelFactory.createDefaultModel();
		Model additionsForOrg = ModelFactory.createDefaultModel();		

		Model CorrectedVIVOPersonRDF = ModelFactory.createDefaultModel();	

		// initialize flags
		boolean ignoreDiffRetract = false;
		boolean ignoreDiffAdd = false;
		boolean ignorePosnDiffRetract = false;
		boolean ignorePosnDiffAdd = false;

		// modify VIVO query with personId
		String VIVORDFBaseQuery = ReadQueryString(fileQryPath + "qStrOnePersonVIVORDF.txt");
		String[] VIVOqueryArgs = {VIVORDFBaseQuery, "VARVALUE", personId};
		String qStrOnePersonVIVORDF = ModifyQuery(VIVOqueryArgs);
		//create ontology model with vivo data for single person
		long startTime = System.currentTimeMillis();		
		OntModel mdlOnePersonVIVORDF = MakeNewModelCONSTRUCT(qStrOnePersonVIVORDF); 
		logger.debug("VIVOonePerson link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	

		// if model is empty, that person does not exist in vivo (or something is wrong) so, bail out, next person
		if (mdlOnePersonVIVORDF.size() > 0 ) {

			// with subject (personId), create OntResource with all statements for individual
			OntResource vivoIndiv = mdlOnePersonVIVORDF.getOntResource(personId);

			// get vivoEmplID and vivoNetId

			String vivoPersonEmplId = getLiteralValue(vivoIndiv, HR_EMPLID);
			String vivoPersonNetId = getLiteralValue(vivoIndiv, HR_NETID);
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


			// send emplId and netId to getQueryArgs, if emplId is blank, then use netId.
			String qStrOnePersonHRISRDF = ModifyQuery(getQueryArgs(vivoIndiv, vivoPersonEmplId, vivoPersonNetId));
			//logger.debug(qStrOnePersonHRISRDF);


			OntModel mdlOnePersonHRISRDF = MakeNewModelCONSTRUCT(qStrOnePersonHRISRDF); 	
			logger.debug("VIVO model has " + mdlOnePersonVIVORDF.size() + " statements.");
			logger.debug("HRIS model has " + mdlOnePersonHRISRDF.size() + " statements.");
			if (!mdlOnePersonHRISRDF.isEmpty()) {

				//Model CorrectedHRISPersonRDF = ModelFactory.createDefaultModel();	
				Model CorrectedHRISPersonRDF = processHRISCorrections(mdlOnePersonHRISRDF, vivoIndiv);
				logger.info("done correcting HRIS statements for " + personId + ".");

				//WriteRdf(blankVIVOEmplIdExFile, blankVIVOEmplIdException, "N3");
				logger.debug("VIVO RDF");
				LogRDF(mdlOnePersonVIVORDF, "N3");
				logger.debug("CorrectedHRISPerson RDF");
				LogRDF(CorrectedHRISPersonRDF, "N3");
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
				boolean isAIuser = mdlOnePersonVIVORDF.contains(null, AIUSER);
				logger.info("AI user? " + isAIuser);

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
							logger.trace(retractionsForPerson);
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
							logger.trace(additionsForPerson);
						} else  {
							logger.info("*** NO PROFILE ADDITIONS ***");
						}
					} //endif for ignoreDiffRetract
					//} else {
					//	logger.info("");
					//	logger.info("VIVO profile is totally isomorphic with HRIS profile - so, no profile change necessary (?)");
					//	logger.info("");
					//}
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

				// now, look at positions for this person and compare VIVO positions with HRIS positions
				// first, set up VIVO positions
				String vivoPersonURI = vivoIndiv.getURI();
				String vivoPersonURIString = ("<" + vivoPersonURI + ">");
				String vivoPosnQuery = ReadQueryString(fileQryPath + "qStrVIVOPositionDesc.txt");
				String[] queryArg2 = {vivoPosnQuery, "VARVALUE" , vivoPersonURIString};
				String qStrVIVOPositionRDF = ModifyQuery(queryArg2); 
				//logger.trace(qStrVIVOPositionRDF);
				startTime = System.currentTimeMillis();
				OntModel mdlVIVOPosnRDF = MakeNewModelCONSTRUCT(qStrVIVOPositionRDF); 
				//OntModel mdlCorrectedVIVOPosnRDF = MakeNewModelCONSTRUCT(qStrVIVOPositionRDF);
				Model mdlCorrectedVIVOposnRdf = ModelFactory.createDefaultModel();
				logger.debug("VIVOposn link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");		

				String vivoHRJobTitle = null;

				List<Statement> vivoPosnList = mdlVIVOPosnRDF.listStatements((Resource) null, JOB_TITLE, (RDFNode) null).toList();
				Integer numVIVOPosn = vivoPosnList.size();
				for (Statement stmt : vivoPosnList ) {
					logger.info("number of VIVO positions: " + numVIVOPosn);
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
						Resource positionType = getPositionType(vivoHRJobTitle, title2family);

						logger.info(positionType);
						//mdlVIVOPosnRDF.add(stmt.getSubject(),  RDF.type, positionType );
						mdlCorrectedVIVOposnRdf.add(stmt.getSubject(),  RDF.type, positionType );
						//List<Statement> changePosnRDFType = mdlVIVOPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
						//for (Statement stmt2 : changePosnRDFType ) {
						//mdlVIVOPosnRDF.remove(stmt2);

						//	mdlVIVOPosnRDF.add(stmt2.getSubject(),  RDF.type, positionType );
						//}				

					} catch  ( Exception e ) {
						logger.error("problem getting position subclass. Error", e );
					} 	

				}
				// this is all existing VIVO position RDF - will be retracted!
				logger.info("*VIVO position RDF* \n");
				LogRDF(mdlVIVOPosnRDF, "N-TRIPLES");

				// TODO consider renaming to MakeNewModel, parse as describe first?


				// now setup HRIS positions
				String hrisPosnQuery = ReadQueryString(fileQryPath + "qStrHRISPositionDesc.txt");
				//  get D2R person URI and pass to HRIS position query
				Resource hrisURI = mdlOnePersonHRISRDF.listSubjects().toList().get(0);
				String hrisURIString = ("<" + hrisURI.getURI() + ">");
				String[] queryArg3 = {hrisPosnQuery, "VARVALUE" , hrisURIString};
				String qStrHRISPositionRDF = ModifyQuery(queryArg3); 
				// construct model with all position RDF for one person
				startTime = System.currentTimeMillis();
				OntModel mdlHRISPosnRDF = MakeNewModelCONSTRUCT(qStrHRISPositionRDF); 	
				logger.debug("HRISposn link query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	

				List<Statement> hrisPosnList = mdlHRISPosnRDF.listStatements((Resource) null, RDFS.label, (RDFNode) null).toList();
				Integer numHRISPosn = hrisPosnList.size();
				logger.info("number of HRIS positions: " + numHRISPosn);
				String hrisPosnLabel = null;
				for (Statement stmt1 : hrisPosnList ) {

					RDFNode hrisLabelObject = stmt1.getObject();

					if (hrisLabelObject.isLiteral()) {
						// now we need the label from the position, because we need to prettify it
						hrisPosnLabel = hrisLabelObject.asLiteral().getLexicalForm();
					} else {
						logger.debug("why is this not a literal? " + hrisLabelObject.toString() + " - " + stmt1.getSubject().getURI());
						continue;
					}


					try {

						//String hrisPosnLabel = getLiteralValue(hrisLabelObject, RDFS.label);

						String prettyTitle = getPrettyTitle(hrisPosnLabel);

						mdlHRISPosnRDF.remove(stmt1);
						mdlHRISPosnRDF.add(stmt1.getSubject(), RDFS.label, ResourceFactory.createPlainLiteral(prettyTitle));
					} catch  ( Exception e ) {
						logger.error("problem getting pretty title for posn. Error", e );
					} 		

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


				try {

					List<Statement> changePosnRDFType = mdlHRISPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
					for (Statement stmt4 : changePosnRDFType ) {
						mdlHRISPosnRDF.remove(stmt4);
						mdlHRISPosnRDF.add(stmt4.getSubject(),  RDF.type, POSITION_TYPE );
					}				

				} catch  ( Exception e ) {
					logger.error("problem getting position subclass. Error", e );
				} 					


				// this is all HRIS position information minus org links - 
				//logger.info("*HRIS position RDF* \n");
				//LogRDF(mdlHRISPosnRDF, "N-TRIPLES");

				// figure out whether these new HR positions have links to existing VIVO orgs or need new orgs minted
				try {
					// look at D2R position and search VIVO for pre-existing organization
					/** CHANGED TO mdlVIVOPosnRDF for trobleshooting, was mdlHRISPosnRDF
					 **/
					//TODO: this depends on rdf:type Position being in the model.  FIX THIS!
					mdlHRISPosnRDF.add(getVivoOrgLinks(mdlVIVOPosnRDF));
					//after VIVO org addition
					logger.debug("*added VIVO orgs to position RDF* \n\n");
					mdlHRISPosnRDF.write(System.out, "N-TRIPLE");


					// look at D2R position and generate D2R URI for orgs that don't appear in VIVO
					// query contains all D2R RDF for the orgs in question
					// TODO - investigate index changes?  query runs a little slow...
					/** CHANGED TO mdlVIVOPosnRDF for trobleshooting, was mdlHRISPosnRDF
					 **/
					Model mdlHRISOrgRDF = getHRISOrgLinks(mdlVIVOPosnRDF);
					if (!mdlHRISOrgRDF.isEmpty()) {
						mdlHRISPosnRDF.add(mdlHRISOrgRDF);
						//after HRIS org addition
						logger.debug("*added HRIS orgs to position RDF* \n\n");
						mdlHRISPosnRDF.write(System.out, "N-TRIPLE");

					} 
					//additionsForPosn.add(mdlHRISPosnRDF);
					try {
						//remove inferred classes from vivo model before diff
						List<Statement> removeVIVORDFType = mdlVIVOPosnRDF.listStatements((Resource) null, RDF.type, (RDFNode) null).toList();
						for (Statement stmt5 : removeVIVORDFType ) {
							logger.info(stmt5.getObject().toString());
							if (stmt5.getObject().toString().equals(THING_TYPE.toString())){
								mdlVIVOPosnRDF.remove(stmt5);
							}
							if (stmt5.getObject().toString().equals(POSITION_TYPE.toString())){
								mdlVIVOPosnRDF.remove(stmt5);
							}					
						}		
						//allAdditions.add(additionsForPosn);
					} catch  ( Exception e ) {
						logger.error("problem with retracting inferred types. Error", e );
					} 	


					//allAdditions.add(additionsForPosn);
				} catch  ( Exception e ) {
					logger.error("problem with making org models. Error", e );
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


					if (ignorePosnDiffRetract) {
						logger.debug("position retract suppressed.");
					} else {
						retractionsForPosition.add(mdlVIVOPosnRDF.difference(mdlHRISPosnRDF));  
						if(retractionsForPosition.size() > 0) {
							logger.info("***" + retractionsForPosition.size() + " POSITION RETRACTIONS ***");  
							retractionsForPosition.write(System.out, "N3");                
							logger.trace(retractionsForPosition);
						} else  {
							logger.info("*** NO POSITION RETRACTIONS ***");
						}
					} //endif for ignoreDiffRetract

					if (ignorePosnDiffAdd) {
						logger.debug("position addition suppressed.");
					} else {

						additionsForPosition.add(mdlCorrectedVIVOposnRdf);
						if(additionsForPosition.size() > 0) {
							logger.info("*** " + additionsForPosition.size() + " POSITION ADDITIONS ***");  
							additionsForPosition.write(System.out, "N3");                
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

				allRetractions.add(retractionsForPosition);

				allAdditions.add(additionsForPosition);


				additionsForPerson.close();
				retractionsForPerson.close();
				additionsForPosition.close();
				retractionsForPosition.close();

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
			logger.warn("VIVO model is empty, meaning this emplId/netId does not exist in VIVO data. Now, add all HRIS RDF to VIVO for this person.");
		}

	}

	public static void main(String[] args) throws Exception {

		// setup models for master retracts and adds
		Model allRetractions = ModelFactory.createDefaultModel();
		String allRetractionsFileName = fileRDFPath + "allRetractions.nt";
		Model allAdditions = ModelFactory.createDefaultModel();
		String allAdditionsFileName = fileRDFPath + "allAdditions.nt";
		Model exceptionRDF = ModelFactory.createDefaultModel();
		String allexceptionsFileName = fileRDFPath + "allexceptions.txt";		
		// setup logging
		PropertyConfigurator.configure(fileQryPath + "loggercfg.txt");
		logger.info("Entering application.");



		String readFromFile = null;
		
		if (args != null) {
			if (args[0].equals("-f")) {
				logger.info("reading from file " + args[1]);
				readFromFile = args[1];
			}
		}
		
		logger.info("querying VIVO service for a list of persons.  (wait time ~90 seconds)...");

		// generate a model of all VIVO uris that have either netId or HR emplId
		Model mdlAllVIVOPerson = ModelFactory.createDefaultModel();
		mdlAllVIVOPerson = CreateAllVIVOPersonList(readFromFile);
		long numPersons = mdlAllVIVOPerson.size(); 
		logger.info("generated a model of all VIVO uris that have either netId or HR emplId");
		logger.info("found a total of " + numPersons + " statements.");



		long personCount = 0;

		logger.info("VIVO query complete.  Iterating through results...");

		try {
			//create models for person RDF 

			//for every "eligible" Person in VIVO (must have netId OR emplId to play...) 
			ResIterator personiter = mdlAllVIVOPerson.listSubjects();

			// warning! model has 10,000+ items...
			while (personiter.hasNext(  )) {  
				personCount++; 
				// use Person URI to generate all relevant Person RDF via query
				String personId = personiter.next(  ).toString(  );
				logger.info("\n\n processing " + personCount + " of " + numPersons + "\n constructing VIVO RDF for " + personId + "...");
				processVIVOperson(personId, allAdditions, allRetractions, exceptionRDF);
				WriteRdf(allRetractionsFileName, allRetractions, "N-TRIPLE");
				WriteRdf(allAdditionsFileName, allAdditions, "N-TRIPLE");
			} //end while for person iter
			logger.info("finished with person. \n");
			personiter.close();

		} catch ( Exception e ){
			logger.error("Something got messed up while iterating through the person list.  Error" , e );

		} finally {
			logger.info("done looking at all " + numPersons + " VIVO persons.");
		}

		logger.info("querying HRIS service for a list of NEW persons.  (wait time ~90 seconds)...");
		// generate a model of all HRIS uris , check against VIVO model
		Model mdlNewHRISPerson = ModelFactory.createDefaultModel();
		mdlNewHRISPerson = CreateNewHRISPersonList(readFromFile);
		long numHRISNewPersons = mdlNewHRISPerson.size(); 
		logger.info("generated a model of new HRIS uris that don't match a VIVO netId or HR emplId");
		logger.info("found a total of " + numHRISNewPersons + " statements.");

		// insert procedure to process new HR persons 
		//NOTE needs to be run after ingest occurs!

		try {
			//create models for person RDF 

			//for every "eligible" Person in VIVO (must have netId OR emplId to play...) 
			ResIterator personiter = mdlNewHRISPerson.listSubjects();

			// warning! model has 10,000+ items...
			while (personiter.hasNext(  )) {  
				personCount++; 
				// use Person URI to generate all relevant Person RDF via query
				String personId = personiter.next(  ).toString(  );
				logger.info("\n\n processing " + personCount + " of " + numPersons + "\n constructing VIVO RDF for " + personId + "...");
				processVIVOperson(personId, allAdditions, allRetractions, exceptionRDF);

				//TODO: decide whether to rewrite processVIVOperson to handle any person, VIVO or HRIS.
				//Or, make a new method to add HRIS data (corrections required, but no comparison with vivo necessary)
				// also, fix the correctLabel method so that it catches JR, SR, III AICP ESQ, and checks labelFirst against firstName.
				WriteRdf(allRetractionsFileName, allRetractions, "N-TRIPLE");
				WriteRdf(allAdditionsFileName, allAdditions, "N-TRIPLE");
			} //end while for person iter
			logger.info("finished with person. \n");
			personiter.close();

			System.out.println("Unrecognized titles");
			for (String s : unrecognizedTitles) {
				System.out.println(s);
			}

		} catch ( Exception e ){
			logger.error("Something got messed up while iterating through the person list.  Error" , e );

		} finally {
			logger.info("done looking at all " + numPersons + " VIVO persons.");
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
