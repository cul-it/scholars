
<%@page import="com.hp.hpl.jena.query.ResultSetFormatter"%>
<%@page import="com.hp.hpl.jena.query.ResultSet"%>
<%@page import="com.hp.hpl.jena.query.QueryExecution"%>
<%@page import="com.hp.hpl.jena.query.QueryExecutionFactory"%>
<%@page import="com.hp.hpl.jena.query.QueryFactory"%>
<%@page import="com.hp.hpl.jena.query.Query"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaModelMaker"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>
<%@page import="com.hp.hpl.jena.ontology.OntModelSpec"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="com.hp.hpl.jena.rdf.model.ResourceFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>

<%! 

    static final Property NETID = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
	static final Property NETID_TEMP = ResourceFactory.createProperty("temp://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
	
%>

<%!
   private void normalizeNetIds(Model in, Model out) {
       StmtIterator stmtIt = in.listStatements((Resource) null, NETID, (RDFNode) null);
       while (stmtIt.hasNext()) {
    	   Statement stmt = stmtIt.nextStatement();
    	   if (stmt.getObject().isLiteral()) {
    		   String lex = ((Literal)stmt.getObject()).getLexicalForm().split("@")[0].toLowerCase().trim();
    		   out.add(stmt.getSubject(),NETID_TEMP,lex);
    	   }
       }	   
   }
   
%>


<%

   	OntModel jenaOntModel = ModelAccess.on(application).getBaseOntModel();
   
    Model netIdModel = ModelFactory.createDefaultModel();
	normalizeNetIds(jenaOntModel, netIdModel);
	
	response.setContentType("application/rdf+xml");
	netIdModel.write(response.getOutputStream());
	response.flushBuffer();
	
%>