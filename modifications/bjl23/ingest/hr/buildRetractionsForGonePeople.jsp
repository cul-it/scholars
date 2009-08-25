
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.util.iterator.ClosableIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.ResourceFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.FileReader"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="java.io.File"%><%

   
   File inFile = new File("/Users/bjl23/Desktop/gonePeopleNetids.txt");
   Property cornellemailnetId = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
   Property facultyMemberIn = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAcademicFacultyMember");
   Resource adWhite = ResourceFactory.createResource("http://vivo.library.cornell.edu/ns/0.1#individual21121");
   Resource weillCollegeFlag = ResourceFactory.createResource("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag2ValueWeillMedicalThing");
   
   BufferedReader fileReader = new BufferedReader(new FileReader(inFile));

   Model jenaOntModel = (Model) getServletContext().getAttribute("jenaOntModel");
   Model retractionsModel = ModelFactory.createDefaultModel();
   
   String line = null;
   
   while ( (line = fileReader.readLine()) != null) {
	   Resource personRes = null;
	   Literal netIdLit = ResourceFactory.createPlainLiteral(line);
	   ClosableIterator it = jenaOntModel.listSubjectsWithProperty(cornellemailnetId, netIdLit);
	   if (it.hasNext()) {
		   personRes = (Resource) it.next();
	   }
	   it.close();
	   if (personRes == null) {
		   Literal netIdStringLit = ResourceFactory.createTypedLiteral(line);
		   ClosableIterator it2 = jenaOntModel.listSubjectsWithProperty(cornellemailnetId, netIdStringLit);
	       if (it.hasNext()) {
	           personRes = (Resource) it2.next();
	       }
	       it2.close();
	   }
	   if (personRes == null) {
		   System.out.println(line + " not found");
	   } else {
		   if ( !(jenaOntModel.contains(personRes,RDF.type,weillCollegeFlag)) ) {
			   if ( !(jenaOntModel.contains(personRes,facultyMemberIn,adWhite)) ) {
				   retractionsModel.add(jenaOntModel.listStatements(personRes, null, (RDFNode)null));
				   retractionsModel.add(jenaOntModel.listStatements((Resource)null, null, personRes));
			   } else {
				   System.out.println("Skipping " + line + " - A.D. White Prof-at-Large");
			   }
		   } else {
			   System.out.println("Skipping " + line + " - Weill");
		   }
	   }
	   
   }
   
   response.setContentType("text/n3");
   retractionsModel.write(response.getOutputStream(),"N3");
   response.getOutputStream().flush();
      
%>