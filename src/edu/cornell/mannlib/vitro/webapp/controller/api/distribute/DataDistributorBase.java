/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.util.Map;

import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Validation;

/**
 * Build your DataDistributors on top of this.
 */
public abstract class DataDistributorBase implements DataDistributor {
	/** The name of the action request that we are responding to. */
	protected String actionName;
	protected Map<String, String[]> parameters;

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#actionName")
	public void setActionName(String action) {
		if (actionName == null) {
			actionName = action;
		} else {
			throw new IllegalStateException(
					"Configuration includes multiple instances of actionName: "
							+ actionName + ", and " + action);
		}
	}

	@Validation
	public void validateActionName() {
		if (actionName == null) {
			throw new IllegalStateException(
					"Configuration contains no action name for "
							+ this.getClass().getSimpleName());
		}
	}

	@Override
	public void init(Map<String, String[]> requestParameters)
			throws DataDistributorException {
		this.parameters = requestParameters;
	}

	@Override
	public String getActionName() {
		return actionName;
	}
}
