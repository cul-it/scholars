/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.json;

import java.io.IOException;
import java.io.Writer;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
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

public class DomainExpertJsonServlet extends VitroHttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(DomainExpertJsonServlet.class);
    
    protected static final int DEFAULT_HITS_PER_PAGE = 12;
    protected static final int DEFAULT_MAX_HIT_COUNT = 100;   

    private static final String PARAM_AJAX_REQUEST = "ajax";
    private static final String PARAM_START_INDEX = "startIndex";
    private static final String PARAM_CURRENT_PAGE = "currentPage";
    private static final String PARAM_HITS_PER_PAGE = "hitsPerPage";
    private static final String PARAM_CLASSGROUP = "classgroup";
    private static final String PARAM_RDFTYPE = "type";
    private static final String PARAM_VCLASS_ID = "vclassId";
    private static final String PARAM_QUERY_TEXT = "querytext";
    private static final String PARAM_QUERY_TYPE = "querytype";

         
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

			
			IndividualListQueryResults results = null;
			try{
		        results = IndividualListQueryResults.runQuery(query, iDao);
				log.debug("YES, WE HAVE RESULTS: " + results.getHitCount());
		 	} catch (SearchEngineException e) {
				log.error("Search exception occurred: " + e);
				JSONObject jsonObj = new JSONObject("['what the hell?]");
		 	    return jsonObj;
		   	}
		
			IndividualListResults ilResults = new IndividualListResults(hitsPerPage, results.getIndividuals(), "", false, Collections.<PageRecord>emptyList());
	        rObj = IndividualListResultsUtils.wrapIndividualListResultsInJson(ilResults, vreq, true);

			rObj.put("hitCount", results.getHitCount());
			rObj.put("startIndex", startIndex);
			rObj.put("currentPage", currentPage);
			
			addShortViewRenderings(rObj, vreq);
			log.debug("SHORTVIEWED ROBJ: " + rObj.toString());	 	

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

    /**
     * Get the class groups represented for the individuals in the documents.
     * @param qtxt 
     */
    private List<VClassGroupSearchLink> getClassGroupsLinks(VitroRequest vreq, VClassGroupDao grpDao, SearchResultDocumentList docs, SearchResponse rsp, String qtxt, String qtype) {                                 
        Map<String,Long> cgURItoCount = new HashMap<String,Long>();
        
        List<VClassGroup> classgroups = new ArrayList<VClassGroup>( );
        List<SearchFacetField> ffs = rsp.getFacetFields();
        for(SearchFacetField ff : ffs){
            if(VitroSearchTermNames.CLASSGROUP_URI.equals(ff.getName())){
                List<Count> counts = ff.getValues();
                for( Count ct: counts){                    
                    VClassGroup vcg = grpDao.getGroupByURI( ct.getName() );
                    if( vcg == null ){
                        log.debug("could not get classgroup for URI " + ct.getName());
                    }else{
                        classgroups.add(vcg);
                        cgURItoCount.put(vcg.getURI(),  ct.getCount());
                    }                    
                }                
            }            
        }
        
        grpDao.sortGroupList(classgroups);     
        
        VClassGroupsForRequest vcgfr = VClassGroupCache.getVClassGroups(vreq);
        List<VClassGroupSearchLink> classGroupLinks = new ArrayList<VClassGroupSearchLink>(classgroups.size());
        for (VClassGroup vcg : classgroups) {
        	String groupURI = vcg.getURI();
			VClassGroup localizedVcg = vcgfr.getGroup(groupURI);
            long count = cgURItoCount.get( groupURI );
            if (localizedVcg.getPublicName() != null && count > 0 )  {
                classGroupLinks.add(new VClassGroupSearchLink(qtxt, qtype, localizedVcg, count));
            }
        }
        return classGroupLinks;
    }

    private List<VClassSearchLink> getVClassLinks(VClassDao vclassDao, SearchResultDocumentList docs, SearchResponse rsp, String qtxt, String qtype){        
        HashSet<String> typesInHits = getVClassUrisForHits(docs);                                
        List<VClass> classes = new ArrayList<VClass>(typesInHits.size());
        Map<String,Long> typeURItoCount = new HashMap<String,Long>();        
		log.debug("DOCS " + docs.toString());
		log.debug("RESPONSE " + rsp.toString());
        
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
                            classes.add(type);
                        }
                    }catch(Exception ex){
                        if( log.isDebugEnabled() )
                            log.debug("could not add type " + typeUri, ex);
                    }                                                
                }                
            }            
        }
        
        
        Collections.sort(classes, new Comparator<VClass>(){
            public int compare(VClass o1, VClass o2) {                
                return o1.compareTo(o2);
            }});
        
        List<VClassSearchLink> vClassLinks = new ArrayList<VClassSearchLink>(classes.size());
        for (VClass vc : classes) {                        
            long count = typeURItoCount.get(vc.getURI());
            vClassLinks.add(new VClassSearchLink(qtxt, qtype, vc, count ));
        }
        
        return vClassLinks;
    }       
        
    private HashSet<String> getVClassUrisForHits(SearchResultDocumentList docs){
        HashSet<String> typesInHits = new HashSet<String>();  
        for (SearchResultDocument doc : docs) {
            try {
                Collection<Object> types = doc.getFieldValues(VitroSearchTermNames.RDFTYPE);     
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
    
    private String getSnippet(SearchResultDocument doc, SearchResponse response) {
        String docId = doc.getStringValue(VitroSearchTermNames.DOCID);
        StringBuffer text = new StringBuffer();
        Map<String, Map<String, List<String>>> highlights = response.getHighlighting();
        if (highlights != null && highlights.get(docId) != null) {
            List<String> snippets = highlights.get(docId).get(VitroSearchTermNames.ALLTEXT);
            if (snippets != null && snippets.size() > 0) {
                text.append("... " + snippets.get(0) + " ...");
            }       
        }
        return text.toString();
    }       
    
    private static SearchQuery getQuery(String queryText, String queryType,int hitsPerPage, int startIndex, VitroRequest vreq) {

		String vclassids = vreq.getParameter(PARAM_VCLASS_ID).replaceAll(",","\" OR type:\"");

		log.debug("VCLASSIDS = " + vclassids);
        //String typeParam = "type:\"" + vreq.getParameter(PARAM_VCLASS_ID) + "\"";
		String typeParam = "type:\"" + vclassids + "\"";
		
        SearchQuery query = ApplicationUtils.instance().getSearchEngine().createQuery(queryText);
        
        query.setStart( startIndex )
             .setRows(hitsPerPage);

        // ClassGroup filtering param
        String classgroupParam = "http://vivoweb.org/ontology#vitroClassGrouppeople";
        query.addFilterQuery(typeParam);

		if ( queryType.equals("name") ) {
			query.addFilterQuery("nameLowercase:*" + queryText + "*");
		}

        log.debug("Query = " + query.toString());
        return query;
    }   

    public static class VClassGroupSearchLink extends LinkTemplateModel {        
        long count = 0;
        VClassGroupSearchLink(String querytext, String querytype, VClassGroup classgroup, long count) {
            super(classgroup.getPublicName(), "/search", PARAM_QUERY_TEXT, querytext, PARAM_QUERY_TYPE, querytype, PARAM_CLASSGROUP, classgroup.getURI());
            this.count = count;
        }
        
        public String getCount() { return Long.toString(count); }
    }
    
    public static class VClassSearchLink extends LinkTemplateModel {
        long count = 0;
        VClassSearchLink(String querytext, String querytype, VClass type, long count) {
            super(type.getName(), "/search", PARAM_QUERY_TEXT, querytext, PARAM_QUERY_TYPE, querytype, PARAM_VCLASS_ID, type.getURI());
            this.count = count;
        }
        
    public String getCount() { return Long.toString(count); }               
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

		Map<String, Object> modelMap = new HashMap<String, Object>();
		modelMap.put("individual",
				new IndividualTemplateModel(individual, vreq));
		modelMap.put("vclass", vclassName);
		ServletContext ctx = vreq.getSession().getServletContext();
		ShortViewService svs = ShortViewServiceSetup.getService(ctx);
		return svs.renderShortView(individual, ShortViewContext.EXPERTS,
				modelMap, vreq);
	}
}
