/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.util.Map;

import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.mannlib.vitro.webapp.utils.configuration.Property;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.Validation;

/**
 * TODO
 */
public abstract class RdfDistributorBase implements RdfDistributor {
//	private String actionName;
//
//	@Override
//	public String getActionName() {
//		// TODO Auto-generated method stub
//		throw new RuntimeException("RdfDistributorBase.getActionName() not implemented.");
//		
//	}
//
//	@Property(uri = "http://www.w3.org/2000/01/rdf-schema#label")
//	public void setLabel(String l) {
//		label = l;
//	}
//
//	@Property(uri = "http://vitro.mannlib.cornell.edu/ns/vitro/ApplicationSetup#hasSelectQuery")
//	public void addQuery(String query) {
//		queries.add(query);
//	}
//
//	@Validation
//	public void validate() {
//		if (label == null) {
//			label = this.getClass().getSimpleName() + ":" + this.hashCode();
//		}
//		if (queries.isEmpty()) {
//			throw new IllegalStateException(
//					"Configuration contains no queries for " + label);
//		}
//	}
//
//
//	@Override
//	public Model execute(Map<String, String[]> parameters)
//			throws NotAuthorizedException, MissingParametersException {
//		// TODO Auto-generated method stub
//		throw new RuntimeException("RdfDistributorBase.execute() not implemented.");
//		
//	}
//
}
