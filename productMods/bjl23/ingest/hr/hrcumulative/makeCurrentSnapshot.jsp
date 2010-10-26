<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<%@page import="java.net.URLEncoder"%>
<%@page import="java.io.File"%>

<%@page import="java.io.FileReader"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.utils.Csv2Rdf"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="java.io.IOException"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.VitroJenaModelMaker"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.ParseException"%>
<%@page import="com.hp.hpl.jena.datatypes.xsd.XSDDateTime"%>

<%@page import="com.hp.hpl.jena.datatypes.xsd.XSDDatatype"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>


<%@page import="com.hp.hpl.jena.query.Query"%>
<%@page import="com.hp.hpl.jena.query.QueryFactory"%>
<%@page import="com.hp.hpl.jena.query.QueryExecution"%>
<%@page import="com.hp.hpl.jena.query.QueryExecutionFactory"%>
<%@page import="com.hp.hpl.jena.ontology.OntModelSpec"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="com.hp.hpl.jena.ontology.Individual"%>
<%@page import="com.hp.hpl.jena.util.iterator.ClosableIterator"%>
<%@page import="java.util.HashSet"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelMaker"%>

<%!

	private static final String ABOX_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/hr/hrcumulative/";
	private static final String TBOX_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#";
	
	private static final Property TIMESTAMP = ResourceFactory.createProperty(TBOX_NAMESPACE+"timestamp");
	
	private static final String RULES1_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#";
	
	private static final String[] NETID_LOCAL_NAMES = {"emeritus_Netid", "person_Netid", "separation_Netid"};
	
	private static final String MODEL_NAME = "http://vivo.cornell.edu/ns/hrcumulative/graph/tank/";
	private static final String STORE_NAME = "http://vivo.cornell.edu/ns/hrcumulative/graph/store/";
	private static final String SNAPSHOT_NAME = "http://vivo.cornell.edu/ns/hrcumulative/graph/currentSnapshot";

	private static final DateFormat xsdDateFormat = new SimpleDateFormat("yyyy-MM-dd");
	private static final DateFormat xsdDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	
	private static final Pattern DATE_PATTERN = Pattern.compile("\\d\\d\\d\\d-[0-1]\\d-[0-3]\\d");

%>

<%! %>

<%!

	String[] RULES1_PROP_LOCALNAMES = {"hasDegree","hasJob","hasEmeritus","hasBillingReserve","hasSeparation","hasLeave","hasPerson"};
	String ABSTRACT_PERSON_URI = RULES1_NAMESPACE + "Person";
	String SEPARATED_BY_URI = RULES1_NAMESPACE + "separatedBy";

	private Calendar getTimestamp(Resource obj) {
		Calendar cal = null;
		StmtIterator stmtIt = obj.listProperties(TIMESTAMP);
		if (stmtIt.hasNext()) {
			Statement stmt = stmtIt.nextStatement();
			if (stmt.getObject().isLiteral()) {
				Literal lit = (Literal) stmt.getObject();
				 cal = ((XSDDateTime) lit.getDatatype().parse(lit.getLexicalForm())).asCalendar();
			}
		}
		stmtIt.close();
		return cal;	
	}
	
	private boolean supersedes(Resource obj1, Resource obj2) {
		return getTimestamp(obj1).after(getTimestamp(obj2));
	}
	
	private void makeCurrentSnapshot(Model store, Model currentSnapshot) {
		Property separatedBy = store.getProperty(SEPARATED_BY_URI);
		Property[] rules1properties = new Property[RULES1_PROP_LOCALNAMES.length];
		for (int i=0; i<RULES1_PROP_LOCALNAMES.length; i++) {
			rules1properties[i] = store.getProperty(RULES1_NAMESPACE+RULES1_PROP_LOCALNAMES[i]);
		}
		Resource abstractPersonClass = store.getResource(ABSTRACT_PERSON_URI);
		int count = -1;
		Iterator abstractPersonIt = store.listSubjectsWithProperty(RDF.type,abstractPersonClass);
		while (abstractPersonIt.hasNext()) {
			count++;
			if (count % 50 == 0) {
				System.out.println(count + "abstract persons processed");
			}
			Resource abstractPerson = (Resource) abstractPersonIt.next();
			for (Property prop : rules1properties) {
				Resource currentObj = null;
				StmtIterator stmtIterator = abstractPerson.listProperties(prop);
				while (stmtIterator.hasNext()) {
					Statement stmt = stmtIterator.nextStatement();
					if (stmt.getObject().isResource()) {
						Resource obj = (Resource) stmt.getObject();
						StmtIterator separatedIt = obj.listProperties(separatedBy);
						if (!separatedIt.hasNext()) {
							if (currentObj == null) {
								currentObj = obj;
							} else if (!prop.getURI().equals(RULES1_NAMESPACE+"hasJob")) {  // people can have multiple jobs
								if (supersedes(obj, currentObj)) {
									currentObj = obj;
								}
							}
						}
						separatedIt.close();
					}
				}
				if (currentObj != null) {
					currentSnapshot.add(abstractPerson,prop,currentObj);
					StmtIterator copyIt = abstractPerson.listProperties();
					while (copyIt.hasNext()) {
						Statement stmt = copyIt.nextStatement();
						if (stmt.getObject().isLiteral()) {
							currentSnapshot.add(stmt);
						}
					}
					currentSnapshot.add(store.listStatements(currentObj,(Property)null,(RDFNode)null));
				}
				
			}
		}
	}

%>


<%
	//if (request.getAttribute("errorMsg") == null) {
	//	try {
			
			
			ModelMaker modelMaker = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
		    modelMaker = (modelMaker == null) ? (ModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
		    modelMaker = new VitroJenaModelMaker(modelMaker, request);
		    Model tank = modelMaker.createModel(this.MODEL_NAME);
			Model store = modelMaker.createModel(this.STORE_NAME);
			Model currentSnapshot = modelMaker.createModel(this.SNAPSHOT_NAME);
			System.out.println("Clearing snapshot model");
			currentSnapshot.removeAll((Resource) null, (Property) null, (RDFNode) null);
			System.out.println("Populating snapshot model");
			makeCurrentSnapshot(store, currentSnapshot);
		//} catch (Exception e) {
		//	response.sendRedirect("makeCurrentSnapshot.jsp?errorMsg="+URLEncoder.encode(e.toString(),"UTF-8"));
		//	return;
		//}
	//}

%>


<%@page import="com.hp.hpl.jena.rdf.model.ResourceFactory"%>
<%@page import="org.openrdf.sesame.sail.StatementIterator"%>
<%@page import="java.util.Calendar"%><html>
    <head>
        <title>Current HR Snapshot Constructed</title>
    </head>
    <body>
		<h1>Current HR snapshot constructed</h1>
	</body>
</html>