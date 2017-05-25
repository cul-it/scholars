/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.searchindex.extensions;

import static edu.cornell.library.scholars.webapp.utils.sparqlrunner.SparqlQueryRunner.createAskQueryContext;
import static edu.cornell.library.scholars.webapp.utils.sparqlrunner.SparqlQueryRunner.createSelectQueryContext;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Selector;
import com.hp.hpl.jena.rdf.model.Statement;

import edu.cornell.library.scholars.webapp.utils.sparqlrunner.QueryHolder;
import edu.cornell.mannlib.vitro.webapp.modelaccess.ContextModelAccess;
import edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService;
import edu.cornell.mannlib.vitro.webapp.searchindex.indexing.IndexingUriFinder;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.ContextModelsUser;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;

/**
 * Find URIs to be indexed. The supplied statement must satisfy the matchers and
 * the restrictions. Then the queries will be run and the results will be
 * returned as found URIs.
 * 
 * If matchers are supplied, the statement must match at least one of them.
 * 
 * A matcher is a triplet pattern which will be matched against the statement.
 * The syntax is essentially that of a statement pattern in a WHERE clause, but
 * URIs must be fully qualified. Any unbound variables will act as wild cards
 * 
 * If restrictions are supplied, at least one restriction must return true.
 * 
 * A restriction is in the form of an ASK query. Again, ?subject ?predicate and
 * ?object are bound to their respective values. Then the ASK is executed
 * against the full model from the triple-store.
 *
 * If the matchers and restrictions are satisfied, then the SELECT queries are
 * run against the full model. All values returned from all of the SELECT
 * queries will be treated as found URIs.
 */
public class MatchingRestrictingUriFinder
        implements IndexingUriFinder, ContextModelsUser {
    private static final Log log = LogFactory
            .getLog(MatchingRestrictingUriFinder.class);

    private RDFService rdfService;
    private String label = this.getClass().getSimpleName() + ":"
            + this.hashCode();
    private List<Selector> matchers = new ArrayList<>();
    private List<String> askRestrictions = new ArrayList<>();
    private List<String> queries = new ArrayList<>();

    @Override
    public void setContextModels(ContextModelAccess ma) {
        this.rdfService = ma.getRDFService();
    }

    @Property(uri = "http://www.w3.org/2000/01/rdf-schema#label", maxOccurs = 1)
    public void setLabel(String l) {
        label = l;
    }

    @Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#hasMatcher")
    public void addMatcher(String m) {
        matchers.add(new StatementPatternParser(m).selector());
    }

    @Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#hasAskRestriction")
    public void addRestriction(String ask) {
        askRestrictions.add(confirmValidRestriction(ask));
    }

    private String confirmValidRestriction(String ask) {
        try {
            QueryExecution qe = null;
            try {
                Query q = QueryFactory.create(ask);
                qe = QueryExecutionFactory.create(q, emptyModel());
                qe.execAsk();
                // If we get to here, we're good.
                return ask;
            } finally {
                if (qe != null) {
                    qe.close();
                }
            }
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Ask restriction is invalid: '" + ask + "'", e);
        }
    }

    @Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#hasSelectQuery", minOccurs = 1)
    public void addQuery(String query) {
        queries.add(confirmValidQuery(query));
    }

    private String confirmValidQuery(String query) {
        try {
            QueryExecution qe = null;
            try {
                Query q = QueryFactory.create(query);
                qe = QueryExecutionFactory.create(q, emptyModel());
                qe.execSelect();
                // If we get to here, we're good.
                return query;
            } finally {
                if (qe != null) {
                    qe.close();
                }
            }
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Select query is invalid: '" + query + "'", e);
        }
    }

    @Override
    public void startIndexing() {
        // Nothing to do.
    }

    @Override
    public List<String> findAdditionalURIsToIndex(Statement stmt) {
        List<String> uris = new Core(rdfService, matchers, askRestrictions,
                queries, stmt).findAdditionalURIs();
        if (log.isDebugEnabled()) {
            log.debug(String.format("Found %d uris %s for statement %s",
                    uris.size(), uris, stmt));
        }
        return uris;
    }

    @Override
    public void endIndexing() {
        // Nothing to do.
    }

    @Override
    public String toString() {
        return label;
    }

    /**
     * Do the heavy lifting in a use-it-once-and-throw-it-away class, so we can
     * do it in a clear but thread-safe manner.
     */
    private static class Core {
        private final RDFService rdfService;
        private final List<Selector> matchers;
        private final List<String> askRestrictions;
        private final List<String> queries;
        private final Statement stmt;

        public Core(RDFService rdfService, List<Selector> matchers,
                List<String> askRestrictions, List<String> queries,
                Statement stmt) {
            this.rdfService = rdfService;
            this.matchers = matchers;
            this.askRestrictions = askRestrictions;
            this.queries = queries;
            this.stmt = stmt;
        }

        public List<String> findAdditionalURIs() {
            if (areMatchersSatisfied() && areRestrictionsSatisfied()) {
                return removeDuplicates(getResultsOfSelectQueries());
            } else {
                return Collections.emptyList();
            }
        }

        private boolean areMatchersSatisfied() {
            if (matchers.isEmpty()) {
                return true;
            } else {
                for (Selector matcher : matchers) {
                    if (isMatcherSatisfied(matcher)) {
                        return true;
                    }
                }
            }
            return false;
        }

        private boolean isMatcherSatisfied(Selector matcher) {
            try {
                return emptyModel().add(stmt).listStatements(matcher).toList()
                        .size() > 0;
            } catch (Exception e) {
                log.warn("Failed to apply matcher: '" + matcher + "' to "
                        + stmt);
                return false;
            }
        }

        private boolean areRestrictionsSatisfied() {
            if (askRestrictions.isEmpty()) {
                return true;
            } else {
                for (String askRestriction : askRestrictions) {
                    if (isRestrictionSatisfied(askRestriction)) {
                        return true;
                    }
                }
            }
            return false;
        }

        private boolean isRestrictionSatisfied(String ask) {
            try {
                return createAskQueryContext(rdfService,
                        bindStatementToVariables(ask)).execute().toBoolean();
            } catch (Exception e) {
                log.warn("Failed to apply restriction: '" + ask + "' to "
                        + stmt);
                return false;
            }
        }

        private List<String> getResultsOfSelectQueries() {
            List<String> uris = new ArrayList<>();
            for (String query : queries) {
                uris.addAll(getResultsOfSelectQuery(query));
            }
            return uris;
        }

        private List<String> getResultsOfSelectQuery(String query) {
            try {
                return createSelectQueryContext(rdfService,
                        bindStatementToVariables(query)).execute()
                                .toStringFields().flatten();
            } catch (Exception e) {
                log.warn(
                        "Failed to execute query: '" + query + "' for " + stmt);
                return Collections.emptyList();
            }
        }

        private ArrayList<String> removeDuplicates(
                List<String> withDuplicates) {
            return new ArrayList<>(new HashSet<>(withDuplicates));
        }

        private String bindStatementToVariables(String pattern) {
            QueryHolder holder = new QueryHolder(pattern)
                    .bindToUri("subject", stmt.getSubject().getURI())
                    .bindToUri("predicate", stmt.getPredicate().getURI());
            if (stmt.getObject().isLiteral()) {
                holder = holder.bindToLiteral("object",
                        stmt.getObject().asLiteral());
            } else {
                holder = holder.bindToUri("object",
                        stmt.getObject().asResource().getURI());
            }
            return holder.getQueryString();
        }
    }

    private static Model emptyModel() {
        return ModelFactory.createDefaultModel();
    }

}
