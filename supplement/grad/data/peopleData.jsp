<%@ page import="com.hp.hpl.jena.query.*" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Literal" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@page contentType="text/text" %>
{
    "properties" : {
        "graduate-field" : {
            valueType : "item"
        }
    },
    "items" : [
<%
    //get people and to JSON as items
    Model model = (Model)application.getAttribute("jenaOntModel");
    if( model == null ) throw new Exception("could not get model from application scope");

    HashMap <String,JSONObject> items = new HashMap<String,JSONObject>();

    String prefixes =
            "PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"+
            "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n"+
            "PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#> \n";

    String queryParam=
            "SELECT ?personLabel ?personUri ?gradfieldLabel\n"+
            "WHERE { \n"+
            " \n"+
            "?fieldClusterUri  \n"+
            "rdf:type  \n"+
            "vivo:fieldCluster . \n"+
            " \n"+
            "?gradfieldUri \n"+
            "vivo:associatedWith \n"+
            "?fieldClusterUri . \n"+
            " \n"+
            "?personUri \n"+
            "vivo:memberOfGraduateField \n"+
            "?gradfieldUri . \n"+
            " \n"+
            "OPTIONAL { ?personUri rdfs:label ?personLabel } \n"+
            "OPTIONAL { ?gradfieldUri rdfs:label ?gradfieldLabel } \n"+
            "} \n"+
            "LIMIT 20000";

      QueryExecution qe = null;
    try{
        Query query = QueryFactory.create(prefixes + queryParam);
        qe = QueryExecutionFactory.create(query, model);
        ResultSet results = qe.execSelect();

        while( results.hasNext()){
            QuerySolution soln = results.nextSolution();

            Literal personLabel = soln.getLiteral("personLabel");
            Literal gradfieldLabel = soln.getLiteral("gradfieldLabel");
            Resource person = soln.getResource("personUri");
            String personUri = person.getURI();
            String personUrl = null;
            try{
                personUrl =
                        request.getContextPath() +
                                "/entity?uri=" + URLEncoder.encode(personUri,"UTF-8");
            }catch(UnsupportedEncodingException ex){
                personUrl = "unsupportedEncodingException";
            }

            JSONObject personObj = items.get(personUri);
            if( personObj == null ){
                personObj = new JSONObject();
                items.put(personUri, personObj);
            }
            personObj.put("id",personUri);
            personObj.put("type","faculty member");
            personObj.put("label", personLabel.getString());
            personObj.put("url" , personUrl);
            JSONArray fields = null;
            if( ! personObj.has("graduate-field") ){
                fields = new JSONArray();
                personObj.put("graduate-field",fields);
            }   else {
                fields = (JSONArray) personObj.get("graduate-field");
            }
            fields.put(gradfieldLabel.getString());
        }
    } finally{
        if( qe != null)
            qe.close();
    }

   String queryParamForResearchAreas=
            "SELECT ?personUri ?areaLabel \n"+
            "WHERE { \n"+
            " \n"+
            "?fieldClusterUri  \n"+
            "rdf:type  \n"+
            "vivo:fieldCluster . \n"+
            " \n"+
            "?gradfieldUri \n"+
            "vivo:associatedWith \n"+
            "?fieldClusterUri . \n"+
            " \n"+
            "?personUri \n"+
            "vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative \n"+
            "?gradfieldUri . \n"+
            " \n"+
            "?areaUri \n"+
            "vivo:ResearchAreaOfPerson   \n"+
            "?personUri . \n"+
            " \n"+
            "OPTIONAL { ?areaUri rdfs:label ?areaLabel } \n"+
            "} \n"+
            "LIMIT 20000";

     qe = null;
    try{
        Query query = QueryFactory.create(prefixes + queryParamForResearchAreas);
        qe = QueryExecutionFactory.create(query, model);
        ResultSet results = qe.execSelect();

        while( results.hasNext()){
            QuerySolution soln = results.nextSolution();

            Literal areaLabel = soln.getLiteral("areaLabel");
            Resource person = soln.getResource("personUri");
            String personUri = person.getURI();

            JSONObject personObj = items.get(personUri);
            if( personObj == null ){
                personObj = new JSONObject();
                items.put(personUri, personObj);
            }

            JSONArray areas = null;
            if( ! personObj.has("research-area") ){
                areas = new JSONArray();
                personObj.put("research-area",areas);
            }   else {
                areas = (JSONArray) personObj.get("research-area");
            }
            areas.put(areaLabel.getString());

        }
    } finally{
        if( qe != null)
            qe.close();
    }

    Iterator<String> it = items.keySet().iterator();
    while(it.hasNext()){
        String key = it.next();
        JSONObject item = items.get(key);
        String comma = it.hasNext() ? ",\n":"\n";
        %>
         <%= item.toString() %> <%= comma %>
        <%
    }
    %>
    ]
}
