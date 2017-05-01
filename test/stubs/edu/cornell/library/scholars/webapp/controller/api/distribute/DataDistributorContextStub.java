/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package stubs.edu.cornell.library.scholars.webapp.controller.api.distribute;

import java.util.HashMap;
import java.util.Map;

import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.auth.requestedAction.AuthorizationRequest;
import edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributorContext;
import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import edu.cornell.mannlib.vitro.webapp.rdfservice.impl.jena.model.RDFServiceModel;
import stubs.edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccessStub;

/**
 * A minimal implementation. Additional tests may want to set more values into
 * the RequestModelAccessStub.
 */
public class DataDistributorContextStub implements DataDistributorContext {
	// ----------------------------------------------------------------------
    // Stub infrastructure
    // ----------------------------------------------------------------------

    private final RequestModelAccessStub models = new RequestModelAccessStub();
    private Map<String, String[]> parameters = new HashMap<>();

    public DataDistributorContextStub(Model model) {
        models.setRDFService(new RDFServiceModel(model));
    }

    public void setParameter(String name, String value) {
        parameters.put(name, new String[]{value});
    }

    public void removeParameter(String name) {
        parameters.remove(name);
    }

    // ----------------------------------------------------------------------
    // Stub methods
    // ----------------------------------------------------------------------

    @Override
    public Map<String, String[]> getRequestParameters() {
        return parameters;
    }

    @Override
    public RequestModelAccess getRequestModels() {
        return models;
    }

    @Override
    public boolean isAuthorized(AuthorizationRequest ar) {
        return true;
    }

    // ----------------------------------------------------------------------
    // Un-implemented methods
    // ----------------------------------------------------------------------

}
