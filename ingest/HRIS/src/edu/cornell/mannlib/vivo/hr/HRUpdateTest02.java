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

//from updateFromLDAP.jsp
import java.util.Enumeration;
import com.novell.ldap.LDAPAttributeSet;
import com.novell.ldap.LDAPAttribute;
import com.novell.ldap.LDAPEntry;
import com.novell.ldap.LDAPConstraints;
import com.novell.ldap.LDAPConnection;
import com.novell.ldap.LDAPException;
import com.novell.ldap.LDAPSearchResults;


import com.hp.hpl.jena.vocabulary.RDFS;
import com.hp.hpl.jena.vocabulary.RDF;
import java.util.Map;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import java.util.HashMap;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntResource;
import java.util.List;
import com.hp.hpl.jena.shared.Lock;
import org.skife.csv.CSVReader;
import org.skife.csv.SimpleReader;


import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;


public class HRUpdateTest02 {

	//set up constants for fileIO

	public static String fileRDFPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATErdfdump\\";
	public static String fileQryPath = "C:\\Users\\cmw48\\workspace\\vivocornell\\ingest\\HRIS\\UPDATEqueries\\";     
	public static Boolean useProductionVIVO = false;
	public static Boolean readFromFile = false;
	

	   public static final Property PRIMARY_JOBCODE_LDESC = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc");
	   public static final Property PRIMARY_WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle");
	   

	//set up logging
	static final Logger logger = Logger.getLogger(HRUpdateTest02.class);


