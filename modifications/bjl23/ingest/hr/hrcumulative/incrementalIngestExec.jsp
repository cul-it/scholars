
<%@page import="java.net.URLEncoder"%>
<%@page import="java.io.File"%>

<%!

	private static final String ABOX_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/hr/hrcumulative/";
	private static final String TBOX_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#";
	
	private static final String RULES1_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#";
	
	private static final String[] NETID_LOCAL_NAMES = {"emeritus_Netid", "person_Netid", "separation_Netid"};
	
	private static final String MODEL_NAME = "http://vivo.cornell.edu/ns/hrcumulative/graph/tank/";
	private static final String STORE_NAME = "http://vivo.cornell.edu/ns/hrcumulative/graph/store/";

	private static final DateFormat xsdDateFormat = new SimpleDateFormat("yyyy-MM-dd");
	private static final DateFormat xsdDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	
	private static final Pattern DATE_PATTERN = Pattern.compile("\\d\\d\\d\\d-[0-1]\\d-[0-3]\\d");

%>

<%!

	private static final String OBJECT_PROPERTY_CONSTRUCT = 
	//Yep, this should be a StringBuffer, but at least we're only doing this once
	//I could also load this from a model, but for the moment I'm not going to.
			" PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
			" PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> " +
			" PREFIX hr: <http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#> " +
			" PREFIX hr2: <http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#> " +

			" CONSTRUCT { " +
			"	 ?person hr2:hasPerson ?persondata ." +
			"    ?person hr2:hasDegree ?degree . " +
			"    ?person hr2:hasEmeritus ?emeritus . "+
			"    ?person hr2:hasJob ?job . " +
			"    ?person hr2:hasLeave ?leave . " +
			"    ?person hr2:hasSeparation ?separation . " +
			"    ?person hr2:hasBillingReserve ?billingReserve . " +
			"} WHERE { " +
			"   { ?person hr2:emplid ?emplid ." +
			"     ?persondata hr:person_Emplid ?emplid  " +
			"   } UNION " +
			"   { ?person hr2:emplid ?emplid ."+
			"     ?degree hr:degree_Emplid ?emplid " + 
			"   } UNION " + 
			"   { ?person hr2:emplid ?emplid . " +
			"     ?emeritus hr:emeritus_Emplid ?emplid " + 
			"   } UNION " + 
			"   { ?person hr2:emplid ?emplid . " +
			"     ?job hr:job_Emplid ?emplid " + 
			"   } UNION " + 
			"   { ?person hr2:emplid ?emplid . " +
			"     ?leave hr:leave_Emplid ?emplid " + 
			"   } UNION " + 
			"   { ?person hr2:emplid ?emplid . " +
			"     ?separation hr:separation_Emplid ?emplid " + 
			"   } UNION " +
			"   { ?person hr2:emplid ?emplid . " +
			"     ?billingReserve hr:billingreserve_Emplid ?emplid " + 
			"   } " +
			"}" ;

	String SEPARATION_CONSTRUCT = 
		"# CONSTRUCT to link separations to jobs separated \n" +

		"PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
		"PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> \n" +
		"PREFIX hr1: <http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#> \n" +
		"PREFIX hr2: <http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#> \n" +

		"CONSTRUCT { \n" +
		    "?job hr2:separatedBy ?separation . \n" +
		    "?separation hr2:separates ?job \n" +
		"} WHERE {" +
		    "?separation hr1:separation_PositionNbr ?positionNbr . \n" +
		    "?separation hr1:separation_Emplid ?emplid . \n" +
		    "?job hr1:job_PositionNbr ?positionNbr . \n" +
		    "?job hr1:job_Emplid ?emplid . \n" +
		    "OPTIONAL { \n" +
		    	"?job hr2:separatedBy ?existingSeparation . \n" +
		    "} \n" +
		    "FILTER(!bound(?existingSeparation)) \n" +
		"# FILTER so we don't re-separate jobs that have already been separated! \n" +
		"# makes this non-SWRLizable possibly, unless we can do something with date built-ins \n" +
		"}" ; 

%>

