package edu.cornell.mannlib.vivo.hr;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;

public class HRIngestTest02 {

	public static void main (String[] args) {
		String Q01 = "PREFIX hr: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#> \n" + 
					 "PREFIX cuvivo: <http://vivo.cornell.edu/individual/> \n" + 
				     "PREFIX foaf: <http://xmlns.com/foaf/0.1/> \n" + 
					 "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" + 
					 "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" + 
					 "PREFIX core: <http://vivoweb.org/ontology/core#> \n" + 
					 "CONSTRUCT {\n" +
					    "?HRperson rdf:type foaf:Person . \n" + 
					 "} WHERE {\n" + 
				     	/*"SERVICE <http://bailey.mannlib.cornell.edu:2020/sparql> \n" + */
				     	"SERVICE <http://vivo.cornell.edu:2020/sparql> \n" +
				     	"{\n" +
				     	    "?HRperson rdf:type foaf:Person . \n" + 
				     		/*"?HRperson hr:emplId ?HRemplId . \n" + 
				     		"?HRperson rdfs:label ?HRpersonlabel . \n" + 
				     		"?HRperson hr:WorkingTitle ?workingTitle . \n" + 
				     		"?HRPerson core:email ?HRemail . \n" +*/ 
				     	"} \n" + 
				      "}";
		Model testModel = ModelFactory.createDefaultModel();
		Query TEST01 = QueryFactory.create(Q01);
		QueryExecution QE = QueryExecutionFactory.create(TEST01, testModel);
		
		try {
			// create CONSTRUCT rdf in testModel //
		    QE.execConstruct(testModel);
	    
		    // Print out objects in model using toString
		    NodeIterator iter = testModel.listObjects(  );

		    while (iter.hasNext(  )) {
		         System.out.println("  " + iter.next(  ).toString(  ));
		    }
		    System.out.println("There are " + testModel.size() + " nodes in this model.");       
		    /*} catch (Exception e) {*/
 		    
		} finally {
			QE.close();
		}
		
	}
}
