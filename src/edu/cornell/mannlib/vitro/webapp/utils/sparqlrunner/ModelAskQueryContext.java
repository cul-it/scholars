/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.SparqlQueryRunner.AskQueryContext;
import edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.SparqlQueryRunner.ExecutingAskQueryContext;

/**
 * TODO
 */
public class ModelAskQueryContext implements AskQueryContext {
    private static final Log log = LogFactory
            .getLog(ModelAskQueryContext.class);

    private final Model model;
    private final QueryHolder query;

    public ModelAskQueryContext(Model model, QueryHolder query) {
        this.model = model;
        this.query = query;
    }

    @Override
    public AskQueryContext bindVariableToUri(String name, String uri) {
        return new ModelAskQueryContext(model, query.bindToUri(name, uri));
    }

    @Override
    public AskQueryContext bindVariableToPlainLiteral(String name,
            String value) {
        return new ModelAskQueryContext(model,
                query.bindToPlainLiteral(name, value));
    }

    @Override
    public AskQueryContext bindVariableToLiteral(String name, Literal literal) {
        return new ModelAskQueryContext(model,
                query.bindToLiteral(name, literal));
    }

    @Override
    public String toString() {
        return "ModelAskQueryContext[query=" + query + "]";
    }

    @Override
    public ExecutingAskQueryContext execute() {
        return new ModelExecutingAskQueryContext(model, query);
    }

    private static class ModelExecutingAskQueryContext
            implements ExecutingAskQueryContext {
        private final Model model;
        private final QueryHolder query;

        public ModelExecutingAskQueryContext(Model model, QueryHolder query) {
            this.model = model;
            this.query = query;
        }

        @Override
        public boolean toBoolean() {
            QueryExecution qe = null;
            try {
                Query q = QueryFactory.create(query.getQueryString());
                qe = QueryExecutionFactory.create(q, model);
                return qe.execAsk();
            } catch (Exception e) {
                log.error("problem while running query '"
                        + query.getQueryString() + "'", e);
                return false;
            } finally {
                if (qe != null) {
                    qe.close();
                }
            }
        }

    }
}
