/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.library.scholars.webapp.controller.api.distribute.modelbuilder;

import static edu.cornell.mannlib.vitro.testing.ModelUtilitiesTestHelper.model;
import static edu.cornell.mannlib.vitro.testing.ModelUtilitiesTestHelper.objectProperty;
import static edu.cornell.mannlib.vitro.testing.ModelUtilitiesTestHelper.typeStatement;
import static edu.cornell.library.scholars.webapp.controller.api.distribute.modelbuilder.DrillDownModelBuilderTest.MethodName.BUILD_MODEL;
import static edu.cornell.library.scholars.webapp.controller.api.distribute.modelbuilder.DrillDownModelBuilderTest.MethodName.CLOSE;
import static edu.cornell.library.scholars.webapp.controller.api.distribute.modelbuilder.DrillDownModelBuilderTest.MethodName.INIT;
import static edu.cornell.library.scholars.webapp.controller.api.distribute.modelbuilder.DrillDownModelBuilderTest.MethodName.RESET;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.Before;
import org.junit.Test;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Statement;

import edu.cornell.mannlib.vitro.testing.AbstractTestClass;
import edu.cornell.mannlib.vitro.webapp.auth.requestedAction.AuthorizationRequest;
import edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributor.DataDistributorException;
import edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributorContext;
import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import stubs.edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccessStub;

/**
 * TODO
 */
public class DrillDownModelBuilderTest extends AbstractTestClass {
    public enum MethodName {
        INIT, BUILD_MODEL, CLOSE, RESET
    }

    private static final String SUBJECT_1_URI = "http://test/subject1";
    private static final String SUBJECT_2_URI = "http://test/subject2";
    private static final String TYPE_URI = "http://test/type";
    private static final String PREDICATE_URI = "http://test/predicate";
    private static final String OBJECT_1_URI = "http://test/object1";
    private static final String OBJECT_2_URI = "http://test/object2";
    private static final String SELECT_1_VALUE = "SELECT ?subject WHERE {?subject a ?type}";
    private static final String SELECT_2_VALUES = "SELECT ?subject ?type WHERE {?subject a ?type}";
    private static final String INVALID_SELECT = "SELECT ?subject WHERE ?subject a ?type}";
    private static final String PARAMETER_NAME = "ParameterName";
    private static final String PARAMETER_VALUE = "ParameterValue";

    private static final List<MethodName> PLAIN_CALLING_SEQUENCE = Arrays
            .asList(INIT, BUILD_MODEL, CLOSE);
    private static final List<MethodName> RESET_CALLING_SEQUENCE = Arrays
            .asList(INIT, BUILD_MODEL, CLOSE, RESET);
    private static final List<MethodName> INTERRUPTED_CALLING_SEQUENCE = Arrays
            .asList(INIT, BUILD_MODEL, CLOSE);
    private static final List<Object> NOT_CALLED = Collections.emptyList();

    private DrillDownModelBuilder instance;
    private RecordingMockModelBuilder topLevel;
    private RecordingMockModelBuilder bottomLevel;
    private RequestModelAccessStub models;
    private DataDistributorContext ddc;

    @Before
    public void setup() {
        topLevel = new RecordingMockModelBuilder();
        bottomLevel = new RecordingMockModelBuilder();

        instance = new DrillDownModelBuilder();
        instance.addTopLevelModelBuilder(topLevel);
        instance.addBottomLevelModelBuilder(bottomLevel);

        models = new RequestModelAccessStub();
        ddc = new MockDataDistributorContext(models,
                parameter(PARAMETER_NAME, PARAMETER_VALUE));

    }
    // ----------------------------------------------------------------------
    // The tests
    // ----------------------------------------------------------------------

    @Test
    public void simpleSuccess_checkEverything()
            throws DataDistributorException {
        topLevel.setResponseStatements(typeStatement(SUBJECT_1_URI, TYPE_URI));
        bottomLevel.setResponseStatements(
                objectProperty(SUBJECT_1_URI, PREDICATE_URI, OBJECT_1_URI));

        Model model = executeDrillDown(SELECT_1_VALUE);

        assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
        assertEquals(RESET_CALLING_SEQUENCE, bottomLevel.getCallSequence());
        assertRequestParameters(bottomLevel,
                parameter(PARAMETER_NAME, PARAMETER_VALUE),
                parameter("subject", SUBJECT_1_URI));
        assertSame(models, bottomLevel.getContext().getRequestModels());
        assertEquivalentModels(model(typeStatement(SUBJECT_1_URI, TYPE_URI),
                objectProperty(SUBJECT_1_URI, PREDICATE_URI, OBJECT_1_URI)),
                model);
    }

