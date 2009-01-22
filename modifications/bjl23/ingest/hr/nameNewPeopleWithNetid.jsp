
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

<%

	String VIVO_NS = "http://vivo.library.cornell.edu/ns/0.1#";
	Property NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId");

	ModelMaker modelMaker = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
	modelMaker = (modelMaker == null) ? (ModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
	modelMaker = new VitroJenaModelMaker(modelMaker, request);
	
	Model newPeopleModel = modelMaker.getModel("new people assertions");
	Model outputModel = ModelFactory.createDefaultModel();
	
	outputModel.add(newPeopleModel);
	
	List<String> oldURIs = new ArrayList<String>();
	Iterator resIt = newPeopleModel.listSubjectsWithProperty(NETID);
	while (resIt.hasNext()) {
		Resource res = (Resource) resIt.next();
		oldURIs.add(res.getURI());	
	}
	
	Iterator<String> oldURIit = oldURIs.iterator();
	while(oldURIit.hasNext()) {
		String oldURI = oldURIit.next();
		Resource res = outputModel.getResource(oldURI);
		StmtIterator stmtIt = res.listProperties(NETID);
		Statement stmt = stmtIt.nextStatement();
		String netId = ((Literal)stmt.getObject()).getLexicalForm();
		stmtIt.close();
		ResourceUtils.renameResource(res,VIVO_NS+netId);
	}
	
	response.setContentType("text/plain");
	outputModel.write(response.getOutputStream(),"N3");
	
	%>
	