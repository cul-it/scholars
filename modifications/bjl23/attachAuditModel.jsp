<%@ page import="com.hp.hpl.jena.ontology.OntModel" %>

<%

	OntModel auditModel = (OntModel) getServletContext().getAttribute("jenaAuditModel");
	OntModel ontModel = (OntModel) getServletContext().getAttribute("jenaOntModel");
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
