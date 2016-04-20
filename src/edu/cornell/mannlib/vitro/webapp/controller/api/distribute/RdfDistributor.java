/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import java.util.Map;

import com.hp.hpl.jena.rdf.model.Model;

/**
 * TODO
 */
public interface RdfDistributor {
	String getActionName();

	Model execute(Map<String, String[]> parameters)
			throws NotAuthorizedException, MissingParametersException;

	public class NotAuthorizedException extends Exception {
		public NotAuthorizedException() {
			super();
		}

		public NotAuthorizedException(String message) {
			super(message);
		}

		public NotAuthorizedException(Throwable cause) {
			super(cause);
		}

		public NotAuthorizedException(String message, Throwable cause) {
			super(message, cause);
		}
	}

	public class MissingParametersException extends Exception {
		public MissingParametersException() {
			super();
		}

		public MissingParametersException(String message) {
			super(message);
		}

		public MissingParametersException(Throwable cause) {
			super(cause);
		}

		public MissingParametersException(String message, Throwable cause) {
			super(message, cause);
		}
	}
}