	//methods for creating models, file i/o, etc

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
				logger.debug("..." + "\n");
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
			//  gather ALL HRIS emplIds in a model 
			String qStrAllVIVOPerson=  ReadQueryString(fileQryPath + "qStrAllVIVOPerson.txt");
			String allVIVOFileName = fileRDFPath + "allVIVOPersonURI.nt";
			logger.debug("creating model with ALL VIVO URIs...");
			logger.debug(qStrAllVIVOPerson);
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
		StringBuffer filter=new StringBuffer("(&(!(type=student*))"); //no students from ldap
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
		    
    
    private static Model blankify(Model m) { // turn position objects into blank nodes
        //first, create a new model to hold the new blank nodes	
	    Model blankedModel = ModelFactory.createDefaultModel();
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
            // set newSubj = the subject in the current statment
            		
        	Resource newSubj = (newSubjRes != null) ? newSubjRes : s.getSubject();
        	
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
        	
        	// if the predicate for the current statement is lexically equal to "http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc" AND
        	// the predicate for the current statement is lexically equal to "http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle" then
        	// add new statement in output model with newSubj, predicate from current statement, and newObj
        	
        	//since !this. won't work in my static method, include these vars

        	
        	if (PRIMARY_JOBCODE_LDESC.equals(s.getPredicate()) &&
        	    PRIMARY_WORKING_TITLE.equals(s.getPredicate()) ) {
        		   blankedModel.add(newSubj, s.getPredicate(), newObj);
        	}
        	// if predicate for the current statement does not satisfy the conditions, don't add anything to blankedModel
        }
        return blankedModel;
    }
	
	
	public static void main(String[] args) throws Exception {
		// setup logging
		PropertyConfigurator.configure(fileQryPath + "loggercfg.txt");
		logger.info("Entering application.");
		
		// generate a model of all VIVO uris that have either netId or HR emplId
		Model mdlAllVIVOPerson = ModelFactory.createDefaultModel();
		mdlAllVIVOPerson = CreateAllVIVOPersonList(readFromFile);
		
		// setup query for grabbing VIVO rdf
		String VIVORDFBaseQuery = ReadQueryString(fileQryPath + "qStrOnePersonVIVORDF.txt");
		String HRISRDFBaseQuery = ReadQueryString(fileQryPath + "qStrOnePersonHRISRDF.txt");
		
		//for every "eligible" Person in VIVO (must have netId OR emplId to play...) 
		ResIterator newpersoniter = mdlAllVIVOPerson.listSubjects();
		// warning! model has 10,000+ items...
		while (newpersoniter.hasNext(  )) {

			// use Person URI to generate all relevant Person RDF via query
			String NewPersonId = newpersoniter.next(  ).toString(  );
		    logger.debug(NewPersonId + "\n");
			logger.debug("constructing VIVO RDF for " + NewPersonId + "...");
			String[] VIVOqueryArgs = {VIVORDFBaseQuery, "VARVALUE", NewPersonId};
		    String qStrOnePersonVIVORDF = ModifyQuery(VIVOqueryArgs);
		    Model mdlOnePersonVIVORDF = MakeNewModelCONSTRUCT(qStrOnePersonVIVORDF); 
			System.out.println("VIVOPerson");
			mdlOnePersonVIVORDF.write(System.out, "N3");
		    // look at model (Resource hasProperty?) to: 
          //adding anon for blank nodes
		    String arg0 = "bnode";
		  
		    Model BlankPersonVIVORDF = blankify(mdlOnePersonVIVORDF);
			System.out.println("BlankVIVOPerson");
			BlankPersonVIVORDF.write(System.out, "N3");
		 
		    //Resource personVIVOResource =  mdlOnePersonVIVORDF.createResource(BlankNode node);
		  // Model mdlBlankornot =  personVIVOResource.getModel();
		   
		  // System.out.println(mdlBlankornot);
		  /**ResIterator testiter = personVIVOResource.getLocalName()
		   while (testiter.hasNext(  )) {
			   
				Statement stmt      = testiter.nextStatement();  // get next statement
				Resource  subject   = stmt.getSubject();     // get the subject
				Property  predicate = stmt.getPredicate();   // get the predicate
				RDFNode   object    = stmt.getObject();      // get the object

				// create strings for easier manipulation
				String strStmt = stmt.toString();
				String strSubject = subject.toString();
				String strPredicate = predicate.toString();
				String strObject = object.toString();

				logger.debug(strStmt);
				logger.debug(strSubject);
				logger.debug(strPredicate);
				logger.debug(strObject);

				// conditionals here to modify RDF before rewriting to model
				// create a SELECT CASE style list of things to to do person RDF
/**
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
		*/
		   //Property VIVO_EMPL = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#employeeOf"); 
		   //boolean isEmeritus = personVIVOResource.hasProperty(VIVO_EMPL);
		   //logger.debug(isEmeritus);
		    
		    // determine if isEmeritus
		    
		    // determine if isIgnore (based on ManuallyCurated)
		    
		    
		    
            //pause 
			//Thread.currentThread().sleep(50);
			
		    // get emplId back out of model for this one person
		    Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
			NodeIterator emplIditer = mdlOnePersonVIVORDF.listObjectsOfProperty(HR_EMPLID);
			String VIVOPersonEmplId = "";
			while (emplIditer.hasNext(  )) {		
				VIVOPersonEmplId = emplIditer.next(  ).toString(  );
			 
			}
			
		    logger.debug(VIVOPersonEmplId + "\n");		    
		    // pass VIVO emplIs to HRIS query to get HRIS RDF
			logger.debug("constructing HRIS RDF for " + NewPersonId + "...");
			String[] HRISqueryArgs = {HRISRDFBaseQuery, "VARVALUE", VIVOPersonEmplId};
		    String qStrOnePersonHRISRDF = ModifyQuery(HRISqueryArgs);
		    Model mdlOnePersonHRISRDF = MakeNewModelCONSTRUCT(qStrOnePersonHRISRDF); 		    
		    
		    
		    // set this up to pass netId to LDAP for uid search string
		    Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
			NodeIterator netIditer = mdlOnePersonVIVORDF.listObjectsOfProperty(HR_NETID);
			String VIVOPersonNetId = "";
			while (netIditer.hasNext(  )) {		
			  VIVOPersonNetId = netIditer.next(  ).toString(  );
			}
		    logger.debug(VIVOPersonNetId + "\n");
            
		    
		    // in the event that netID is blank, pass label to LDAP for uid search string
		    Property HR_LABEL = ResourceFactory.createProperty("http://www.w3.org/2000/01/rdf-schema#label"); 
			NodeIterator labeliter = mdlOnePersonVIVORDF.listObjectsOfProperty(HR_LABEL);
			String VIVOPersonlabel = "";
			while (labeliter.hasNext(  )) {		
			  VIVOPersonlabel = labeliter.next(  ).toString(  );
			}
		    logger.debug(VIVOPersonlabel + "\n");
		    
		 
		    
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
		logger.debug(searchFilter + "\n");
		LDAPSearchResults thisResult = searchLdap(searchFilter);
		String orgName = "orgName";
		String resultString = ldapResult2String(thisResult, orgName, searchFilter);
		logger.debug(resultString);
		
		} //end while for person iter
		
	}  //end method

}  //end class