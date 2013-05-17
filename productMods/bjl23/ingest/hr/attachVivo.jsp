<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.ontology.OntModel" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>

<%

    OntModel jenaOntModel = ModelAccess.on(getServletContext()).getJenaOntModel();
	
	Model vivoModel = ModelFactory.createDefaultModel();
	vivoModel.read("file:///Users/bjl23/Desktop/vivo.rdf");
	getServletContext().setAttribute("vivoModel",vivoModel);

	jenaOntModel.addSubModel(vivoModel);

%>

<html>
<head>
  <title>VIVO Model Attached</title>
</head>
<body>
  <h1>VIVO model attached</h1>
</body>
</html>
