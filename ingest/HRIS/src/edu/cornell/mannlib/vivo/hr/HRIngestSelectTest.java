package edu.cornell.mannlib.vivo.hr;

import java.util.Iterator;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFactory;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;
import com.hp.hpl.jena.rdf.model.RDFNode;

public class HRIngestSelectTest {

	public static void main (String[] args) {
		String qStr01 = "PREFIX hr: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#> \n" + 
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
				     	"{\n" +
			     	    "?titleMap rdf:type <http://vivo.library.cornell.edu/ns/hr/titleMapping#TitleMapping> .\n" +  
			     		"?titleMap titlemap:titlemapping_originalTitleStr ?wtitle . \n" +
			     		"?titleMap titlemap:titlemapping_modifiedTitleStr ?prettyTitle . \n" +
			       	"}\n" + 
				    "}";
		
		Model testModel = ModelFactory.createDefaultModel();
		//ResultSet testResultSet = ResultSetFactory.create(queryIterator, vars)//
		Query qTest02 = QueryFactory.create(qStr01);
		//QueryExecution QE = QueryExecutionFactory.create(TEST01, testModel);//
		QueryExecution qexec = QueryExecutionFactory.create(qTest02, testModel);
		try {
			// create CONSTRUCT rdf in testModel //
		    /*QE.execConstruct(testModel);*/
	    
			// create SELECT rdf in  testResultSet //
			//ResultSet testResultSet = qexec.execSelect() ;//
			Iterator<QuerySolution>testResultSet = qexec.execSelect() ;
			int counter = 0;
		    for ( ; testResultSet.hasNext() ; )
		    {
		    	QuerySolution soln = testResultSet.next() ;
		      RDFNode person = soln.get("?person") ;       // Get a result variable by name.
		      System.out.println(person);
		      RDFNode emplId = soln.get("?emplId") ;       // Get a result variable by name.
		      System.out.println(emplId);
		      RDFNode netId = soln.get("?netId") ;       // Get a result variable by name.
		      System.out.println(netId);
		      RDFNode wtitle = soln.get("?wtitle") ;       // Get a result variable by name.
		      System.out.println(wtitle);
		      //Resource r = soln.getResource("VarR") ; // Get a result variable - must be a resource//
		      //Literal l = soln.getLiteral("VarL") ;   // Get a result variable - must be a literal//
		    // Print out objects in model using toString
		    /*NodeIterator iter = testModel.listObjects(  );

		    while (iter.hasNext(  )) {
		         System.out.println("  " + iter.next(  ).toString(  ));
		    }
		    */
			
			// Iterate and print ResultSet //

            counter = counter + 1;
		    }
			
			System.out.println("Iterated over " + counter + " rows in this resultSet.");
		    /*} catch (Exception e) {*/
 		    
		} finally {
			qexec.close();

			System.out.println("all done.");
		}
		
	}
}
