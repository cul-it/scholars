<%@ page import="com.hp.hpl.jena.query.*" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Literal" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Set" %>
<%@page contentType="application/json" %>
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

    HashMap <String,String> gradfieldMap = new HashMap<String,String>();

    String prefixes =
            "PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"+
            "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n"+
            "PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#> \n";

    String queryParam=
            "SELECT ?personLabel ?personUri ?gradfieldUri ?gradfieldLabel\n"+
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
                    Resource gradfield = soln.getResource("gradfieldUri");
                    Resource person = soln.getResource("personUri");
                    String personLabelStr = personLabel.getString();
                    String gradfieldUri = gradfield.getURI();
                    String gradfieldLabelStr = gradfieldLabel.getString();
                    String personUri = person.getURI();
                    String comma = results.hasNext() ? ",": "";
                    gradfieldMap.put( gradfieldUri, gradfieldLabelStr);
%>
        { type : "faculty member" ,
          id : "<%= personUri %>" ,
          label : "<%= personLabelStr %>" ,
          "graduate-field" : "<%= gradfieldLabelStr %>"
        } <%= comma %>
<%
                }
            } finally{
                if( qe != null)
                    qe.close();
            }
%>
    ]
}
