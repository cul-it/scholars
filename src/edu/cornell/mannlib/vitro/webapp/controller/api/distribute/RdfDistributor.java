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
			throws RdfDistributorException;

	public class RdfDistributorException extends Exception {
		public RdfDistributorException() {
			super();
		}

		public RdfDistributorException(String message) {
			super(message);
		}

		public RdfDistributorException(Throwable cause) {
			super(cause);
		}

		public RdfDistributorException(String message, Throwable cause) {
			super(message, cause);
		}
	}

	public class NoSuchActionException extends RdfDistributorException {
		public NoSuchActionException() {
			super();
		}
		
		public NoSuchActionException(String message) {
			super(message);
		}
		
		public NoSuchActionException(Throwable cause) {
			super(cause);
		}
		
		public NoSuchActionException(String message, Throwable cause) {
			super(message, cause);
		}
	}
	
	public class NotAuthorizedException extends RdfDistributorException {
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

	public class MissingParametersException extends RdfDistributorException {
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

	public class ActionFailedException extends RdfDistributorException {
		public ActionFailedException() {
			super();
		}

		public ActionFailedException(String message) {
			super(message);
		}

		public ActionFailedException(Throwable cause) {
			super(cause);
		}

		public ActionFailedException(String message, Throwable cause) {
			super(message, cause);
		}
	}
}
