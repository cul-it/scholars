/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.api.distribute;

import static edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService.ResultFormat.JSON;

import java.io.InputStream;
import java.io.OutputStream;

import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.cornell.mannlib.vitro.webapp.modelaccess.RequestModelAccess;
import edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService;
import edu.cornell.mannlib.vitro.webapp.utils.configuration.RequestModelsUser;

/**
 * TODO
 */
public class GrantsBubbleChartDistributor extends DataDistributorBase implements
		RequestModelsUser {
	private static final Log log = LogFactory
			.getLog(GrantsBubbleChartDistributor.class);

	/** The models on the current request. */
	private RequestModelAccess models;

	/** The select query to be executed. */
	private static final String SELECT_QUERY_STRING = "" //
			+ "PREFIX local:          <http://scholars.cornell.edu/individual/> \n " //
			+ "PREFIX obo:            <http://purl.obolibrary.org/obo/> \n " //
			+ "PREFIX rdfs:           <http://www.w3.org/2000/01/rdf-schema#> \n " //
			+ "PREFIX scholars-grant: <http://scholars.cornell.edu/ontology/grant.owl#> \n " //
			+ "PREFIX scholars-hr:    <http://scholars.cornell.edu/ontology/hr.owl#> \n " //
			+ "PREFIX vivo:           <http://vivoweb.org/ontology/core#> \n " //
			+ "SELECT ?grant ?grantTitle ?amount \n " //
			+ "       ?person ?personName ?personNetid \n " //
			+ "       ?dept ?deptName \n " //
			+ "       ?startYear ?endYear \n " //
			+ "WHERE \n " //
			+ "{ \n " //
			+ "  ?grant a vivo:Grant . \n " //
			+ "  ?grant rdfs:label ?grantTitle . \n " //
			+ "  ?grant vivo:totalAwardAmount ?amount . \n " //
			+ "  \n " //
			+ "  ?grant vivo:relates ?node1 . \n " //
			+ "  ?node1 a vivo:PrincipalInvestigatorRole . \n " //
			+ "  ?node1 obo:RO_0000052 ?person . \n " //
			+ "  ?person rdfs:label ?personName . \n " //
			+ "  ?person scholars-hr:netId ?personNetid . \n " //
			+ "  \n " //
			+ "  ?grant vivo:relates ?node2 . \n " //
			+ "  ?node2 a vivo:AdministratorRole . \n " //
			+ "  ?node2 obo:RO_0000052 ?dept . \n " //
			+ "  ?dept rdfs:label ?deptName . \n " //
			+ "  \n " //
			+ "  ?grant vivo:dateTimeInterval ?dti . \n " //
			+ "  ?dti vivo:end ?end . \n " //
			+ "  ?end vivo:dateTime ?enddt . \n " //
			+ "  BIND(SUBSTR(STR(?enddt),1,4) AS ?endYear) . \n " //
			+ "  ?dti vivo:start ?start . \n " //
			+ "  ?start vivo:dateTime ?startdt . \n " //
			+ "  BIND(SUBSTR(STR(?startdt),1,4) AS ?startYear) . \n " //
			+ "}";

	@Override
	public void setRequestModels(RequestModelAccess models) {
		this.models = models;
	}

	@Override
	public String getContentType() throws DataDistributorException {
		return "application/sparql-results+json";
	}

	@Override
	public void writeOutput(OutputStream output)
			throws DataDistributorException {
		try {
			RDFService rdfService = models.getRDFService();
			InputStream results = rdfService.sparqlSelectQuery(
					SELECT_QUERY_STRING, JSON);
			IOUtils.copy(results, output);
		} catch (Exception e) {
			throw new ActionFailedException(e);
		}
	}

	@Override
	public void close() throws DataDistributorException {
		// Nothing to do.
	}
}
