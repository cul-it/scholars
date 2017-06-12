/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.json;

import java.io.IOException;
import java.io.Writer;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import edu.cornell.mannlib.vitro.webapp.application.ApplicationUtils;
import edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean;
import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.beans.VClass;
import edu.cornell.mannlib.vitro.webapp.beans.VClassGroup;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.FreemarkerHttpServlet;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.IndividualListController;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.IndividualListController.PageRecord;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.IndividualListQueryResults;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.ExceptionResponseValues;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.ResponseValues;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.TemplateResponseValues;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder.ParamMap;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder;
import edu.cornell.mannlib.vitro.webapp.controller.individuallist.IndividualListResults;
import edu.cornell.mannlib.vitro.webapp.controller.individuallist.IndividualListResultsUtils;
import edu.cornell.mannlib.vitro.webapp.controller.VitroHttpServlet;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.dao.IndividualDao;
import edu.cornell.mannlib.vitro.webapp.dao.IndividualDao;
import edu.cornell.mannlib.vitro.webapp.dao.jena.VClassGroupCache;
import edu.cornell.mannlib.vitro.webapp.dao.VClassDao;
import edu.cornell.mannlib.vitro.webapp.dao.VClassGroupDao;
import edu.cornell.mannlib.vitro.webapp.dao.VClassGroupsForRequest;
import edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary;
import edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory;
import edu.cornell.mannlib.vitro.webapp.i18n.I18n;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchEngine;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchEngineException;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchFacetField.Count;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchFacetField;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchQuery;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchQuery.Order;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResponse;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResultDocument;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResultDocumentList;
import edu.cornell.mannlib.vitro.webapp.search.VitroSearchTermNames;
import edu.cornell.mannlib.vitro.webapp.services.shortview.ShortViewService;
import edu.cornell.mannlib.vitro.webapp.services.shortview.ShortViewService.ShortViewContext;
import edu.cornell.mannlib.vitro.webapp.services.shortview.ShortViewServiceSetup;
import edu.cornell.mannlib.vitro.webapp.utils.searchengine.SearchQueryUtils;
import edu.cornell.mannlib.vitro.webapp.web.templatemodels.LinkTemplateModel;
import edu.cornell.mannlib.vitro.webapp.web.templatemodels.searchresult.IndividualSearchResult;
import edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.IndividualTemplateModel;

/**
 * 
 */

