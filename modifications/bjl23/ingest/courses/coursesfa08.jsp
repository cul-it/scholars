<% /* WARNING: do not run on a public webapp; not thread safe : doesn't lock the webapp model */ %>

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

<% /* Here comes one big long narrative script written in a JSP, because we don't
      have a nice way of compiling clone-specific Java classes */ %>

<%! 
	String SEMESTER = "2009sp2";
	String RAW_DATA_MODEL = "classes"+SEMESTER+" - raw";
	String RAW_INSTRUCTORS_MODEL = "classes"+SEMESTER+" - instructors - raw";
	String WORK_MODEL = "Courses - Work Model";
	String ADDITIONS = "Courses - Additions";
	String RETRACTIONS = "Courses - Retractions";
%>

<%

	//return; /* safety latch: REMOVE ME TO RUN */

    ModelMaker modelMaker = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);

	Model rawDataModel = modelMaker.createModel(RAW_DATA_MODEL);
	Model workModel = modelMaker.createModel(WORK_MODEL);
	workModel.removeAll(null,null,null);
	Model additions = modelMaker.createModel(ADDITIONS);
	additions.removeAll(null,null,null);
	Model retractions = modelMaker.createModel(RETRACTIONS);
	retractions.removeAll(null,null,null);

	workModel.add(rawDataModel);

	Model webappModel = modelMaker.createModel("vitro:jenaOntModel");
	WebappDaoFactory wadf = new WebappDaoFactoryJena(ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM,webappModel));
%>

<%!
	JenaIngestUtils utils = new JenaIngestUtils();

	//String tboxNs = "http://vitro.mannlib.cornell.edu/ns/courses/2008FA#";
	String tboxNs = "http://vitro.mannlib.cornell.edu/ns/cornell/stars/classes#";
	String VITRO_NS = "http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" ;

	String principalCourseClassURI = tboxNs+"PrimaryCourse";
	String subCourseClassURI = tboxNs+"SubCourse";
	String hasSubCourseClassURI = tboxNs+"hasSubCourse";
	String seminarClassURI = tboxNs+"Seminar";
	String lectureClassURI = tboxNs+"Lecture";
	String labClassURI = tboxNs+"Lab";
	String sectionURI = tboxNs+"Section";
	String fieldworkURI = tboxNs+"Fieldwork";
	String studioSessionURI = tboxNs+"StudioSession";

	Property meetingPatternProperty = ResourceFactory.createProperty(tboxNs+"class_MeetingPatternSdescr");
	Property startAndEndTimeProperty = ResourceFactory.createProperty(tboxNs+"class_StartandEndTime");
	Property componentProperty = ResourceFactory.createProperty(tboxNs+"class_SsrComponent");
	Property facilityProperty = ResourceFactory.createProperty(tboxNs+"class_FacilityLdescr");	
	Property principalOrSubcourse = ResourceFactory.createProperty(tboxNs+"class_PrincipalorSubcourse");
	Property hasSubCourseProperty = ResourceFactory.createProperty(tboxNs+"hasSubCourse");
	Property classSectionProperty = ResourceFactory.createProperty(tboxNs+"class_ClassSection");
	Property classMeetingTimeTextProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#classMeetingTimeText");
	Property subjectProperty = ResourceFactory.createProperty(tboxNs+"class_Subject");
	Property catalogNumberProperty = ResourceFactory.createProperty(tboxNs+"class_CatalogNbr");
	Property courseIdProperty = ResourceFactory.createProperty(tboxNs+"class_CourseId");
	Property gradingBasisProperty = ResourceFactory.createProperty(tboxNs+"class_GradingBasis");
	Property unitsMinimumProperty = ResourceFactory.createProperty(tboxNs+"class_UnitsMinimum");
	Property unitsMaximumProperty = ResourceFactory.createProperty(tboxNs+"class_UnitsMaximum");	
	Property courseTitleLong = ResourceFactory.createProperty(tboxNs+"class_CourseTitleLong");
	Property academicTermProperty = ResourceFactory.createProperty(tboxNs+"class_Academic_Term_Ldescr");

	Property vivoClassCreditsProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#classCredits");
	Property vivoClassYearTermProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#classYearTerm");
	Property vivoClassGradeOptionProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#classGradeOption");
	Property vivoCourseIdProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#classCourseId");
	Property vivoClassCourseCode4DigitProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#classCourseCode4Digit");
	Property vitroMoniker = ResourceFactory.createProperty("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#moniker");

%>

