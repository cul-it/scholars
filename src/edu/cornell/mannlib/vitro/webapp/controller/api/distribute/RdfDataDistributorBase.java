/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.io.OutputStream;
import java.util.Map;

import com.hp.hpl.jena.rdf.model.Model;

/**
 * What the RDF distributors have in common.
 * 
 * Perhaps in a later implementation, this could allow the user to request other
 * forms instead of Turtle.
 */
public abstract class RdfDataDistributorBase extends DataDistributorBase {
	protected abstract Model execute() throws DataDistributorException;

	@Override
	public String getContentType() throws DataDistributorException {
		return "text/turtle";
	}

	@Override
	public void writeOutput(OutputStream output)
			throws DataDistributorException {
		execute().write(output, "TTL");
	}

}
