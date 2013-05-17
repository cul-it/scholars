<%@ page import="com.hp.hpl.jena.ontology.OntModel" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>

<%

	OntModel auditModel = (OntModel) getServletContext().getAttribute("jenaAuditModel");
    OntModel ontModel = ModelAccess.on(getServletContext()).getJenaOntModel();
	ontModel.addSubModel(auditModel);

%>

<html>
<head>
	<title>Audit Model Attached to Webapp</title>
</head>
<body>
	<h1>Audit model attached to webapp</h1>
</body>
</html>
