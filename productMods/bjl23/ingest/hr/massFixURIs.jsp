
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.File"%>
<%@page import="com.hp.hpl.jena.util.ResourceUtils"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDFS"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.query.QuerySolution"%>
<%@page import="com.hp.hpl.jena.query.ResultSet"%>
<%@page import="com.hp.hpl.jena.query.QueryExecutionFactory"%>
<%@page import="com.hp.hpl.jena.query.QueryExecution"%>
<%@page import="com.hp.hpl.jena.query.QueryFactory"%>
<%@page import="com.hp.hpl.jena.query.Query"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%><%
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>

OntModel jenaOntModel = ModelAccess.on(application).getJenaOntModel();
OntModel baseOntModel = ModelAccess.on(application).getBaseOntModel();

Model retractionsModel = ModelFactory.createDefaultModel();
Model additionsModel = ModelFactory.createDefaultModel();

String queryStr = 
	"PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
    "PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> \n" +
    "PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> \n" +
    "PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#> \n" +
    "PREFIX mann:  <http://vivo.cornell.edu/ns/mannadditions/0.1#> \n" +

    "SELECT ?person \n" + 
    "WHERE \n" + 
    "{ \n" +
     "?person rdf:type vivo:CornellEmployee . \n" +
     "?person rdfs:label ?label \n" +
     "FILTER (regex(str(?person),\"hri3\")) \n" +
    "} \n" + 
    "LIMIT 5000 \n";
    
    Query query = QueryFactory.create(queryStr);
    QueryExecution qe = QueryExecutionFactory.create(query, jenaOntModel);
    ResultSet rs = qe.execSelect();
    while (rs.hasNext()) {
    	QuerySolution sol = (QuerySolution) rs.next();
    	Resource personRes = sol.getResource("?person");
    	retractionsModel.add(baseOntModel.listStatements(personRes, null, (RDFNode) null));
    	retractionsModel.add(baseOntModel.listStatements((Resource)null, null, personRes));
    	additionsModel.add(baseOntModel.listStatements(personRes, null, (RDFNode) null));
        additionsModel.add(baseOntModel.listStatements((Resource)null, null, personRes));
        // get new URI
        StmtIterator labelIt = baseOntModel.listStatements(personRes, RDFS.label, (RDFNode)null);
        String labelStr = "";
        while (labelIt.hasNext()) {
        	Statement labelStmt = labelIt.nextStatement();
        	labelStr = ((Literal)labelStmt.getObject()).getLexicalForm();
        }
        String[] labelTokens = labelStr.split(" ");
        String localName = labelTokens[1].replaceAll("\\W","")+labelTokens[0].replaceAll("\\W","");
                
        String preferredURI = "http://vivo.library.cornell.edu/ns/0.1#" + localName;
        int count = 0;
        while (baseOntModel.getIndividual(preferredURI) != null) {
        	count++;
        	preferredURI = "http://vivo.library.cornell.edu/ns/0.1#" + localName + "_" + count;
        }
        
        // rename in additions model
        Resource newRes = additionsModel.getResource(personRes.getURI());
        ResourceUtils.renameResource(newRes, preferredURI);
    System.out.println("yep");
}

        System.out.println("What the fuck???");
        
        File retractionsFile = new File("/Users/bjl23/Desktop/renamedPersonRetractions.n3");
        File additionsFile = new File("/Users/bjl23/Desktop/renamedPersonAdditions.n3");
        
        FileOutputStream additionsFos = new FileOutputStream(additionsFile);
        FileOutputStream retractionsFos = new FileOutputStream(retractionsFile);
        
        retractionsModel.write(retractionsFos, "N3");
        additionsModel.write(additionsFos, "N3");
        additionsFos.flush();
        retractionsFos.flush();
        additionsFos.close();
        retractionsFos.close();
        
    
    
    
%>


