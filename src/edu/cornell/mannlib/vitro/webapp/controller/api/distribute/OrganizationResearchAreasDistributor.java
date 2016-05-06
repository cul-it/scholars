/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

import javax.servlet.ServletContext;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.ServletContextUser;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Validation;

/**
 * TODO
 */
public class OrganizationResearchAreasDistributor extends RdfDistributorBase
		implements ServletContextUser {
	public static final String FILE_OF_FAKE_DATA = "/WEB-INF/resources/fake_organization_research_areas.ttl";

	/** The name of the action request that we are responding to. */
	private String actionName;

	/** The context, so we can find a file of fake data. */
	private ServletContext ctx;

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
	public void validate() {
		if (actionName == null) {
			throw new IllegalStateException(
					"Configuration contains no action name for "
							+ this.getClass().getSimpleName());
		}
	}

	@Override
	public void setServletContext(ServletContext ctx) {
		this.ctx = ctx;
	}

	@Override
	public String getActionName() {
		return actionName;
	}

	/**
	 * fake_organization_research_areas.ttl
	 */
	@Override
	public Model execute(Map<String, String[]> parameters)
			throws RdfDistributorException {
		InputStream stream = ctx.getResourceAsStream(FILE_OF_FAKE_DATA);
		if (stream == null) {
			throw new ActionFailedException("The fake data file "
					+ "doesn't exist in the servlet context: '"
					+ FILE_OF_FAKE_DATA + "'");
		}

		Model model = ModelFactory.createDefaultModel();
		model.read(stream, null, "TTL");
		try {
			stream.close();
		} catch (IOException e) {
			throw new ActionFailedException(e);
		}
		return model;
	}

}
