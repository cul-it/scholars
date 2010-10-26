<%

    final String EMPL_ID = "http://vivo.cornell.edu/ns/hr/0.9/hr.owl#";
    final String NET_ID = "http://vivo.cornell.edu/ns/0.1#CornellemailnetId";

    final String WORKFLOW_FILE = "/bjl23/ingest/hr/hrIngestWorkflow2.n3";
    final String WORKFLOW_FORMAT = "N3";
    final String WORKFLOW_URI = "http://vitro.mannlib.cornell.edu/ns/ingest/HRIngestWorkflow#HrIngestWorkflow";
    
    boolean ingestComplete = false;

    if (request.getParameter("submit") != null) {
	    VitroRequest vreq = new VitroRequest(request);
	    
	    //normalize keys in existing model
	    OntModel jenaOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM,getVitroJenaModelMaker(vreq).getModel("vitro:jenaOntModel"));
	    Model tempModel = ModelFactory.createDefaultModel();
	    String[] propURIs = {EMPL_ID, NET_ID};
	    for (String propURI : propURIs) {
	    	Property prop = jenaOntModel.getProperty(propURI);
	    	StmtIterator stmtIt = jenaOntModel.listStatements((Resource)null,prop,(RDFNode)null);
	    	while (stmtIt.hasNext()) {
	    		Statement stmt = stmtIt.nextStatement();
	    		if (stmt.getObject().isLiteral()) {
	    			tempModel.add(stmt.getSubject(), stmt.getPredicate(), ((Literal)stmt.getObject()).getLexicalForm());
	    		}
	    	}
	    }
	    jenaOntModel.addSubModel(tempModel);
	    
	    String workflowFilePath = getServletContext().getRealPath(WORKFLOW_FILE);
	    File workflowFile = new File(workflowFilePath);
	    FileInputStream fis = new FileInputStream(workflowFile);
	    OntModel workflowModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
	    workflowModel.read(fis, null, WORKFLOW_FORMAT);
	    Individual workflowInd = workflowModel.getIndividual(WORKFLOW_URI);
	    JenaIngestWorkflowProcessor workflowProcessor = new JenaIngestWorkflowProcessor(workflowInd,getVitroJenaModelMaker(vreq));
		String startingStepURI = request.getParameter("startingStep");
		if (startingStepURI == null) {
	    	workflowProcessor.run();
		} else {
			workflowProcessor.run(workflowModel.getIndividual(startingStepURI));
		}
	    ingestComplete = true;
    }

%>

<%!

	private ModelMaker getVitroJenaModelMaker(HttpServletRequest request) {
	    ModelMaker myVjmm = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
	    myVjmm = (myVjmm == null) ? (ModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : myVjmm;
	    return new VitroJenaSpecialModelMaker(myVjmm, request);
	}

%>


   
<%@page import="edu.cornell.mannlib.vitro.webapp.utils.jena.JenaIngestUtils"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.utils.jena.JenaIngestWorkflowProcessor"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="com.hp.hpl.jena.ontology.OntModelSpec"%>
<%@page import="com.hp.hpl.jena.ontology.Individual"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelMaker"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaSpecialModelMaker"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%><html>
   <head>
       <title>Run HR Ingest</title>
   </head>
   <body>
<% if (ingestComplete) { %>
        <h1>Ingest Complete</h1>
<% } else { %>
       <h1>Run HR Ingest</h1>
       <p>Make sure a DB has been connected with a model named "raw data" 
           containing the raw data from the HR CSV files.</p>
       <form method="post" action="">
		   <p><input type="text" name="startingStep"/>Optional workflow step URI</p>
           <input type="submit" name="submit" value="Run Ingest"/>
       </form>
<% } %>
   </body>
   </html>
    
