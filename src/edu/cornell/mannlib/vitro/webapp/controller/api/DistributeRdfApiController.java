/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor;
import edu.cornell.mannlib.vitro.webapp.modelaccess.ModelAccess;

/**
 * TODO
 * 
 * <pre>
 * On init, read from data to get the configuration and instantiate the available classes.
 *   (do we want to do that as part of the startup manager?)
 * On request, 
 * 	 find the distributor that corresponds to the action (throw error if none)
 *   Note that the distributors must be thread-safe
 *   Pass the parameter map to the distributor, along with the RequestModels.
 *   Call execute (if error, log and complain)
 *     Returns a graph
 * Serialize as ttl, regardless of the accept header.
 * </pre>
 */
public class DistributeRdfApiController extends VitroApiServlet {
	private static final Log log = LogFactory
			.getLog(DistributeRdfApiController.class);
	private Map<String, RdfDistributor> distributors;

	/**
	 * Read the configuration of distributors, and instantiate. Create a map
	 * linking actions to instances. If any failure, write warning to the log
	 * and create an empty map.
	 */
	@Override
	public void init() throws ServletException {
		// List<RdfDistributor> list = new ArrayList<>();
		//
		// try {
		// ServletContext ctx = getServletContext();
		// ConfigurationBeanLoader beanLoader = new ConfigurationBeanLoader(
		// ModelAccess.on(ctx).getOntModel(DISPLAY), ctx);
		// list.addAll(beanLoader.loadAll(RdfDistributor.class));
		// } catch (ConfigurationBeanLoaderException e) {
		// log.error("Failed to initialize list of RdfDistributors "
		// + "-- using empty list.", e);
		// }
		//
		// Map<String, RdfDistributor> map = new HashMap<>();
		// for (RdfDistributor dist : list) {
		// map.put(dist.getActionName(), dist);
		// }
		//
		// this.distributors = Collections.unmodifiableMap(map);
	}

	/**
	 * TODO
	 * 
	 * <pre>
	 * On init,
	 * Read the configuration of distributors, and instantiate. Create a map linking actions to instances.
	 * If any failure, write warning to the log and create a truncated or empty map.
	 * 
	 * </pre>
	 */

	private static final String QUERY_STRING = "" //
			+ "PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n " //
			+ "PREFIX rdfs:     <http://www.w3.org/2000/01/rdf-schema#> \n " //
			+ "PREFIX bibo:     <http://purl.org/ontology/bibo/> \n " //
			+ "PREFIX vivo:     <http://vivoweb.org/ontology/core#> \n " //
			+ "CONSTRUCT { \n " //
			+ "  ?pub rdfs:label ?label . \n " //
			+ "  ?pub vivo:freetextKeyword ?keyword . \n " //
			+ "} \n " //
			+ "WHERE \n " //
			+ "{ \n " //
			+ "  ?person vivo:relatedBy ?auth . \n " //
			+ "  ?auth a vivo:Authorship . \n " //
			+ "  ?auth vivo:relates ?pub . \n " //
			+ "  ?pub a bibo:Document . \n " //
			+ "  ?pub rdfs:label ?label . \n " //
			+ "  ?pub vivo:freetextKeyword ?keyword . \n " //
			+ "}";

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		String uri = req.getParameter("person");
		String queryStr = QUERY_STRING.replace("?person", "<" + uri + ">");
		log.warn("QUERY: " + queryStr);
		
		OntModel model = ModelAccess.on(req).getOntModel();
		QueryExecution qe = null;
		try {
			Query query = QueryFactory.create(queryStr, Syntax.syntaxARQ);
			qe = QueryExecutionFactory.create(query, model);
			Model result = qe.execConstruct();

			resp.setContentType("text/turtle;charset=UTF-8");
			result.write(resp.getOutputStream(), "TTL");
		} catch (Exception e) {
			log.error("Failed to execute the Construct query: " + queryStr, e);
		} finally {
			if (qe != null) {
				qe.close();
			}
		}

		// TODO Auto-generated method stub
		log.error("BOGUS SERVER");
		throw new RuntimeException(
				"DistributeRdfApiController.doGet() not implemented.");

	}

	/**
	 * If you want to use a post form, go ahead.
	 */
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doGet(req, resp);
	}

	/**
	 * TODO
	 * 
	 * <pre>
	 * Read the parameters, get the requested action,  
	 * If no instance for the action, error
	 * Call execute on the action.
	 *   Deal with these errors
	 *     Parameter missing
	 *     Not authorized
	 *     Unexpected
	 * Pass the RDF to the output stream.
	 * 
	 * Can we go further and read the accept header and return the appropriate encoding?
	 * </pre>
	 */

}