<%
	
	Calendar cal = Calendar.getInstance();
	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	String modTime = dateFormat.format(cal.getTime());

	String[] typeURIs = {seminarClassURI, lectureClassURI, labClassURI, sectionURI, fieldworkURI, studioSessionURI } ;
	String[] values = {"SEM", "LEC", "LAB", "DIS", "FLD", "STU"} ;
	
	String principalCourseTypeConstruct = "" +
	"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
	"PREFIX courses: <"+tboxNs+">\n" +
	"PREFIX vitro: <"+VitroVocabulary.vitroURI+">\n" +
	"PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
	"CONSTRUCT { \n" +
	"    ?course rdf:type <"+principalCourseClassURI+"> . \n" +
    "    ?course rdf:type <http://vivo.library.cornell.edu/ns/0.1#SemesterClass> . \n" +
    "    ?course vitro:modTime \""+ modTime +"\"^^xsd:dateTime \n " +
	"} WHERE { \n" +
	"    ?course courses:class_PrincipalorSubcourse \"Principal\" \n" +
	"}\n" ;
	
	String subCourseTypeConstruct = "" +
	"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
	"PREFIX courses: <"+tboxNs+">\n" +
	"PREFIX vitro: <"+VitroVocabulary.vitroURI+">\n" +
	"PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
	"CONSTRUCT { \n" +
	"    ?course rdf:type <"+subCourseClassURI+"> . \n" +
	"    ?course vitro:modTime \""+ modTime +"\"^^xsd:dateTime \n " +
	"} WHERE { \n" +
	"    ?course courses:class_PrincipalorSubcourse \"Sub-courses\" \n" +
	"}\n" ;
		
	String hasSubCourseConstruct = "" +
	"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
	"PREFIX courses: <"+tboxNs+">\n" +
	"CONSTRUCT { \n" +
	"    ?course courses:hasSubCourse ?subCourse \n" +
	"} WHERE { \n" +
	"    ?course rdf:type courses:PrimaryCourse .\n" +
	"    ?course courses:class_CourseId ?id . \n" +
	"    ?subCourse rdf:type courses:SubCourse . \n" +
	"    ?subCourse courses:class_CourseId ?id \n" +
	"}\n" ;
		
	List<String> typeSparqlConstructs = new LinkedList<String>();
	typeSparqlConstructs.add(principalCourseTypeConstruct);
	typeSparqlConstructs.add(subCourseTypeConstruct);
	typeSparqlConstructs.add(hasSubCourseConstruct);

	for(int i=0; i<typeURIs.length; i++) {
		String q = "" +
		"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
		"PREFIX courses: <"+tboxNs+">\n" +
		"CONSTRUCT { \n" +
		"    ?course rdf:type <"+typeURIs[i]+"> \n" +
		"} WHERE { \n" +
		"    ?course courses:class_SsrComponent \""+values[i]+"\" \n" +
		"}\n" ;
		typeSparqlConstructs.add(q);
	}

	for (String queryStr : typeSparqlConstructs) {
		System.out.println(queryStr);
		Query query = QueryFactory.create(queryStr);
        QueryExecution qexec = QueryExecutionFactory.create(query,workModel);
        try {
			Model tmp = ModelFactory.createDefaultModel();
            qexec.execConstruct(tmp);
			workModel.add(tmp);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}

	//Okay, now we're going to iterate through the courses and link them to instructors
	Pattern leftParenPattern = Pattern.compile("\\(");
	Pattern rightParenPattern = Pattern.compile("\\)");
	Property taughtByProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#taughtByAcademicEmployee");
	Property teachesClassProperty = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#teacherOfSemesterClass"); 
	OntModel workOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM, workModel);
	OntModel webappOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM, webappModel);
	Model tmp = ModelFactory.createDefaultModel();
	
	for (Iterator principalCoursesIt = workOntModel.listIndividuals(ResourceFactory.createResource(tboxNs+"Class")); principalCoursesIt.hasNext(); ) {
		Individual principalCourse = (Individual) principalCoursesIt.next();
		boolean isPrincipalCourse = false;
		RDFNode principalOrSubcourseValue = null;
		principalOrSubcourseValue = principalCourse.getPropertyValue(principalOrSubcourse);
		if ( (principalOrSubcourseValue != null) && (principalOrSubcourseValue.isLiteral()) && ("Principal".equals(((Literal)principalOrSubcourseValue).getLexicalForm())) ) {
			isPrincipalCourse = true;
		}
		RDFNode valueNode = principalCourse.getPropertyValue(ResourceFactory.createProperty(tboxNs+"class_PrimaryInstructor"));
		if (valueNode != null) {
				String instructorStr = ((Literal)valueNode).getLexicalForm();
				//all the split()ting is kinda dumb, but I hate being off by one when taking substrings
				//It would probably be nicer to, say, do this kind of stuff in Perl or something
				String[] tokens = leftParenPattern.split(instructorStr);
				for (int i=0; i<tokens.length; i++) {
					if (tokens[i].indexOf(")") > 2) {
						String[] smallerTokens = rightParenPattern.split(tokens[i]);
						String instructorNetId = smallerTokens[0];
						System.out.println("Instructor netID: "+instructorNetId);
						String instructorURI = wadf.getIndividualDao().getIndividualURIFromNetId(instructorNetId+"@cornell.edu");
						Individual instructorRes = null;
						if (instructorURI != null) {
							instructorRes = webappOntModel.getIndividual(instructorURI);
						}
						if (instructorRes != null) {
							tmp.add(principalCourse, taughtByProperty, instructorRes);
							tmp.add(instructorRes, teachesClassProperty, principalCourse);
							if (isPrincipalCourse) {
								// SET PORTAL FLAGS BASED ON INSTRUCTOR'S FLAGS FOR PRIMARY COURSE
								ClosableIterator typeIt = instructorRes.listRDFTypes(true);
								try {
									while (typeIt.hasNext()) {
										Resource typeRes = (Resource) typeIt.next();	
										if ( (!typeRes.isAnon()) && 
											 (VitroVocabulary.vitroURI.equals(typeRes.getNameSpace())) && 
											 (typeRes.getLocalName() != null) && 
											 (typeRes.getLocalName().indexOf("Flag1Value")==0) ) {
											tmp.add(principalCourse,RDF.type,typeRes);
										}
									}
								} finally {
									if (typeIt != null)  {
										typeIt.close();
									}
								}
							}
						} 			
					}
				}
		}
		if (isPrincipalCourse) {
			StringBuffer sb = new StringBuffer();
			sb.append("<p>");
			//Okay, great. Now we just need to make a big HTML fragment describing the meeting times
			sb.append(renderCourseIndividualMeetingTime(principalCourse));
			sb.append("</p>");
			Map<Integer,String> subCourseMap = new HashMap<Integer,String>();
			for (Iterator subCourseIt = principalCourse.listPropertyValues(hasSubCourseProperty); subCourseIt.hasNext(); ) {
				RDFNode subCourseNode = (RDFNode) subCourseIt.next();
				if (subCourseNode.canAs(Individual.class)) {
					Individual subCourseInd = (Individual) subCourseNode.as(Individual.class);
					String classSectionStr = "0";
					try {
						classSectionStr = ((Literal)subCourseInd.getPropertyValue(classSectionProperty)).getLexicalForm();
					} catch (Exception e) {}
					Integer classSectionInteger = new Integer(classSectionStr);
					subCourseMap.put(classSectionInteger,renderCourseIndividualMeetingTime(subCourseInd));		
				}
			}
			List<Integer> keyList = new LinkedList<Integer>();
			keyList.addAll(subCourseMap.keySet());
			Collections.sort(keyList);
			if (keyList.size() > 0) {
				if (keyList.size()==1) {
					sb.append("<p>Sub-section:</p>");
				} else {
					sb.append("<p>Sub-sections:</p>");
				}
				sb.append("<ul>");
				for (Integer key : keyList) {
					sb.append("<li>");
					sb.append(subCourseMap.get(key));
					sb.append("</li>");
				}		
				sb.append("</ul>");
			}
			tmp.add(principalCourse,classMeetingTimeTextProperty,ResourceFactory.createPlainLiteral(sb.toString()));
			//random other properties
			//make a label
			String subjectStr = "";
			try {
				subjectStr = ((Literal)principalCourse.getPropertyValue(subjectProperty)).getLexicalForm();
			} catch (Exception e) {}
			String catalogNumberStr = "";
			try {
				catalogNumberStr = ((Literal)principalCourse.getPropertyValue(catalogNumberProperty)).getLexicalForm();
			} catch (Exception e) {}
			String courseTitleLongStr = "";
			try {
				courseTitleLongStr = ((Literal)principalCourse.getPropertyValue(courseTitleLong)).getLexicalForm();
			} catch (Exception e) {}
			String labelStr = subjectStr+" "+catalogNumberStr+" - "+courseTitleLongStr+" ("+getMeetingTimeString(principalCourse)+")";
			tmp.add(principalCourse,RDFS.label,labelStr);
			tmp.add(principalCourse,vivoClassCourseCode4DigitProperty,subjectStr+" "+catalogNumberStr);
			String minCreditsStr = "";
			try {
				minCreditsStr = ((Literal)principalCourse.getPropertyValue(unitsMinimumProperty)).getLexicalForm();
			} catch (Exception e) {}
			String maxCreditsStr = "";
			try {
				maxCreditsStr = ((Literal)principalCourse.getPropertyValue(unitsMaximumProperty)).getLexicalForm();
			} catch (Exception e) {}
			String creditsStr = "";
			if (minCreditsStr.equals(maxCreditsStr)) {
				creditsStr = minCreditsStr;
			} else {
				creditsStr = minCreditsStr+" to "+maxCreditsStr;
			}
			tmp.add(principalCourse,vivoClassCreditsProperty,creditsStr);
			tmp.add(principalCourse,vitroMoniker,creditsStr+" credit course");
			tmp.add(principalCourse,vivoClassYearTermProperty,principalCourse.getPropertyValue(academicTermProperty));
			tmp.add(principalCourse,vivoCourseIdProperty,principalCourse.getPropertyValue(courseIdProperty));
			String gradeOptionStr = "";
			try {
				gradeOptionStr = ((Literal)principalCourse.getPropertyValue(gradingBasisProperty)).getLexicalForm();
				if ("GRD".equals(gradeOptionStr)) {
					tmp.add(principalCourse,vivoClassGradeOptionProperty,"letter");
				} else if ("SUS".equals(gradeOptionStr)) {
					tmp.add(principalCourse,vivoClassGradeOptionProperty,"satisfactory/unsatisfactory");
				}
			} catch (Exception e) {}	
	    }
	}
	
	workOntModel.add(tmp);

	//FINAL SPARQL QUERY TO GET THE STUFF WE WANT TO ADD TO VIVO
	
	String finalConstruct = "" +
	"CONSTRUCT { \n" +
	"    ?s ?p ?o \n" +
	"} WHERE { \n" +
	"    ?s ?p ?o \n"+
    "}\n\n";
	
