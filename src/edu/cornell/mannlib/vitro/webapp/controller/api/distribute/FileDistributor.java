/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

import edu.cornell.mannlib.vitro.webapp.application.ApplicationUtils;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Validation;

/**
 * TODO
 */
public class FileDistributor extends RdfDistributorBase {
	private static final Log log = LogFactory.getLog(FileDistributor.class);
	
	

	/** The name of the action request that we are responding to. */
	private String actionName;

	/** The path to the data file, relative to the Vitro home directory. */
	private String datapath;

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

	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#path")
	public void setPath(String path) {
		if (datapath == null) {
			datapath = path;
		} else {
			throw new IllegalStateException(
					"Configuration includes multiple instances of datapath: "
							+ datapath + ", and " + path);
		}
	}

	@Validation
	public void validate() {
		if (actionName == null) {
			throw new IllegalStateException(
					"Configuration contains no action name for "
							+ this.getClass().getSimpleName());
		}
		if (datapath == null) {
			throw new IllegalStateException(
					"Configuration contains no data path for "
							+ this.getClass().getSimpleName());
		}
	}

	@Override
	public String getActionName() {
		return actionName;
	}

	/**
	 * Right now, this assumes a file of TTL and returns a model. Generalize it.
	 */
	@Override
	public Model execute(Map<String, String[]> parameters)
			throws RdfDistributorException {
		Path home = ApplicationUtils.instance().getHomeDirectory().getPath();
		log.debug("home directory is at: " + home);
		Path datafile = home.resolve(datapath);
		try (InputStream stream = Files.newInputStream(datafile)) {
			Model model = ModelFactory.createDefaultModel();
			model.read(stream, null, "TTL");
			return model;
		} catch (IOException e) {
			throw new ActionFailedException(e);
		}
	}

}
