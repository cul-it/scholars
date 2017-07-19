/* $This file is distributed under the terms of the license in /doc/license.txt$ */
package edu.cornell.mannlib.vitro.webapp.controller.ajax;

import java.io.IOException;
import java.lang.Integer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONException;

import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.RDFNode;

import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.ajax.VitroAjaxController;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder;
import edu.cornell.mannlib.vitro.webapp.dao.jena.QueryUtils;

public class HomePageDataGetters extends AbstractAjaxResponder {

    private static final Log log = LogFactory.getLog(HomePageDataGetters.class.getName());
    private static final String PARAM_QUERY_TYPE = "querytype";
	private List<Map<String,String>>  queryResults;
    private String theCount;	
    private static String RESEARCHER_QUERY = ""
        + "PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"
    	+ "PREFIX foaf:     <http://xmlns.com/foaf/0.1/>  \n"
    	+ "PREFIX vitro:    <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>  \n"
        + "SELECT DISTINCT (count(?mst) AS ?count)  \n"
        + "WHERE { \n"
        + " ?person rdf:type foaf:Person .  \n"
        + " ?person vitro:mostSpecificType ?mst . \n"
        + " FILTER (str(?mst) != \"http://xmlns.com/foaf/0.1/Person\") \n"
        + "}";

    private static String GRANT_QUERY = ""
        + "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"
        + "PREFIX bibo: <http://purl.org/ontology/bibo/>  \n"
        + "PREFIX vivo: <http://vivoweb.org/ontology/core#>  \n"
        + "SELECT DISTINCT (count(distinct ?grant) as ?count) \n"
        + "WHERE { \n"
        + "    ?grant rdf:type vivo:Grant .  \n"
        + "}";

    private static String ARTICLE_QUERY = ""
        + "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"
        + "PREFIX bibo: <http://purl.org/ontology/bibo/>  \n"
        + "PREFIX vivo: <http://vivoweb.org/ontology/core#>  \n"
        + "SELECT DISTINCT (count(distinct ?article) as ?count)  \n"
        + "WHERE { \n"
        + " ?article rdf:type bibo:AcademicArticle .  \n"
        + "}";

    private static String JOURNAL_QUERY = ""
        + "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"
        + "PREFIX bibo: <http://purl.org/ontology/bibo/>  \n"
        + "PREFIX vivo: <http://vivoweb.org/ontology/core#>  \n"
        + "SELECT DISTINCT (count(distinct ?journal) as ?count) \n"
        + "WHERE { \n"
        + " ?journal rdf:type bibo:Journal .  \n"
        + "}";

	public HomePageDataGetters(HttpServlet parent, VitroRequest vreq,
			HttpServletResponse resp) {
		super(parent, vreq, resp);
    }

	@Override
	public String prepareResponse() throws IOException, JSONException {
		try {
            String queryType = vreq.getParameter(PARAM_QUERY_TYPE);

			queryResults = getQueryResults(queryType, vreq);
			
			String response = "{ ";
			
			for (Map<String, String> map: queryResults) {
				theCount = map.get("count");
				response += "\"count\": \"" + theCount + "\"";
			}

            response += " }";

			log.debug(response);

			return response;
		} catch (Exception e) {
			log.error("Failed homepage datagetters", e);
			return EMPTY_RESPONSE;
		}
	}

    private List<Map<String,String>>  getQueryResults(String queryType, VitroRequest vreq) {

        String queryStr = "";
		switch(queryType) {
			case "researcher": 
				queryStr = RESEARCHER_QUERY;
				break;
			case "grant": 
				queryStr = GRANT_QUERY;
				break;
			case "article": 
				queryStr = ARTICLE_QUERY;
				break;
			case "journal": 
				queryStr = JOURNAL_QUERY;
				break;
			default :
		 		queryStr = RESEARCHER_QUERY;
		}

        log.debug("queryStr = " + queryStr);
        List<Map<String,String>>  queryResults = new ArrayList<Map<String,String>>();
        try {
            ResultSet results = QueryUtils.getQueryResults(queryStr, vreq);
            while (results.hasNext()) {
                QuerySolution soln = results.nextSolution();
                queryResults.add(QueryUtils.querySolutionToStringValueMap(soln));
            }
        } catch (Exception e) {
            log.error(e, e);
        }    

        return queryResults;
    }
}

