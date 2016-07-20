/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.util.HashSet;
import java.util.Set;

import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.SparqlQueryRunner.ConstructQueryContext;
import edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.SparqlQueryRunner.SelectQueryContext;

/**
 * Some utility methods that come in handy.
 */
public abstract class SparqlSelectDataDistributorBase extends
		DataDistributorBase {

	/** The models on the current request. */
	protected RequestModelAccess models;

	protected Set<String> uriBinders = new HashSet<>();
	protected Set<String> literalBinders = new HashSet<>();

	@SuppressWarnings("hiding")
	@Override
	public void init(DataDistributorContext ddContext) {
		super.init(ddContext);
		this.models = ddContext.getRequestModels();
	}

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#uriBinding")
	public void addUriBinder(String uriBindingName) {
		this.uriBinders.add(uriBindingName);
	}

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#literalBinding")
	public void addLiteralBinder(String literalBindingName) {
		this.literalBinders.add(literalBindingName);
	}

	@Override
	public String getContentType() throws DataDistributorException {
		return "application/sparql-results+json";
	}

	protected SelectQueryContext bindUriParameters(
			SelectQueryContext queryContext) throws MissingParametersException {
		for (String name : this.uriBinders) {
			queryContext = queryContext.bindVariableToUri(name,
					getOneParameter(name));
		}
		return queryContext;
	}

	protected ConstructQueryContext bindUriParameters(
			ConstructQueryContext queryContext)
			throws MissingParametersException {
		for (String name : this.uriBinders) {
			queryContext = queryContext.bindVariableToUri(name,
					getOneParameter(name));
		}
		return queryContext;
	}

	protected SelectQueryContext bindLiteralParameters(
			SelectQueryContext queryContext) throws MissingParametersException {
		for (String name : this.literalBinders) {
			queryContext = queryContext.bindVariableToPlainLiteral(name,
					getOneParameter(name));
		}
		return queryContext;
	}

	protected ConstructQueryContext bindLiteralParameters(
			ConstructQueryContext queryContext)
			throws MissingParametersException {
		for (String name : this.literalBinders) {
			queryContext = queryContext.bindVariableToPlainLiteral(name,
					getOneParameter(name));
		}
		return queryContext;
	}

	private String getOneParameter(String name)
			throws MissingParametersException {
		String[] uris = parameters.get(name);
		if (uris == null || uris.length == 0) {
			throw new MissingParametersException("A '" + name
					+ "' parameter is required.");
		} else if (uris.length > 1) {
			throw new MissingParametersException(
					"Unexpected multiple values for '" + name + "' parameter.");
		}
		return uris[0];
	}

}
