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
 * Paged search controller that uses the search engine
 */

public class DomainExpertController extends FreemarkerHttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(DomainExpertController.class);
    
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
	private static final String KEYWORD_FIELD = "keyword_txt";

    protected static final Map<Format,Map<Result,String>> templateTable;

    protected enum Format { 
        HTML, XML, CSV; 
    }
    
    protected enum Result {
        PAGED, ERROR, BAD_QUERY         
    }
    
    static{
        templateTable = setupTemplateTable();
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
 
             String queryText = vreq.getParameter(PARAM_QUERY_TEXT);  
             String queryType = vreq.getParameter(PARAM_QUERY_TYPE); 
 			 
             log.debug("Query text is \""+ queryText + "\""); 
  
             String badQueryMsg = badQueryText( queryText, vreq );
             if( badQueryMsg != null ){
                 return doFailedSearch(badQueryMsg, queryText, format, vreq);
             }
                 
             SearchQuery query = getQuery(queryText, queryType, hitsPerPage, startIndex, vreq);   
         	 log.debug("THE QUERY = " + query.toString());

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
			//JSONObject rObj = null;
	        JSONObject rObj = IndividualListResultsUtils.wrapIndividualListResultsInJson(ilResults, vreq, true);

			addShortViewRenderings(rObj, vreq);
			log.debug("SHORTVIEWED ROBJ: " + rObj.toString());	 	

/*              List<Individual> individuals = new ArrayList<Individual>(docs.size());
              Iterator<SearchResultDocument> docIter = docs.iterator();
              while( docIter.hasNext() ){
                  try {                                    
                      SearchResultDocument doc = docIter.next();
                      String uri = doc.getStringValue(VitroSearchTermNames.URI);                    
                      Individual ind = iDao.getIndividualByURI(uri);
                      if(ind != null) {
                        ind.setSearchSnippet( getSnippet(doc, response) );
                        individuals.add(ind);
                      }
                  } catch(Exception e) {
                      log.error("Problem getting usable individuals from search hits. ",e);
                  }
              }          
*/
             ParamMap pagingLinkParams = new ParamMap();
             pagingLinkParams.put(PARAM_QUERY_TEXT, queryText);
             pagingLinkParams.put(PARAM_QUERY_TYPE, queryType);
             pagingLinkParams.put(PARAM_HITS_PER_PAGE, String.valueOf(hitsPerPage));
             
             
             /* Compile the data for the templates */
             
             Map<String, Object> body = new HashMap<String, Object>();
             
             String classGroupParam = "http://vivoweb.org/ontology#vitroClassGrouppeople"; 
             log.debug("ClassGroupParam is \""+ classGroupParam + "\"");   
             boolean classGroupFilterRequested = false;
             if (!StringUtils.isEmpty(classGroupParam)) {
                 VClassGroup grp = grpDao.getGroupByURI(classGroupParam);
                 classGroupFilterRequested = true;
                 if (grp != null && grp.getPublicName() != null)
                     body.put("classGroupName", grp.getPublicName());
             }
             
             String typeParam = vreq.getParameter(PARAM_RDFTYPE);
             boolean typeFilterRequested = false;
             if (!StringUtils.isEmpty(typeParam)) {
                 VClass type = vclassDao.getVClassByURI(typeParam);
                 typeFilterRequested = true;
                 if (type != null && type.getName() != null)
                     body.put("typeName", type.getName());
             }
             
             /* Add ClassGroup and type refinement links to body */
             if( wasHtmlRequested ){                                
                 if ( !classGroupFilterRequested && !typeFilterRequested ) {
                     // Search request includes no ClassGroup and no type, so add ClassGroup search refinement links.
                     body.put("classGroupLinks", getClassGroupsLinks(vreq, grpDao, docs, response, queryText, queryType));                            
                 } else if ( classGroupFilterRequested && !typeFilterRequested ) {
                     // Search request is for a ClassGroup, so add rdf:type search refinement links
                     // but try to filter out classes that are subclasses
                     body.put("classLinks", getVClassLinks(vclassDao, docs, response, queryText, queryType));                       
                     pagingLinkParams.put(PARAM_CLASSGROUP, classGroupParam);
 
                 } else {
                     //search request is for a class so there are no more refinements
                     pagingLinkParams.put(PARAM_RDFTYPE, typeParam);
                 }
             }           
// 			 log.debug("individuals = " + rObj.toString());//individuals.toString());
			
			List<String> svhList = new ArrayList<String>();
			JSONArray indArray = rObj.getJSONArray("individuals");
			
			for(int i = 0 ; i < indArray.length() ; i++){
			    svhList.add(indArray.getJSONObject(i).getString("shortViewHtml"));
			}
			
             body.put("individuals", svhList);
 
             body.put("querytext", queryText);
             body.put("querytype", queryType);
             body.put("title", queryText + " - " + appBean.getApplicationName()
                     + " Search Results");
             
            body.put("hitCount", hitCount);
	        body.put("hitsPerPage", DEFAULT_HITS_PER_PAGE);
            body.put("startIndex", startIndex);
            body.put("currentPage", currentPage);
             
             body.put("pagingLinks", 
                     getPagingLinks(startIndex, hitsPerPage, hitCount,  
                                    vreq.getServletPath(),
                                    pagingLinkParams, vreq));
 
             if (startIndex != 0) {
                 body.put("prevPage", getPreviousPageLink(startIndex,
                         hitsPerPage, vreq.getServletPath(), pagingLinkParams));
             }
             if (startIndex < (hitCount - hitsPerPage)) {
                 body.put("nextPage", getNextPageLink(startIndex, hitsPerPage,
                         vreq.getServletPath(), pagingLinkParams));
             }
 	
 	        String template = templateTable.get(format).get(Result.PAGED);

            return new TemplateResponseValues(template, body);
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

    private SearchQuery getQuery(String queryText, String queryType,int hitsPerPage, int startIndex, VitroRequest vreq) {
        // Lowercase the search term to support wildcard searches: The search engine applies no text
        // processing to a wildcard search term.
        SearchQuery query = ApplicationUtils.instance().getSearchEngine().createQuery();

		String queryString = KEYWORD_FIELD + ":*" + queryText + "*";
		query.setQuery(queryString);
        
        query.setStart( startIndex )
             .setRows(hitsPerPage);

        // ClassGroup filtering param
        String classgroupParam = "http://vivoweb.org/ontology#vitroClassGrouppeople";
        
        // rdf:type filtering param
        String typeParam = vreq.getParameter(PARAM_RDFTYPE);

        if ( ! StringUtils.isBlank(classgroupParam) ) {
            // ClassGroup filtering
            log.debug("Firing classgroup query ");
            log.debug("request.getParameter(classgroup) is "+ classgroupParam);
            query.addFilterQuery(VitroSearchTermNames.CLASSGROUP_URI + ":\"" + classgroupParam + "\"");
			if ( queryType.equals("name") ) {
				query.addFilterQuery("nameLowercase:*" + queryText + "*");
			}
            
            //with ClassGroup filtering we want type facets
            query.addFacetFields(VitroSearchTermNames.RDFTYPE).setFacetLimit(-1);
            
        }else if (  ! StringUtils.isBlank(typeParam) ) {
            // rdf:type filtering
            log.debug("Firing type query ");
            log.debug("request.getParameter(type) is "+ typeParam);   
            query.addFilterQuery(VitroSearchTermNames.RDFTYPE + ":\"" + typeParam + "\"");
            //with type filtering we don't have facets.            
        }else{ 
            //When no filtering is set, we want ClassGroup facets
        	query.addFacetFields(VitroSearchTermNames.CLASSGROUP_URI).setFacetLimit(-1);
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
    
    protected static List<PagingLink> getPagingLinks(int startIndex, int hitsPerPage, long hitCount, String baseUrl, ParamMap params, VitroRequest vreq) {

        List<PagingLink> pagingLinks = new ArrayList<PagingLink>();
        
        // No paging links if only one page of results
        if (hitCount <= hitsPerPage) {
            return pagingLinks;
        }
        
        int maxHitCount = DEFAULT_MAX_HIT_COUNT ;
        if( startIndex >= DEFAULT_MAX_HIT_COUNT  - hitsPerPage )
            maxHitCount = startIndex + DEFAULT_MAX_HIT_COUNT ;                
            
        for (int i = 0; i < hitCount; i += hitsPerPage) {
            params.put(PARAM_START_INDEX, String.valueOf(i));
            if ( i < maxHitCount - hitsPerPage) {
                int pageNumber = i/hitsPerPage + 1;
                boolean iIsCurrentPage = (i >= startIndex && i < (startIndex + hitsPerPage)); 
                if ( iIsCurrentPage ) {
                    pagingLinks.add(new PagingLink(pageNumber));
                } else {
                    pagingLinks.add(new PagingLink(pageNumber, baseUrl, params));
                }
            } else {
            	pagingLinks.add(new PagingLink(I18n.text(vreq, "paging_link_more"), baseUrl, params));
                break;
            }
        }   
        
        return pagingLinks;
    }
    
    private String getPreviousPageLink(int startIndex, int hitsPerPage, String baseUrl, ParamMap params) {
        params.put(PARAM_START_INDEX, String.valueOf(startIndex-hitsPerPage));
        return UrlBuilder.getUrl(baseUrl, params);
    }
    
    private String getNextPageLink(int startIndex, int hitsPerPage, String baseUrl, ParamMap params) {
        params.put(PARAM_START_INDEX, String.valueOf(startIndex+hitsPerPage));
        return UrlBuilder.getUrl(baseUrl, params);
    }
    
    protected static class PagingLink extends LinkTemplateModel {
        
        PagingLink(int pageNumber, String baseUrl, ParamMap params) {
            super(String.valueOf(pageNumber), baseUrl, params);
        }
        
        // Constructor for current page item: not a link, so no url value.
        PagingLink(int pageNumber) {
            setText(String.valueOf(pageNumber));
        }
        
        // Constructor for "more..." item
        PagingLink(String text, String baseUrl, ParamMap params) {
            super(text, baseUrl, params);
        }
    }
   
    private ExceptionResponseValues doSearchError(Throwable e, Format f) {
        Map<String, Object> body = new HashMap<String, Object>();
        body.put("message", "Search failed: " + e.getMessage());  
        return new ExceptionResponseValues(getTemplate(f,Result.ERROR), body, e);
    }   
    
    private TemplateResponseValues doFailedSearch(String message, String querytext, Format f, VitroRequest vreq) {
        Map<String, Object> body = new HashMap<String, Object>();       
        body.put("title", I18n.text(vreq, "search_for", querytext));        
        if ( StringUtils.isEmpty(message) ) {
        	message = I18n.text(vreq, "search_failed");
        }        
        body.put("message", message);
        return new TemplateResponseValues(getTemplate(f,Result.ERROR), body);
    }

    private TemplateResponseValues doNoHits(String querytext, Format f, VitroRequest vreq) {
        Map<String, Object> body = new HashMap<String, Object>();       
        body.put("title", I18n.text(vreq, "search_for", querytext));        
        body.put("message", I18n.text(vreq, "no_matching_results"));     
        return new TemplateResponseValues(getTemplate(f,Result.ERROR), body);        
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

    protected boolean isRequestedCallAjax(VitroRequest req){
        if( req != null ){
            String param = req.getParameter(PARAM_AJAX_REQUEST);
            if( param != null && "1".equals(param)){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    protected Format getFormat(VitroRequest req){
            return Format.HTML;
    }
    
    protected static String getTemplate(Format format, Result result){
        if( format != null && result != null)
            return templateTable.get(format).get(result);
        else{
            log.error("getTemplate() must not have a null format or result.");
            return templateTable.get(Format.HTML).get(Result.ERROR);
        }
    }
    
    protected static Map<Format,Map<Result,String>> setupTemplateTable(){
        Map<Format,Map<Result,String>> table = new HashMap<>();
        
        HashMap<Result,String> resultsToTemplates = new HashMap<Result,String>();
        
        // set up HTML format
        resultsToTemplates.put(Result.PAGED, "findDomainExpert.ftl");
        resultsToTemplates.put(Result.ERROR, "search-error.ftl");
        // resultsToTemplates.put(Result.BAD_QUERY, "search-badQuery.ftl");        
        table.put(Format.HTML, Collections.unmodifiableMap(resultsToTemplates));
        
        // set up XML format
        resultsToTemplates = new HashMap<Result,String>();
        resultsToTemplates.put(Result.PAGED, "search-xmlResults.ftl");
        resultsToTemplates.put(Result.ERROR, "search-xmlError.ftl");

        // resultsToTemplates.put(Result.BAD_QUERY, "search-xmlBadQuery.ftl");        
        table.put(Format.XML, Collections.unmodifiableMap(resultsToTemplates));
        
        
        // set up CSV format
        resultsToTemplates = new HashMap<Result,String>();
        resultsToTemplates.put(Result.PAGED, "search-csvResults.ftl");
        resultsToTemplates.put(Result.ERROR, "search-csvError.ftl");
        
        // resultsToTemplates.put(Result.BAD_QUERY, "search-xmlBadQuery.ftl");        
        table.put(Format.CSV, Collections.unmodifiableMap(resultsToTemplates));

        
        return Collections.unmodifiableMap(table);
    }

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
