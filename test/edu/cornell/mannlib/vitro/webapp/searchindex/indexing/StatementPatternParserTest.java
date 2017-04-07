/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.searchindex.indexing;

import static com.hp.hpl.jena.rdf.model.ResourceFactory.*;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createProperty;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createResource;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import org.junit.Test;

import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Selector;
import com.hp.hpl.jena.rdf.model.SimpleSelector;
import com.hp.hpl.jena.vocabulary.RDF;

import edu.cornell.mannlib.vitro.testing.AbstractTestClass;
import edu.cornell.mannlib.vitro.webapp.searchindex.indexing.StatementPatternParser.PatternException;

/**
 * TODO
 */
public class StatementPatternParserTest extends AbstractTestClass {
    private static final Resource SUBJECT = createResource(
            "http://test/subject");
    private static final Property PREDICATE = createProperty(
            "http://test/predicate");
    private static final Resource OBJECT = createResource("http://test/object");
    private static final Literal PLAIN_LITERAL = createPlainLiteral(
            "plain literal");
    private static final Literal TYPED_LITERAL = createTypedLiteral(
            "typedLiteral", XSDDatatype.XSDName);
    private static final Literal LANG_LITERAL = createLangLiteral("langLiteral",
            "en");

    @Test
    public void nullString_throwsException() {
        expectException(PatternException.class, "pattern may not be null");
        assertExpectedSelector(new SimpleSelector(), null);
    }

    @Test
    public void emptyString_throwsException() {
        expectException(PatternException.class, "may not be empty");
        assertExpectedSelector(new SimpleSelector(), "");
    }

    @Test
    public void notEnoughParts_throwsException() {
        expectException(PatternException.class, "invalid",
                IllegalArgumentException.class, "must be in three parts");
        assertExpectedSelector(new SimpleSelector(), "this that");
    }

    @Test
    public void allVariables() {
        assertExpectedSelector(new SimpleSelector(), "?s ?p ?o");
    }

    @Test
    public void subjectIsUri() {
        assertExpectedSelector(
                new SimpleSelector(SUBJECT, null, (RDFNode) null),
                format("<%s> ?p ?o", SUBJECT.getURI()));
    }

    @Test
    public void invalidSubject_throwsException() {
        expectException(PatternException.class, "invalid",
                PatternException.class, "URI or a variable");
        assertExpectedSelector(
                new SimpleSelector(SUBJECT, null, (RDFNode) null),
                format("<<%s> ?p ?o", SUBJECT.getURI()));
    }

    @Test
    public void predicateIsUri() {
        assertExpectedSelector(
                new SimpleSelector(null, PREDICATE, (RDFNode) null),
                format("?s <%s> ?o", PREDICATE.getURI()));
    }

    @Test
    public void predicateIsA() {
        assertExpectedSelector(
                new SimpleSelector(null, RDF.type, (RDFNode) null),
                format("?s a ?o"));
    }

    @Test
    public void invalidPredicate_throwsException() {
        expectException(PatternException.class, "invalid",
                PatternException.class, "URI or a variable");
        assertExpectedSelector(new SimpleSelector(null, null, (RDFNode) null),
                format("?s <someStuff>XX ?o"));
    }

    @Test
    public void objectIsUri() {
        assertExpectedSelector(new SimpleSelector(null, null, OBJECT),
                format("?s ?p <%s>", OBJECT.getURI()));
    }

    @Test
    public void objectIsPlainLiteral() {
        assertExpectedSelector(new SimpleSelector(null, null, PLAIN_LITERAL),
                format("?s ?p \"%s\"", PLAIN_LITERAL));
    }

    @Test
    public void objectIsTypedLiteral() {
        assertExpectedSelector(new SimpleSelector(null, null, TYPED_LITERAL),
                format("?s ?p \"%s\"^^<%s>", TYPED_LITERAL.getLexicalForm(),
                        TYPED_LITERAL.getDatatypeURI()));
    }

    @Test
    public void objectIsLangLiteral() {
        assertExpectedSelector(new SimpleSelector(null, null, LANG_LITERAL),
                format("?s ?p \"%s\"@%s", LANG_LITERAL.getLexicalForm(),
                        LANG_LITERAL.getLanguage()));
    }

    @Test
    public void invalidObject_throwsException() {
        expectException(PatternException.class, "invalid",
                PatternException.class, "URI or a Literal or a variable");
        assertExpectedSelector(new SimpleSelector(null, null, (RDFNode) null),
                format("?s ?p <someStuff>@"));
    }

    /**
     * Test plan
     * 
     * <pre>
     * More than 3 parts without quotes
     * typed literal
     * plain literal
     * lang literal
     * URI in each position
     * Variable in each position.
     * "a" as a predicate
     * variables in any or all places
     * funky syntax errors?
     * </pre>
     */

    // ----------------------------------------------------------------------
    // helper methods
    // ----------------------------------------------------------------------

    private void assertExpectedSelector(SimpleSelector expected,
            String pattern) {
        Selector actual = new StatementPatternParser(pattern).selector();

        assertEquals(formatSelector(expected), formatSelector(actual));
    }

    private String format(String format, Object... args) {
        return String.format(format, args);
    }

    private String formatSelector(Selector s) {
        return String.format("Selector[%s %s %s]", s.getSubject(),
                s.getPredicate(), s.getObject());
    }

}
