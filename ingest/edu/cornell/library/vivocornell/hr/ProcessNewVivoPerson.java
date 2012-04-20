package edu.cornell.library.vivocornell.hr;

import java.io.FileInputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.skife.csv.CSVReader;
import org.skife.csv.SimpleReader;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import com.hp.hpl.jena.vocabulary.RDF;
import com.hp.hpl.jena.vocabulary.RDFS;

public class ProcessNewVivoPerson extends IteratorMethods {
	
	public final Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
	public final Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
	public final Property EMPLOYEE_TYPE = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/0.1#CornellEmployee"); 
	public final Property JOB_TITLE = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#hrJobTitle");
	public final Property WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#WorkingTitle");
	
	public String titleMapFile = IngestMain.fileRDFPath + "jobtitles5.csv";

	private final Logger logger = Logger.getLogger(this.getClass());
	CreateModel cm = new CreateModel();
	ReadWrite rw = new ReadWrite();  
	CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();
	
	public Model processNewVIVOperson(OntResource newHRISIndiv, String personId) throws Exception {
		// for each person in VIVO person list, do stuff and return RDF additions
		
		// allAdditions is the aggregate 
		Model allAdditions = ModelFactory.createDefaultModel();
		Model additionsForNEWHRISPerson = ModelFactory.createDefaultModel();
		logger.info("personId" + personId );
		boolean ignoreHRISAdd = false;
		String NEWHRISRDFBaseQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrNewPersonHRISRDF.txt");

		String hrisURIString = ("<" + newHRISIndiv.getURI() + ">");
		String[] NEWHRISQueryArg = {NEWHRISRDFBaseQuery, "VARVALUE" , hrisURIString};
		String qStrNEWHRISRDF = rw.ModifyQuery(NEWHRISQueryArg); 
		logger.info("new HRIS query string \n\n" + qStrNEWHRISRDF );

		OntModel mdlNEWPersonHRISRDF = cm.MakeNewModelCONSTRUCT(qStrNEWHRISRDF); 
		// with subject (personId), create OntResource with all statements for individual
		OntResource newHRISPersonIndiv = mdlNEWPersonHRISRDF.getOntResource(personId);
		logger.info("indiv " + newHRISPersonIndiv );
		// get vivoEmplID and vivoNetId

		String HRISPersonEmplId = rw.getLiteralValue(newHRISPersonIndiv, HR_EMPLID);
		String HRISPersonNetId = rw.getLiteralValue(newHRISPersonIndiv, HR_NETID);
		if (HRISPersonEmplId.equals("")) {
			logger.warn("WARNING: blank HRIS emplID for " + newHRISPersonIndiv);
			//blankVIVOEmplIdException.add(CorrectedVIVOPersonRDF);
		}
		if (HRISPersonNetId.equals("")) {
			logger.warn("WARNING: blank HRIS netId for " + newHRISPersonIndiv );
			//blankVIVOEmplIdException.add(CorrectedVIVOPersonRDF);
		}
		logger.debug("HRISEmplId - " + HRISPersonEmplId);
		logger.debug("HRISNetId - " + HRISPersonNetId);

		logger.debug("HRIS model has " + mdlNEWPersonHRISRDF.size() + " statements.");
		
		Map<String,String> title2family = new HashMap<String,String>();
		//File titleMapFile = new File(getServletContext().getRealPath(TITLE_MAP_PATH));
		FileInputStream fis = new FileInputStream(titleMapFile);
		CSVReader csvReader = new SimpleReader();
		List<String[]> fileRows = csvReader.parse(fis);
		for(String[] row : fileRows) {
			title2family.put(row[0], row[1]);
		}
		
		if (!mdlNEWPersonHRISRDF.isEmpty()) {
			logger.debug("mdlNewPersonHrisRdf is not empty.");
        
		// come up with a convenience function for correcting hr label comma space problem, call here and in chd	
		//	String hrisPersonLabel = rw.getLiteralValue(newHRISPersonIndiv, RDFS.label);
		//	String newLabel = null;
		//		String delimiter = "\\,";
		//		String[] labelParts;
		//		newLabel = "";
		//		labelParts = hrisPersonLabel.split(delimiter);
		//		if (labelParts[1].substring(0,1).equals(" ")) {
		//			newLabel = labelParts[0] + "," + labelParts[1];			
		//		logger.info("HRIS label not modified.");
		//		} else {
		//		  newLabel = labelParts[0] + ", " + labelParts[1];	
		//		logger.info("HRIS label modified.");
		//		Map<String, String> labelHash = correctLabel(hrisPersonLabel);
		//		newLabel = labelHash.get("newLabel");
		//	    }
		//	}

			//Model CorrectedHRISPersonRDF = ModelFactory.createDefaultModel();	
			CorrectHrData chd = new CorrectHrData();
			String HRISPersonJobTitle = rw.getLiteralValue(newHRISPersonIndiv, WORKING_TITLE);
			logger.debug("HRISPersonJobTitle is : " + HRISPersonJobTitle);
			Model CorrectedHRISNEWPersonRDF = chd.processHRISCorrections(mdlNEWPersonHRISRDF, newHRISPersonIndiv);
			logger.info("done correcting HRIS statements for " + personId + ".");
			try {
				String prettyTitle = chd.getPrettyTitle(HRISPersonJobTitle);
				Resource positionType = ResourceFactory.createResource();
				if (prettyTitle != null) {
					logger.info("prettyTitle is not null:" + prettyTitle);
				    positionType = chd.getPositionType(prettyTitle, title2family);
				    if (positionType != null) {
				    	logger.info("positionType: " + positionType );
				    	logger.debug("getPositionType is changing " + HRISPersonJobTitle + " to " + positionType);
						CorrectedHRISNEWPersonRDF.add(newHRISPersonIndiv,  RDF.type, positionType );
						Resource employeeType = chd.getEmployeeType(positionType);
						CorrectedHRISNEWPersonRDF.add(newHRISPersonIndiv,  RDF.type, employeeType );
				    } else {
				        logger.info("positionType is null, need to update titlemapping file.");
				    }
				} else {
					logger.info("prettyTitle is null, keeping  " + HRISPersonJobTitle);
					positionType = chd.getPositionType(HRISPersonJobTitle, title2family);		
					    if (positionType != null) {
					    	logger.info("positionType: " + positionType );
							CorrectedHRISNEWPersonRDF.add(newHRISPersonIndiv,  RDF.type, positionType );
							Resource employeeType = chd.getEmployeeType(positionType);
							CorrectedHRISNEWPersonRDF.add(newHRISPersonIndiv,  RDF.type, employeeType );
					    } else {
					        logger.info("positionType is null, need to update titlemapping file.");
					    }
					logger.info("adding " + HRISPersonJobTitle + "to prettyTitle exceptions list." );
					cdm.addMissingPrettyTitle(HRISPersonJobTitle);
				}
				//mdlVIVOPosnRDF.add(stmt.getSubject(),  RDF.type, positionType );


				//	mdlVIVOPosnRDF.add(stmt2.getSubject(),  RDF.type, positionType );
				//}				

			} catch  ( Exception e ) {
				logger.error("problem getting position subclass. Error", e );
			} 	
			CorrectedHRISNEWPersonRDF.add(newHRISPersonIndiv,  RDF.type, EMPLOYEE_TYPE );
			// add back rdf:type core:Position with vivoURI?
			//mdlHRISPosnRDF.add(vivoIndiv,  RDF.type, POSITION_TYPE );
			//WriteRdf(blankVIVOEmplIdExFile, blankVIVOEmplIdException, "N3");
			logger.debug("HRIS RDF");
			rw.LogRDF(mdlNEWPersonHRISRDF, "N3");
			logger.debug("CorrectedHRISPerson RDF");
			rw.LogRDF(CorrectedHRISNEWPersonRDF, "N3");
			Long numHRStatements = CorrectedHRISNEWPersonRDF.size();
			if (numHRStatements < 1) {
				logger.warn("No statements in HRIS for "+ newHRISPersonIndiv + " : " + HRISPersonEmplId + " : " + HRISPersonNetId + ".  Something is SERIOUSLY wrong.");
				//allNoHRISDataException.add(CorrectedVIVOPersonRDF);
				//!!! DON'T RETRACT VIVO STATEMENTS !!!
				ignoreHRISAdd = false;
			}


			try {
				logger.info("preparing HRIS add RDF");  


				if (ignoreHRISAdd) {
					logger.debug("addition suppressed.");
				} else {

					cdm.addModel(CorrectedHRISNEWPersonRDF);
					additionsForNEWHRISPerson.add(CorrectedHRISNEWPersonRDF);
					if(additionsForNEWHRISPerson.size() > 0) {
						logger.info("*** " + additionsForNEWHRISPerson.size() + " PROFILE ADDITIONS ***");  
						additionsForNEWHRISPerson.write(System.out, "N3");                
						logger.trace(additionsForNEWHRISPerson);
					} else  {
						logger.info("*** NO PROFILE ADDITIONS ***");
					}
				} //endif for ignoreHRISAdd

				// reset flags

				ignoreHRISAdd = false;

			} catch  ( Exception e ) {
				logger.error("Trouble adding NEW HRIS profile RDF for this person to master add/retract model. Error" + e + "\n");
			} finally {
				logger.info("done with NEW HRIS profile retract/add for " + personId + "." + "\n");
				allAdditions.add(cdm.getAdditions());
				//logger.info("Here's your adds");
		        //rw.LogRDF(cdm.getAdditions(), "N3");
				//allAdditions.add(additionsForNEWHRISPerson);
				additionsForNEWHRISPerson.close();
			}
		} else {
			logger.info("new person HRIS model is empty.  Why? " + personId + "." + "\n");
		}

		return allAdditions;
	}
}