    @Test
    public void sparqlReturnsTwoValues() throws DataDistributorException {
        topLevel.setResponseStatements(typeStatement(SUBJECT_1_URI, TYPE_URI));

        executeDrillDown(SELECT_2_VALUES);

        assertRequestParameters(bottomLevel,
                parameter(PARAMETER_NAME, PARAMETER_VALUE),
                parameter("subject", SUBJECT_1_URI),
                parameter("type", TYPE_URI));
    }

    @Test
    public void sparqlReturnsNoRows() throws DataDistributorException {
        Model model = executeDrillDown(SELECT_1_VALUE);

        assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
        assertEquals(NOT_CALLED, bottomLevel.getCallSequence());
        assertEquivalentModels(model(), model);
    }

    @Test
    public void sparqlReturnsTwoRows() throws DataDistributorException {
        topLevel.setResponseStatements(typeStatement(SUBJECT_1_URI, TYPE_URI),
                typeStatement(SUBJECT_2_URI, TYPE_URI));
        List<MethodName> bottomCalls = new ArrayList<>(RESET_CALLING_SEQUENCE);
        bottomCalls.addAll(RESET_CALLING_SEQUENCE);

        executeDrillDown(SELECT_1_VALUE);

        assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
        assertEquals(bottomCalls, bottomLevel.getCallSequence());
    }
    
    @Test
    public void twoBottomLevelBuilders() throws DataDistributorException {
        RecordingMockModelBuilder bottomLevel2 = new RecordingMockModelBuilder();
        instance.addBottomLevelModelBuilder(bottomLevel2);

        topLevel.setResponseStatements(typeStatement(SUBJECT_1_URI, TYPE_URI));
        bottomLevel.setResponseStatements(
                objectProperty(SUBJECT_1_URI, PREDICATE_URI, OBJECT_1_URI));
        bottomLevel2.setResponseStatements(
                objectProperty(SUBJECT_1_URI, PREDICATE_URI, OBJECT_2_URI));

        Model model = executeDrillDown(SELECT_1_VALUE);

        assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
        assertEquals(RESET_CALLING_SEQUENCE, bottomLevel.getCallSequence());
        assertEquals(RESET_CALLING_SEQUENCE, bottomLevel2.getCallSequence());
        assertEquivalentModels(model(typeStatement(SUBJECT_1_URI, TYPE_URI),
                objectProperty(SUBJECT_1_URI, PREDICATE_URI, OBJECT_1_URI),
                objectProperty(SUBJECT_1_URI, PREDICATE_URI, OBJECT_2_URI)),
                model);
    }

    @Test
    public void invalidSelectQuery_returnsNoRows_logsError()
            throws DataDistributorException {
        StringWriter logOutput = new StringWriter();
        captureLogOutput(
                "edu.cornell.mannlib.vitro.webapp.utils.sparqlrunner.ModelSelectQueryContext",
                logOutput, true);

        executeDrillDown(INVALID_SELECT);

        assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
        assertEquals(NOT_CALLED, bottomLevel.getCallSequence());
        assertTrue(
                logOutput.toString().contains("problem while running query"));
    }

    @Test
    public void topLevelThrowsException_throwsException() {
        try {
            topLevel.setThrowsException(true);
            executeDrillDown(SELECT_1_VALUE);
            fail("Expected a DataDistributionException");
        } catch (DataDistributorException e) {
            assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
            assertEquals(NOT_CALLED, bottomLevel.getCallSequence());
        }
    }

    @Test
    public void bottomLevelThrowsException_throwsException() {
        try {
            topLevel.setResponseStatements(
                    typeStatement(SUBJECT_1_URI, TYPE_URI));
            bottomLevel.setThrowsException(true);
            executeDrillDown(SELECT_1_VALUE);
            fail("Expected a DataDistributionException");
        } catch (DataDistributorException e) {
            assertEquals(PLAIN_CALLING_SEQUENCE, topLevel.getCallSequence());
            assertEquals(INTERRUPTED_CALLING_SEQUENCE,
                    bottomLevel.getCallSequence());
        }

    }

