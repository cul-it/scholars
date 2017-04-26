/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner;

import static com.hp.hpl.jena.rdf.model.ResourceFactory.createLangLiteral;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createPlainLiteral;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createTypedLiteral;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import com.hp.hpl.jena.datatypes.RDFDatatype;
import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.rdf.model.Literal;

import edu.cornell.mannlib.vitro.testing.AbstractTestClass;

/**
 * Check the functionality of QueryHolder.
 */
public class QueryHolderTest extends AbstractTestClass {
    private static final String SOME_URI = "http://some.uri/";
    private static final String SOME_LITERAL = "abracadabra";
    private static final String SOME_LANGUAGE = "en";
    private static final RDFDatatype SOME_TYPE = XSDDatatype.XSDint;
    private static final int SOME_INTEGER = 4;

    private static final String FIND_ONCE = "SELECT ?s ?p WHERE { ?s ?p ?bindMe }";
    private static final String URI_BOUND_ONCE = "SELECT ?s ?p WHERE { ?s ?p <"
            + SOME_URI + "> }";
    private static final String LITERAL_BOUND_ONCE = "SELECT ?s ?p WHERE { ?s ?p \""
            + SOME_LITERAL + "\" }";
    private static final String TYPED_LITERAL_BOUND_ONCE = "SELECT ?s ?p WHERE { ?s ?p \""
            + SOME_INTEGER + "^^" + SOME_TYPE.getURI() + "\" }";
    private static final String LANGUAGE_LITERAL_BOUND_ONCE = "SELECT ?s ?p WHERE { ?s ?p \""
            + SOME_LITERAL + "@" + SOME_LANGUAGE + "\" }";

    private static final String FIND_TWICE = "CONSTRUCT { ?s ?p ?find_twice } WHERE { ?s ?p ?find_twice }";
    private static final String URI_BOUND_TWICE = "CONSTRUCT { ?s ?p <"
            + SOME_URI + "> } WHERE { ?s ?p <" + SOME_URI + "> }";
    private static final String LITERAL_BOUND_TWICE = "CONSTRUCT { ?s ?p \""
            + SOME_LITERAL + "\" } WHERE { ?s ?p \"" + SOME_LITERAL + "\" }";

    private static final String SQUEEZED = "CONSTRUCT {?s ?p ?squeeze} WHERE {?s ?p ?squeeze}";
    private static final String URI_BOUND_SQUEEZED = "CONSTRUCT {?s ?p <"
            + SOME_URI + ">} WHERE {?s ?p <" + SOME_URI + ">}";
    private static final String LITERAL_BOUND_SQUEEZED = "CONSTRUCT {?s ?p \""
            + SOME_LITERAL + "\"} WHERE {?s ?p \"" + SOME_LITERAL + "\"}";

    private static final String FIND_IN_SELECT_CLAUSE = "SELECT ?s ?p ?bindMe WHERE { ?s ?p ?bindMe }";
    private static final String URI_BOUND_IN_SELECT_CLAUSE = "SELECT ?s ?p ?bindMe WHERE { ?s ?p <"
            + SOME_URI + "> }";

    // ----------------------------------------------------------------------
    // The tests
    // ----------------------------------------------------------------------

    @Test
    public void hasVariable_findsOne() {
        assertTrue(new QueryHolder(FIND_ONCE).hasVariable("bindMe"));
    }

    @Test
    public void hasVariable_findsTwo() {
        assertTrue(new QueryHolder(FIND_TWICE).hasVariable("find_twice"));
    }

    @Test
    public void hasVariable_doesntFindOne() {
        assertFalse(new QueryHolder(FIND_TWICE).hasVariable("notThere"));
    }

    @Test
    public void hasVariable_notFooledByExtendedName() {
        assertFalse(new QueryHolder(FIND_ONCE).hasVariable("bind"));
    }

    @Test
    public void hasVariable_notFooledByPunctuation() {
        assertTrue(new QueryHolder(SQUEEZED).hasVariable("squeeze"));
    }