<%!

	void applyObjectPropertyConstruct(Model model) {
		Model tmp = ModelFactory.createDefaultModel();
		Query query = QueryFactory.create(OBJECT_PROPERTY_CONSTRUCT);
		QueryExecution qe = QueryExecutionFactory.create(query,model);
		qe.execConstruct(tmp);
		model.add(tmp);
	}

	void applySeparationConstruct(Model model) {
		Model tmp = ModelFactory.createDefaultModel();
		Query query = QueryFactory.create(SEPARATION_CONSTRUCT);
		QueryExecution qe = QueryExecutionFactory.create(query,model);
		qe.execConstruct(tmp);
		model.add(tmp);
	}

	void makeAbstractPersons(Model model) {
		// TODO: make this look at more than just the Person table
		String[] emplidPropURIs = {TBOX_NAMESPACE+"person_Emplid", TBOX_NAMESPACE+"emeritus_Emplid", 
							   TBOX_NAMESPACE+"degree_Emplid", TBOX_NAMESPACE+"separation_Emplid",
							   TBOX_NAMESPACE+"leave_Emplid", TBOX_NAMESPACE+"billingreserve_Emplid",
							   TBOX_NAMESPACE+"job_Emplid" };
		Model additionsModel = ModelFactory.createDefaultModel();
		Property newEmplidProperty = additionsModel.getProperty(RULES1_NAMESPACE+"emplid");
		Resource newPersonType = additionsModel.getResource(RULES1_NAMESPACE+"Person");
		HashSet<String> emplidSet = new HashSet<String>();
		for (int i=0; i<emplidPropURIs.length; i++) {
			Property emplidProp = model.getProperty(emplidPropURIs[i]); 
			StmtIterator stmtIt = model.listStatements((Resource)null,emplidProp,(RDFNode)null);
			while (stmtIt.hasNext()) {
				Statement emplStmt = stmtIt.nextStatement();
				RDFNode emplidNode = emplStmt.getObject();
				String emplidStr = null;
				if (emplidNode.isLiteral()) {
					emplidStr = ((Literal)emplidNode).getLexicalForm();
				}
				if ( (emplidStr != null) && (!(emplidSet.contains(emplidStr))) ) {
					emplidSet.add(emplidStr);
					// assuming subject resource is named according to hr-cumulative conventions
					Resource newPersonRes = additionsModel.createResource(emplStmt.getSubject().getURI().replace("hrcumulative","hrcumulative/person"));
					additionsModel.add(newPersonRes, RDF.type, newPersonType);
					additionsModel.add(newPersonRes, newEmplidProperty, emplidStr);				
				}
			}
		}
		model.add(additionsModel);
	}

	void timestampResources(Model model, String dateStr) throws ParseException {
		Date date = xsdDateFormat.parse(dateStr);
		String dateTimeLexicalForm = xsdDateTimeFormat.format(date);
		Literal dateTimeLit = model.createTypedLiteral(dateTimeLexicalForm,XSDDatatype.XSDdateTime);
		Iterator resIt = model.listSubjects();
		Model tmp = ModelFactory.createDefaultModel();
		Property timestampProp = tmp.createProperty(TBOX_NAMESPACE+"timestamp");
		while (resIt.hasNext()) {
			Resource res = (Resource) resIt.next();
			tmp.add(res, timestampProp, dateTimeLit);
		}
		model.add(tmp);
	}

	void fixBadNetids(Model model) {
		Model additionsModel = ModelFactory.createDefaultModel();
		Model retractionsModel = ModelFactory.createDefaultModel();
		for (int i=0; i<NETID_LOCAL_NAMES.length; i++) {
			String propLocalName = NETID_LOCAL_NAMES[i];
			Property prop = model.getProperty(TBOX_NAMESPACE+propLocalName);
			StmtIterator stmtIt = model.listStatements((Resource)null, prop, (RDFNode)null);
			while (stmtIt.hasNext()) {
				Statement stmt = stmtIt.nextStatement();
				if (stmt.getObject().isLiteral()) {
					Literal lit = (Literal) stmt.getObject();
					if (lit.getLexicalForm().contains("-")) {
						retractionsModel.add(stmt);
						String[] badLexParts = lit.getLexicalForm().split("-");
						String alphaPart = "";
						String numericPart = "";
						try {
							Integer.decode(badLexParts[0]);
							alphaPart = badLexParts[1].toLowerCase();
							numericPart = badLexParts[0];
						} catch (NumberFormatException nfe) {
							try {
								Integer.decode(badLexParts[1]);
								alphaPart = badLexParts[0].toLowerCase();
								numericPart = badLexParts[1];
							} catch (NumberFormatException nfee) {
								throw new Error("Unable to repair "+lit.getLexicalForm());
							}
						}
						
						String newLexicalForm = alphaPart + numericPart;
						Literal newLit = model.createLiteral(newLexicalForm);
						System.out.println("Changed "+lit.getLexicalForm()+" to "+newLexicalForm);
						additionsModel.add(stmt.getSubject(),stmt.getPredicate(),newLit);
					}
				}
			}
		}
		model.remove(retractionsModel);
		model.add(additionsModel);
	}

	String runCsvIngest(File csvDir, Model tank) throws IOException, ParseException {
		if (tank.supportsTransactions()) {
			try {
				tank.begin();
				tank.removeAll((Resource)null,(Property)null,(RDFNode)null);
			} finally {
				tank.commit();
			}
		} else {
			tank.removeAll((Resource)null,(Property)null,(RDFNode)null);
		}
		File[] filesInDir = csvDir.listFiles();
		String dateStr = null;
		for (int file=0; file<filesInDir.length; file++) {
			File currentFile = filesInDir[file];
			String filename = currentFile.getName();
			String[] filenameParts = filename.split("\\.");
			if (filenameParts.length>1) {
				String extension = filenameParts[filenameParts.length-1];
				String preextension = filenameParts[filenameParts.length-2];
				if ("csv".equalsIgnoreCase(extension)) {
					String[] preextensionParts = preextension.split("-");
					String className = preextensionParts[preextensionParts.length-1];
					// there's got to be a better way of using the regex pattern to extract the date.
					String[] findDate = DATE_PATTERN.split(preextension);
					dateStr = preextension.substring(findDate[0].length(),findDate[0].length()+10);
					char[] quoteChars = {'"'};
					Csv2Rdf csv2rdf = new Csv2Rdf(quoteChars, ABOX_NAMESPACE+dateStr+"/", TBOX_NAMESPACE, className);
					FileInputStream fis = new FileInputStream(currentFile);
					Model[] models = csv2rdf.convertToRdf(fis);
					fixBadNetids(models[0]);
					timestampResources(models[0],dateStr);
					if (tank.supportsTransactions()) {
						try {
							tank.begin();
							tank.add(models[0]);
						} finally {
							tank.commit();
						}
					} else {
						tank.add(models[0]);
					}
				}
			}
		}
		System.out.println("data loaded");
		makeAbstractPersons(tank);	
		System.out.println("abstract persons made");
		applyObjectPropertyConstruct(tank);
		System.out.println("object properties constructed");
		return dateStr;
	}
	
	/**
	* If two individuals have the same properties except for the timestamp, return true.
	* Otherwise false.
	*/
	private boolean similarResource(Resource res1, Resource res2) {
		Model res1model = copyPropsExceptTimestamp(res1);
		Model res2model = copyPropsExceptTimestamp(res2);
		return res1model.isIsomorphicWith(res2model);
	}
	
	private Model copyPropsExceptTimestamp(Resource res) {
		Model tmp = ModelFactory.createDefaultModel();
		StmtIterator stmtIt = res.listProperties();
		while (stmtIt.hasNext()) {
			Statement stmt = stmtIt.nextStatement();
			if ( (!(stmt.getPredicate().getURI().equals(this.TBOX_NAMESPACE+"timestamp"))) && (!(stmt.getPredicate().getURI().equals(this.TBOX_NAMESPACE+"currentAsOf"))) ) {
				tmp.add(tmp.getResource("fake://forComparison/"),stmt.getPredicate(),stmt.getObject());
			}
		}
		return tmp;
	}
	
	private void tank2store(Model tank, Model store, String dateStr) throws ParseException {
		// Iterate through all individuals in tank
		OntModel tankOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM,tank);
		OntModel storeOntModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM,store);
		Iterator personIt = tankOntModel.listIndividuals(tankOntModel.getResource(this.RULES1_NAMESPACE+"Person"));
		while (personIt.hasNext()) {
			Individual personInd = (Individual) personIt.next();
			RDFNode emplidNode = personInd.getPropertyValue(tankOntModel.getProperty(this.RULES1_NAMESPACE+"emplid"));
			ClosableIterator storePersonIt = storeOntModel.listSubjectsWithProperty(storeOntModel.getProperty(this.RULES1_NAMESPACE+"emplid"),emplidNode);
			// there had better be only one
			try {
				if (storePersonIt.hasNext()) {
					// get existing Person with this emplid from the Store
					Individual storePerson = (Individual) ((Resource)storePersonIt.next()).as(Individual.class);
					StmtIterator personDataIt = personInd.listProperties();
					// iterate through each existing property of the Person
					while (personDataIt.hasNext()) {
						Statement personDataStmt = personDataIt.nextStatement();
						if (personDataStmt.getObject().isResource()) {
							// only look at object properties
							Resource newDataObject = (Resource) personDataStmt.getObject();
							boolean newDataIsRedundant = false;
							Resource redundantExistingResource = null;
							Iterator existingValuesIt = storePerson.listPropertyValues(personDataStmt.getPredicate());
							while (existingValuesIt.hasNext()) {
								Resource existingDataObject = (Resource) existingValuesIt.next();  	 
								if (similarResource(newDataObject,existingDataObject)) {
									newDataIsRedundant = true;
									redundantExistingResource = existingDataObject;
								}
							}
							if (!newDataIsRedundant) {
								storeOntModel.add(personDataStmt);
								storeOntModel.add(newDataObject.listProperties() );
							} else {
								Property currentAsOf = storeOntModel.getProperty(TBOX_NAMESPACE+"currentAsOf");
								storeOntModel.removeAll(redundantExistingResource, currentAsOf, null);
								Date date = xsdDateFormat.parse(dateStr);
								String dateTimeLexicalForm = xsdDateTimeFormat.format(date);
								storeOntModel.add(redundantExistingResource, currentAsOf, dateStr, XSDDatatype.XSDdateTime);
								// mark existing data as current as of today's date 
							}
						}
					}
				} else {
					// Here's the (relatively) easy part: copy everything about the new person into the store
					StmtIterator personStmtIt = personInd.listProperties();
					while (personStmtIt.hasNext()) {
						Statement personStmt = personStmtIt.nextStatement();
						storeOntModel.add(personStmt);
						if (personStmt.getObject().isResource()) {
							Resource objRes = (Resource) personStmt.getObject();
							storeOntModel.add(objRes.listProperties());
							// stamp currentAsOf
							Property currentAsOf = storeOntModel.getProperty(TBOX_NAMESPACE+"currentAsOf");
							Date date = xsdDateFormat.parse(dateStr);
							String dateTimeLexicalForm = xsdDateTimeFormat.format(date);
							storeOntModel.add(objRes, currentAsOf, dateStr, XSDDatatype.XSDdateTime);
							
						}
					}
				}
			} finally {
				storePersonIt.close();
			}
		}
		System.out.println("about to apply separations");
		applySeparationConstruct(store);
	}

%>

<%

	System.out.println("incrementalIngestExec");

	String retryPath = "./incrementalIngest.jsp";

	String csvDirPath = request.getParameter("csvPath");
	File csvDir;
	
	csvDir = new File(csvDirPath);

	if (!csvDir.isDirectory()) {
		response.sendRedirect(retryPath+"?errorMsg=Please+enter+the+path+to+a+directory.");
		return;
	}
	
	try {
		ModelMaker modelMaker = (ModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
	    modelMaker = (modelMaker == null) ? (ModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
	    modelMaker = new VitroJenaModelMaker(modelMaker, request);
	    Model tank = modelMaker.createModel(this.MODEL_NAME);
		String dateStr = runCsvIngest(csvDir, tank);
		Model store = modelMaker.createModel(this.STORE_NAME);
		tank2store(tank,store,dateStr);
	} catch (Exception e) {
		response.sendRedirect(retryPath+"?errorMsg="+URLEncoder.encode(e.toString(),"UTF-8"));
		return;
	}
			
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  

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
<%@page import="com.hp.hpl.jena.rdf.model.ModelMaker"%><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
	<title>Incremental HR Ingest Completed</title>
</head>

<body>
	<h1>Incremental HR Ingest Completed</h1>
</body>

</html>




 