public class ResearchAndScholarshipJsonServlet extends VitroHttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(ResearchAndScholarshipJsonServlet.class);
    
    protected static final int DEFAULT_HITS_PER_PAGE = 12;
    protected static final int DEFAULT_MAX_HIT_COUNT = 100;   

    private static final String PARAM_AJAX_REQUEST = "ajax";
    private static final String PARAM_START_INDEX = "startIndex";
    private static final String PARAM_CURRENT_PAGE = "currentPage";
    private static final String PARAM_HITS_PER_PAGE = "hitsPerPage";
    private static final String PARAM_CLASSGROUP = "classgroup";
    private static final String PARAM_RDFTYPE = "type";
    private static final String PARAM_VCLASS_ID = "vclassId";
    private static final String PARAM_AFFILIATIONS = "affiliations";
    private static final String PARAM_ADMINISTRATORS = "administrators";
    private static final String PARAM_FUNDERS = "funders";
    private static final String PARAM_PUB_VENUES = "pubVenues";
    private static final String PARAM_START_YEAR = "startYear";
    private static final String PARAM_END_YEAR = "endYear";
    private static final String PARAM_ACTIVE_YEAR = "activeYear";
    private static final String PARAM_QUERY_TEXT = "querytext";
    private static final String PARAM_QUERY_TYPE = "querytype";
	private static final String KEYWORD_FIELD = "keyword_txt";

    protected enum Order {
        ASC, DESC         
    }
         
     @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doPost(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doGet(req, resp);
        VitroRequest vreq = new VitroRequest(req);
		JSONObject rObj = processAjaxRequest(vreq, resp);

		resp.setCharacterEncoding("UTF-8");
		resp.setContentType("application/json;charset=UTF-8");
		Writer writer = resp.getWriter();

//		rObj.put("errorMessage", errorMessage);
		writer.write(rObj.toString());
		
	}
	
	public static JSONObject processAjaxRequest(VitroRequest vreq, HttpServletResponse response) {
		JSONObject rObj = null;
		String errorMessage = "";

		try {
	        if( vreq.getWebappDaoFactory() == null 
	                || vreq.getWebappDaoFactory().getIndividualDao() == null ){
	            log.error("Could not get webappDaoFactory or IndividualDao");
	            throw new Exception("Could not access model.");
	        }

	        IndividualDao iDao = vreq.getWebappDaoFactory().getIndividualDao();

	        int startIndex = getStartIndex(vreq);            
	        int hitsPerPage = getHitsPerPage( vreq );           
	        int currentPage = getCurrentPage( vreq );  

	        String queryText = vreq.getParameter(PARAM_QUERY_TEXT);  
	        String queryType = vreq.getParameter(PARAM_QUERY_TYPE);  

			SearchQuery query = getQuery(queryText, queryType, hitsPerPage, startIndex, vreq);  
//
		 	  SearchEngine search = ApplicationUtils.instance().getSearchEngine();
			  SearchResponse resp = null;           
            try {
                resp = search.query(query);
            } catch (Exception ex) {                
                log.error("could not run search query",ex);
				JSONObject jsonObj = new JSONObject("{'query exception'}");
		 	    return jsonObj;
            }

              SearchResultDocumentList docs = resp.getResults();
              if (docs == null) {
                  log.error("Document list for a search was null");                
				JSONObject jsonObj = new JSONObject("{'failed search'}");
		 	    return jsonObj;
              }
			  log.debug("DOCS = " + docs.toString());  
              long hitCount = docs.getNumFound();
              log.debug("Number of hits = " + hitCount);
              if ( hitCount < 1 ) {                
                  JSONObject jsonObj = new JSONObject("{individuals:''}");
		 	    return jsonObj;
				
              }            

			List<Individual> individuals = new ArrayList<Individual>(docs.size());
			for (SearchResultDocument doc : docs) {
				String uri = doc.getStringValue(VitroSearchTermNames.URI);
				Individual individual = iDao.getIndividualByURI(uri);
				if (individual == null) {
					log.debug("No individual for search document with uri = " + uri);
				} else {
					individuals.add(individual);
					log.debug("Adding individual " + uri + " to individual list");
				}
			}

			IndividualListQueryResults results = new IndividualListQueryResults((int) hitCount, individuals);
			IndividualListResults ilResults = new IndividualListResults(hitsPerPage, results.getIndividuals(), "", false, Collections.<PageRecord>emptyList());
			
	        rObj = IndividualListResultsUtils.wrapIndividualListResultsInJson(ilResults, vreq, true);

			rObj.put("hitCount", results.getHitCount());
			rObj.put("startIndex", startIndex);
			rObj.put("currentPage", currentPage);
						
			addShortViewRenderings(rObj, vreq);
			//log.debug("rObj = " + rObj.toString());
			return rObj;
		}
		catch (Throwable e) {
			log.error("Search exception occurred: " + e);
			//JSONObject jsonObj = new JSONObject("[]");
	 	    return rObj;
			
		}
    }

    private static int getHitsPerPage(VitroRequest vreq) {
        int hitsPerPage = DEFAULT_HITS_PER_PAGE;
        try{ 
            hitsPerPage = Integer.parseInt(vreq.getParameter(PARAM_HITS_PER_PAGE)); 
        } catch (Throwable e) { 
            hitsPerPage = DEFAULT_HITS_PER_PAGE; 
        }                        
        log.debug("hitsPerPage is " + hitsPerPage);  
        return hitsPerPage;
    }

    private static int getStartIndex(VitroRequest vreq) {
        int startIndex = 0;
        try{ 
            startIndex = Integer.parseInt(vreq.getParameter(PARAM_START_INDEX)); 
        }catch (Throwable e) { 
            startIndex = 0; 
        }            
        log.debug("startIndex is " + startIndex);
        return startIndex;
    }

    private static int getCurrentPage(VitroRequest vreq) {
        int currentPage = 0;
        try{ 
            currentPage = Integer.parseInt(vreq.getParameter(PARAM_CURRENT_PAGE)); 
        }catch (Throwable e) { 
            currentPage = 0; 
        }            
        log.debug("currentPage is " + currentPage);
        return currentPage;
    }
   
    private static SearchQuery getQuery(String queryText, String queryType,int hitsPerPage, int startIndex, VitroRequest vreq) {
		
		Enumeration params = vreq.getParameterNames(); 
		while(params.hasMoreElements()){
		 String paramName = (String)params.nextElement();
		 log.debug("Parameter Name - "+paramName+", Value - "+vreq.getParameter(paramName));
		}
		
        SearchQuery query = ApplicationUtils.instance().getSearchEngine().createQuery();
        
		String queryString = KEYWORD_FIELD + ":\"" + queryText.toLowerCase() + "\" OR nameLowercase:\"" + queryText.toLowerCase() 
						+ "\" OR ALLTEXT:\"" + queryText.toLowerCase() + "\"";

		query.setQuery(queryString);

        query.setStart( startIndex )
             .setRows(hitsPerPage);

		String vclassidCheck = vreq.getParameter(PARAM_VCLASS_ID);
		log.debug("VCLASSIDS = " + vclassidCheck);
		String[] vclassArray = vclassidCheck.split(",");
		if ( vclassArray.length == 1 && vclassidCheck.contains("BFO_0000002") ) {
			String classgroupParam = "http://vivoweb.org/ontology#vitroClassGrouppublications";
			query.addFilterQuery(VitroSearchTermNames.CLASSGROUP_URI + ":\"" + classgroupParam + "\"");
		}
		else {
			String vclassids = vclassidCheck.replaceAll(",","\" OR type:\"");
			String typeParam = "type:\"" + vclassids + "\"";
	        query.addFilterQuery(typeParam);
		}

		// add filters for an of the checked facets
		if (vreq.getParameterMap().containsKey(PARAM_AFFILIATIONS)) {
			String affiliations = vreq.getParameter(PARAM_AFFILIATIONS).replaceAll(",","\" OR affiliation_txt:\"");
			query.addFilterQuery("affiliation_txt:\"" + affiliations + "\"");
		}
		if (vreq.getParameterMap().containsKey(PARAM_ADMINISTRATORS)) {
			String administrators = vreq.getParameter(PARAM_ADMINISTRATORS).replaceAll(",","\" OR administrator_txt:\"");
			query.addFilterQuery("administrator_txt:\"" + administrators + "\"");
		}
		if (vreq.getParameterMap().containsKey(PARAM_FUNDERS)) {
			String funders = vreq.getParameter(PARAM_FUNDERS).replaceAll(",","\" OR funder_ss:\"");
			query.addFilterQuery("funder_ss:\"" + funders + "\"");
		}
		if (vreq.getParameterMap().containsKey(PARAM_PUB_VENUES)) {
			String pub_venues = vreq.getParameter(PARAM_PUB_VENUES).replaceAll(",","\" OR pub_venue_ss:\"");
			query.addFilterQuery("pub_venue_ss:\"" + pub_venues + "\"");
		}
		if (vreq.getParameterMap().containsKey(PARAM_START_YEAR) && vreq.getParameterMap().containsKey(PARAM_END_YEAR)) {
			String startYear = vreq.getParameter(PARAM_START_YEAR);
			String endYear = vreq.getParameter(PARAM_END_YEAR);
			if ( queryType.equals("pubs") ) {
				query.addFilterQuery("pub_date_dt:[" + startYear + "-01-01T00:00:00Z TO " + endYear + "-01-01T00:00:00Z]");
			}
			else if ( queryType.equals("grants") ) {
				String activeYear = vreq.getParameter(PARAM_ACTIVE_YEAR);
				if ( !activeYear.equals("reset") ) {
					query.addFilterQuery("start_date_dt:[" + startYear + "-01-01T00:00:00Z TO " + activeYear + "-01-01T00:00:00Z]");
					query.addFilterQuery("end_date_dt:[" + activeYear + "-01-01T00:00:00Z TO " + endYear + "-01-01T00:00:00Z]");
				}
				else {
					query.addFilterQuery("start_date_dt:[" + startYear + "-01-01T00:00:00Z TO *]");
					query.addFilterQuery("end_date_dt:[* TO " + endYear + "-01-01T00:00:00Z]");
				}
			}
		}

		if ( queryType.equals("pubs") ) {
			query.addFilterQuery("type:\"http://purl.org/ontology/bibo/Document\"");
		}
		else if ( queryType.equals("grants") ) {
			query.addFilterQuery("type:\"http://vivoweb.org/ontology/core#Grant\" OR type:\"http://vivoweb.org/ontology/core#Contract\"");
		}
		else {
			query.addFilterQuery("-type:\"http://www.w3.org/2004/02/skos/core#Concept\"");
			query.addFilterQuery("-type:\"http://purl.org/ontology/bibo/Journal\"");
		}

        log.debug("Query = " + query.toString());
        return query;
    }   

    private static HashSet<String> getFacetResultsForHits(SearchResultDocumentList docs, String ffName){
        HashSet<String> typesInHits = new HashSet<String>();  
        for (SearchResultDocument doc : docs) {
            try {
                Collection<Object> types = doc.getFieldValues(ffName);
                if (types != null) {
                    for (Object o : types) {
                        String typeUri = o.toString();
                        typesInHits.add(typeUri);
                    }
                }
            } catch (Exception e) {
                log.error("problems getting rdf:type for search hits",e);
            }
        }
        return typesInHits;
    }

	    /**
	     * Makes a message to display to user for a bad search term.
	     * @param queryText
	     * @param exceptionMsg
	     */
    private String makeBadSearchMessage(String querytext, String exceptionMsg, VitroRequest vreq){
        String rv = "";
        try{
            //try to get the column in the search term that is causing the problems
            int coli = exceptionMsg.indexOf("column");
            if( coli == -1) return "";
            int numi = exceptionMsg.indexOf(".", coli+7);
            if( numi == -1 ) return "";
            String part = exceptionMsg.substring(coli+7,numi );
            int i = Integer.parseInt(part) - 1;

            // figure out where to cut preview and post-view
            int errorWindow = 5;
            int pre = i - errorWindow;
            if (pre < 0)
                pre = 0;
            int post = i + errorWindow;
            if (post > querytext.length())
                post = querytext.length();
            // log.warn("pre: " + pre + " post: " + post + " term len:
            // " + term.length());

            // get part of the search term before the error and after
            String before = querytext.substring(pre, i);
            String after = "";
            if (post > i)
                after = querytext.substring(i + 1, post);

            rv = I18n.text(vreq, "search_term_error_near") +
            		" <span class='searchQuote'>"
                + before + "<span class='searchError'>" + querytext.charAt(i)
                + "</span>" + after + "</span>";
        } catch (Throwable ex) {
            return "";
        }
        return rv;
    }
    
    public static final int MAX_QUERY_LENGTH = 500;
    
	private static void addShortViewRenderings(JSONObject rObj, VitroRequest vreq) throws JSONException {
		JSONArray individuals = rObj.getJSONArray("individuals");
		String vclassName = rObj.getJSONObject("vclass").getString("name");
		for (int i = 0; i < individuals.length(); i++) {
			JSONObject individual = individuals.getJSONObject(i);
			individual.put("shortViewHtml",
					renderShortView(individual.getString("URI"), vclassName, vreq));
		}
	}

	private static String renderShortView(String individualUri, String vclassName, VitroRequest vreq) {
		IndividualDao iDao = vreq.getWebappDaoFactory().getIndividualDao();
		Individual individual = iDao.getIndividualByURI(individualUri);

		IndividualTemplateModel itm = new IndividualTemplateModel(individual, vreq);
		Collection<String> mst = itm.getMostSpecificTypes();
		Map<String, Object> modelMap = new HashMap<String, Object>();
		modelMap.put("individual", itm);
		modelMap.put("vclass", vclassName);
		log.debug("Individual MST = " + mst.iterator().next());
		ShortViewContext svc;
		switch(mst.iterator().next()) {
			case "Journal Article": 
				svc = ShortViewContext.PUBLICATIONS;
				break;
			case "Grant": 
				svc = ShortViewContext.RESEARCH;
				break;
			case "Contract": 
				svc = ShortViewContext.RESEARCH;
				break;
			default :
		 		svc = ShortViewContext.BROWSE;
		}
		ServletContext ctx = vreq.getSession().getServletContext();
		ShortViewService svs = ShortViewServiceSetup.getService(ctx);
		return svs.renderShortView(individual, svc,
				modelMap, vreq);
	}
	
	public static <K, V extends Comparable<? super V>> Map<K, V> sortByValue( Map<K, V> map ) {
	    List<Map.Entry<K, V>> list =
	        new LinkedList<>( map.entrySet() );
	    Collections.sort( list, new Comparator<Map.Entry<K, V>>()
	    {
	        @Override
	        public int compare( Map.Entry<K, V> o1, Map.Entry<K, V> o2 )
	        {
	            return ( o2.getValue() ).compareTo( o1.getValue() );
	        }
	    } );

	    Map<K, V> result = new LinkedHashMap<>();
	    for (Map.Entry<K, V> entry : list)
	    {
	        result.put( entry.getKey(), entry.getValue() );
	    }
	    return result;
	}
	
}
