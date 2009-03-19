
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

<%!
    private String[] tokenizeLabel(Individual ind) {
        RDFNode labelNode = ind.getPropertyValue(RDFS.label);
        if (labelNode == null || ( (labelNode != null) && (!labelNode.isLiteral()))) {
            String [] empty = {"", ""};
            return empty;
        } else {
            String labelLexicalForm = ((Literal)labelNode).getLexicalForm();
            return labelLexicalForm.split(" ");
        }
    }

%>


<%

    OntModel m = (OntModel) getServletContext().getAttribute("jenaOntModel");
    OntModel newPeopleModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);

    String vivoNs = "http://vivo.library.cornell.edu/ns/0.1#";
    
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
    orgProps.add(hasLibrary);
    orgProps.add(hasDepartmentOrDivision);
    orgProps.add(affiliatedOrg);
    orgProps.add(hasSubUnit);
    List<Property> affiliationProps = new LinkedList<Property>();
    affiliationProps.add(hasFaculty);
    affiliationProps.add(hasLibrarian);
    affiliationProps.add(headedBy);
        
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
                    currentPeople.add(person);
                }
            }
        }
    }
    
    
    int notFound = 0;
    int found = 0;
    int noEmail = 0;
    
    List<String> notFoundList = new LinkedList<String>();
    
    Iterator personIt = m.listIndividuals(WcmcPerson);
    while (personIt.hasNext()) {
        Individual personInd = (Individual) personIt.next();
        // check for CWID
        if (personInd.getPropertyValue(cwid) != null) {
            RDFNode emailValue = personInd.getPropertyValue(email);
            String emailLexicalForm = "";
            if ( (emailValue != null) && (emailValue.isLiteral()) ) {
                emailLexicalForm = ((Literal)emailValue).getLexicalForm();
            } else {
                noEmail++;
            }
            // try to find in VIVO by nonCornellemail
            StmtIterator it1 = m.listStatements((Resource)null, nonCornellemail, emailLexicalForm);
            StmtIterator it2 = m.listStatements((Resource)null, nonCornellemail, m.createTypedLiteral(emailLexicalForm));
            if ( it1.hasNext() || it2.hasNext() ) {
                found++;
            } else {
                // try to find be name matching
                boolean matchable = false;
                String[] personIndTokens = tokenizeLabel(personInd);
                for ( Individual existingPerson : currentPeople ) {
                    String[] existingIndTokens = tokenizeLabel(existingPerson);
                    if (existingIndTokens[0].equalsIgnoreCase(personIndTokens[0]) &&
                        existingIndTokens[1].equalsIgnoreCase(personIndTokens[1])
                    ) {
                        matchable = true;
                        found++;
                        out.println("<p> Matched "+personInd.getLabel(null)+" with "+existingPerson.getLabel(null)+"</p>");
                        break;
                    }
                }
                if (!matchable) {
                    notFound++;
                    notFoundList.add(((Literal)personInd.getPropertyValue(RDFS.label)).getLexicalForm());
                    // It's a new person!  Let's at him/her.
                    // add the data properties 
                    // turn Jobs into direct properties
                    // add appropriate types based on jobs
                    StmtIterator stmtIt = personInd.listProperties();
                    while (stmtIt.hasNext()) {
                        Statement stmt = stmtIt.nextStatement();
                        if (stmt.getObject().isLiteral()) {
                        	newPeopleModel.add(stmt);
                        }
                    }
                    String monikerStr = "";
                    Iterator hasJobStmtIt = personInd.listPropertyValues(hasJob);
                    while (hasJobStmtIt.hasNext()) {
                    	Individual jobInd = (Individual)((RDFNode) hasJobStmtIt.next()).as(Individual.class);
                    	String jobTitleStr = ((Literal)jobInd.getPropertyValue(jobTitle)).getLexicalForm();
                    	if (monikerStr.length()>0) {
                    		monikerStr += " / ";
                    	}
                    	monikerStr += jobTitleStr;
                    	
                    	String deptStr = ((Literal)jobInd.getPropertyValue(jobDepartment)).getLexicalForm();
                    	// match dept in VIVO
                    	Resource dept = null;
                    	StmtIterator deptIt = m.listStatements((Resource)null,weillDeptId,deptStr);
                    	while (deptIt.hasNext()) {
                    		Statement deptStmt = deptIt.nextStatement();
                    		dept = deptStmt.getSubject();
                    		if (deptIt.hasNext()) {
                    			System.out.println("WARNING: multiple matches for "+deptStr);
                    		}
                    	}
                    	
                    	if ("Library".equals(deptStr)) {
                    		newPeopleModel.add(personInd,RDF.type,CornellLibrarian);
                    		if (dept != null) {
                    			newPeopleModel.add(personInd, librarianIn, dept);
                    			newPeopleModel.add(dept, hasLibrarian, personInd);
                    		}
                    	} else {
                    		newPeopleModel.add(personInd,RDF.type,CornellFacultyMember);
                    		if (dept != null) {
                    			newPeopleModel.add(personInd, facultyMemberIn, dept);
                    			newPeopleModel.add(dept, hasFaculty, personInd);
                    		}
                    	}
                    }
                    newPeopleModel.add(personInd, moniker, monikerStr);
                    newPeopleModel.add(personInd, RDF.type, LifeSciencesPortalFlag);
                    newPeopleModel.add(personInd, RDF.type, VetMedPortalFlag);
                    newPeopleModel.add(personInd, RDF.type, WeillMedicalFlag);
                }
            }
        }
    }
    
    // rename the people in the newPeopleModel to use the main VIVO namespace
    Model outputModel = ModelFactory.createDefaultModel();
    outputModel.add(newPeopleModel);
    StmtIterator newPersonIt = newPeopleModel.listStatements((Resource)null,cwid,(RDFNode)null);
    int count = 0;
    while (newPersonIt.hasNext()) {
    	count++;
    	Statement newPersonStmt = newPersonIt.nextStatement();
    	Individual newPersonInd = (Individual) newPersonStmt.getSubject().as(Individual.class);
    	String localName = newPersonInd.getLabel(null).replaceAll("\\W","");
    	String URI = vivoNs + localName;
    	String testURI = new String(URI);
    	Individual testInd = m.getIndividual(URI);
    	int suffix = 0;
    	while (testInd != null) {
    		suffix++;
    		testURI = new String(URI+"_"+suffix);
    	    testInd = m.getIndividual(testURI);
    	}
    	Resource outputRes = outputModel.getResource(newPersonInd.getURI());
    	ResourceUtils.renameResource(outputRes, testURI);
    }
    
    System.out.println("Made "+count+" new Weill people");
    
    response.setContentType("application/rdf+xml");
    outputModel.write(response.getOutputStream());
    response.getOutputStream().flush();
    response.getOutputStream().close();

%>