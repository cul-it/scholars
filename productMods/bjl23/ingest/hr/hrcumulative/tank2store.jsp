
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.ontology.Individual"%>
<%@page import="com.hp.hpl.jena.util.iterator.ClosableIterator"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="com.hp.hpl.jena.ontology.OntModelSpec"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaModelMaker"%>

<%! 
	String TANK_GRAPH_URI = "http://vivo.cornell.edu/ns/hrcumulative/graph/tank/";
	String STORE_GRAPH_URI = "http://vivo.cornell.edu/ns/hrcumulative/graph/store/";

	String PERSON_CLASS_URI = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#Person";
	String EMPLID_PROPERTY_URI = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#person_Emplid";
	
	OntModelSpec ONT_MODEL_SPEC = OntModelSpec.OWL_MEM;
%>

<%

	return; /* safety latch: REMOVE ME TO RUN */

    VitroJenaModelMaker modelMaker = (VitroJenaModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);
    
    Model tankModel = modelMaker.createModel(TANK_GRAPH_URI);
    Model storeModel = modelMaker.createModel(STORE_GRAPH_URI);
    
    OntModel tankOntModel = ModelFactory.createOntologyModel(ONT_MODEL_SPEC,tankModel);
    OntModel storeOntModel = ModelFactory.createOntologyModel(ONT_MODEL_SPEC,storeModel);
    
    Resource personClassRes = tankModel.getResource(this.PERSON_CLASS_URI);
    Property emplidProperty = tankModel.getProperty(this.EMPLID_PROPERTY_URI);
    
    ClosableIterator personIt = tankOntModel.listIndividuals(personClassRes);
    try {
    	while (personIt.hasNext()) {
    		Individual personInd = (Individual) personIt.next();
    		RDFNode emplidValue = personInd.getPropertyValue(emplidProperty);
    		if (emplidValue != null) {
    			// so there will be multiple storePersonInds.  We want the latest.
    			// storePersonInd = 
    		}
    	}
    } finally {
    	personIt.close();	
    }
   
    
    
 %>