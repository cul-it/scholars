/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.rdf.model.Literal;

import edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService;
import edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.SparqlQueryRunner.AskQueryContext;
import edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.SparqlQueryRunner.ExecutingAskQueryContext;

/**
 * TODO
 */
public class RdfServiceAskQueryContext implements AskQueryContext {
    private static final Log log = LogFactory
            .getLog(RdfServiceAskQueryContext.class);

    private final RDFService rdfService;
    private final QueryHolder query;

    public RdfServiceAskQueryContext(RDFService rdfService, QueryHolder query) {
        this.rdfService = rdfService;
        this.query = query;
    }

    @Override
    public AskQueryContext bindVariableToUri(String name, String uri) {
        return new RdfServiceAskQueryContext(rdfService,
                query.bindToUri(name, uri));
    }

    @Override
    public AskQueryContext bindVariableToPlainLiteral(String name,
            String value) {
        return new RdfServiceAskQueryContext(rdfService,
                query.bindToPlainLiteral(name, value));
    }

    @Override
    public AskQueryContext bindVariableToLiteral(String name,
            Literal literal) {
        return new RdfServiceAskQueryContext(rdfService,
                query.bindToLiteral(name, literal));
    }

    @Override
    public ExecutingAskQueryContext execute() {
        return new RdfServiceExecutingAskQueryContext(rdfService, query);
    }

    @Override
    public String toString() {
        return "RdfServiceAskQueryContext[query=" + query + "]";
    }

    private static class RdfServiceExecutingAskQueryContext
            implements ExecutingAskQueryContext {
        private final RDFService rdfService;
        private final QueryHolder query;

        public RdfServiceExecutingAskQueryContext(RDFService rdfService,
                QueryHolder query) {
            this.rdfService = rdfService;
            this.query = query;
        }

        @Override
        public boolean toBoolean() {
            try {
                return rdfService.sparqlAskQuery(query.getQueryString());
            } catch (Exception e) {
                log.error("problem while running query '"
                        + query.getQueryString() + "'", e);
                return false;
            }
        }

    }
}
