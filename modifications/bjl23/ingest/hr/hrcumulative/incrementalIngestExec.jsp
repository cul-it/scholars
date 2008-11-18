
<%@page import="java.net.URLEncoder"%>
<%@page import="java.io.File"%>

<%!

	private static final String ABOX_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/hr/hrcumulative/";
	private static final String TBOX_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/1#";
	
	private static final String RULES1_NAMESPACE = "http://vitro.mannlib.cornell.edu/ns/bjl23/hr/rules1#";
	
	private static final String[] NETID_LOCAL_NAMES = {"emeritus_Netid", "person_Netid", "separation_Netid"};
	
	private static final String MODEL_NAME = "tank-dev";

	private static final DateFormat xsdDateFormat = new SimpleDateFormat("yyyy-MM-dd");
	private static final DateFormat xsdDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	
	private static final Pattern DATE_PATTERN = Pattern.compile("\\d\\d\\d\\d-[0-1]\\d-[0-3]\\d");

%>

<%!

	void makeAbstractPersons(Model model) {
		// TODO: change URI generation 
		Model additionsModel = ModelFactory.createDefaultModel();
		Property emplidProperty = model.getProperty(TBOX_NAMESPACE+"person_Emplid");
		Property newEmplidProperty = additionsModel.getProperty(RULES1_NAMESPACE+"emplid");
		Resource personType = model.getResource(TBOX_NAMESPACE+"Person");
		Resource newPersonType = additionsModel.getResource(RULES1_NAMESPACE+"Person");
		StmtIterator stmtIt = model.listStatements((Resource)null,RDF.type,personType);
		while (stmtIt.hasNext()) {
			Statement stmt = stmtIt.nextStatement();
			Resource subj = stmt.getSubject();
			StmtIterator emplIt = subj.listProperties(emplidProperty);
			Literal emplidLiteral = null;
			while (emplIt.hasNext()) {
				Statement emplStmt = emplIt.nextStatement();
				RDFNode emplidNode = emplStmt.getObject();
				if (emplidNode.isLiteral()) {
					emplidLiteral = (Literal) emplidNode;
				}
			}
			// assuming subject resource is named and has a localName
			Resource newPersonRes = additionsModel.createResource(RULES1_NAMESPACE+subj.getLocalName());
			additionsModel.add(newPersonRes, RDF.type, newPersonType);
			if (emplidLiteral != null) {
				additionsModel.add(newPersonRes, newEmplidProperty, emplidLiteral);				
			} else {
				System.out.println("WARN: Couldn't find emplid for "+subj.getURI());
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
						String alphaPart = badLexParts[1].toLowerCase();
						String numericPart = badLexParts[0];
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

	void runCsvIngest(File csvDir, Model tank) throws IOException, ParseException {
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
					String dateStr = preextension.substring(findDate[0].length(),findDate[0].length()+10);
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
		makeAbstractPersons(tank);	
	}

%>



<%

	String retryPath = "./incrementalIngest.jsp";

	String csvDirPath = request.getParameter("csvPath");
	File csvDir;
	
	csvDir = new File(csvDirPath);

	if (!csvDir.isDirectory()) {
		response.sendRedirect(retryPath+"?errorMsg=Please+enter+the+path+to+a+directory.");
		return;
	}
	
	try {
		VitroJenaModelMaker modelMaker = (VitroJenaModelMaker) request.getSession().getAttribute("vitroJenaModelMaker");
	    modelMaker = (modelMaker == null) ? (VitroJenaModelMaker) getServletContext().getAttribute("vitroJenaModelMaker") : modelMaker;
	    modelMaker = new VitroJenaModelMaker(modelMaker, request);
	    Model tank = modelMaker.createModel(this.MODEL_NAME);
		runCsvIngest(csvDir, tank);
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
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
	<title>Incremental HR Ingest Completed</title>
</head>

<body>
	<h1>Incremental HR Ingest Completed</h1>
</body>

</html>




 