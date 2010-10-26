
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="java.util.HashSet"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDFS"%>
<%@page import="com.hp.hpl.jena.ontology.Individual"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.ontology.OntClass"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>	
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%><%


	OntModel m = (OntModel) getServletContext().getAttribute("jenaOntModel");

	Property personDepartment = m.getProperty("http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_Department");
	OntClass OrganizedEndeavor = m.getOntClass("http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavor");
	//OntClass AcademicDepartment = m.getOntClass("http://vivo.library.cornell.edu/ns/0.1#AcademicDepartment");
	Property weillDeptId = m.getProperty("http://vivo.cornell.edu/ns/mannadditions/0.1#weillDeptId");
	
	Resource WeillCornellFlag = m.getResource("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag2ValueWeillMedicalThing");
	
	HashSet<String> missingDepartments = new HashSet<String>();
	int notMissing = 0;	
	
	Model weillDeptIdModel = ModelFactory.createDefaultModel();
	
	StmtIterator deptIt = m.listStatements((Resource)null, personDepartment, (RDFNode)null);
	while (deptIt.hasNext()) {
		Statement deptStmt = deptIt.nextStatement();
		String deptNameStr = ((Literal)deptStmt.getObject()).getLexicalForm();
		Iterator deptIndIt = m.listIndividuals(OrganizedEndeavor);
		boolean found = false;
		String labelStr = "";
		while (deptIndIt.hasNext()) {
			Individual deptInd = (Individual) deptIndIt.next();
			try {
				labelStr = ((Literal)deptInd.getPropertyValue(weillDeptId)).getLexicalForm();
			} catch (Exception e) {}
			if ( m.contains(deptInd, RDF.type, WeillCornellFlag) &&					
					labelStr.equals(deptNameStr)) {
				found = true;
				weillDeptIdModel.add(deptInd, weillDeptId, labelStr);
				break;
			}
		}
		if (!found) {
			missingDepartments.add(deptNameStr);
		} else {
			notMissing++;
		}
	}

	
	//response.setContentType("application/rdf+xml");
	//weillDeptIdModel.write(response.getOutputStream());
	//response.getOutputStream().flush();
	//response.getOutputStream().close();
	
	
	out.println("<p>"+notMissing+" found </p>");
	
	for (String missingDeptName : missingDepartments) {
		out.println("<p>"+missingDeptName+"</p>");
	}
	
	
%>