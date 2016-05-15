/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.sparql;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.utils.sparql.SelectQueryRunner.ExecutingSelectQueryContext;
import edu.cornell.mannlib.vitro.webapp.utils.sparql.SelectQueryRunner.SelectQueryContext;

/**
 * An implementation of QueryContext based on a Model.
 * 
 * Package access. Instances should be created only by SelectQueryRunner, or by
 * a method on this class.
 */
class ModelQueryContext implements SelectQueryContext {
	private static final Log log = LogFactory.getLog(ModelQueryContext.class);

	private final Model model;
	private final SelectQueryHolder query;

	public ModelQueryContext(Model model, SelectQueryHolder query) {
		this.model = model;
		this.query = query;
	}

	@Override
	public ModelQueryContext bindVariableToUri(String name, String uri) {
		return new ModelQueryContext(model, query.bindToUri(name, uri));
	}

	@Override
	public ModelQueryContext bindVariableToValue(String name, String value) {
		return new ModelQueryContext(model, query.bindToValue(name, value));
	}

	@Override
	public ExecutingSelectQueryContext execute() {
		return new ModelExecutingQueryContext(model, query);
	}

	private static class ModelExecutingQueryContext implements
			ExecutingSelectQueryContext {
		private final Model model;
		private final SelectQueryHolder query;

		public ModelExecutingQueryContext(Model model, SelectQueryHolder query) {
			this.model = model;
			this.query = query;
		}

		@Override
		public StringResultsMapping getStringFields(String... names) {
			Set<String> fieldNames = new HashSet<>(Arrays.asList(names));
			try {
				Query q = QueryFactory.create(query.getQueryString());
				QueryExecution qexec = QueryExecutionFactory.create(q, model);
				try {
					ResultSet results = qexec.execSelect();
					return new StringResultsMapping(results, fieldNames);
				} finally {
					qexec.close();
				}
			} catch (Exception e) {
				log.error(
						"problem while running query '"
								+ query.getQueryString() + "'", e);
				return StringResultsMapping.EMPTY;
			}
		}
	}
}
