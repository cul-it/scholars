/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute.modelbuilder;

import static edu.cornell.mannlib.vitro.webapp.utils.sparql.SparqlQueryRunner.createConstructQueryContext;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.DataDistributor.DataDistributorException;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.DataDistributor.MissingParametersException;
import edu.cornell.mannlib.vitro.webapp.controller.api.distribute.DataDistributorContext;
import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.sparql.SparqlQueryRunner.ConstructQueryContext;

/**
 * Run a construct query to build the model. Bind parameters from the request, as needed.
 */
public class ConstructModelBuilder implements ModelBuilder {
	private static final Log log = LogFactory
			.getLog(ConstructModelBuilder.class);

	protected RequestModelAccess models;
	private Map<String, String[]> parameters;
	protected String rawConstructQuery;
	private Set<String> uriBinders = new HashSet<>();
	private Set<String> literalBinders = new HashSet<>();

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#uriBinding")
	public void addUriBinder(String uriBindingName) {
		this.uriBinders.add(uriBindingName);
	}

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#literalBinding")
	public void addLiteralBinder(String literalBindingName) {
		this.literalBinders.add(literalBindingName);
	}

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#constructQuery", minOccurs = 1, maxOccurs = 1)
	public void setRawConstructQuery(String query) {
		rawConstructQuery = query;
	}

	@Override
	public void init(DataDistributorContext ddContext)
			throws DataDistributorException {
		this.parameters = ddContext.getRequestParameters();
		this.models = ddContext.getRequestModels();
	}

	@Override
	public Model buildModel() throws DataDistributorException {
		ConstructQueryContext queryContext = createConstructQueryContext(
				models.getRDFService(), rawConstructQuery);
		queryContext = bindUriParameters(queryContext);
		queryContext = bindLiteralParameters(queryContext);
		log.debug("Query context is: " + queryContext);
		return queryContext.execute().toModel();
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

	@Override
	public void close() {
		// Nothing to do.
	}

}
