/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.library.scholars.webapp.controller.api.distribute.modelbuilder;

import com.hp.hpl.jena.rdf.model.Model;

import edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributorContext;
import edu.cornell.library.scholars.webapp.controller.api.distribute.DataDistributor.DataDistributorException;

/**
 * Creates a local model as the basis for later queries.
 * 
 * One instance can be reused by calling reset().
 */
public interface ResettableModelBuilder extends ModelBuilder {
    /** Call once, after instantiating or reset */
    @Override
    void init(DataDistributorContext ddContext) throws DataDistributorException;

    /** Call once, after each call to init. */
    @Override
    Model buildModel() throws DataDistributorException;

    /** Call once, after each call to buildModel. */
    @Override
    void close();

    /** Permits a safe repeat of the calls to init, buildModel and close. */
    void reset();
}