//	String finalConstruct = "" + 
//	"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
//	"PREFIX courses: <"+tboxNs+">\n" +
//	"CONSTRUCT { \n" +
//	"    ?course ?p ?o . \n" +
//	"	 ?s ?q ?course \n" +
//	"} WHERE { \n" +
//	"    ?course rdf:type <http://vivo.library.cornell.edu/ns/0.1#SemesterClass> . \n" +
//	"    ?course ?p ?o . \n" +
//	"	 ?s ?q ?course \n" +
//	"	FILTER(!regex(str(?p),\""+tboxNs+"\")) \n" +
//	"	FILTER(!regex(str(?o),\""+tboxNs+"\")) \n" +
//	"	FILTER(!regex(str(?s),\""+tboxNs+"\")) \n" +
//	"	FILTER(!regex(str(?q),\""+tboxNs+"\")) \n" +
//	"}\n" ;

	Query finalQuery = QueryFactory.create(finalConstruct);
    QueryExecution finalQexec = QueryExecutionFactory.create(finalQuery,workModel);
    try { 
        finalQexec.execConstruct(additions);
    } catch (Exception e) {
        e.printStackTrace();
    }
	
%>

<%!

	String getMeetingTimeString(Individual courseInd) {
		String meetingPatternStr = "";
		try {
			meetingPatternStr = ((Literal)courseInd.getPropertyValue(meetingPatternProperty)).getLexicalForm();
		} catch (Exception e) {}
		String startAndEndTimeStr = "";
		try {
			startAndEndTimeStr = ((Literal)courseInd.getPropertyValue(startAndEndTimeProperty)).getLexicalForm();	
		} catch (Exception e) {}
		return meetingPatternStr+" "+startAndEndTimeStr;
	}

	String renderCourseIndividualMeetingTime(Individual courseInd) {
		String componentStr = "";
		try {
			componentStr = ((Literal)courseInd.getPropertyValue(componentProperty)).getLexicalForm();
		} catch (Exception e) {}
		if ("SEM".equals(componentStr)) { componentStr = "Seminar"; }
		if ("LEC".equals(componentStr)) { componentStr = "Lecture"; }
		if ("LAB".equals(componentStr)) { componentStr = "Lab"; }
		if ("DIS".equals(componentStr)) { componentStr = "Discussion section"; }
		if ("FLD".equals(componentStr)) { componentStr = "Fieldwork" ; }
		if ("STU".equals(componentStr)) { componentStr = "Studio" ; }
		if ("RSC".equals(componentStr)) { componentStr = "Research" ; }
		if ("IND".equals(componentStr)) { componentStr = "Independent study"; }
		
		String facilityStr = "";
		try {
			facilityStr = ((Literal)courseInd.getPropertyValue(facilityProperty)).getLexicalForm();
		} catch (Exception e) {}
		return (new StringBuffer().append(componentStr).append(" ").append(getMeetingTimeString(courseInd)).append(" (").append(facilityStr).append(")")).toString();
	}
%>


<%@page import="java.util.Calendar"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary"%>
<%@page import="com.hp.hpl.jena.util.iterator.ClosableIterator"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelMaker"%><html>
    <head>
		<title>TEST</title>
	</head>
	<body>
		<h1>
			Links Additions Model Has <%=additions.size()%> Statements
		</h1>
	</body>
</html>