    @Test
    public void bindToUri_notFound_noComplaint() {
        bindToUri(FIND_ONCE, "notThere", SOME_URI).yields(FIND_ONCE);
    }

    @Test
    public void bindToUri_findsOne_bindsIt() {
        bindToUri(FIND_ONCE, "bindMe", SOME_URI).yields(URI_BOUND_ONCE);
    }

    @Test
    public void bindToUri_findsTwo_bindsBoth() {
        bindToUri(FIND_TWICE, "find_twice", SOME_URI).yields(URI_BOUND_TWICE);
    }

    @Test
    public void bindToUri_notFooledByExtendedName() {
        bindToUri(FIND_ONCE, "bind", SOME_URI).yields(FIND_ONCE);
    }

    @Test
    public void bindToUri_notFooledByPunctuation() {
        bindToUri(SQUEEZED, "squeeze", SOME_URI).yields(URI_BOUND_SQUEEZED);
    }

    @Test
    public void bindToPlainLiteral_notFound_noComplaint() {
        bindToPlainLiteral(FIND_ONCE, "notThere", SOME_LITERAL)
                .yields(FIND_ONCE);
    }

    @Test
    public void bindToPlainLiteral_findsOne_bindsIt() {
        bindToPlainLiteral(FIND_ONCE, "bindMe", SOME_LITERAL)
                .yields(LITERAL_BOUND_ONCE);
    }

    @Test
    public void bindToPlainLiteral_findsTwo_bindsBoth() {
        bindToPlainLiteral(FIND_TWICE, "find_twice", SOME_LITERAL)
                .yields(LITERAL_BOUND_TWICE);
    }

    @Test
    public void bindToPlainLiteral_notFooledByExtendedName() {
        bindToPlainLiteral(FIND_ONCE, "bind", SOME_LITERAL).yields(FIND_ONCE);
    }

    @Test
    public void bindToPlainLiteral_notFooledByPunctuation() {
        bindToPlainLiteral(SQUEEZED, "squeeze", SOME_LITERAL)
                .yields(LITERAL_BOUND_SQUEEZED);
    }

    @Test
    public void bindToLiteralPlain() {
        bindToLiteral(FIND_ONCE, "bindMe", createPlainLiteral(SOME_LITERAL))
                .yields(LITERAL_BOUND_ONCE);
    }

    @Test
    public void bindToLiteralTyped() {
        bindToLiteral(FIND_ONCE, "bindMe",
                createTypedLiteral(String.valueOf(SOME_INTEGER), SOME_TYPE))
                        .yields(TYPED_LITERAL_BOUND_ONCE);
    }

    @Test
    public void bindToLiteralLanguage() {
        bindToLiteral(FIND_ONCE, "bindMe",
                createLangLiteral(SOME_LITERAL, SOME_LANGUAGE))
                        .yields(LANGUAGE_LITERAL_BOUND_ONCE);
    }

    @Test
    public void variableInSelectClauseIsLeftAlone() {
        bindToUri(FIND_IN_SELECT_CLAUSE, "bindMe", SOME_URI)
                .yields(URI_BOUND_IN_SELECT_CLAUSE);
    }

    // ----------------------------------------------------------------------
    // Helper methods and classes
    // ----------------------------------------------------------------------

    private Yielder bindToUri(String query, String name, String uri) {
        QueryHolder holder = new QueryHolder(query);
        QueryHolder bound = holder.bindToUri(name, uri);
        return new Yielder(bound.getQueryString());
    }

    private Yielder bindToPlainLiteral(String query, String name,
            String value) {
        QueryHolder holder = new QueryHolder(query);
        QueryHolder bound = holder.bindToPlainLiteral(name, value);
        return new Yielder(bound.getQueryString());
    }

    private Yielder bindToLiteral(String query, String name, Literal literal) {
        QueryHolder holder = new QueryHolder(query);
        QueryHolder bound = holder.bindToLiteral(name, literal);
        return new Yielder(bound.getQueryString());
    }

    private class Yielder {
        private final String actual;

        public Yielder(String actual) {
            this.actual = actual;
        }

        void yields(String expected) {
            assertEquals(expected, actual);
        }
    }
}
