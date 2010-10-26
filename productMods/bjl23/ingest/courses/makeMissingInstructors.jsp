
<%@page import="com.hp.hpl.jena.datatypes.xsd.XSDDatatype"%>
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

<%! 
	String RAW_DATA_MODEL = "Courses - Additions";
	
	String WORK_MODEL = "Courses - Missing Instructor Additions";
	String MODTIME_MODEL = "new modtimes" ;
	
	Property MODTIME = ResourceFactory.createProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#modTime");
	String STARS_NS = "http://vitro.mannlib.cornell.edu/ns/cornell/stars/classes#";
	Property PRIMARY_INSTRUCTOR_PROP = ResourceFactory.createProperty(STARS_NS+"class_PrimaryInstructor");
	
	Property TAUGHT_BY_PROP = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#taughtByAcademicEmployee");
	Property TEACHES_CLASS_PROP = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#teacherOfSemesterClass");
	
	Resource PERSON_CLASS = ResourceFactory.createResource("http://www.aktors.org/ontology/portal#Person");
	Property CORNELL_EMAIL_NETID = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId");
	
	String NEW_RES_NS = "http://vivo.cornell.edu/resource/classes/2009fa/";
	
%>

<%! 
	public List<String[]> parseInstructors(String input) { 
		
		List<String[]> instructors = new LinkedList<String[]>();
		try {
			// not going to bother pre-compiling these patterns
			String[] individualInstructorStrs = input.split("\\)");
			for (int i=0; i<individualInstructorStrs.length; i++) {
				String[] nameAndNetId = individualInstructorStrs[i].split("\\(");
				String netId = (nameAndNetId.length>1) ? nameAndNetId[1] : null;
				String[] namePieces = nameAndNetId[0].split(",");
				namePieces[0] = namePieces[0].trim();
				namePieces[1] = namePieces[1].trim();
				String name = namePieces[0]+", "+namePieces[1];
				String[] outputPair = new String[2];
				outputPair[0] = name; 
				outputPair[1] = netId;
				instructors.add(outputPair);
			}
		} catch (Exception e) {
			System.out.println("Error parsing "+input);
		}
		return instructors;
	}

%>


<%

    VitroJenaModelMaker modelMaker = (VitroJenaModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);
    
    Model rawModel = modelMaker.getModel(RAW_DATA_MODEL);
    Model workModel = modelMaker.createModel(WORK_MODEL);
    workModel.removeAll((Resource)null,(Property)null,(RDFNode)null);
    Model modTimeModel = modelMaker.createModel(MODTIME_MODEL);
    modTimeModel.removeAll((Resource)null,(Property)null,(RDFNode)null);
    
    int alreadyHaveInstructors = 0;
    int addedInstructors = 0;
    
    StmtIterator stmtIt = rawModel.listStatements((Resource)null, this.PRIMARY_INSTRUCTOR_PROP, (RDFNode)null);
    while (stmtIt.hasNext()) {
    	Statement stmt = stmtIt.nextStatement();
    	if (rawModel.contains(stmt.getSubject(),this.TAUGHT_BY_PROP,(RDFNode)null)) {
    	 	alreadyHaveInstructors++;
    	} else {
    		addedInstructors++;
    		String instructorString = ((Literal)stmt.getObject()).getLexicalForm();
    		for (String[] instData : parseInstructors(instructorString) ) {
    			String identifier = (instData[1] != null) ? instData[1] : instData[0].replaceAll("\\W","");
    			Resource instructorRes = workModel.createResource(NEW_RES_NS+"instructor/"+identifier);
    			workModel.add(instructorRes,RDF.type,PERSON_CLASS);
    			workModel.add(instructorRes,RDFS.label,instData[0]);
    			if (instData[1] != null) {
    				workModel.add(instructorRes,CORNELL_EMAIL_NETID,instData[1]+"@cornell.edu");
    			} else {
    				System.out.println("Created "+instructorRes.getURI());
    			}
    			Resource actualClassRes = stmt.getSubject();
    			//Resource actualClassRes = ResourceFactory.createResource(NEW_RES_NS+stmt.getSubject().getLocalName());
    			workModel.add(actualClassRes,this.TAUGHT_BY_PROP,instructorRes);
    			workModel.add(instructorRes,this.TEACHES_CLASS_PROP,actualClassRes);
    			modTimeModel.add(actualClassRes,MODTIME,"2009-01-11T17:00:00",XSDDatatype.XSDdateTime);
    		}
    	}
    	    	
    }
    
    System.out.println(alreadyHaveInstructors+" skipped because already had instructors");
    System.out.println(addedInstructors+" new instructors added");

    
%>