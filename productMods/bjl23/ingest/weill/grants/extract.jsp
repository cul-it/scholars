
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary"%>
<%@page import="java.util.List"%>
<%@page import="com.hp.hpl.jena.vocabulary.RDF"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.ontology.Individual"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.ResourceFactory"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="com.hp.hpl.jena.ontology.OntModelSpec"%>
<%@page import="com.hp.hpl.jena.rdf.model.StmtIterator"%>
<%@page import="com.hp.hpl.jena.rdf.model.Statement"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.query.*" %>
<%@page import="com.hp.hpl.jena.vocabulary.OWL"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.utils.jena.DedupAndExtract"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.JenaModelUtils"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>

<%!

    private final static Resource PORTAL_FLAG = ResourceFactory.createResource(VitroVocabulary.vitroURI + "Flag1Value10Thing"); // vetmed

    private final static String VIVO_NS = "http://vivo.library.cornell.edu/ns/0.1#";
 
%>


<%!

    private final static String EXTRACT_QUERY = " \n" +
"PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
"PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> \n" + 
"PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> \n" +
"PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>\n" +
"PREFIX mann:  <http://vivo.cornell.edu/ns/mannadditions/0.1#>\n" +
"#\n" +
"# Extracts Weill grant data. Needs to be piped after a sameAs deduplication stage\n" +
"#\n" +
"CONSTRUCT {\n" +
"   ?g rdf:type vivo:ResearchGrant .\n" +
"   ?g vitro:label ?label . \n" +
"   ?g vivo:FinancialAwardHasPrimaryInvestigatorPerson ?pi .\n" +
"   ?pi vivo:PersonPrimaryInvestigatorOfFinancialAward ?g .\n" +
"   ?g vivo:FinancialAwardIsCoInvestigatedByPerson ?copi .\n" +
"   ?copi vivo:PersonCoInvestigatorOfFinancialAward ?g .\n" +
"   ?pi vitro:label ?piLabel . \n" +
"   ?pi <http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_CWID> ?piCwid . \n" + 
"   ?copi vitro:label ?copiLabel . \n" +
"   ?copi <http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_CWID> ?copiCwid . \n" +
"   ?pi rdf:type ?piType . \n" +
"   ?copi rdf:type ?copiType . \n" +
"   ?g vivo:fundedBy ?f .\n" +
"   ?f vivo:fundsAward ?g .\n" +
"   ?f rdf:type vivo:grantFundingAgent . \n" +
"   ?f vitro:label ?fLabel .\n" +
"   ?f vivo:weillFundingAgencyCode ?fCode .\n" +
"   ?g vivo:raspAwardId ?raspAwardId .\n" +
"   ?g vivo:weillGrantCurrentFundEffectiveDate ?beginDate .\n" +
"   ?g vivo:weillGrantFinalExpirationDate ?endDate\n" +
"} WHERE {\n" +
"   ?g rdf:type vivo:ResearchGrant .\n" +
"   ?g vitro:label ?label .\n" +
"   ?g <http://ingest.mannlib.cornell.edu/generalizedXMLtoRDF/0.1/AWARD_STATUS> \"Active\" .\n" +
"   ?g vivo:FinancialAwardHasPrimaryInvestigatorPerson ?pi .\n" +
"   ?pi vivo:PersonPrimaryInvestigatorOfFinancialAward ?g .\n" +
"    OPTIONAL { \n" +
"        ?pi vitro:label ?piLabel . \n" +
"        ?pi <http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_CWID> ?piCwid . \n" + 
"        FILTER (regex(str(?pi),\"WCMCGrantAwards\")) \n" +
"        LET (?piType := <http://www.aktors.org/ontology/portal#AcademicEmployee>) \n" +
"    } \n" +
"   OPTIONAL {\n" +
"       ?g vivo:FinancialAwardIsCoInvestigatedByPerson ?copi .\n" +
"       ?copi vivo:PersonCoInvestigatorOfFinancialAward ?g\n" +
"       OPTIONAL { \n" +
"           ?copi vitro:label ?copiLabel . \n" +
"           ?copi <http://vitro.mannlib.cornell.edu/ns/wcmc/people/person_CWID> ?copiCwid . \n" + 
"           FILTER (regex(str(?copi),\"WCMCGrantAwards\")) \n" +
"           LET (?copiType := <http://www.aktors.org/ontology/portal#AcademicEmployee>) \n" +
"       } \n" +
"   }\n" +
"   OPTIONAL {\n" +
"       ?g vivo:fundedBy ?f .\n" +
"       ?f vivo:fundsAward ?g .\n" +
"       ?f vitro:label ?fLabel .\n" +
"       ?f vivo:weillFundingAgencyCode ?fCode .\n" +
"   }\n" +
"   ?g vivo:raspAwardId ?raspAwardId .\n" +
"   OPTIONAL {\n" +
"       ?g vivo:weillGrantCurrentFundEffectiveDate ?beginDate\n" +
"   }\n" +
"   OPTIONAL {\n" +
"       ?g vivo:weillGrantFinalExpirationDate ?endDate\n" +
"   } \n" +
"} " ; 


%>

<%

    OntModel model = ModelAccess.on(getServletContext()).getJenaOntModel();

    Model abox = (new JenaModelUtils()).extractABox(model);
    System.out.println(abox.size());
    abox.add(model.listStatements((Resource) null, OWL.sameAs, (RDFNode) null));
    System.out.println(abox.size());

    OntModel output = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM, (new DedupAndExtract()).dedupAndExtract(abox, VIVO_NS));
    System.out.println(output.size());

    // now run the SPARQL CONSTRUCT
    Model desiredProperties = ModelFactory.createDefaultModel();
    Query extractQuery = QueryFactory.create(EXTRACT_QUERY, Syntax.syntaxARQ);
    QueryExecution qe = QueryExecutionFactory.create(extractQuery, output);
    qe.execConstruct(desiredProperties);
    
    response.setContentType("text/N3");
    desiredProperties.write(response.getOutputStream(),"N3");
    
%>
