
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.io.OutputStream"%>
<%@page import="com.hp.hpl.jena.util.ResourceUtils"%>
<%@page import="com.hp.hpl.jena.ontology.OntModelSpec"%>
<%@page import="java.util.List"%>
<%@page import="java.util.LinkedList"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="java.util.HashSet"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDFS"%>
<%@page import="com.hp.hpl.jena.ontology.Individual"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.ontology.OntClass"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>

<%
/*
    This script is good for use only in 2009-03 because it just constructs
    a deletion graph for any Weill faculty (excluding library) that are lacking
    a CWID
*/

%>


<%

    OntModel m = (OntModel) getServletContext().getAttribute("jenaOntModel");
    OntModel retractionsModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);

    String vivoNs = "http://vivo.library.cornell.edu/ns/0.1#";
    
    Property sunrise = m.getProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#sunrise");
    
    Property WcmcPerson = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/Person");
    Property cwid = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_CWID");
    Property nonCornellemail = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#nonCornellemail");
    Property email = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_Email");
    
    Property hasJob = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/hasJob");
    Property weillDeptId = m.getProperty("http://vivo.cornell.edu/ns/mannadditions/0.1#weillDeptId");
    Property jobTitle = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_Title");
    Property jobDepartment = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_Department");
    
    //VIVO props
    Property moniker = m.getProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#moniker");
    Resource CornellFacultyMember = m.getResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellFaculty");
    Resource CornellLibrarian = m.getResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellLibrarian");
    Property facultyMemberIn = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAcademicFacultyMember");
    Property librarianIn = m.getProperty("http://vivo.cornell.edu/ns/mannadditions/0.1#employeeOfAsLibrarian"); 
    
    Resource LifeSciencesPortalFlag = m.getResource("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag1Value1Thing");
    Resource VetMedPortalFlag = m.getResource("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag1Value10Thing");
    Resource WeillMedicalFlag = m.getResource("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag2ValueWeillMedicalThing");
        
    // Weill departments in VIVO
    Property hasLibrary = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#hasLibrary");
    Property hasSubUnit = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasSubOrganizedEndeavor");
    Property hasDepartmentOrDivision = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#hasAcademicDepartmentOrDivision");
    Property affiliatedOrg = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasAffiliatedOrganizedEndeavor");
    Property hasFaculty = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#hasEmployeeAcademicFacultyMember");
    Property hasLibrarian = m.getProperty("http://vivo.cornell.edu/ns/mannadditions/0.1#hasEmployeeLibrarian");
    Property headedBy = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#cornellOrganizedEndeavorHasLeadParticipantPerson");
    Resource weill = m.getResource("http://vivo.library.cornell.edu/ns/0.1#individual192");
    List<Property> orgProps = new LinkedList<Property>();
    //orgProps.add(hasLibrary);
    orgProps.add(hasDepartmentOrDivision);
    orgProps.add(affiliatedOrg);
    orgProps.add(hasSubUnit);
    List<Property> affiliationProps = new LinkedList<Property>();
    affiliationProps.add(hasFaculty);
    //affiliationProps.add(hasLibrarian);
    affiliationProps.add(headedBy);
        
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    Date dumpDate = dateFormat.parse("2008-04-01T00:00:00");
    
    int retractionCount = 0;
    
    List<Individual> currentPeople = new LinkedList<Individual>();
    //build a list of Weill people in the current VIVO model
    Individual weillInd = m.getIndividual(weill.getURI());
    for ( Property orgProp : orgProps ) { 
        Iterator orgValueIt = weillInd.listPropertyValues(orgProp);
        while (orgValueIt.hasNext()) {
            RDFNode node = (RDFNode) orgValueIt.next();
            Individual org = (Individual) node.as(Individual.class);
            for ( Property affilProp : affiliationProps ) {
                Iterator affilValueIt = org.listPropertyValues(affilProp);
                while (affilValueIt.hasNext()) {
                    RDFNode affilNode = (RDFNode) affilValueIt.next();
                    Individual person = (Individual) affilNode.as(Individual.class);
                    if (person.getPropertyValue(cwid) == null) {
                    	//retract if created before 2008-04-01
                    	Date sunriseDate = null;
                    	if (person.getPropertyValue(sunrise) != null) {
                    	    String sunriseLex = ((Literal)person.getPropertyValue(sunrise)).getLexicalForm();
                    	    sunriseDate = dateFormat.parse(sunriseLex);
                    	}
                    	if ( (sunriseDate == null) || sunriseDate.before(dumpDate)) {
	                    	retractionCount++;
	                    	retractionsModel.add(m.listStatements(person,null,(RDFNode)null));
	                    	retractionsModel.add(m.listStatements((Resource)null,null,person));
                    	}
                    	
                    }
                    currentPeople.add(person);
                }
            }
        }
    }
    
    System.out.println("Retracted "+retractionCount+" people");
    
    OutputStream outStream = response.getOutputStream();
    response.setContentType("application/rdf+xml");
    retractionsModel.write(outStream);
    outStream.flush();
    outStream.close();

%>