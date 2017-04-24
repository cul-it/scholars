/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.library.scholars.webapp.controller.api.distribute;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import org.apache.commons.io.FileUtils;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import com.hp.hpl.jena.rdf.model.ModelFactory;

import edu.cornell.mannlib.vitro.testing.AbstractTestClass;
import edu.cornell.mannlib.vitro.webapp.application.ApplicationUtils;
import edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributor.DataDistributorException;
import edu.cornell.library.scholars.webapp.controller.api.distribute.PatternMatchingFileDistributor.FileFinder;
import stubs.edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributorContextStub;
import stubs.edu.cornell.mannlib.vitro.webapp.modules.ApplicationStub;

/**
 * TODO
 */
public class PatternMatchingFileDistributorTest extends AbstractTestClass {

    private static final String PARAMETER_NAME = "matcher";
    private static final String EMPTY_JSON = "[]";
    private static final String FILENAME = "my.file";
    private static final String TEST_DATA = "[true, false]";

    private ApplicationStub application;
    private DataDistributorContextStub context;
    private PatternMatchingFileDistributor instance;
    private File file;
    private ByteArrayOutputStream output = new ByteArrayOutputStream();
    private StringWriter logOutput = new StringWriter();

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    @Before
    public void setupForOverallTests() throws IOException {
        ApplicationStub.setup(null, null);
        application = (ApplicationStub) ApplicationUtils.instance();
        application.setHomeDirectory(folder.getRoot());

        context = new DataDistributorContextStub(
                ModelFactory.createDefaultModel());

        instance = new PatternMatchingFileDistributor();
        instance.setParameterName(PARAMETER_NAME);
        instance.setEmptyResponse(EMPTY_JSON);

        // Standard setup for success.
        context.setParameter(PARAMETER_NAME, FILENAME);
        instance.setParameterPattern(".+");
        instance.setFilepathPattern("\\0");
        file = new File(folder.getRoot(), FILENAME);
        FileUtils.write(file, TEST_DATA);
    }

    // ----------------------------------------------------------------------
    // Overall tests
    // ----------------------------------------------------------------------

    @Test(expected = PatternSyntaxException.class)
    public void invalidRegexForParameterPattern_throwsException()
            throws DataDistributorException {
        instance.setParameterPattern("*+");
        assertExpectedOutput(EMPTY_JSON);
    }

    @Test
    public void noParameterValue_issuesWarning_returnsEmpty()
            throws DataDistributorException {
        captureLogOutput(PatternMatchingFileDistributor.class, logOutput, true);
        context.removeParameter(PARAMETER_NAME);
        assertExpectedOutput(EMPTY_JSON);
        assertTrue(logOutput.toString().contains("WARN No value provided"));
    }

    @Test
    public void noFileSoDistributeEmptyResult()
            throws DataDistributorException {
        file.delete();
        assertExpectedOutput(EMPTY_JSON);
    }

    @Test
    public void createAFileAndDistributeIt()
            throws DataDistributorException {
        assertExpectedOutput(TEST_DATA);
    }

    // ----------------------------------------------------------------------
    // FileFinder tests
    // ----------------------------------------------------------------------

    private static final Path HOME_PATH = Paths.get("/home/path");
    private FileFinder finder;

    @Test
    public void matchWithSimpleSubstitution() {
        finder = fileFinder( //
                "EntireString", // parameter value
                ".*", // parameter pattern
                "\\0" // filepath pattern
        );
        assertEquals(HOME_PATH + "/EntireString", finder.find().toString());
    }

    @Test
    public void noMatch_issuesWarning_returnsNull() {
        captureLogOutput(PatternMatchingFileDistributor.class, logOutput, true);
        finder = fileFinder( //
                "NoMatch", // parameter value
                "DoesntMatch", // parameter pattern
                "\\0" // filepath pattern
        );
        assertNull(finder.find());
        assertTrue(logOutput.toString().contains("WARN Failed to parse"));

    }

    @Test
    public void PatternMatchesPartOfTheValue() {
        finder = fileFinder( //
                "PartialMatch", // parameter value
                "Match", // parameter pattern
                "\\0" // filepath pattern
        );
        assertEquals(HOME_PATH + "/Match", finder.find().toString());
    }

    @Test
    public void matchWithMultipleGroups() {
        finder = fileFinder( //
                "http://complicated/pattern.match", // parameter value
                "//(.*)/(.*)\\.(.*)$", // parameter pattern
                "extension-\\3, filename-\\2, host-\\1" // filepath pattern
        );
        assertEquals(
                HOME_PATH
                        + "/extension-match, filename-pattern, host-complicated",
                finder.find().toString());
    }

    // ----------------------------------------------------------------------
    // Helper methods
    // ----------------------------------------------------------------------

    private void assertExpectedOutput(String expected)
            throws DataDistributorException {
        instance.init(context);
        instance.writeOutput(output);
        assertEquals(expected, output.toString());
    }

    private FileFinder fileFinder(String parameterValue,
            String parameterPattern, String filepathPattern) {
        Map<String, String[]> parameters = new HashMap<>();
        parameters.put(PARAMETER_NAME, new String[] { parameterValue });
        Pattern parameterParser = Pattern.compile(parameterPattern);
        return new FileFinder(parameters, PARAMETER_NAME, parameterParser,
                filepathPattern, HOME_PATH);
    }
}
