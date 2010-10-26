
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
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

    Property PREFERRED_TITLE = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#preferredTitle");
    Property MONIKER = ResourceFactory.createProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#moniker");
    
%>

<%

    ModelMaker modelMaker = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (ModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);
    
    Model existingPeopleModel = 
    	("retractions".equals(request.getParameter("mode")))
            ? modelMaker.getModel("existing people retractions")
            : modelMaker.getModel("existing people assertions");
    Model vivoModel = modelMaker.getModel("vitro:jenaOntModel");
    if (vivoModel.size() < 10000) {
        throw new RuntimeException("VIVO model is too small.  A current snapshot of VIVO must be made available.");
    }
    
    Model outputModel = ModelFactory.createDefaultModel();
    
    StmtIterator stmtIt = existingPeopleModel.listStatements();
    while (stmtIt.hasNext()) {
    	Statement stmt = stmtIt.nextStatement();
    	if (!stmt.getPredicate().equals(MONIKER) && !stmt.getPredicate().equals(RDF.type)) {
    		outputModel.add(stmt);
    	}
    }
    
    StmtIterator monikerStmtIt = existingPeopleModel.listStatements((Resource)null, MONIKER, (RDFNode)null);
    while (monikerStmtIt.hasNext()) {   
    	Statement monikerStmt = monikerStmtIt.nextStatement();
    	StmtIterator testVivoForPreferredIt = vivoModel.listStatements(monikerStmt.getSubject(), PREFERRED_TITLE, (RDFNode) null);
    	if (!testVivoForPreferredIt.hasNext()) {
    		outputModel.add(monikerStmt);
    	}
    	testVivoForPreferredIt.close();
    }
    
   
    response.setContentType("text/plain");
    outputModel.write(response.getOutputStream(),"N3");
    //existingPeopleModel.difference(outputModel).write(response.getOutputStream(),"N3");
    response.getOutputStream().flush();
    
%>


    