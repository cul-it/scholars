
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.util.ResourceUtils"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="com.hp.hpl.jena.assembler.Mode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.rdf.model.ResourceFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaModelMaker"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelMaker"%>

<%!

    String VIVO_NS = "http://vivo.library.cornell.edu/ns/0.1#";
    Property FIRST_NAME = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#FirstName");
    Property LAST_NAME = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#LastName");
    Property NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId");
    Resource RULE_PERSON_TYPE = ResourceFactory.createResource("http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#Person");

%>

<%

    ModelMaker modelMaker = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (ModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);
    
    Model newPeopleModel = modelMaker.getModel("new people assertions");
    Model vivoModel = modelMaker.getModel("vitro:jenaOntModel");
    if (vivoModel.size() < 10000) {
    	throw new RuntimeException("VIVO model is too small.  A current snapshot of VIVO must be made available.");
    }
    
    Model outputModel = ModelFactory.createDefaultModel();
    
    //outputModel.add(newPeopleModel);
    
    List<String> oldURIs = new ArrayList<String>();
    Iterator resIt = newPeopleModel.listSubjectsWithProperty(NETID);
    while (resIt.hasNext()) {
        Resource res = (Resource) resIt.next();
        oldURIs.add(res.getURI());  
        outputModel.add(newPeopleModel.listStatements((Resource)res, null, (RDFNode)null));
        outputModel.add(newPeopleModel.listStatements((Resource)null, null, res));
    }
    
    Iterator<String> oldURIit = oldURIs.iterator();
    while(oldURIit.hasNext()) {
        String oldURI = oldURIit.next();
        Resource res = outputModel.getResource(oldURI);
        ResourceUtils.renameResource(res,getNewURI(res, vivoModel));
    }
    
    Model filteredModel = ModelFactory.createDefaultModel(); // shoehorning some extra stuff in here to filter out an unwanted type
    StmtIterator filterIt = outputModel.listStatements();
    while (filterIt.hasNext()) {
        Statement stmt = filterIt.nextStatement();
        if (!stmt.getObject().equals(RULE_PERSON_TYPE)) {
        	filteredModel.add(stmt);
        }
    }
    
    response.setContentType("text/plain");
    filteredModel.write(response.getOutputStream(),"N3");
    
%>

<%!

    private String getNewURI(Resource res, Model vivoModel) {
        String firstName = getStringValue(res, FIRST_NAME);
        if (firstName != null) {
        	firstName = firstName.trim().replaceAll("\\W","");
        }
        String lastName = getStringValue(res, LAST_NAME).replaceAll("\\W","");
        if (lastName != null) {
        	lastName = lastName.trim();
        }
        boolean useName = true;
        if ( !( (firstName == null) || (lastName == null) )) {
        	String uriUsingName = VIVO_NS + firstName + lastName;
        	Resource test = vivoModel.getResource( uriUsingName );
        	StmtIterator stmtIt = test.listProperties();
        	if (!stmtIt.hasNext()) {
        		return uriUsingName; 
        	}
        	stmtIt.close();
        } 
        return VIVO_NS + getStringValue(res, NETID);
    }

    private String getStringValue(Resource res, Property prop) {
        StmtIterator stmtIt = res.listProperties(prop);
        if (!stmtIt.hasNext()) {
        	return null;
        }
        try {
        	Statement stmt = stmtIt.nextStatement();
            return ((Literal)stmt.getObject()).getLexicalForm();
        } finally {
        	stmtIt.close();	
        }
    }

%>

    