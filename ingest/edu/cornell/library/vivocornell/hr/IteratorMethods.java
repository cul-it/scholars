package edu.cornell.library.vivocornell.hr;

import java.util.HashSet;
import java.util.Set;

import org.apache.log4j.Logger;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import com.hp.hpl.jena.vocabulary.RDF;



public class IteratorMethods {

	public static final Resource PERSON_TYPE = ResourceFactory.createResource("http://xmlns.com/foaf/0.1/Person");
	
	public static Set<String> unrectitle = new HashSet<String>();
	public static Set<String> missingPrettyTitles = new HashSet<String>();	
	private final Logger logger = Logger.getLogger(this.getClass());
	//CreateModel cm = new CreateModel();
	//ReadWrite rw = new ReadWrite();  
	CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();
	
public Model IterateThroughVivoPersonList(Model mdlAllVIVOPerson) throws Exception {
	Model allRetractions = ModelFactory.createDefaultModel();
	String allRetractionsFileName = IngestMain.fileRDFPath + "allRetractions.nt";
	Model allAdditions = ModelFactory.createDefaultModel();
	String allAdditionsFileName = IngestMain.fileRDFPath + "allAdditions.nt";
	Model exceptionRDF = ModelFactory.createDefaultModel();
	String allexceptionsFileName = IngestMain.fileRDFPath + "allexceptions.txt";	
	Model allNEWAdditions = ModelFactory.createDefaultModel();
	
		long numPersons = mdlAllVIVOPerson.size(); 
		logger.info("generated a model of all VIVO uris that have either netId or HR emplId");
		logger.info("found a total of " + numPersons + " statements.");
		long personCount = 0;

		try {
			//create models for person RDF 
			// TODO: is this new instance of rw necessary? 
			ReadWrite rw = new ReadWrite();

			CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();
 
			//for every "eligible" Person in VIVO (must have netId OR emplId to play...) 
			ResIterator personiter = mdlAllVIVOPerson.listSubjects();

			// warning! model has 10,000+ items...
			while (personiter.hasNext(  )) {  
				personCount++; 
				// use Person URI to generate all relevant Person RDF via query
				String personId = personiter.next(  ).toString(  );
				logger.info("\n\n processing " + personCount + " of " + numPersons + "\n constructing VIVO RDF for " + personId + "...");
				// make a call to process person, and return Profile Additions
				// add those additions to allUpdateAdditions
				// 
				UpdateVivoPerson uvp = new UpdateVivoPerson();

				// make a call to process person on return Profile Retractions
				// add those additions to allUpdateAdditions
				
				cdm = uvp.processVivoperson(personId, cdm);
				logger.info("logging retractions and additions...");
				rw.LogRDF(cdm.getRetractions(), "N3");
				rw.LogRDF(cdm.getAdditions(), "N3");
				// make a call to process person on return Profile Retractions
				// add those additions to allUpdateAdditions

				// write rdf to all 
				rw.WriteRdf(allRetractionsFileName, cdm.getRetractions(), "N-TRIPLE");
				rw.WriteRdf(allAdditionsFileName, cdm.getAdditions(), "N-TRIPLE");
			} //end while for person iter
			logger.info("finished with person. \n");
			personiter.close();

		} catch ( Exception e ){
			logger.error("Something got messed up while iterating through the person list.  Error" , e );

		} finally {
			logger.info("done looking at all " + numPersons + " VIVO persons.");
			unrectitle = cdm.getUnrecognizedTitles();
			logger.info("Unrecognized Titles: \n\n" + unrectitle );
		}
		//satisfying compiler: 

		return mdlAllVIVOPerson;		
	}

	public Model IterateThroughHrisPersonList(Model mdlNewHrisDiff) throws Exception {

		Model allUrisAdded = ModelFactory.createDefaultModel();
		Model allAdditions = ModelFactory.createDefaultModel();
		Model allNewAdditions = ModelFactory.createDefaultModel();
		String allNewAdditionsFileName = IngestMain.fileRDFPath + "allNEWAdditions.nt";		
	

		long numHRISNewPersons = mdlNewHrisDiff.size(); 
		long newpersonCount = 0;
		logger.info("generated a model of all HRIS URIs that need to be added to VIVO.");
		logger.info("found a total of " + numHRISNewPersons + " statements.");
		long personCount = 0;
		OntModel mdlNewHRISPerson = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		try {
			//create models for person RDF 
			// TODO: is this new instance of rw necessary? 
			ReadWrite rw = new ReadWrite();
			CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();
			//for every Person in HRIS D2R not already in VIVO 
			//create models for NEW person RDF 
			//Resource hrisURI = mdlNewHRISPerson.listStatements().nextStatement().getSubject();
			//for every "eligible" Person in VIVO (must have netId OR emplId to play...) 
			ResIterator newpersoniter = mdlNewHrisDiff.listSubjects();
		    ProcessNewVivoPerson pnvp = new ProcessNewVivoPerson();

			while (newpersoniter.hasNext(  )) {  
				newpersonCount++; 
				// use Person URI to generate all relevant Person RDF via query
				String personId = newpersoniter.next(  ).toString(  );
				// ont resource is representation of individual Person statement
				// TODO: find a way to fix this workaround - seems like a cheat!
				// we want newHRISIndiv to be an OntResource, but mdlNewHrisDiff can't do that for us
				// clunky fix is to create an OntModel, and add the "Model" mdlNewHrisDiff to it.
				//look- passing as Model

				mdlNewHRISPerson.add(mdlNewHrisDiff);
				OntResource newHRISIndiv = mdlNewHRISPerson.getOntResource(personId);
				allUrisAdded.add(newHRISIndiv, RDF.type, PERSON_TYPE);
				logger.info("\n\n processing " + newpersonCount + " of " + numHRISNewPersons + "\n constructing VIVO RDF for " + personId + "...");


				//pvp.processVivoperson(personId);
				allAdditions = pnvp.processNewVIVOperson(newHRISIndiv, personId);
				allNewAdditions.add(allAdditions);
				//TODO: decide whether to rewrite processVIVOperson to handle any person, VIVO or HRIS.
				//Or, make a new method to add HRIS data (corrections required, but no comparison with vivo necessary)
				// also, fix the correctLabel method so that it catches JR, SR, III AICP ESQ, and checks labelFirst against firstName.
 

			} //end while for person iter
			logger.info("finished with person. \n");
			newpersoniter.close();
			rw.WriteRdf(allNewAdditionsFileName, allNewAdditions, "N-TRIPLE");

		//	System.out.println("Unrecognized titles");
		//	for (String s : unrecognizedTitles) {
		//		System.out.println(s);
		//	}
		} catch ( Exception e ){
			logger.error("Something got messed up while iterating through the HRIS person list.  Error" , e );

		} finally {
			missingPrettyTitles = cdm.getMissingPrettyTitles();
			logger.info("Missing Pretty Titles: \n\n" + missingPrettyTitles );
			if (numHRISNewPersons != 0 ) {
				logger.info("done adding RDF for " + numHRISNewPersons + " HRIS persons. \n *** ADD THIS RDF TO VIVO BEFORE CONTINUING***");
			} else {
				logger.info("no new HRIS persons to add to VIVO.");
			}

		}
		//satisfying compiler: 

		return allUrisAdded;		

	}
	
	
}