    // ----------------------------------------------------------------------
    // Helper methods
    // ----------------------------------------------------------------------

    private Parameter parameter(String name, String... values) {
        return new Parameter(name, values);
    }

    private Model executeDrillDown(String selectQuery)
            throws DataDistributorException {
        try {
            instance.setDrillDownQuery(selectQuery);
            instance.init(ddc);
            return instance.buildModel();
        } finally {
            instance.close();
        }
    }

    private void assertEquivalentModels(Model expected, Model actual) {
        Set<Statement> expectedStmts = expected.listStatements().toSet();
        Set<Statement> actualStmts = actual.listStatements().toSet();
        assertEquals(expectedStmts, actualStmts);
    }

    private void assertRequestParameters(RecordingMockModelBuilder mb,
            Parameter... expected) {
        assertEquals(new ParameterLists(expected),
                new ParameterLists(mb.getContext().getRequestParameters()));
    }

    // ----------------------------------------------------------------------
    // Helper classes
    // ----------------------------------------------------------------------

    private static class RecordingMockModelBuilder
            implements ResettableModelBuilder {
        private List<MethodName> callSequence = new ArrayList<>();
        private Model responseModel = ModelFactory.createDefaultModel();
        private DataDistributorContext context;
        private boolean throwsException;

        public void setResponseStatements(Statement... statements) {
            responseModel = ModelFactory.createDefaultModel().add(statements);
        }

        public void setThrowsException(boolean throwsException) {
            this.throwsException = throwsException;
        }

        @Override
        public void init(DataDistributorContext ddContext)
                throws DataDistributorException {
            callSequence.add(INIT);
            context = ddContext;
        }

        @Override
        public Model buildModel() throws DataDistributorException {
            callSequence.add(BUILD_MODEL);
            if (throwsException) {
                throw new DataDistributorException("Forced exception");
            } else {
                return responseModel;
            }
        }

        @Override
        public void close() {
            callSequence.add(CLOSE);
        }

        @Override
        public void reset() {
            callSequence.add(RESET);
        }

        public List<MethodName> getCallSequence() {
            return callSequence;
        }

        public DataDistributorContext getContext() {
            return context;
        }

    }

    private static class MockDataDistributorContext
            implements DataDistributorContext {
        private final RequestModelAccess models;
        private final ParameterLists parameterMap;

        public MockDataDistributorContext(RequestModelAccess models,
                Parameter... parameters) {
            this.models = models;
            this.parameterMap = new ParameterLists(parameters);
        }

        @Override
        public Map<String, String[]> getRequestParameters() {
            return parameterMap.asArrays();
        }

        @Override
        public RequestModelAccess getRequestModels() {
            return models;
        }

        @Override
        public boolean isAuthorized(AuthorizationRequest ar) {
            throw new RuntimeException(
                    "DataDistributorContext.isAuthorized() not implemented.");

        }

    }

    private static class Parameter {
        private final String name;
        private final String[] values;

        public Parameter(String name, String... values) {
            this.name = name;
            this.values = values;
        }

        public String getName() {
            return name;
        }

        public String[] getValues() {
            return values;
        }
    }

    private static class ParameterLists {
        private Map<String, List<String>> lists = new HashMap<>();
        private Map<String, String[]> arrays = new HashMap<>();

        public ParameterLists(Map<String, String[]> map) {
            for (String key : map.keySet()) {
                lists.put(key, Arrays.asList(map.get(key)));
                arrays.put(key, map.get(key));
            }
        }

        public ParameterLists(Parameter... parameters) {
            for (Parameter p : parameters) {
                lists.put(p.getName(), Arrays.asList(p.getValues()));
                arrays.put(p.getName(), p.getValues());
            }
        }

        public Map<String, String[]> asArrays() {
            return arrays;
        }

        @Override
        public int hashCode() {
            return lists.hashCode();
        }

        @Override
        public boolean equals(Object obj) {
            return lists.equals(((ParameterLists) obj).lists);
        }

        @Override
        public String toString() {
            return lists.toString();
        }
    }
}
