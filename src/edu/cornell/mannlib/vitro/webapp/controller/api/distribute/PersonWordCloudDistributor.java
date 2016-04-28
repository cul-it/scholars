/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.RequestModelsUser;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Validation;

/**
 * TODO
 */
public class PersonWordCloudDistributor extends RdfDistributorBase implements
		RequestModelsUser {
	private static final Log log = LogFactory
			.getLog(PersonWordCloudDistributor.class);

	/** The name of the action request that we are responding to. */
	private String actionName;

	/** The models on the current request. */
	private RequestModelAccess models;

	/** The construct query to be executed. */
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

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#actionName")
	public void setActionName(String action) {
		if (actionName == null) {
			actionName = action;
		} else {
			throw new IllegalStateException(
					"Configuration includes multiple instances of actionName: "
							+ actionName + ", and " + action);
		}
	}

	@Validation
	public void validate() {
		if (actionName == null) {
			throw new IllegalStateException(
					"Configuration contains no action name for "
							+ this.getClass().getSimpleName());
		}
	}

	@Override
	public void setRequestModels(RequestModelAccess models) {
		this.models = models;
	}

	@Override
	public String getActionName() {
		return actionName;
	}

	@Override
	public Model execute(Map<String, String[]> parameters)
			throws RdfDistributorException {
		String uri = getPersonUri(parameters);
		String queryStr = QUERY_STRING.replace("?person", "<" + uri + ">");

		OntModel model = models.getOntModel();
		QueryExecution qe = null;
		try {
			Query query = QueryFactory.create(queryStr, Syntax.syntaxARQ);
			qe = QueryExecutionFactory.create(query, model);
			return qe.execConstruct();
		} catch (Exception e) {
			throw new ActionFailedException(e);
		} finally {
			if (qe != null) {
				qe.close();
			}
		}
	}

	private String getPersonUri(Map<String, String[]> parameters)
			throws MissingParametersException {
		String[] persons = parameters.get("person");
		if (persons == null || persons.length == 0) {
			throw new MissingParametersException(
					"A 'person' parameter is required.");
		} else {
			return persons[0];
		}
	}

}
