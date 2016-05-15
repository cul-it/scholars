/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.sparql;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService;

/**
 * A conversational tool for handling SPARQL queries.
 * 
 * <pre>
 * Examples:
 *   List<String> values = createQueryContext(rdfService, queryString)
 *                             .bindVariableToUri("uri", uri)
 * 				               .execute()
 * 				               .getStringFields("partner")
 * 				               .flatten();
 * 
 *   SelectQueryHolder q = selectQuery(queryString)
 *                             .bindToUri("uri", uri));
 *   List<Map<String, String> map = createQueryContext(model, q)
 *                             .execute()
 *                             .getStringFields();
 * </pre>
 * 
 * The query context can come from either an RDFService or a Model.
 * 
 * The execute() method does not actually execute the query: it merely sets it
 * up syntactically.
 * 
 * If you don't supply any field names to getStringFields(), you get all of
 * them.
 * 
 * Any string value that returns a blank or empty string is omitted from the
 * results. Any row that returns no values is omitted from the results.
 */
public final class SelectQueryRunner {
	private static final Log log = LogFactory.getLog(SelectQueryRunner.class);

	private SelectQueryRunner() {
		// No need to create an instance.
	}

	public static SelectQueryHolder selectQuery(String queryString) {
		return new SelectQueryHolder(queryString);
	}

	public static SelectQueryContext createQueryContext(RDFService rdfService,
			String queryString) {
		return createQueryContext(rdfService, selectQuery(queryString));
	}

	public static SelectQueryContext createQueryContext(RDFService rdfService,
			SelectQueryHolder query) {
		return new RdfServiceQueryContext(rdfService, query);
	}

	public static SelectQueryContext createQueryContext(Model model,
			String queryString) {
		return createQueryContext(model, selectQuery(queryString));
	}

	public static SelectQueryContext createQueryContext(Model model,
			SelectQueryHolder query) {
		return new ModelQueryContext(model, query);
	}

	public static interface SelectQueryContext {
		public SelectQueryContext bindVariableToUri(String name, String uri);

		public SelectQueryContext bindVariableToValue(String name, String value);

		public ExecutingSelectQueryContext execute();
	}

	public static interface ExecutingSelectQueryContext {
		public StringResultsMapping getStringFields(String... fieldNames);
	}

}
