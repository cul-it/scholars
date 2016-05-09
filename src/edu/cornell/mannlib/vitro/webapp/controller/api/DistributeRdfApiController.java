/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api;

import static edu.cornell.mannlib.vitro.webapp.modelaccess.ModelNames.DISPLAY;
import static edu.cornell.mannlib.vitro.webapp.utils.sparql.SelectQueryRunner.createQueryContext;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor.ActionFailedException;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor.MissingParametersException;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor.NoSuchActionException;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor.NotAuthorizedException;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.RdfDistributor.RdfDistributorException;
import edu.cornell.mannlib.vitro.webapp.modelaccess.ModelAccess;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.ConfigurationBeanLoader;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.ConfigurationBeanLoaderException;

/**
 * Find a distributor description for the requested action. Create an instance
 * of that distributor. Run it, and return the resulting model as a Turtle file.
 */
public class DistributeRdfApiController extends VitroApiServlet {
	private static final Log log = LogFactory
			.getLog(DistributeRdfApiController.class);

	private static final String DISTRIBUTOR_FOR_SPECIFIED_ACTION = ""
			+ "PREFIX : <http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#> \n"
			+ "SELECT ?distributor  \n" //
			+ "WHERE { \n" //
			+ "   ?distributor :actionName ?action . \n" //
			+ "} \n";

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		try {
			Model model = ModelAccess.on(req).getOntModel(DISPLAY);
			String action = req.getParameter("action");

			String uri = findDistributorForAction(action, model);
			RdfDistributor instance = instantiateDistributor(req, uri, model);
			runIt(req, resp, instance);
			
		} catch (NoSuchActionException e) {
			do400BadRequest(e.getMessage(), resp);
		} catch (MissingParametersException e) {
			do400BadRequest(e.getMessage(), resp);
		} catch (NotAuthorizedException e) {
			do403Forbidden(resp);
		} catch (Exception e) {
			do500InternalServerError(e.getMessage(), e, resp);
		}
	}

	private String findDistributorForAction(String action, Model model)
			throws NoSuchActionException {
		if (action == null || action.isEmpty()) {
			throw new NoSuchActionException(
					"'action' parameter was not provided.");
		}

		List<String> uris = createQueryContext(model,
				DISTRIBUTOR_FOR_SPECIFIED_ACTION)
				.bindVariableToValue("action", action).execute()
				.getStringFields("distributor").flatten();
		Collections.sort(uris);
		log.debug("Found URIs for action '" + action + "': " + uris);

		if (uris.isEmpty()) {
			throw new NoSuchActionException(
					"Did not find an RdfDistributor for '" + action + "'");
		}
		if (uris.size() > 1) {
			log.warn("Found more than one RdfDistributor for '" + action
					+ "': " + uris);
		}

		return uris.get(0);
	}

	private RdfDistributor instantiateDistributor(HttpServletRequest req,
			String distributorUri, Model model) throws ActionFailedException {
		try {
			return new ConfigurationBeanLoader(model, req).loadInstance(
					distributorUri, RdfDistributor.class);
		} catch (ConfigurationBeanLoaderException e) {
			throw new ActionFailedException(
					"Failed to instantiate the RDF Distributor: "
							+ distributorUri, e);
		}
	}

	private void runIt(HttpServletRequest req, HttpServletResponse resp,
			RdfDistributor instance) throws IOException,
			RdfDistributorException {
		@SuppressWarnings("unchecked")
		Map<String, String[]> parameters = req.getParameterMap();
		Model result = instance.execute(parameters);

		resp.setContentType("text/turtle;charset=UTF-8");
		result.write(resp.getOutputStream(), "TTL");
	}

	private void do400BadRequest(String message, HttpServletResponse resp)
			throws IOException {
		log.debug("400BadRequest: " + message);
		resp.setStatus(400);
		resp.getWriter().println(message);
	}

	private void do403Forbidden(HttpServletResponse resp) throws IOException {
		log.debug("403Forbidden");
		resp.setStatus(403);
		resp.getWriter().println("Not authorized for this action.");
	}

	private void do500InternalServerError(String message, Exception e,
			HttpServletResponse resp) throws IOException {
		log.warn("500InternalServerError " + message, e);
		resp.setStatus(500);
		PrintWriter w = resp.getWriter();
		w.println(message);
		e.printStackTrace(w);
	}

	/**
	 * If you want to use a post form, go ahead.
	 */
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doGet(req, resp);
	}
}
