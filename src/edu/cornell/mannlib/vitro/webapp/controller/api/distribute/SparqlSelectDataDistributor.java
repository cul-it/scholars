/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import static edu.cornell.mannlib.vitro.webapp.utils.sparql.SelectQueryRunner.createQueryContext;

import java.io.OutputStream;
import java.util.HashSet;
import java.util.Set;

import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.RequestModelsUser;
import edu.cornell.mannlib.vitro.webapp.utils.sparql.SelectQueryRunner.SelectQueryContext;

/**
 * <pre>
 * Issue a SPARQL SELECT query and return the results as JSON. You provide:
 * - the action name
 * - the query string
 * - names of request parameters, whose values will be bound as URIs in the query
 * - names of request parameters, whose values will  be bound as plain literals in the query
 * 
 * So if the configuration looks like this:
 * :sample_sparql_query_distributor
 *     a   <java:edu.cornell.mannlib.vitro.webapp.controller.api.distribute.DataDistributor> ,
 *         <java:edu.cornell.mannlib.vitro.webapp.controller.api.distribute.SparqlSelectDataDistributor> ;
 *     :actionName "sampleAction" ;
 *     :query """
 *       PREFIX foo: <http://some.silly.domain/foo#>
 *       SELECT ?article
 *       WHERE {
 *         ?person foo:isAuthor ?article .
 *         ?article foo:hasTopic ?topic .
 *       }
 *     """ ;
 *     :uriBinding "person" ;
 *     :literalBinding "topic" .
 * 
 * Then this request: 
 *    dataRequest/sampleAction?person=http%3A%2F%2Fmy.domain.edu%2Findividual%2Fn1234&topic=Oncology
 *    
 * Will execute this query:
 *    PREFIX foo: <http://some.silly.domain/foo#>
 *    SELECT ?article
 *    WHERE {
 *      <http://my.domain.edu/individual/n1234> foo:isAuthor ?article .
 *      ?article foo:hasTopic "Oncology" .
 *    }
 * 
 * Each specified binding name must have exactly one value in the request parameters.
 * </pre>
 */
public class SparqlSelectDataDistributor extends DataDistributorBase implements
		RequestModelsUser {

	/** The models on the current request. */
	private RequestModelAccess models;

	private String rawQuery;
	private Set<String> uriBinders = new HashSet<>();
	private Set<String> literalBinders = new HashSet<>();

	@Override
	public void setRequestModels(RequestModelAccess models) {
		this.models = models;
	}

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#query", minOccurs = 1, maxOccurs = 1)
	public void setRawQuery(String query) {
		rawQuery = query;
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

	@Override
	public void writeOutput(OutputStream output)
			throws DataDistributorException {
		SelectQueryContext queryContext = createQueryContext(
				this.models.getRDFService(), this.rawQuery);
		bindUriParameters(queryContext);
		bindLiteralParameters(queryContext);
		queryContext.execute().writeToOutput(output);
	}

	private void bindUriParameters(SelectQueryContext queryContext)
			throws MissingParametersException {
		for (String name : this.uriBinders) {
			queryContext.bindVariableToUri(name, getOneParameter(name));
		}
	}

	private void bindLiteralParameters(SelectQueryContext queryContext)
			throws MissingParametersException {
		for (String name : this.literalBinders) {
			queryContext
					.bindVariableToPlainLiteral(name, getOneParameter(name));
		}
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
	public void close() throws DataDistributorException {
		// Nothing to do.
	}

}
