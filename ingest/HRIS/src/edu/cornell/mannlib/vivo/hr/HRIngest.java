package edu.cornell.mannlib.vivo.hr;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;

public class HRIngest {

	public static void main (String[] args) {
		String Q01 = "PREFIX hr: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#> \n" + 
				 "PREFIX cuvivo: <http://vivo.cornell.edu/individual/> \n" + 
			     "PREFIX foaf: <http://xmlns.com/foaf/0.1/> \n" + 
				 "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" + 
				 "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" + 
				 "PREFIX core: <http://vivoweb.org/ontology/core#> \n" + 
				 "PREFIX titlemap: <http://vivo.library.cornell.edu/ns/hr/titleMapping#TitleMapping> \n" + 
					 /*"CONSTRUCT {\n" +
					 	"?person hr:emplId ?emplId .\n" +
					 	"?person hr:netId ?netId .\n" +
					 	"?person hr:WorkingTitle ?prettyTitle . \n" +  
					 	"?prettytitleID titlemap:titlemapping_modifiedTitleStr ?prettyTitle . \n" +
					 "} \n" +*/
					 "SELECT DISTINCT ?person ?emplId ?netId ?wtitle \n" + 	
					 "WHERE {\n" + 
				     	/*"SERVICE <http://bailey.mannlib.cornell.edu:2020/sparql> \n" + */
				     	"SERVICE <http://vivo.cornell.edu:2020/sparql> \n" + 
				     	"{\n" +
				     		"?person rdf:type foaf:Person . \n" + 
				     	    "?person hr:emplId ?emplId .\n" + 
				     		"?person hr:netId ?netId . \n" +
				     		"?person hr:WorkingTitle ?wtitle . \n" +
				       	"}\n" + 
				     	"SERVICE <http://bailey.mannlib.cornell.edu:7070/sesame/repositories/titlemapping> \n" + 
				     	"{\n" +
				     	    "?titleMap rdf:type <http://vivo.library.cornell.edu/ns/hr/titleMapping#TitleMapping> .\n" +  
				     		"?titleMap titlemap:titlemapping_originalTitleStr ?wtitle . \n" +
				     		"?titleMap titlemap:titlemapping_modifiedTitleStr ?prettyTitle . \n" +
				       	"}\n" + 
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
		    System.out.println("There are " + testModel.size() + " statements in this model.");       
		    /*} catch (Exception e) {*/
 		    
		} finally {
			QE.close();
		}
		
	}
}
