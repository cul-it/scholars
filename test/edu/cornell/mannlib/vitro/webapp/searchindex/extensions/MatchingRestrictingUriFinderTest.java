/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.searchindex.extensions;

import static com.hp.hpl.jena.rdf.model.ResourceFactory.createPlainLiteral;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createProperty;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createResource;
import static com.hp.hpl.jena.rdf.model.ResourceFactory.createStatement;
import static edu.cornell.mannlib.vitro.testing.ModelUtilitiesTestHelper.model;
import static edu.cornell.mannlib.vitro.webapp.modelaccess.ModelAccess.WhichService.CONTENT;
import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThat;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.vocabulary.RDF;

import edu.cornell.mannlib.vitro.testing.AbstractTestClass;
import edu.cornell.mannlib.vitro.webapp.rdfservice.impl.jena.model.RDFServiceModel;
import edu.cornell.mannlib.vitro.webapp.searchindex.extensions.StatementPatternParser.PatternException;
import stubs.edu.cornell.mannlib.vitro.webapp.modelaccess.ContextModelAccessStub;

/**
 * TODO
 */
public class MatchingRestrictingUriFinderTest extends AbstractTestClass {
    private static final String LABEL = "UriFinder label";
    private static final Resource SUBJECT_1 = createResource(
            "http://test/subject1");
    private static final Property PREDICATE_1 = createProperty(
            "http://test/predicate1");
    private static final Property PREDICATE_2 = createProperty(
            "http://test/predicate2");
    private static final Resource OBJECT_1 = createResource(
            "http://test/object1");
    private static final Resource TYPE_1 = createResource("http://test/type1");
    private static final Literal LITERAL_1 = createPlainLiteral(
            "a literal value.");
    private static final Resource UNKNOWN_RESOURCE = createResource(
            "http://test/unknown");

    private static final String EASY_RESTRICTION = "ASK {?s ?p ?o}";
    private static final String SUBJECT_RESTRICTION = String
            .format("ASK {<%s> ?p ?o}", SUBJECT_1);
    private static final String SUBJECT_BINDING_RESTRICTION = String
            .format("ASK {?subject <%s> <%s>}", PREDICATE_2, OBJECT_1);
    private static final String PREDICATE_BINDING_RESTRICTION = String
            .format("ASK {<%s> ?predicate <%s>}", SUBJECT_1, OBJECT_1);
    private static final String OBJECT_BINDING_RESTRICTION = String
            .format("ASK {<%s> <%s> ?object}", SUBJECT_1, PREDICATE_2);
    private static final String FAILING_RESTRICTION = String
            .format("ASK {<%s> ?p ?o}", UNKNOWN_RESOURCE);

    private static final String SELECT_SUBJECTS = "SELECT ?s WHERE { ?s ?p ?o }";
    private static final String SELECT_PREDICATES = "SELECT ?p WHERE { ?s ?p ?o }";
    private static final String SELECT_OBJECT_FROM_BOUND_PREDICATE = "SELECT ?o WHERE { ?s ?predicate ?o }";

    private MatchingRestrictingUriFinder finder;
    private List<String> uris;

