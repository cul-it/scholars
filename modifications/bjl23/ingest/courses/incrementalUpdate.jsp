
<%@page import="com.hp.hpl.jena.util.iterator.ExtendedIterator"%><%@page import="com.hp.hpl.jena.datatypes.xsd.XSDDatatype"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%><% /* WARNING: do not run on a public webapp; not thread safe : doesn't lock the webapp model */ %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaModelMaker" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.jena.WebappDaoFactoryJena" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.utils.jena.JenaIngestUtils" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Literal" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Property" %>
<%@ page import="com.hp.hpl.jena.rdf.model.RDFNode" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ResourceFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Statement" %>
<%@ page import="com.hp.hpl.jena.vocabulary.RDFS" %>
<%@ page import="com.hp.hpl.jena.ontology.Individual" %>
<%@ page import="com.hp.hpl.jena.ontology.OntModel" %>
<%@ page import="com.hp.hpl.jena.ontology.OntModelSpec" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="com.hp.hpl.jena.query.Query" %>
<%@ page import="com.hp.hpl.jena.query.QueryExecution" %>
<%@ page import="com.hp.hpl.jena.query.QueryExecutionFactory" %>
<%@ page import="com.hp.hpl.jena.query.QueryFactory" %>

<% /*
	This process assumes that there is new data in a model called Courses - Additions
	and a snapshot from the current Sesame data in Sesame Snapshot.
	
	It will produce a delta in:
		Retractions for Sesame
		Additions for Sesame
*/ %>


<% 

/*

	General plan here:
		foreach class in newModel
			get by key in existingModel
			if not found, copy new class into additionsModel
			else
				get 1-deep models for each class
				rewrite new class with existing URI
				diff models 
				if diff > just modTime 
					get full models for each
					matrix
		end foreach
		
*/

%>

<%! 
	String NEW_MODEL = "Courses - Additions";
	String EXISTING_MODEL = "Sesame Snapshot";
	String SESAME_ADDITIONS = "Additions for Sesame";
	String SESAME_RETRACTIONS = "Retractions for Sesame";
	
	Property MODTIME = ResourceFactory.createProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#modTime");
	
	String STARS_NS = "http://vitro.mannlib.cornell.edu/ns/cornell/stars/classes#";
	Resource CLASS = ResourceFactory.createResource(STARS_NS+"Class");
	Property KEY = ResourceFactory.createProperty(STARS_NS+"class_CourseIDandClassNbr");
	
%>


<%!

	// iterative copy method to copy properties and direct properties of related objects (but not further)
	private void copyAs(Resource res, Resource asRes, Model model) {
		StmtIterator stmtIt = res.listProperties();
		while (stmtIt.hasNext()) {
			Statement stmt = stmtIt.nextStatement();
			model.add(asRes, stmt.getPredicate(), stmt.getObject());
			if (stmt.getObject().isResource()) {
				StmtIterator objStmtIt = ((Resource)stmt.getObject()).listProperties();
				while (objStmtIt.hasNext()) {
					Statement objStmt = objStmtIt.nextStatement();
					if (objStmt.getObject().isResource() && ( ((Resource)objStmt.getObject()).equals(res) )) {
						model.add(objStmt.getSubject(),objStmt.getPredicate(),asRes);	
					} else {
						model.add(objStmt);
					}
				}
			}
		}
	}

	private void copy(Resource res, Model model) {
		copyAs(res, res, model);
	}

%>

<%

    VitroJenaModelMaker modelMaker = (VitroJenaModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);
    
    Model newModel = modelMaker.getModel(NEW_MODEL);
    Model existingModel = modelMaker.getModel(EXISTING_MODEL);
    
    Model sesameAdditionsModel = modelMaker.createModel(SESAME_ADDITIONS);
    Model sesameRetractionsModel = modelMaker.createModel(SESAME_RETRACTIONS);
    sesameAdditionsModel.removeAll((Resource)null,(Property)null,(RDFNode)null);
    sesameRetractionsModel.removeAll((Resource)null,(Property)null,(RDFNode)null);
    
    OntModel newOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM,newModel);
    OntModel existingOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM,existingModel);
    
    
    int zeroMatches = 0;
    int oneMatch = 0;
    int moreThanOneMatch = 0;
    int maxMatches = 0;
    
    int unchanged = 0;
    int changed = 0;
    int newClasses = 0;
    
    /* Iterate through each of the new classes */
    Iterator newClassIt = newOntModel.listIndividuals(CLASS);
    while (newClassIt.hasNext()) {
    	Individual newClassInd = (Individual) newClassIt.next();
    	// try to get the matching individual(s) in existingModel
    	RDFNode keyValue = newClassInd.getPropertyValue(KEY);
    	if (keyValue != null) {
	    	ExtendedIterator existIt = existingModel.listSubjectsWithProperty(KEY, keyValue);
	    	
	    	//int numMatches = testIt.toSet().size();
	    	//if (numMatches==0) zeroMatches++; 
	    	//else if (numMatches==1) oneMatch++;
	    	//else if (numMatches>1) moreThanOneMatch++;
	    	//else System.out.println("Error!");
	    	//if (numMatches>maxMatches) maxMatches = numMatches;
	    	
	    	if (!existIt.hasNext()) {
	    		// class not found, so copy new resource into additions graph
	    		copy(newClassInd,sesameAdditionsModel);
	    		newClasses++;
	    	} else {
		    	while (existIt.hasNext()) {
		    		Resource existResource = (Resource) existIt.next();
		    		Model existingSubGraph = ModelFactory.createDefaultModel();
		    		Model newSubGraph = ModelFactory.createDefaultModel();
		    		existingSubGraph.add(existingModel.listStatements(existResource,(Property)null,(RDFNode)null));
		    		existingSubGraph.add(existingModel.listStatements((Resource)null,(Property)null,existResource));
		    		// rewrite existing statements using the existing URI
		    		StmtIterator it = newOntModel.listStatements(newClassInd, (Property)null, (RDFNode)null);
		    		while (it.hasNext()) {
		    			Statement stmt = it.nextStatement();
						newSubGraph.add(existResource, stmt.getPredicate(), stmt.getObject());
		    		}
		    		it = newOntModel.listStatements((Resource)null, (Property)null, newClassInd);
		    		while (it.hasNext()) {
		    			Statement stmt = it.nextStatement();
						newSubGraph.add(stmt.getSubject(), stmt.getPredicate(), existResource);
		    		}
		    		Model diff = newSubGraph.difference(existingSubGraph);
		    		//System.out.println("diff: "+diff.size());
		    		if (diff.size()>1) {
		    			sesameRetractionsModel.add(existingSubGraph);
		    			copyAs(newClassInd,existResource,sesameAdditionsModel);
		    			changed++;
		    		} else {
		    			unchanged++;	
		    		}
		    		
		    	}
	    	}
	    	existIt.close();
    	} else {
    		System.out.println("WARNING: "+newClassInd.getURI()+" has no identifier");
    	}
    }
       
    System.out.println("\n--------\n");
    System.out.println("New classes: "+newClasses);
    System.out.println("Unchanged classes: "+unchanged);
    System.out.println("Changed classes: "+changed);
    
    //System.out.println("New classes: "+zeroMatches);
    //System.out.println("One match: "+oneMatch);
    //System.out.println("More than one match: "+moreThanOneMatch);
    //System.out.println("Greatest number of matches: "+maxMatches);
%>