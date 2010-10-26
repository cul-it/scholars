<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaModelMaker" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.utils.jena.JenaIngestUtils" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Literal" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ResourceFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Statement" %>
<%@ page import="com.hp.hpl.jena.ontology.OntModel" %>
<%@ page import="com.hp.hpl.jena.ontology.OntModelSpec" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedList" %>
<%@ page import="com.hp.hpl.jena.query.Query" %>
<%@ page import="com.hp.hpl.jena.query.QueryExecution" %>
<%@ page import="com.hp.hpl.jena.query.QueryExecutionFactory" %>
<%@ page import="com.hp.hpl.jena.query.QueryFactory" %>


<% /* Here comes one big long narrative script written in a JSP, because we don't
      have a nice way of compiling clone-specific Java classes */ %>

<% 
	String RAW_DATA_MODEL = "CALS Faculty Reporting Data Work Model";
	String WORK_MODEL = "CFR-Links-WorkModel";
	String ADDITIONS = "CFR-Links-Additions";
	String RETRACTIONS = "CFR-Links-Retractions";
%>

<%

    VitroJenaModelMaker modelMaker = (VitroJenaModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
    modelMaker = new VitroJenaModelMaker(modelMaker, request);

%>

<%
	Model rawDataModel = modelMaker.createModel(RAW_DATA_MODEL);
	Model workModel = modelMaker.createModel(WORK_MODEL);
	workModel.removeAll(null,null,null);
	Model additions = modelMaker.createModel(ADDITIONS);
	additions.removeAll(null,null,null);
	Model retractions = modelMaker.createModel(RETRACTIONS);
	retractions.removeAll(null,null,null);

	JenaIngestUtils utils = new JenaIngestUtils();

	String tboxNs = "http://vitro.mannlib.cornell.edu/ns/mann/calsFacultyReporting#";
	String VITRO_NS = "http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" ;

	String[] deptProps = { tboxNs+"Dept_Web_Title", tboxNs+"Dept_Web_URL" } ;
	String[] rcProps = { tboxNs+"Research_Center_Web", tboxNs+"Research_Center_URL" } ; 
	String[] pProps = { tboxNs+"Professional_Web_Title", tboxNs+"Professional_URL" } ;
	String[] oProps = { tboxNs+"Other_Web_Title", tboxNs+"Other_URL" } ;
	List<String[]> origPropertyList = new LinkedList<String[]>();
	origPropertyList.add( deptProps );
	origPropertyList.add( rcProps  ) ;
	origPropertyList.add( pProps );
	origPropertyList.add( oProps );


	for (String[] propURIs : origPropertyList) {
		String linkConstruct = 
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
			"PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
			"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n"+
			"PREFIX owl: <http://www.w3.org/2002/07/owl#>\n"+
			"PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>\n"+
			"PREFIX cfr: <"+tboxNs+">\n" +
	
			" CONSTRUCT { \n" +
			"	?person vitro:additionalLink _:link . \n" +
			"	_:link rdf:type vitro:Link . \n" +
			"	_:link vitro:linkAnchor ?anchorText . \n" +
			"	_:link vitro:linkURL ?url \n" +
			"} WHERE { \n" +
			"	?person cfr:hasResponse ?response . \n" +
			"	?response <"+propURIs[0]+"> ?anchorText . \n" +
			"	?response <"+propURIs[1]+"> ?url \n" +
            "   FILTER(str(?anchorText) != \"\") " +
			"   FILTER(str(?url) != \"\") " +
			"}";

		Query query = QueryFactory.create(linkConstruct);
        QueryExecution qexec = QueryExecutionFactory.create(query,rawDataModel);
        try {
            qexec.execConstruct(workModel);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}

		Model tmp = ModelFactory.createDefaultModel();
		/* Now we need to chop off everything after the pipe */
		for (Statement stmt : ((List<Statement>) workModel.listStatements().toList()) ) {
			if (!stmt.getObject().isLiteral()) {
				tmp.add(stmt);
			} else {
				//I'm going to assume plain literals
				String lit = ((Literal)stmt.getObject()).getLexicalForm();
				String[] splitt = lit.split("\\|");
				String splitLit = (splitt.length>0) ? splitt[0] : "";
				// If it's a URL, we want to do some special massaging.
				if (stmt.getPredicate().getURI().equals(VITRO_NS+"linkURL")) {
					String urlStr = splitLit;
					String[] tokens = urlStr.split("\\|");
					if (tokens.length>0) {
						urlStr = tokens[0];
						//tokenize on spaces
						tokens = urlStr.split(" ");
						int maxLength = 0;
						//get the longest token
						String longestWord = "";
								for (int i=0; i<tokens.length; i++) {
									if (tokens[i].length()>maxLength) {
										maxLength = tokens[i].length();
										longestWord = tokens[i];
									}
								}
								urlStr = longestWord;
								//if the token is greater than 7 characters and contains a dot,
								//we'll assume it's supposed to be a URL
								if ( (urlStr.length()>7) && urlStr.indexOf(".")>-1) {
									//let's make sure the URL has http://
									//this will, of course, mangle things if we have, say, a mailto: URI here
									urlStr.replaceAll("Http","http");
									if (urlStr.indexOf("http://") != 0) {
										urlStr = "http://"+urlStr;
									}			
								}						
					}
					splitLit = urlStr;
				}
				if (splitLit.length()>0)
					tmp.add(stmt.getSubject(), stmt.getPredicate(), tmp.createLiteral(splitLit));
				}
			}	
		

		//Now let's get just the links that still have a nonempty anchor and url
		Model tmp2 = ModelFactory.createDefaultModel();
		String queryStr = 
			"PREFIX vitro: <"+VITRO_NS+">\n"+
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"+
			"CONSTRUCT { \n"+
			"    ?person vitro:additionalLink ?link .\n"+
			"    ?link rdf:type ?type .\n"+
			"    ?link vitro:linkURL ?url .\n"+
			"    ?link vitro:linkAnchor ?anchor \n"+
			"} WHERE { \n"+
			"    ?person vitro:additionalLink ?link .\n"+
			"    ?link rdf:type ?type .\n"+
			"    ?link vitro:linkURL ?url .\n"+
			"    ?link vitro:linkAnchor ?anchor \n"+
			"    FILTER(str(?url) != \"\") \n"+
			"    FILTER(str(?anchor) != \"\") \n"+
			"}";

		Query query = QueryFactory.create(queryStr);
        QueryExecution qexec = QueryExecutionFactory.create(query,tmp);
        try {
            qexec.execConstruct(tmp2);
        } catch (Exception e) {
            e.printStackTrace();
        }
		String NEW_LINK_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/calsFacultyReporting/2007/";

		//Now let's convert all our lovely new bnode Link individuals into named individuals
		Model tmp3 = utils.renameBNodes(tmp, NEW_LINK_NAMESPACE+"link");
	
		// Replace the old statements with the new pipe-less ones
		workModel.removeAll(null,null,null);
		workModel.add(tmp3); //do I really want to do this?
		additions.add(tmp3);

		//now we want to retract any existing links for people who have new links

		/* Okay, now we want to attach the webapp model and construct a copy of the old links to retract */
		Model webappModel = modelMaker.createModel("vitro:jenaOntModel");	
		queryStr = 
			"PREFIX vitro: <"+VITRO_NS+">\n"+
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"+
			"CONSTRUCT { \n"+
			"    ?person vitro:additionalLink ?link .\n"+
			"    ?link ?linkProp ?linkObj .\n"+
			"} WHERE { \n"+
			"    ?person vitro:additionalLink ?link .\n"+
			"    ?link ?linkProp ?linkObj .\n"+
			"    ?person vitro:additionalLink ?newLink \n" + 
			"    FILTER(!regex(str(?link),\""+NEW_LINK_NAMESPACE+"\")) \n"+
			"    FILTER(regex(str(?newLink),\""+NEW_LINK_NAMESPACE+"\")) \n"+
			"}";
	
		OntModel unionModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		unionModel.addSubModel(tmp3);
		unionModel.addSubModel(webappModel);
		query = QueryFactory.create(queryStr);
        qexec = QueryExecutionFactory.create(query,unionModel);
        try {
            qexec.execConstruct(retractions);
        } catch (Exception e) {
            e.printStackTrace();
        }
	

		//Let's do this again, with the primary links
		queryStr = 
			"PREFIX vitro: <"+VITRO_NS+">\n"+
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"+
			"CONSTRUCT { \n"+
			"    ?person vitro:primaryLink ?link .\n"+
			"    ?link ?linkProp ?linkObj .\n"+
			"} WHERE { \n"+
			"    ?person vitro:primaryLink ?link .\n"+
			"    ?link ?linkProp ?linkObj .\n"+
			"    ?person vitro:additionalLink ?newLink \n" + 
			"    FILTER(!regex(str(?link),\""+NEW_LINK_NAMESPACE+"\")) \n"+
			"    FILTER(regex(str(?newLink),\""+NEW_LINK_NAMESPACE+"\")) \n"+
			"}";
	    query = QueryFactory.create(queryStr);
        qexec = QueryExecutionFactory.create(query,unionModel);
        try {
            qexec.execConstruct(retractions);
        } catch (Exception e) {
            e.printStackTrace();
        }
	
		System.out.println("Done - yay!"); 

%>

<html>
    <head>
		<title>TEST</title>
	</head>
	<body>
		<h1>
			Links Work Model Has <%=workModel.size()%> Statements
		</h1>
	</body>
</html>
