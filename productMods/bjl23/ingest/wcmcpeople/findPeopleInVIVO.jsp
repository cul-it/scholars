
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
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>

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

    OntModel m = ModelAccess.on(getServletContext()).getJenaOntModel();

	Property WcmcPerson = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/Person");
	Property cwid = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_CWID");
	Property nonCornellemail = m.getProperty("http://vivo.library.cornell.edu/ns/0.1#nonCornellemail");
	Property email = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_Email");
	
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
		out.println("<p>Working with: "+personInd.getLabel(null)+"</p>");
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
				}
			}
		}
	}
	
	out.println("<p>"+currentPeople.size()+" people in VIVO");
	
	out.println("<p>Found: "+found+"</p>");
	out.println("<p>Not found: "+notFound+"</p>");
	
	out.println("<ul>");
	
	for ( String notFoundStr : notFoundList ) {
		out.println( "<li>" + notFoundStr + "</li>" );
	}
	
	out.println("</ul>");
	
	out.println("<p>No email: "+noEmail+"</p>");

%>