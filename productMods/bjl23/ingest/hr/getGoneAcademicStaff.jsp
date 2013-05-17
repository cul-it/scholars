
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

<%
   /* Need to remove:
	   1. headOf relationships
	   2. employment properties
	   3. graduate field memberships
	   4. courses taught
	 */
%>


<%! 

    static final Property NETID = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
	static final Property NETID_TEMP = ResourceFactory.createProperty("temp://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
	static final Property EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId");
	static final Property EMPLID_TEMP = ResourceFactory.createProperty("temp://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId");

	static final String storeGraphURI = "http://vivo.cornell.edu/ns/hrcumulative/graph/store/";
	
%>

<%!

	String goneFacultyQueryStr = 
		"PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" +
		"PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>" +
		"PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>\n"+
		"PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>\n"+
		"PREFIX vivot: <temp://vivo.library.cornell.edu/ns/0.1#>\n"+
		"PREFIX mann:  <http://vivo.cornell.edu/ns/mannadditions/0.1#>\n"+
		"PREFIX hr1: <http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#>\n"+
		"PREFIX hr2: <http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#>\n"+
		"PREFIX afn:   <http://jena.hpl.hp.com/ARQ/function#>\n"+
		"#\n"+
		"# This query gets all range entities labels and types of a person\n"+
		"# A query like this could be used to get enough info to create a display\n"+
		"# page for an entity.\n"+
		"#\n"+
		"CONSTRUCT { " +
		"	?person ?p ?o . \n" +
		"   ?oo ?pp ?person \n" +
		" } \n"	+	
		"WHERE \n"+
		"{\n"+
		" ?person rdf:type vivo:CornellAcademicStaff .\n"+
		" ?person rdfs:label ?personLabel .\n"+
		" OPTIONAL {\n"+
		"    ?person rdf:type vitro:Flag2ValueWeillMedicalThing .\n"+
		"    ?person rdfs:label ?weill \n"+
		" }\n"+
		" FILTER (!bound(?weill))\n"+
		" OPTIONAL {\n"+
		"    ?person vitro:sunset ?sunset .\n"+
		" }\n"+
		" ?person vitro:moniker ?moniker .\n"+
		" FILTER ( !regex(?moniker,\"[Em]meritus\") )\n"+
		" FILTER ( (!bound(?sunset)) || (afn:now()<?sunset) )\n"+
		" OPTIONAL {\n"+
		"    ?person <temp://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId> ?emplid .\n"+
		"    ?job hr1:job_Emplid ?emplid .\n"+
		"    OPTIONAL {\n"+
		"        ?job hr2:separatedBy ?separation\n"+
		"    }    \n"+
		" }\n"+
		" OPTIONAL {\n"+
		"    ?person vivot:CornellemailnetId ?netId .\n"+
		"    ?hrperson hr1:person_Netid ?netId . \n " +
	    "    ?hrperson hr1:person_Emplid ?emplid. \n" +
		"    ?job hr1:job_Emplid ?emplid .\n"+
		"    OPTIONAL {\n"+
		"        ?job hr2:separatedBy ?separation\n"+
		"    }    \n"+
		" }\n"+
		" OPTIONAL { "+
		"    ?person vivot:CornellemailnetId ?netId .\n"+
		"    ?emeritus hr1:emeritus_Netid ?netId" +
		" } " +
		" FILTER (!bound(?emeritus)) " +
		" FILTER (!bound(?separation))\n"+
		" FILTER (!bound(?job))\n"+
		" ?person ?p ?o . " +
		" OPTIONAL { " +
		"   ?oo ?pp ?person " +
		" } " +
		"}";

%>


<%!

	//comvert literals to plain literals
   private void normalizeDataPropertyStatements(Model in, Property prop, Model out, Property propOut) {
       StmtIterator stmtIt = in.listStatements((Resource) null, prop, (RDFNode) null);
       while (stmtIt.hasNext()) {
    	   Statement stmt = stmtIt.nextStatement();
    	   if (stmt.getObject().isLiteral()) {
    		   String lex = ((Literal)stmt.getObject()).getLexicalForm();
    		   out.add(stmt.getSubject(),propOut,lex);
    	   }
       }
   }

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

// Need to deal with datatype mismatch:
// 1. Normalize (webapp) netIds to temporary graph
// 2. Normalize (webapp) emplIds to temporary graph
// 3. Mark current jobs in temporary graph

	VitroJenaModelMaker modelMaker = (VitroJenaModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);
	Model storeModel = modelMaker.getModel(storeGraphURI);
    
    OntModel jenaOntModel = ModelAccess.on(application).getBaseOntModel();
   
   	OntModel ontModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
   	ontModel.addSubModel(jenaOntModel);
   	ontModel.addSubModel(storeModel);
   
	Model emplidModel = ModelFactory.createDefaultModel();
	normalizeDataPropertyStatements(ontModel,EMPLID,emplidModel,EMPLID_TEMP);
	ontModel.addSubModel(emplidModel);
	
	Model netIdModel = ModelFactory.createDefaultModel();
	normalizeNetIds(ontModel, netIdModel);
	ontModel.addSubModel(netIdModel);
   	
	System.out.println(goneFacultyQueryStr);
	
	Query goneFacultyQuery = QueryFactory.create(goneFacultyQueryStr);
	QueryExecution exec = QueryExecutionFactory.create(goneFacultyQuery,ontModel);
	Model outModel = ModelFactory.createDefaultModel();
	exec.execConstruct(outModel);
	
	response.setContentType("application/rdf+xml");
	outModel.write(response.getOutputStream());
	response.flushBuffer();
	
%>