<%@ page import="com.hp.hpl.jena.query.*" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%-- Generate JSON for people exhibit --%>

<%@page contentType="application/json" %>

<%
    //get people and to JSON as items
    Model model = (Model)application.getAttribute("jenaOntModel");
    if( model == null ) throw new Exception("could not get model from application scope");

    JSONObject data = new JSONObject();
    JSONArray items = new JSONArray();
    data.put("itmes",items);

    String queryParam="blakjd";
      QueryExecution qe = null;
            try{
                Query query = QueryFactory.create(queryParam);
                qe = QueryExecutionFactory.create(query, model);
                if( query.isSelectType() ){
                    ResultSet results = null;
                    results = qe.execSelect();

                    
                }
            } finally{
                if( qe != null)
                    qe.close();
            }
    //get departments, add to JSON as itmes

    //get research areas, add to JSON as itmes

    //get labs, add to JSON as itmes

    //add schema
%>
