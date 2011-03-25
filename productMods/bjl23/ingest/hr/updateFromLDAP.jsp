
<%@page import="java.io.FileOutputStream"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDFS"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.InsertException"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.WebappDaoFactoryJena"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.query.QueryExecutionFactory"%>
<%@page import="com.hp.hpl.jena.query.QueryExecution"%>
<%@page import="com.hp.hpl.jena.query.QueryFactory"%>
<%@page import="com.hp.hpl.jena.query.Query"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.novell.ldap.LDAPAttributeSet"%>
<%@page import="com.novell.ldap.LDAPAttribute"%>
<%@page import="com.novell.ldap.LDAPEntry"%>
<%@page import="com.novell.ldap.LDAPConstraints"%>
<%@page import="com.novell.ldap.LDAPConnection"%>
<%@page import="com.novell.ldap.LDAPException"%>
<%@page import="com.novell.ldap.LDAPSearchResults"%>


<%!
    private static final String RETRACTIONS_OUTPUT_FILE = "/tmp/ldapretractions.n3";
    private static final String ADDITIONS_OUTPUT_FILE = "/tmp/ldapadditions.n3";
    private static final String NEW_PEOPLE_OUTPUT_FILE = "/tmp/ldapnewpeople.n3";
%>


<%!

private String makeLdapSearchFilter(String fullname){
	int comma = fullname.indexOf(','),space1=-1,space2=-1;
	if(comma<0){
		System.out.print("name lacks a comma: " + fullname);
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

	/**
   @param searchFilter - eduora uses the searchFilter:(|(cn=*^0*)(uid=*^0*)(edupersonnickname=*^0*)) where 
   ^0 gets replaced by the search str.
   @param attributes - the attributes that you want from ldap, one att name per an array item. ex:
   String[] attr = new String[] {"cornelledunetid","cn","cornelledutype","mail","mailRoutingAddress"};
*/
public LDAPSearchResults searchLdap(String searchFilter)throws LDAPException{

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
		System.out.println( "error: " + e );
		String serverError = null;
		if( (serverError = e.getLDAPErrorMessage()) != null) 
			System.out.println("Server: " + serverError);
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
private String ldapResult2String(LDAPSearchResults res, String orgName,String ldapFilter){
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

%>


<%!

   private static final Property DEPT_ID = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#departmentHRcode");
   private static final Property ACTIVITY_ID = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#activityHRcode");
   private static final Property NETID = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
   private static final Property PRIMARY_JOBCODE_LDESC = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc");
   private static final Property PRIMARY_WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle");
   
   private static final Property MONIKER = ResourceFactory.createProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#moniker");
   
   private static final Property HR_LASTNAME = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#LastName");
   private static final Property HR_FIRSTNAME = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#FirstName");
   private static final Property CORE_MIDDLENAME = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#middleName");
   private static final Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
   private static final Property HR_WORKINGTITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#WorkingTitle");
   private static final Property HR_PRIMARYJOBCODELDESC = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc");
   private static final Property HR_ADDRESS1 = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#Address1");
   private static final Property HR_LDAPJOBNUMBER = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#LDAPJobNumber");
    
   private static final Resource FACULTY_ADMINISTRATIVE_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#FacultyAdministrativePosition");
   private static final Resource FACULTY_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#FacultyPosition");
   private static final Resource LIBRARIAN_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#LibrarianPosition");
   private static final Resource ACADEMIC_STAFF_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonFacultyAcademicPosition");
   private static final Resource NONACADEMIC_STAFF_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonAcademicPosition");
   
   private static final Resource FACULTY = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellFaculty");
   private static final Resource LIBRARIAN = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellLibrarian");
   private static final Resource ACADEMIC_STAFF = ResourceFactory.createResource("http://vivo.library.cornell.edu/ns/0.1#CornellAcademicStaff");
   private static final Resource STAFF = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellNonAcademicStaff");
   
   private static final Property FOAF_FIRSTNAME = ResourceFactory.createProperty("http://xmlns.com/foaf/0.1/firstName");
   private static final Property FOAF_LASTNAME = ResourceFactory.createProperty("http://xmlns.com/foaf/0.1/lastName");
     
   private static final Property PERSON_IN_POSITION = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#personInPosition");
   private static final Property POSITION_FOR_PERSON = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionForPerson");
   
   private static final Property POSITION_IN_ORGANIZATION = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionInOrganization");
   private static final Property ORGANIZATION_FOR_POSITION = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#organizationForPosition");

   private static final Property CORE_HR_JOB_TITLE = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#hrJobTitle");
   
   private static final Property ORIGINAL_TITLE = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/hr/titleMapping#titlemapping_originalTitleStr");
   private static final Property MODIFIED_TITLE = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/hr/titleMapping#titlemapping_modifiedTitleStr");
   
   private static final String TITLE_MAP_PATH = "/bjl23/ingest/hr/jobtitles.csv";
   private static final String PRETTY_TITLE_PATH = "bjl23/ingest/hr/titleMappings.rdf";
   
   private Set<String> missingOrgs = new HashSet<String>();
   private Set<String> unrecognizedTitles = new HashSet<String>();
   

%>

<%!

   public Map<String, String> getDepts(Model m) {
	   m.enterCriticalSection(Lock.READ);
	   try {
		   Map dept2id = new HashMap<String, String>();
	       StmtIterator deptIt = m.listStatements((Resource) null, DEPT_ID, (RDFNode) null);
	       while (deptIt.hasNext()) {
	    	   Statement s = deptIt.nextStatement();
	    	   dept2id.put(s.getSubject().getURI(), ((Literal) s.getObject()).getLexicalForm());
	       }
	       deptIt = m.listStatements((Resource) null, ACTIVITY_ID, (RDFNode) null);
	       while (deptIt.hasNext()) {
	           Statement s = deptIt.nextStatement();
	           dept2id.put(s.getSubject().getURI(), ((Literal) s.getObject()).getLexicalForm());
	       }
	       return dept2id;
	   } finally {
		   m.leaveCriticalSection();
	   }
   }

%>

<%!

    private OntResource getPersonResource(String emailNetId, OntModel ontModel) {
	    List<Resource> resList = ontModel.listSubjectsWithProperty(NETID, emailNetId).toList();
	    if (resList.size() == 0) {
	    	resList = ontModel.listSubjectsWithProperty(NETID, ontModel.createTypedLiteral(emailNetId)).toList();
	    }
	    if (resList.size() == 0) {
	    	return null;
	    }
	    if (resList.size() > 1) {
	    	System.out.println("More than one resource with netid " + emailNetId);
	    } 
	    if (resList.get(0).canAs(OntResource.class)) {    
	    	return (OntResource) resList.get(0).as(OntResource.class);
	    } else {
	    	throw new RuntimeException("Unable to return resource for person " + emailNetId + " as OntResource");
	    }
    }

    private Resource getOrgRes(String deptid, Model model) {
    	List<Resource> resList = model.listSubjectsWithProperty(DEPT_ID, deptid).toList();
    	if (resList.size() == 0) {
    		resList = model.listSubjectsWithProperty(DEPT_ID, model.createTypedLiteral(deptid)).toList();
    	}
    	if (resList.size() == 0) {
            resList = model.listSubjectsWithProperty(ACTIVITY_ID, deptid).toList();
        }
    	if (resList.size() == 0) {
            resList = model.listSubjectsWithProperty(ACTIVITY_ID, model.createTypedLiteral(deptid)).toList();
        }
    	if (resList.size() > 0) {
    		return resList.get(0);
    	} else {
    		return null;
    	}
    	
    }

%>

<%!

   private Resource getPositionType(String jobtitle, Map<String,String> titlemap) {
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
		   return this.ACADEMIC_STAFF_POSITION;
	   } else if (!jobtitle.contains("Director") && !jobtitle.contains("Dir ") && !jobtitle.contains("- SP") && family == null) {
		   unrecognizedTitles.add(jobtitle);
           return null;
	   } else {
		   return NONACADEMIC_STAFF_POSITION;
	   }
   }

   private boolean isSpecialFacultyTitle(String jobtitle) {
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
   
   private String mapTitle(String uglyTitle, Model prettyTitles) {   
       List<Resource> origList = prettyTitles.listSubjectsWithProperty(ORIGINAL_TITLE, uglyTitle).toList();
       if (origList.size() > 0) {
    	   List<Statement> modList = origList.get(0).listProperties(MODIFIED_TITLE).toList();
    	   if (modList.size() > 0) {
    		   return ((Literal) modList.get(0).getObject()).getLexicalForm();
    	   } else {
    		   return uglyTitle;
    	   }
       } else return uglyTitle;
       
   }

   private boolean isEmeritus(LDAPEntry personEntry) {
		 LDAPAttribute univTitleAttr = personEntry.getAttribute("cornelleduunivtitle1");
		 String univtitle = (univTitleAttr != null) ? univTitleAttr.getStringValue() : null;
		 LDAPAttribute workingtitleAttr = personEntry.getAttribute("cornelleduwrkngtitle1");
		 String workingtitle = (workingtitleAttr != null) ? workingtitleAttr.getStringValue() : null;
         if (univtitle != null && univtitle.trim().equals("Prof Emeritus")) {
             return true;
         } else if (workingtitle != null && (workingtitle.contains("Emeritus") || workingtitle.contains("emeritus"))) {
             return true;
         } else {
             return false;
         }
   }

   private Model makeCurrentPositions(LDAPEntry personEntry, OntResource personRes, WebappDaoFactory wadf, Map<String,String> titleMap, Model prettyTitles) {
	   Model currentPositions = ModelFactory.createDefaultModel();
	   for (int i=1; i<=2; i++) {
		    LDAPAttribute deptAttr = personEntry.getAttribute("cornelledudeptid" + i);
		    String deptid = (deptAttr != null) ? deptAttr.getStringValue() : null;
		    LDAPAttribute univTitleAttr = personEntry.getAttribute("cornelleduunivtitle" + i);
		    String univtitle = (univTitleAttr != null) ? univTitleAttr.getStringValue() : null;
		    LDAPAttribute workingtitleAttr = personEntry.getAttribute("cornelleduwrkngtitle" + i);
		    String workingtitle = (workingtitleAttr != null) ? workingtitleAttr.getStringValue() : null;
		    if (deptid != null && univtitle != null && workingtitle != null && workingtitle.trim().length() > 0) {
	    	    String positionURI = "http://vivo.cornell.edu/individual/" + personRes.getLocalName() + "-position" + i;
	    	    Resource positionRes = currentPositions.createResource(positionURI);
	    	    String positionLabel = (workingtitle != null) ? workingtitle : univtitle;
	    	    positionLabel = mapTitle(positionLabel, prettyTitles);
	    	    Resource positionType = getPositionType(univtitle, titleMap);
	    	    if (positionType != null) {
	    	        Resource orgRes = getOrgRes(deptid, personRes.getModel());
	    	        if (orgRes != null) {
	    	        	if (i == 1) {
	    	        		currentPositions.add(personRes, this.PRIMARY_JOBCODE_LDESC, univtitle);
	    	        		currentPositions.add(personRes, this.PRIMARY_WORKING_TITLE, positionLabel);
	    	        	}
		    	        currentPositions.add(positionRes, RDFS.label, positionLabel);
	                        currentPositions.add(positionRes, RDF.type, positionType);    
                                currentPositions.add(positionRes, CORE_HR_JOB_TITLE, univtitle);
                                currentPositions.add(positionRes, HR_LDAPJOBNUMBER, currentPositions.createTypedLiteral(i));
		    	        currentPositions.add(personRes, this.PERSON_IN_POSITION, positionRes);
		    	        currentPositions.add(positionRes, this.POSITION_FOR_PERSON, personRes);
		    	        currentPositions.add(orgRes, this.ORGANIZATION_FOR_POSITION, positionRes);
	    	            currentPositions.add(positionRes, this.POSITION_IN_ORGANIZATION, orgRes);
	    	        } else {
	    	            missingOrgs.add(deptid);
	    	        }
	    	    }	
		    }	    
	   }
	   return currentPositions;
   }

%>

<%!

   private Model getExistingPositions(OntResource personRes, Map<String,String> titleMap) {
	   Model m = ModelFactory.createDefaultModel();
	   String personURI = personRes.getURI();
	   String positionConstruct = "CONSTRUCT { ?s ?p ?position . \n" +
			                      "    ?position ?pp ?o . \n" +
			                      "    <" + personURI + "> <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc> ?primaryJobcodeLdesc . \n" +
			                      "    <" + personURI + "> <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle> ?primaryWorkingTitle . \n" +
                                              "    ?position <http://vivoweb.org/ontology/core#hrJobTitle> ?hrJobTitle .  \n" +
                                              "    ?position <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#LDAPJobNumber> ?jobNumber  \n" +
			                      "} WHERE { \n" +
		                          "    <" + personURI + "> <http://vivoweb.org/ontology/core#personInPosition> ?position . \n" +
			                      "    ?s ?p ?position . \n" +
			                      "    ?position ?pp ?o . \n" +
                                              "    OPTIONAL { ?position <http://vivoweb.org/ontology/core#hrJobTitle> ?hrJobTitle . } \n" +
                                              "    OPTIONAL { ?position <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#LDAPJobNumber> ?jobNumber } \n" +
			                      "    OPTIONAL { <" + personURI + "> <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc> ?primaryJobcodeLdesc } \n" +
                                  "    OPTIONAL { <" + personURI + "> <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle> ?primaryWorkingTitle } \n" +
                                  "    FILTER (?o != <http://www.w3.org/2002/07/owl#Thing>) \n" +
                                  "    FILTER (?o != <http://vivoweb.org/ontology/core#DependentResource>) \n" +
                                  "    FILTER (?o != <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#DependentResource>) \n" +
                                  "    FILTER (?o != <http://vivoweb.org/ontology/core#Position>) \n" +
                                  "    FILTER (!bound(?jobNumber) || ?jobNumber < \"3\"^^<http://www.w3.org/2001/XMLSchema#int>) \n" +
			                      "}";
	   //System.out.println(positionConstruct);
	   Query q = QueryFactory.create(positionConstruct);
	   QueryExecution qe = QueryExecutionFactory.create(q, personRes.getModel());
	   qe.execConstruct(m);
	
// need to exclude hand-entered non-exempt positions	   
//	   List<Statement> posTitleList = m.listStatementsWithProperty(RDF.type, (RDFNode) null).toList();
//	   for (Resource pos : posList) {
//		   if (getPositionType(pos, titleMap) == null) {
//			   m.remove(pos, null, null);
//			   m.remove(null, null, pos);
//		   }
//	   }
	   
	   return m;
   }

%>

<%!

    private Model blankify(Model m) { // turn position objects into blank nodes
	    Model blankedModel = ModelFactory.createDefaultModel();
        Map<Resource, Resource> blankingMap = new HashMap<Resource,Resource>();
        List<Resource> resList = m.listSubjectsWithProperty(RDF.type).toList();
        for (Resource res : resList) {
        	if (res.getURI() != null) {
        		blankingMap.put(res, blankedModel.createResource());
        	}
        }
        StmtIterator sit = m.listStatements();
        while(sit.hasNext()) {
        	Statement s = sit.nextStatement();
        	Resource newSubjRes = blankingMap.get(s.getSubject());
        	Resource newSubj = (newSubjRes != null) ? newSubjRes : s.getSubject();
        	RDFNode newObjRes = null;
        	if (s.getObject().isResource()) {
        		newObjRes = blankingMap.get((Resource) s.getObject());
        	}
        	RDFNode newObj = (newObjRes != null) ? newObjRes : s.getObject();
        	if (!this.PRIMARY_JOBCODE_LDESC.equals(s.getPredicate()) &&
        	    !this.PRIMARY_WORKING_TITLE.equals(s.getPredicate()) ) {
        		   blankedModel.add(newSubj, s.getPredicate(), newObj);
        	}
        }
        return blankedModel;
    }


    private Model getExistingAttributes(Resource personRes) {
    	Model existingAttributes = ModelFactory.createDefaultModel();
    	existingAttributes.add(personRes.listProperties(HR_LASTNAME));
    	existingAttributes.add(personRes.listProperties(FOAF_LASTNAME));
        existingAttributes.add(personRes.listProperties(HR_FIRSTNAME));
        existingAttributes.add(personRes.listProperties(FOAF_FIRSTNAME));
        existingAttributes.add(personRes.listProperties(CORE_MIDDLENAME));
        existingAttributes.add(personRes.listProperties(HR_NETID));
        existingAttributes.add(personRes.listProperties(HR_WORKINGTITLE));
        existingAttributes.add(personRes.listProperties(HR_PRIMARYJOBCODELDESC));
        existingAttributes.add(personRes.listProperties(HR_ADDRESS1));
    	return existingAttributes;
    }
    
    private void addCurrentAttribute(Model model, Resource person, Property prop, LDAPEntry ldapEntry, String attrName) {
    	LDAPAttribute attr = ldapEntry.getAttribute(attrName);
    	if (attr != null) {
    		String attrValue = attr.getStringValue().trim();
    		if (attrValue.length() > 0) {    	
    			   	model.add(person, prop, attrValue);
    	    }
    	}
    }
    
    private Model makeCurrentAttributes(Resource personRes, LDAPEntry personEntry) {
        Model currentAttributes = ModelFactory.createDefaultModel();
        
        addCurrentAttribute(currentAttributes, personRes, HR_LASTNAME, personEntry, "sn");
        addCurrentAttribute(currentAttributes, personRes, FOAF_LASTNAME, personEntry, "sn");
        addCurrentAttribute(currentAttributes, personRes, HR_FIRSTNAME, personEntry, "givenName");
        addCurrentAttribute(currentAttributes, personRes, FOAF_FIRSTNAME, personEntry, "givenName");
        addCurrentAttribute(currentAttributes, personRes, CORE_MIDDLENAME, personEntry, "cornelledumiddlename");
        addCurrentAttribute(currentAttributes, personRes, HR_NETID, personEntry, "uid");
        addCurrentAttribute(currentAttributes, personRes, HR_WORKINGTITLE, personEntry, "cornelleduwrkngtitle1");
        addCurrentAttribute(currentAttributes, personRes, HR_PRIMARYJOBCODELDESC, personEntry, "cornelleduunivtitle1");
        addCurrentAttribute(currentAttributes, personRes, HR_ADDRESS1, personEntry, "cornelleducampusaddress");
        
        return currentAttributes;
    }

%>

<%

// do an HR ingest from Cornell's LDAP data

OntModel m = (OntModel) getServletContext().getAttribute("baseOntModel");
WebappDaoFactory wadf = (WebappDaoFactory) getServletContext().getAttribute("webappDaoFactory");

Model retractions = ModelFactory.createDefaultModel();
Model additions = ModelFactory.createDefaultModel();
Model newPeople = ModelFactory.createDefaultModel();

Map<String,String> dept2id = getDepts(m);

Map<String,String> title2family = new HashMap<String,String>();
File titleMapFile = new File(getServletContext().getRealPath(TITLE_MAP_PATH));
FileInputStream fis = new FileInputStream(titleMapFile);
CSVReader csvReader = new SimpleReader();
List<String[]> fileRows = csvReader.parse(fis);
for(String[] row : fileRows) {
    title2family.put(row[0], row[1]);
}

Model prettyTitles = ModelFactory.createDefaultModel();
prettyTitles.read(new FileInputStream(new File(getServletContext().getRealPath(PRETTY_TITLE_PATH))), null, "N3");

int i = 0;

for (String deptURI : dept2id.keySet()) {
	Thread.currentThread().sleep(50);
	i++;
	String deptId = dept2id.get(deptURI);
	String ldapQuery = "(&(!(type=student*))(cornelledudeptid1="+deptId+"))";  
	System.out.println(ldapQuery + " " + i);
	LDAPSearchResults results = searchLdap(ldapQuery);
	if (!results.hasMoreElements()) {
		out.write("No people found in LDAP for dept " + deptId + "\n");
	} else while (results.hasMoreElements()) {
		LDAPEntry personEntry = (LDAPEntry) results.next();
		LDAPAttribute emailnetidAtt = personEntry.getAttribute("eduPersonPrincipalName");
        LDAPAttribute lastNameAttr = personEntry.getAttribute("sn");
        boolean ignore = false;
		if (emailnetidAtt == null || emailnetidAtt.getStringValue().trim().length() == 0 
				|| lastNameAttr == null || lastNameAttr.getStringValue().trim().length() == 0) { 
			        continue;
		}
		String emailnetid = emailnetidAtt.getStringValue();
		m.enterCriticalSection(Lock.WRITE);
		try {
			OntResource personRes = getPersonResource(emailnetid, m);
		    boolean newPerson = false;
			if (personRes == null) {	
				personRes = m.createOntResource("http://vivo.cornell.edu/individual/" + emailnetid.split("@")[0]);
				newPerson = true;
			}
			Model existingPositions = getExistingPositions(personRes, title2family);
			LDAPAttribute personTypeAttr = personEntry.getAttribute("cornelledutype");
            if (personTypeAttr != null && "retiree".equals(personTypeAttr.getStringValue()) && !isEmeritus(personEntry)) {
                retractions.add(existingPositions);
                ignore = true;
            }
			//System.out.println("existingPositions " + existingPositions.size());
			Model currentPositions = makeCurrentPositions(personEntry, personRes, wadf, title2family, prettyTitles);
			//System.out.println("currentPositions  "  + currentPositions.size());
			Model existingBlank = blankify(existingPositions);
			//System.out.println("existingBlank  "  + existingBlank.size());
			Model currentBlank = blankify(currentPositions);
			//System.out.println("currentBlank  "  + currentBlank.size());
			
			//System.out.println("existingBlank");
			//existingBlank.write(System.out, "N3");
			
			//System.out.println("currentBlank");
            //currentBlank.write(System.out, "N3");
			
			if (!ignore && !newPerson) {
                Model existingAttributes = getExistingAttributes(personRes);
                Model currentAttributes = makeCurrentAttributes(personRes, personEntry);
                retractions.add(existingAttributes.difference(currentAttributes));
                additions.add(currentAttributes.difference(existingAttributes));
			
				if (!existingBlank.isIsomorphicWith(currentBlank)) {
					retractions.add(existingPositions);
					additions.add(currentPositions);
					if (currentPositions.difference(existingPositions).contains((Resource) null, this.PRIMARY_JOBCODE_LDESC, (RDFNode) null)) {
						retractions.add(m.listStatements(personRes, MONIKER, (RDFNode) null));
						StmtIterator stmtIt = currentPositions.listStatements(personRes, this.PRIMARY_WORKING_TITLE, (RDFNode) null);
						while (stmtIt.hasNext()) {
							Statement stmt = stmtIt.nextStatement();
							additions.add(stmt.getSubject(), MONIKER, stmt.getObject());
						}
					}
				}

			} else if (!ignore && newPerson && currentPositions.size() > 0) {
				newPeople.add(currentPositions);
				newPeople.add(personRes, NETID, emailnetid);
				StmtIterator stmtIt = currentPositions.listStatements(personRes, this.PRIMARY_WORKING_TITLE, (RDFNode) null);
                while (stmtIt.hasNext()) {
                    Statement stmt = stmtIt.nextStatement();
                    newPeople.add(stmt.getSubject(), MONIKER, stmt.getObject());
                }
                String lastName = (lastNameAttr != null) ? lastNameAttr.getStringValue() : "";
                LDAPAttribute firstNameAttr = personEntry.getAttribute("givenName");
                String firstName = (firstNameAttr != null) ? firstNameAttr.getStringValue() : "";
                newPeople.add(personRes, FOAF_FIRSTNAME, firstName);
                newPeople.add(personRes, FOAF_LASTNAME, lastName);
                newPeople.add(personRes, RDFS.label, lastName + ", " + firstName);
                if (currentPositions.contains((Resource) null, RDF.type, this.FACULTY_ADMINISTRATIVE_POSITION)
                		    || currentPositions.contains((Resource) null, RDF.type, this.FACULTY_POSITION)
                	    ) {
                	newPeople.add(personRes, RDF.type, FACULTY);
                } else if (currentPositions.contains((Resource) null, RDF.type, this.LIBRARIAN_POSITION)) {
                	newPeople.add(personRes, RDF.type, LIBRARIAN);
                } else if (currentPositions.contains((Resource) null, RDF.type, this.ACADEMIC_STAFF_POSITION)) {
                	newPeople.add(personRes, RDF.type, ACADEMIC_STAFF);
                } else {
                	newPeople.add(personRes, RDF.type, STAFF);
                }
				//newPeople.add(newPersonTypes);
				//newPeople.add(currentAttributes);
			} else {
			     //System.out.println("isomorphic!");
			}
		} finally {
			m.leaveCriticalSection();
		}
	}
    
}

FileOutputStream retOut = new FileOutputStream(new File(RETRACTIONS_OUTPUT_FILE));
retractions.difference(additions).write(retOut, "N3");
FileOutputStream addOut = new FileOutputStream(new File(ADDITIONS_OUTPUT_FILE));
m.enterCriticalSection(Lock.READ);
try {
    additions.difference(retractions).difference(m).write(addOut, "N3");
} finally {
    m.leaveCriticalSection();
}
FileOutputStream newOut = new FileOutputStream(new File(NEW_PEOPLE_OUTPUT_FILE));
newPeople.write(newOut, "N3");

System.out.println("Unrecognized titles");
for (String s : unrecognizedTitles) {
    System.out.println(s);
}

System.out.println("\nMissing orgs");
for (String s : missingOrgs) {
    System.out.println(s);
}

%>

<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="java.util.Map"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.rdf.model.ResourceFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="com.hp.hpl.jena.ontology.OntResource"%>
<%@page import="java.util.List"%>
<%@page import="com.hp.hpl.jena.shared.Lock"%>
<%@page import="org.skife.csv.CSVReader"%>
<%@page import="org.skife.csv.SimpleReader"%>




