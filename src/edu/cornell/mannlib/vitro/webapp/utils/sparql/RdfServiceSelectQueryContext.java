/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.sparql;

import static edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService.ResultFormat.JSON;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.query.ResultSet;

import edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService;
import edu.cornell.mannlib.vitro.webapp.rdfservice.impl.RDFServiceUtils;
import edu.cornell.mannlib.vitro.webapp.utils.sparql.SparqlQueryRunner.ExecutingSelectQueryContext;
import edu.cornell.mannlib.vitro.webapp.utils.sparql.SparqlQueryRunner.SelectQueryContext;

/**
 * An implementation of QueryContext based on an RDFService.
 * 
 * Package access. Instances should be created only by SparqlQueryRunner, or by
 * a method on this class.
 */
class RdfServiceSelectQueryContext implements SelectQueryContext {
	private static final Log log = LogFactory
			.getLog(RdfServiceSelectQueryContext.class);

	private final RDFService rdfService;
	private final QueryHolder query;

	RdfServiceSelectQueryContext(RDFService rdfService, QueryHolder query) {
		this.rdfService = rdfService;
		this.query = query;
	}

	@Override
	public RdfServiceSelectQueryContext bindVariableToUri(String name, String uri) {
		return new RdfServiceSelectQueryContext(rdfService,
				query.bindToUri(name, uri));
	}

	@Override
	public RdfServiceSelectQueryContext bindVariableToPlainLiteral(String name, String value) {
		return new RdfServiceSelectQueryContext(rdfService, query.bindToPlainLiteral(name,
				value));
	}

	@Override
	public String toString() {
		return "RdfServiceSelectQueryContext[query=" + query + "]";
	}

	@Override
	public ExecutingSelectQueryContext execute() {
		return new RdfServiceExecutingQueryContext(rdfService, query);
	}

	private static class RdfServiceExecutingQueryContext implements
			ExecutingSelectQueryContext {
		private final RDFService rdfService;
		private final QueryHolder query;

		public RdfServiceExecutingQueryContext(RDFService rdfService,
				QueryHolder query) {
			this.rdfService = rdfService;
			this.query = query;
		}

		@Override
		public StringResultsMapping toStringFields(String... names) {
			Set<String> fieldNames = new HashSet<>(Arrays.asList(names));
			try {
				ResultSet results = RDFServiceUtils.sparqlSelectQuery(
						query.getQueryString(), rdfService);
				return new StringResultsMapping(results, fieldNames);
			} catch (Exception e) {
				log.error(
						"problem while running query '"
								+ query.getQueryString() + "'", e);
				return StringResultsMapping.EMPTY;
			}
		}

		@Override
		public void writeToOutput(OutputStream output) {
			try {
				InputStream resultStream = rdfService.sparqlSelectQuery(
						query.getQueryString(), JSON);
				IOUtils.copy(resultStream, output);
			} catch (Exception e) {
				log.error(
						"problem while running query '"
								+ query.getQueryString() + "'", e);
			}
		}
	}
}