    @Before
    public void setup() {
        Model model = model(createStatement(SUBJECT_1, RDF.type, TYPE_1),
                createStatement(SUBJECT_1, PREDICATE_1, LITERAL_1),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        RDFServiceModel rdfService = new RDFServiceModel(model);
        ContextModelAccessStub models = new ContextModelAccessStub();
        models.setRDFService(CONTENT, rdfService);

        finder = new MatchingRestrictingUriFinder();
        finder.setContextModels(models);
    }

    // ----------------------------------------------------------------------
    // Tests on label
    // ----------------------------------------------------------------------

    @Test
    public void labelAppearsInToString() {
        finder.setLabel(LABEL);
        assertEquals(LABEL, finder.toString());
    }

    @Test
    public void noLabel_generatesOne() {
        assertThat(finder.toString(), containsString(
                MatchingRestrictingUriFinder.class.getSimpleName()));
    }

    // ----------------------------------------------------------------------
    // Tests on matchers
    // ----------------------------------------------------------------------

    @Test(expected = PatternException.class)
    public void matcherNotValidSyntax_throwsExceptionDuringInit() {
        finder.addMatcher("BOGUS");
    }

    @Test
    public void noMatcher_succeeds() {
        findUris(matchers(), restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_1, LITERAL_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherObjectProperty_succeeds() {
        findUris(matchers(opMatcher(SUBJECT_1, PREDICATE_2, OBJECT_1)),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherDataProperty_succeeds() {
        findUris(matchers(dpMatcher(SUBJECT_1, PREDICATE_1, LITERAL_1)),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_1, LITERAL_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherTypeStatement_succeeds() {
        findUris(matchers(opMatcher(SUBJECT_1, RDF.type, TYPE_1)),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, RDF.type, TYPE_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherSubjectWildcard_succeeds() {
        findUris(
                matchers(funkyMatcher("?s", uriString(PREDICATE_2),
                        uriString(OBJECT_1))),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherPredicateWildcard_succeeds() {
        findUris(
                matchers(funkyMatcher(uriString(SUBJECT_1), "?p",
                        uriString(OBJECT_1))),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherObjectWildcard_succeeds() {
        findUris(
                matchers(funkyMatcher(uriString(SUBJECT_1),
                        uriString(PREDICATE_2), "?o")),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void matcherDoesntMatch_returnsNothing() {
        findUris(matchers(opMatcher(SUBJECT_1, PREDICATE_1, OBJECT_1)),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(0, uris.size());
    }

    @Test
    public void twoMatchers_secondMatches_succeeds() {
        findUris(
                matchers(dpMatcher(SUBJECT_1, PREDICATE_1, LITERAL_1),
                        opMatcher(SUBJECT_1, PREDICATE_2, OBJECT_1)),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void twoMatchers_neitherMatches_returnsNothing() {
        findUris(
                matchers(dpMatcher(SUBJECT_1, PREDICATE_1, LITERAL_1),
                        opMatcher(SUBJECT_1, PREDICATE_1, OBJECT_1)),
                restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(0, uris.size());
    }

    // ----------------------------------------------------------------------
    // Tests on restrictions
    // ----------------------------------------------------------------------

    @Test
    public void restrictionNotValidSyntax_throwsExceptionDuringInit() {
        expectException(IllegalArgumentException.class,
                "restriction is invalid");
        finder.addRestriction("ASK {?s ?o ?p ."); // no closing brace
    }

    @Test
    public void noRestrictions_succeeds() {
        findUris(matchers(), restrictions(), queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_1, LITERAL_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void easyRestriction_passes_succeeds() {
        findUris(matchers(), restrictions(EASY_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void subjectRestriction_passes_succeeds() {
        findUris(matchers(), restrictions(SUBJECT_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void subjectBindingRestriction_passes_succeeds() {
        findUris(matchers(), restrictions(SUBJECT_BINDING_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void predicateBindingRestriction_passes_succeeds() {
        findUris(matchers(), restrictions(PREDICATE_BINDING_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void objectBindingRestriction_passes_succeeds() {
        findUris(matchers(), restrictions(OBJECT_BINDING_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void restrictionDoesNotPass_returnsNothing() {
        findUris(matchers(), restrictions(FAILING_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(0, uris.size());
    }

    @Test
    public void twoRestrictions_secondPasses_succeeds() {
        findUris(matchers(),
                restrictions(FAILING_RESTRICTION, EASY_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_2, OBJECT_1));
        assertEquals(1, uris.size());
    }

    @Test
    public void twoRestrictions_neitherPasses_returnsNothing() {
        findUris(matchers(),
                restrictions(FAILING_RESTRICTION, SUBJECT_BINDING_RESTRICTION),
                queries(SELECT_SUBJECTS),
                createStatement(UNKNOWN_RESOURCE, PREDICATE_2, OBJECT_1));
        assertEquals(0, uris.size());
    }

    // ----------------------------------------------------------------------
    // Tests on select
    // ----------------------------------------------------------------------

    @Test
    public void selectQueryNotValidSyntax_throwsExceptionDuringInit() {
        expectException(IllegalArgumentException.class, "query is invalid");
        finder.addQuery("SELECT ? WHERE {?s ?o ?p ."); // no closing brace
    }

    @Test
    public void oneQuery_succeeds() {
        findUris(matchers(), restrictions(), queries(SELECT_PREDICATES),
                createStatement(SUBJECT_1, PREDICATE_1, LITERAL_1));
        assertEquals(
                new HashSet<>(Arrays.asList(PREDICATE_1.getURI(),
                        PREDICATE_2.getURI(), RDF.type.getURI())),
                new HashSet<>(uris));
    }

    @Test
    public void twoQueries_succeeds() {
        findUris(matchers(), restrictions(),
                queries(SELECT_PREDICATES, SELECT_SUBJECTS),
                createStatement(SUBJECT_1, PREDICATE_1, LITERAL_1));
        assertEquals(
                new HashSet<>(
                        Arrays.asList(SUBJECT_1.getURI(), PREDICATE_1.getURI(),
                                PREDICATE_2.getURI(), RDF.type.getURI())),
                new HashSet<>(uris));
    }

    @Test
    public void predicateBindingSeletQuery_succeeds() {
        findUris(matchers(), restrictions(),
                queries(SELECT_OBJECT_FROM_BOUND_PREDICATE),
                createStatement(SUBJECT_1, RDF.type, LITERAL_1));
        assertEquals(
                Collections.singleton(TYPE_1.getURI()),
                new HashSet<>(uris));
    }

    // ----------------------------------------------------------------------
    // helper methods
    // ----------------------------------------------------------------------

    private String opMatcher(Resource s, Property p, Resource o) {
        return String.format("<%s> <%s> <%s>", s, p, o);
    }

    private String dpMatcher(Resource s, Property p, Literal o) {
        return String.format("<%s> <%s> \"%s\"", s, p, o);
    }

    private String funkyMatcher(String s, String p, String o) {
        return String.format("%s %s %s", s, p, o);
    }

    private String uriString(Resource resource) {
        return "<" + resource + ">";
    }

    private List<String> matchers(String... matchers) {
        return Arrays.asList(matchers);
    }

    private List<String> restrictions(String... restrictions) {
        return Arrays.asList(restrictions);
    }

    private List<String> queries(String... queries) {
        return Arrays.asList(queries);
    }

    private void findUris(List<String> matchers, List<String> restrictions,
            List<String> queries, Statement stmt) {
        for (String m : matchers) {
            finder.addMatcher(m);
        }
        for (String r : restrictions) {
            finder.addRestriction(r);
        }
        for (String q : queries) {
            finder.addQuery(q);
        }
        uris = finder.findAdditionalURIsToIndex(stmt);
    }

}
