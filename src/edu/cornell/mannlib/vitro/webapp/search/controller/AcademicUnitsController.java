/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.search.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

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
 * Paged search controller that uses the search engine
 */

public class AcademicUnitsController extends FreemarkerHttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(AcademicUnitsController.class);
    
    protected static final int DEFAULT_HITS_PER_PAGE = 12;
    protected static final int DEFAULT_MAX_HIT_COUNT = 100;   

    private static final String PARAM_START_INDEX = "startIndex";
    private static final String PARAM_CURRENT_PAGE = "currentPage";
    private static final String PARAM_HITS_PER_PAGE = "hitsPerPage";
    private static final String PARAM_CLASSGROUP = "classgroup";
    private static final String PARAM_RDFTYPE = "type";
    private static final String PARAM_ORIGIN = "origin";
    private static final String PARAM_VCLASS_ID = "vclassId";
    private static final String PARAM_QUERY_TEXT = "querytext";
    private static final String PARAM_QUERY_TYPE = "querytype";
	private static final String TEMPLATE = "academicUnits.ftl";
	private static List<String> sortedAlphaList;
    protected enum Format { 
        HTML, XML, CSV; 
    }
    
    protected enum Result {
        PAGED, ERROR, BAD_QUERY         
    }
    
    /**
     * Overriding doGet from FreemarkerHttpController to do a page template (as
     * opposed to body template) style output for XML requests.
     * 
     * This follows the pattern in AutocompleteController.java.
     */
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException  {
        VitroRequest vreq = new VitroRequest(request);
            super.doGet(vreq, response);
    }

    @Override
    protected ResponseValues processRequest(VitroRequest vreq) {    	    	
    	
        //There may be other non-html formats in the future
        Format format = getFormat(vreq);            
        boolean wasXmlRequested = Format.XML == format;
        boolean wasCSVRequested = Format.CSV == format;
        log.debug("Requested format was " + (wasXmlRequested ? "xml" : "html"));
        boolean wasHtmlRequested = ! (wasXmlRequested || wasCSVRequested); 
        
        try {
			
	            //make sure an IndividualDao is available 
             if( vreq.getWebappDaoFactory() == null 
                     || vreq.getWebappDaoFactory().getIndividualDao() == null ){
                 log.error("Could not get webappDaoFactory or IndividualDao");
                 throw new Exception("Could not access model.");
             }
             IndividualDao iDao = vreq.getWebappDaoFactory().getIndividualDao();
             VClassGroupDao grpDao = vreq.getWebappDaoFactory().getVClassGroupDao();
             VClassDao vclassDao = vreq.getWebappDaoFactory().getVClassDao();
             
             ApplicationBean appBean = vreq.getAppBean();
             
             log.debug("IndividualDao is " + iDao.toString() + " Public classes in the classgroup are " + grpDao.getPublicGroupsWithVClasses().toString());
             log.debug("VClassDao is "+ vclassDao.toString() );            
             
             int startIndex = getStartIndex(vreq);            
             int hitsPerPage = getHitsPerPage( vreq );           
             int currentPage = getCurrentPage( vreq );           
 
             String origin = vreq.getParameter(PARAM_ORIGIN); //== null) ? "none" : vreq.getParameter(PARAM_SOURCE);
             String queryText = vreq.getParameter(PARAM_QUERY_TEXT);  
             String queryType = (vreq.getParameter(PARAM_QUERY_TYPE) == null) ? "colleges" : vreq.getParameter(PARAM_QUERY_TYPE); 
             String vclassid = vreq.getParameter(PARAM_VCLASS_ID);  

             String classGroupParam = "http://vivoweb.org/ontology#vitroClassGrouporganizations"; 
 			 
             log.debug("Query text is \""+ queryText + "\""); 
             log.debug("Query type is \""+ queryType + "\""); 
             log.debug("Vclassid is \""+ vclassid + "\""); 
             log.debug("Origin is \""+ origin + "\""); 
  
			// user cannot do a "quick search" without entering text
			// the source param is passed when a quick search is done
			if ( origin != null && origin.equals("template") ) {
			 	String badQueryMsg = badQueryText( queryText, vreq );
             	if( badQueryMsg != null ){
                 	return doFailedSearch(badQueryMsg, queryText, format, vreq);
             	}
			}
			 
			 // this class uses the hitsPerPage variable differently. We want to fetch all the units because
			 // we need them to build the alpha list, but we do not want to render short views for all of them
			 // (too much overhead). So there is no need to pass the hitsPerPage to the query.
             SearchQuery query = getQuery(queryText, queryType, startIndex, vreq, classGroupParam);   

 		 	  SearchEngine search = ApplicationUtils.instance().getSearchEngine();
 			  SearchResponse response = null;           
              try {
                  response = search.query(query);
              } catch (Exception ex) {                
                  String msg = makeBadSearchMessage(queryText, ex.getMessage(), vreq);
                  log.error("could not run search query",ex);
                  return doFailedSearch(msg, queryText, format, vreq);              
              }
	
              if (response == null) {
                  log.error("Search response was null");                                
                  return doFailedSearch(I18n.text(vreq, "error_in_search_request"), queryText, format, vreq);
              }

              SearchResultDocumentList docs = response.getResults();
              if (docs == null) {
                  log.error("Document list for a search was null");                
                  return doFailedSearch(I18n.text(vreq, "error_in_search_request"), queryText, format, vreq);
              }

              long hitCount = docs.getNumFound();
              log.debug("Number of hits = " + hitCount);
              if ( hitCount < 1 ) {                
                  return doNoHits(queryText, format, vreq);
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

	        JSONObject rObj = IndividualListResultsUtils.wrapIndividualListResultsInJson(ilResults, vreq, true);
			// We'll use this JSONArray to build the alpha list
			JSONArray indArrayOne = rObj.getJSONArray("individuals");

			// building the list of letters we need to drive the alpha 
			// selection in the UI;
			Set<String> alphaList = new HashSet<>();
		    List<JSONObject> jsonValues = new ArrayList<JSONObject>();
	    	for (int i = 0; i < indArrayOne.length(); i++) {
	        	jsonValues.add(indArrayOne.getJSONObject(i));
	    	}
		    for (int i = 0; i < indArrayOne.length(); i++) {
				String tmp = jsonValues.get(i).getString("name");
				alphaList.add(tmp.substring(0,1));
		    }
			sortedAlphaList = new ArrayList(alphaList);
			Collections.sort(sortedAlphaList);

			// now we can add the short views
			addShortViewRenderings(rObj, vreq, DEFAULT_HITS_PER_PAGE);

			// We'll use this second JSONArray to build the rendered shortviews
			JSONArray indArrayTwo = rObj.getJSONArray("individuals");
			List<String> svhList = new ArrayList<String>();
			Integer count = new Integer(hitsPerPage);
			if ( indArrayTwo.length() < count ) {
				count = indArrayTwo.length();
			}
			for(int i = 0 ; i <  count; i++){
			    svhList.add(indArrayTwo.getJSONObject(i).getString("shortViewHtml"));
			}
            /* Compile the data for the templates */             
            Map<String, Object> body = new HashMap<String, Object>();
            
            body.put("individuals", svhList);
		    body.put("alphaList", sortedAlphaList);
            body.put("querytext", queryText);
 		    if ( queryText != null && queryText.length() > 0 ) {
            	body.put("querytype", "");
			}
			else {
				body.put("querytype", queryType);
			}
            body.put("title", appBean.getApplicationName());
            
			body.put("hitCount", hitCount);
			body.put("hitsPerPage", DEFAULT_HITS_PER_PAGE);
			body.put("startIndex", startIndex);
			body.put("currentPage", currentPage);

			// we want to display the counts for the four types of orgs,
			// so do a separate query to get these
			log.debug("start facet query");
			SearchQuery facetQuery = getFacetCountsQuery(classGroupParam); 
			
			SearchEngine facetSearch = ApplicationUtils.instance().getSearchEngine();
			SearchResponse facetResponse = null;           
            try {
                facetResponse = facetSearch.query(facetQuery);
            } catch (Exception ex) {                
                String msg = makeBadSearchMessage(queryText, ex.getMessage(), vreq);
                log.error("could not run search query",ex);
                return doFailedSearch(msg, queryText, format, vreq);              
            }
	
            if (facetResponse == null) {
                log.error("Search response was null");                                
                return doFailedSearch(I18n.text(vreq, "error_in_search_request"), queryText, format, vreq);
            }

            SearchResultDocumentList facetDocs = facetResponse.getResults();
            if (facetDocs == null) {
                log.error("Document list for a search was null");                
                return doFailedSearch(I18n.text(vreq, "error_in_search_request"), queryText, format, vreq);
            }
			log.debug("end facet query");
			body.put("mstFacet", getMostSpecificTypeFacet(facetDocs, facetResponse));  
			  	
            return new TemplateResponseValues(TEMPLATE, body);
        } catch (Throwable e) {
            return doSearchError(e,format);
        }        
    }
	
    private int getHitsPerPage(VitroRequest vreq) {
        int hitsPerPage = DEFAULT_HITS_PER_PAGE;
        try{ 
            hitsPerPage = Integer.parseInt(vreq.getParameter(PARAM_HITS_PER_PAGE)); 
        } catch (Throwable e) { 
            hitsPerPage = DEFAULT_HITS_PER_PAGE; 
        }                        
        log.debug("hitsPerPage is " + hitsPerPage);  
        return hitsPerPage;
    }

    private int getStartIndex(VitroRequest vreq) {
        int startIndex = 0;
        try{ 
            startIndex = Integer.parseInt(vreq.getParameter(PARAM_START_INDEX)); 
        }catch (Throwable e) { 
            startIndex = 0; 
        }            
        log.debug("startIndex is " + startIndex);
        return startIndex;
    }

    private int getCurrentPage(VitroRequest vreq) {
        int currentPage = 0;
        try{ 
            currentPage = Integer.parseInt(vreq.getParameter(PARAM_CURRENT_PAGE)); 
        }catch (Throwable e) { 
            currentPage = 0; 
        }            
        log.debug("currentPage is " + currentPage);
        return currentPage;
    }

    private String badQueryText(String qtxt, VitroRequest vreq) {
        if( qtxt == null || "".equals( qtxt.trim() ) )
        	return I18n.text(vreq, "enter_search_term");
        
        if( qtxt.equals("*:*") )
        	return I18n.text(vreq, "invalid_search_term") ;
        
        return null;
    }

	
	private SearchQuery getQuery(String queryText, String queryType, int startIndex, VitroRequest vreq, String classgroupParam) {
	
	    SearchQuery query = ApplicationUtils.instance().getSearchEngine().createQuery();
	
		String queryString = PARAM_RDFTYPE;
		// if the user is doing a quick search, we need to apply the queryText to all class types
		if ( queryText != null && queryText.length() > 0 ) {
			queryString += ":\"http://vivoweb.org/ontology/core#College\" OR type:" +
							"\"http://vivoweb.org/ontology/core#School\" OR type:" +
							"\"http://vivoweb.org/ontology/core#Library\" OR type:" +
							"\"http://vivoweb.org/ontology/core#AcademicDepartment\" OR type:" +
							"\"http://vivoweb.org/ontology/core#Institute\""; 

			query.addFilterQuery("nameLowercase:*" + queryText.toLowerCase().replaceAll(" ", "* AND nameLowercase:*") + "*");
		}
		else if ( queryType.equals("colleges") ) {
			queryString += ":\"http://vivoweb.org/ontology/core#College\"";
		}
		else if ( queryType.equals("schools") ) {
			queryString += ":\"http://vivoweb.org/ontology/core#School\"";
		}
		else if ( queryType.equals("libraries") ) {
			queryString += ":\"http://vivoweb.org/ontology/core#Library\"";
		}
		else if ( queryType.equals("departments") ) {
			queryString += ":\"http://vivoweb.org/ontology/core#AcademicDepartment\"";
		}
		else if ( queryType.equals("institutes") ) {
			queryString += ":\"http://vivoweb.org/ontology/core#Institute\"";
		}
		
		query.addSortField("nameLowercaseSingleValued", SearchQuery.Order.ASC);
			
		query.setQuery(queryString);
	    
	    query.setStart( startIndex )
	         .setRows(120);
	
	    query.addFilterQuery(VitroSearchTermNames.CLASSGROUP_URI + ":\"" + classgroupParam + "\"");
			    

	    //with ClassGroup filtering we want type facets
	    query.addFacetFields(VitroSearchTermNames.RDFTYPE).setFacetLimit(-1);
		query.addFacetFields("mostSpecificTypeURIs").setFacetLimit(-1);
	
		// affiliations apply to all types
	        
	    log.debug("Query = " + query.toString());
	    return query;
	}   

    private List<VClassSearchLink>  getVClassFacet(VClassDao vclassDao, SearchResultDocumentList docs, SearchResponse rsp){        
        HashSet<String> typesInHits = getFacetResultsForHits(docs, VitroSearchTermNames.RDFTYPE);                                
        Map<String,Long> typeURItoCount = new HashMap<String,Long>();        
        
        List<SearchFacetField> ffs = rsp.getFacetFields();
//		log.debug("FFS " + ffs.toString());
        for(SearchFacetField ff : ffs){
            if(VitroSearchTermNames.RDFTYPE.equals(ff.getName())){
                List<Count> counts = ff.getValues();
                for( Count ct: counts){  
                    String typeUri = ct.getName();
                    long count = ct.getCount();
                    try{                                                   
                        if( VitroVocabulary.OWL_THING.equals(typeUri) ||
                            count == 0 )
                            continue;
                        VClass type = vclassDao.getVClassByURI(typeUri);
                        if( type != null &&
                            ! type.isAnonymous() &&
                              type.getName() != null && !"".equals(type.getName()) &&
                              type.getGroupURI() != null ){ //don't display classes that aren't in classgroups                                   
                            typeURItoCount.put(typeUri,count);
                        }
                    }catch(Exception ex){
                        if( log.isDebugEnabled() )
                            log.debug("could not add type " + typeUri, ex);
                    }                                                
                }                
            }            
        }

		log.debug("typeURItoCount = " + typeURItoCount.toString());
        
		Map<String,Long> sortedClassFacets = sortByValue(typeURItoCount);
        log.debug("sortedClassFacets = " + sortedClassFacets.toString());

        List<VClassSearchLink> classFacets= new ArrayList<VClassSearchLink>(sortedClassFacets.size());
		for (Map.Entry<String, Long> entry : sortedClassFacets.entrySet()) {
			VClass type = vclassDao.getVClassByURI(entry.getKey());
			if ( !type.getName().equals("Article") && !type.getName().equals("Academic Article") ) {
				classFacets.add(new VClassSearchLink(type, entry.getValue() ));
			}
		}

        return classFacets;
    }       
        
    private HashSet<String> getFacetResultsForHits(SearchResultDocumentList docs, String ffName){
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
    
	private SearchQuery getFacetCountsQuery(String classgroupParam) {
	
	    SearchQuery query = ApplicationUtils.instance().getSearchEngine().createQuery();
	
		String queryString = PARAM_RDFTYPE + ":\"http://vivoweb.org/ontology/core#College\"";
		queryString += " OR " + PARAM_RDFTYPE + ":\"http://vivoweb.org/ontology/core#School\"";
		queryString += " OR " + PARAM_RDFTYPE + ":\"http://vivoweb.org/ontology/core#Library\"";
		queryString += " OR " + PARAM_RDFTYPE + ":\"http://vivoweb.org/ontology/core#AcademicDepartment\"";
		queryString += " OR " + PARAM_RDFTYPE + ":\"http://vivoweb.org/ontology/core#Institute\"";
			
		query.setQuery(queryString);
	    
	    query.setStart( 0 )
	         .setRows(1);
	
	    query.addFilterQuery(VitroSearchTermNames.CLASSGROUP_URI + ":\"" + classgroupParam + "\"");
			    

	    //with ClassGroup filtering we want type facets
	    query.addFacetFields(VitroSearchTermNames.RDFTYPE).setFacetLimit(-1);
		query.addFacetFields("mostSpecificTypeURIs").setFacetLimit(-1);
	
		// affiliations apply to all types
	        
	    log.debug("Facet Count Query = " + query.toString());
	    return query;
	}   

    private Map<String,Long> getMostSpecificTypeFacet(SearchResultDocumentList docs, SearchResponse rsp){        
        Map<String,Long> mostSpecificTypeFacets = new HashMap<String,Long>();        
        
        List<SearchFacetField> ffs = rsp.getFacetFields();
		String mstName = "mostSpecificTypeURIs";
        for(SearchFacetField ff : ffs){
            if(mstName.equals(ff.getName())){
                List<Count> counts = ff.getValues();
                for( Count ct: counts){  
                    String mst = ct.getName();
                    long count = ct.getCount();
					if ( count > 0 ) {
                    	mostSpecificTypeFacets.put(mst,count);
					}
                }                
            }            
        }
        
		// sort by count
		Map<String,Long> sortedMstFacets = sortByValue(mostSpecificTypeFacets);
		log.debug("The mst facet = " + sortedMstFacets.toString());
        return sortedMstFacets;
    }       

    public static class VClassSearchLink extends LinkTemplateModel {
        long count = 0;
		String name;
        VClassSearchLink(VClass type, long count) {
            super(type.getName(), "/search", PARAM_VCLASS_ID, type.getURI());
			this.name = type.getName(); 
            this.count = count;
        }

		public String getName() { return name; }
        
    	public String getCount() { return Long.toString(count); }               
    }
       
	private ExceptionResponseValues doSearchError(Throwable e, Format f) {
        Map<String, Object> body = new HashMap<String, Object>();
        body.put("title", "Search Failed");  
        body.put("message", "Search failed: " + e.getMessage());  
        return new ExceptionResponseValues("search-error.ftl", body, e);
	}

    private TemplateResponseValues doFailedSearch(String message, String querytext, Format f, VitroRequest vreq) {
        Map<String, Object> body = new HashMap<String, Object>();       
        if ( querytext == null || StringUtils.isEmpty(querytext) ) {
			body.put("title", "No Search Term");
	        message =  "no_search_term";
		}
		else {
			body.put("title", "Search Failed");
	        body.put("badquerytext", querytext);
		}
        
        if ( StringUtils.isEmpty(message) ) {
        	message = "search_failed";
        }        
        body.put("message", message);
        return new TemplateResponseValues(TEMPLATE, body);
    }

    private TemplateResponseValues doNoHits(String querytext, Format f, VitroRequest vreq) {
        Map<String, Object> body = new HashMap<String, Object>();       
        body.put("title", "No Search Results");        
        body.put("badquerytext", querytext);        
		body.put("message", "no_matches");    
        return new TemplateResponseValues(TEMPLATE, body);        
    }
    
    private TemplateResponseValues doNewSearch(VitroRequest vreq) {
        Map<String, Object> body = new HashMap<String, Object>();       
        body.put("title", "New Search");        
        body.put("message", "new_search");     
        return new TemplateResponseValues(TEMPLATE, body);        
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

    protected Format getFormat(VitroRequest req){
            return Format.HTML;
    }
    
	private static void addShortViewRenderings(JSONObject rObj, VitroRequest vreq, Integer hitsPerPage) throws JSONException {
		JSONArray individuals = rObj.getJSONArray("individuals");
		String vclassName = rObj.getJSONObject("vclass").getString("name");
		// since hitsPerPage works differently for this class
		// we never want more than 12 displayed initially
		Integer count = new Integer(hitsPerPage);
		if ( individuals.length() < count ) {
			count = individuals.length();
		}
		for (int i = 0; i < count; i++) {
			JSONObject individual = individuals.getJSONObject(i);
			individual.put("shortViewHtml",
					renderShortView(individual.getString("URI"), vclassName, vreq));
		}
	}

	private static String renderShortView(String individualUri, String vclassName, VitroRequest vreq) {
		IndividualDao iDao = vreq.getWebappDaoFactory().getIndividualDao();
		Individual individual = iDao.getIndividualByURI(individualUri);

		Map<String, Object> modelMap = new HashMap<String, Object>();
		modelMap.put("individual",
				new IndividualTemplateModel(individual, vreq));
		modelMap.put("vclass", vclassName);
		ServletContext ctx = vreq.getSession().getServletContext();
		ShortViewService svs = ShortViewServiceSetup.getService(ctx);
		return svs.renderShortView(individual, ShortViewContext.ACADEMIC_UNITS,
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

	private static JSONArray sortJSONArray(JSONArray individuals, String alpha) throws JSONException {
		
		JSONArray sortedJsonArray = new JSONArray();
		
	    List<JSONObject> jsonValues = new ArrayList<JSONObject>();
    	for (int i = 0; i < individuals.length(); i++) {
        	jsonValues.add(individuals.getJSONObject(i));
    	}
	    Collections.sort( jsonValues, new Comparator<JSONObject>() {
	        private static final String KEY_NAME = "name";

	        @Override
	        public int compare(JSONObject a, JSONObject b) {
	            String valA = new String();
	            String valB = new String();

	            try {
	                valA = (String) a.get(KEY_NAME);
	                valB = (String) b.get(KEY_NAME);
	            } 
	            catch (JSONException e) {
	                //do something
	            }

	            return valA.compareTo(valB);
	            //if you want to change the sort order, simply use the following:
	            //return -valA.compareTo(valB);
	        }
	    });

		Set<String> alphaList = new HashSet<>();

	    for (int i = 0; i < individuals.length(); i++) {
			String tmp = jsonValues.get(i).getString("name");
			alphaList.add(tmp.substring(0,1));
			if ( alpha.length() == 1 ) {
				if ( alpha.equals(tmp) ) {
	        		sortedJsonArray.put(jsonValues.get(i));
				}
			}
			else {
				sortedJsonArray.put(jsonValues.get(i));
			}
	    }
		sortedAlphaList = new ArrayList(alphaList);
		Collections.sort(sortedAlphaList);
		
		return sortedJsonArray;
	}

}
