package edu.cornell.library.vivocornell.hr;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.vocabulary.RDFS;

//added these four as part for the bandaid for position subclass mapping
import org.skife.csv.CSVReader;
import org.skife.csv.SimpleReader; 

public class CorrectHrData {
	
	public static final Property PRIMARY_JOBCODE_LDESC = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryJobcodeLdesc");
	public static final Property PRIMARY_WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#primaryWorkingTitle");
	public static final Property WORKING_TITLE = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#WorkingTitle");
	public static final Property AIUSER = ResourceFactory.createProperty("http://vivoweb.org/ontology/activity-insight#aiUser");	   
	public static final Property HR_EMPLID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#emplId"); 
	public static final Property HR_NETID = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#netId"); 
	public static final Property MAN_CURATED = ResourceFactory.createProperty("http://vivo.cornell.edu/ns/hr/0.9/hr.owl#ManuallyCurated"); 
	public static final Property EMERTI_PROF = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#EmeritusProfessor"); 
	public static final Property PERSON_AS_LISTED = ResourceFactory.createProperty("http://vivoweb.org/ontology/provenance-support#PersonAsListed"); 
	public static final Property PRETTY_TITLE = ResourceFactory.createProperty("http://vivo.library.cornell.edu/ns/hr/titleMapping#titlemapping_modifiedTitleStr");
	public static final Property POSN_IN_ORG = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionInOrganization");
	public static final Property PERSON_IN_POSN = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#personInPosition");
	public static final Property POSN_FOR_PERSON = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#positionForPerson");
	public static final Property FIRST_NAME = ResourceFactory.createProperty("http://xmlns.com/foaf/0.1/firstName");
	public static final Property LAST_NAME = ResourceFactory.createProperty("http://xmlns.com/foaf/0.1/lastName");
	public static final Property JOB_TITLE = ResourceFactory.createProperty("http://vivoweb.org/ontology/core#hrJobTitle");

	public static final Resource FACULTY_ADMINISTRATIVE_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#FacultyAdministrativePosition");
	public static final Resource FACULTY_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#FacultyPosition");
	public static final Resource LIBRARIAN_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#LibrarianPosition");
	public static final Resource ACADEMIC_STAFF_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonFacultyAcademicPosition");
	public static final Resource NONACADEMIC_STAFF_POSITION = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonAcademicPosition");

	public static final Resource FACULTY = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellFaculty");
	public static final Resource LIBRARIAN = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellLibrarian");
	public static final Resource ACADEMIC_STAFF = ResourceFactory.createResource("http://vivo.library.cornell.edu/ns/0.1#CornellAcademicStaff");
	public static final Resource STAFF = ResourceFactory.createResource("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellNonAcademicStaff");
    public static final Resource NON_ACAD = ResourceFactory.createResource("http://vivoweb.org/ontology/core#NonAcademic");
    		
	public static final Resource THING_TYPE = ResourceFactory.createResource("http://www.w3.org/2002/07/owl#Thing");
	public static final Resource POSITION_TYPE = ResourceFactory.createResource("http://vivoweb.org/ontology/core#Position");

	//public Set<String> unrecognizedTitles = new HashSet<String>();	
	CumulativeDeltaModeler cdm = new CumulativeDeltaModeler();

	private final Logger logger = Logger.getLogger(this.getClass());
	CreateModel cm = new CreateModel();
	ReadWrite rw = new ReadWrite();  
	
	public Model processHRISCorrections(OntModel mdlOnePersonHRISRDF, OntResource vivoIndiv) throws Exception {

		// mdlOnePersonHRISRDF contains relevant HRIS RDF for this person so we can match against VIVO RDF.
		// things to do with hris model: 
		// see if vivoperson exists in hris data (if not, why not? are they CCE, or non-exempt?)
		// find a way to add prettytitle to model and/or update hrisWorkingTitle  ( DONE, but remove is not working so well.)
		// compare hrisWorkingTitle and vivoWorkingTitle, if no match, use hrisWorkingTitle
		// fix label comma space problem

		Model CorrectedHRISPersonRDF = ModelFactory.createDefaultModel();

		// initialize flags
		boolean manuallyCurated = false;
		boolean isEmeritus = false;


		try {
			String vivoLabel = rw.getLiteralValue(vivoIndiv, RDFS.label);
			String vivoWorkingTitle = rw.getLiteralValue(vivoIndiv, WORKING_TITLE);
			String vivoFirstName = rw.getLiteralValue(vivoIndiv, FIRST_NAME);
			String vivoLastName = rw.getLiteralValue(vivoIndiv, LAST_NAME);


			//mdlOnePersonVIVORDF.write(System.out, "N-TRIPLE");

			// conditionals here to modify RDF before rewriting to model
			// create a SELECT CASE style list of things to to do person RDF

			// check to see if we have a manually curated flag set for this node
			if (vivoIndiv.hasRDFType(EMERTI_PROF)) {
				logger.info("is Emeritus!");
				isEmeritus = true;
			}

			// check to see if we have a manually curated flag set for this person
			if (vivoIndiv.hasRDFType(MAN_CURATED)) {
				logger.info("Manually Curated!");
				manuallyCurated = true;
			}

			// check to see if we have a person as listed flag set for this person
			if (vivoIndiv.hasRDFType(PERSON_AS_LISTED)) {
				logger.info("Person As Listed!");
				manuallyCurated = true;
			}


			Resource hrisURI = mdlOnePersonHRISRDF.listStatements().nextStatement().getSubject();

			// fill up corrected HRIS model with all statements from original HRIS model
			StmtIterator hrisIter = mdlOnePersonHRISRDF.listStatements();
			while (hrisIter.hasNext()) {
				Statement stmt      = hrisIter.nextStatement();  // get next statement
				Resource  subject   = stmt.getSubject();     // get the subject
				Property  predicate = stmt.getPredicate();   // get the predicate
				RDFNode   object    = stmt.getObject();      // get the object
				CorrectedHRISPersonRDF.add(vivoIndiv, predicate, object);
			}

			// with subject (hrisURI), create OntResource with all statements for individual
			OntResource hrisIndiv = mdlOnePersonHRISRDF.getOntResource(hrisURI);

			String hrisWorkingTitle = rw.getLiteralValue(hrisIndiv, WORKING_TITLE);
			String prettyTitle = this.getPrettyTitle(hrisWorkingTitle);

			// always compare VIVO working title to HRIS 

			if (vivoWorkingTitle != null) {
				logger.debug("pretty hrisWorkingTitle = " + prettyTitle);
				if (prettyTitle != null) {

					if ((vivoWorkingTitle).equals(prettyTitle)){
						logger.info("working titles match!");
						CorrectedHRISPersonRDF.remove(vivoIndiv, WORKING_TITLE, hrisIndiv.getPropertyValue(WORKING_TITLE));
						CorrectedHRISPersonRDF.add(vivoIndiv, WORKING_TITLE, prettyTitle);
					} else {
						logger.info("working titles don't match!");
						logger.info(vivoWorkingTitle + "," + prettyTitle);

						if (prettyTitle.equals("")) {
							logger.trace("keeping original working title.");
						} else {	

							try {
								CorrectedHRISPersonRDF.remove(vivoIndiv, WORKING_TITLE, hrisIndiv.getPropertyValue(WORKING_TITLE));
								CorrectedHRISPersonRDF.add(vivoIndiv, WORKING_TITLE, prettyTitle);
							} catch ( Exception e ) {
								logger.error("problem correcting pretty title RDF. Error" , e );
							} finally {
								logger.debug("title corrected");
							}
						}  //endif prettyTitle blank
					} // end if workingTitles match
				} else { 
					logger.info("vivoHRISTitle is null - use VIVO working title if it exists.");
				} // endif HRIS title null
			} else {
				logger.info("vivoWorkingTitle is null - use pretty HRIS working title if it exists.");
				CorrectedHRISPersonRDF.add(vivoIndiv, WORKING_TITLE, prettyTitle);
				//ignoreAddRetract
			} // end else 

			
			
			//if don't update profile data, then 
			// always fix label

			String hrisLabel = rw.getLiteralValue(hrisIndiv, RDFS.label);
			String newLabel = null;
			//test vivoLabel for unicode
			if (containsUnicode(vivoLabel)) {
				logger.info("VIVO label contains unicode!  Don't overwrite with HRIS label.");
				try {
					RDFNode hrisLabelNode =  hrisIndiv.getPropertyValue(RDFS.label);
					if (hrisLabelNode != null) {
					//CorrectedHRISPersonRDF.remove(vivoIndiv, RDFS.label, hrisIndiv.getPropertyValue(RDFS.label));
					CorrectedHRISPersonRDF.remove(vivoIndiv, RDFS.label, hrisLabelNode);
					CorrectedHRISPersonRDF.add(vivoIndiv, RDFS.label, vivoLabel);
					} else {
						logger.info("What's wrong with vivoLabel" + vivoLabel + " or hrisLabeL : " + hrisLabel );
					}
				} catch ( Exception e ) {
					logger.error("problem correcting HRIS label RDF. Error" , e );
				} finally {

				}
			} else {

				String delimiter = "\\,";
				String[] labelParts;
				newLabel = "";
				labelParts = hrisLabel.split(delimiter);
				if (labelParts[1].substring(0,1).equals(" ")) {
					newLabel = labelParts[0] + "," + labelParts[1];			
				logger.info("HRIS label not modified.");
				} else {
				  newLabel = labelParts[0] + ", " + labelParts[1];	
				logger.info("HRIS label modified.");

				Map<String, String> labelHash = correctLabel(hrisLabel);
				newLabel = labelHash.get("newLabel");

			    }
			}

			//System.out.print(strSubject);
			//System.out.print(" " + strPredicate + " ");
			//System.out.print(" \"" + newLabel + "\"");
			//System.out.print("\n\n");
			//System.out.print(" \"" + strObject + "\"");
			try {

				RDFNode hrisLabelNode =  hrisIndiv.getPropertyValue(RDFS.label);
				logger.info("hrisLabelNode: " + hrisLabelNode);
				if (hrisLabelNode != null) {
					//CorrectedHRISPersonRDF.remove(vivoIndiv, RDFS.label, hrisIndiv.getPropertyValue(RDFS.label));
					CorrectedHRISPersonRDF.remove(vivoIndiv, RDFS.label, hrisLabelNode);
					//CorrectedHRISPersonRDF.add(vivoIndiv, RDFS.label, newLabel);
					CorrectedHRISPersonRDF.add(vivoIndiv, RDFS.label, vivoLabel);
				} else {
					logger.info("What's wrong with vivoLabel" + vivoLabel + " or hrisLabeL : " + hrisLabel );
				}
			} catch ( Exception e ) {
				logger.error("problem correcting HRIS label RDF. Error" , e );
			} finally {

			}


			// TODO Consolidate these in a more efficient and effective method
			if (containsUnicode(vivoFirstName)) {
				logger.info("VIVO first name contains unicode!  Don't overwrite with HRIS first name.");
				try {
					CorrectedHRISPersonRDF.remove(vivoIndiv, FIRST_NAME, hrisIndiv.getPropertyValue(FIRST_NAME));
					CorrectedHRISPersonRDF.add(vivoIndiv, FIRST_NAME, vivoFirstName);
				} catch ( Exception e ) {
					logger.error("problem correcting HRIS firstname RDF. Error" , e );
				} finally {

				}
			}

			if (containsUnicode(vivoLastName)) {
				logger.info("VIVO last name contains unicode!  Don't overwrite with HRIS last name.");
				try {
					CorrectedHRISPersonRDF.remove(vivoIndiv, LAST_NAME, hrisIndiv.getPropertyValue(LAST_NAME));
					CorrectedHRISPersonRDF.add(vivoIndiv, LAST_NAME, vivoLastName);
				} catch ( Exception e ) {
					logger.error("problem correcting HRIS lastname RDF. Error" , e );
				} finally {

				}
			}


			// all statements: 
			//Resource renameIt = CorrectedHRISPersonRDF.getResource(subject.toString());
			//ResourceUtils.renameResource( renameIt, VIVOmatchURI);

		} catch  ( Exception e ) {

			logger.error("Rats.  Something happened while looking at HRIS person statements. Error" , e );
		} finally {
			logger.info("done with statements for " + vivoIndiv + ".");
		}
		return CorrectedHRISPersonRDF;

	}
	
	public String getPrettyTitle(String hrisWorkingTitle) throws Exception {	

		String prettyTitleQuery = rw.ReadQueryString(IngestMain.fileQryPath + "qStrPrettyTitle.txt");
		String[] prettyTitleQueryArg = {prettyTitleQuery, "VARVALUE" , hrisWorkingTitle};
		String qStrPrettyTitleRDF = rw.ModifyQuery(prettyTitleQueryArg); 
		String prettyTitle = "";

		//logger.trace(qStrPrettyTitleRDF);
		long startTime = System.currentTimeMillis();			
		OntModel mdlPrettyTitleRDF = cm.MakeNewModelCONSTRUCT(qStrPrettyTitleRDF); 
		logger.debug("pretty title query time: " + (System.currentTimeMillis() - startTime) + " \n\n\n");	
		if (mdlPrettyTitleRDF.isEmpty()) {
			logger.debug("no pretty title match for " + hrisWorkingTitle);
			//keep hrisWorkingTitle
			prettyTitle = hrisWorkingTitle;
		} else {
			Resource thisTitle = mdlPrettyTitleRDF.listSubjects().toList().get(0);
			String thisTitleString = thisTitle.toString();
			OntResource ontresPrettyTitle = mdlPrettyTitleRDF.getOntResource(thisTitleString);
			prettyTitle = rw.getLiteralValue(ontresPrettyTitle, PRETTY_TITLE);
			logger.debug("changing " + hrisWorkingTitle + " to " + prettyTitle);
		}
		return prettyTitle;
	}
	
	private static boolean containsUnicode(String s) {
		char[] asCharArr = s.toCharArray();
		for(int i=0;i <asCharArr.length;i++) {
			if (asCharArr[i] > 127) {
				return true;
			}
		}
		return false;   
	}
	
	public Map<String, String> correctLabel(String correctThisLabel) throws Exception {
		// first, split on the comma
		String delimiterComma = "\\,";
		String[] labelParts;
		String[] leftSideParts;
		String[] rightSideParts;

		labelParts = correctThisLabel.split(delimiterComma);
		// split label at comma 


		// the first thing to the right is firstName
		// anything with a delimiter after firstName should be middleName
		String leftSide = labelParts[0];
		// everything to the right is lastname and suffix
		String rightSide = labelParts[1];

		//setup a hash to return all the parts we find
		Map<String, String> result = new HashMap<String, String>();

		if (rightSide.substring(0,1).equals(" ")) {
			// check to see if string already has a space between comma and right part
			result.put("newLabel", leftSide + "," + rightSide);			
			//logger.info("HRIS label not modified.");
		} else {
			// if not, add the space in the final label
			result.put("newLabel", leftSide + ", " + rightSide);
			//logger.info("HRIS label modified.");
		}
		String delimiterSpace = "\\ ";
		leftSideParts = leftSide.split(delimiterSpace);
		rightSideParts = rightSide.split(delimiterSpace);
		logger.debug("leftSide has " + leftSideParts.length + " parts.");
		logger.debug("rightSide has " + rightSideParts.length + " parts.");		

		return result;
	}
	
	public boolean isSpecialFacultyTitle(String jobtitle) {
		return (
				"Andrew D. White Prof-At-Large".equals(jobtitle) ||
				"Prof Assoc Vis".equals(jobtitle) ||
				"Prof Asst Visit".equals(jobtitle) ||
				"Prof Visiting".equals(jobtitle) ||
				"Prof Adj".equals(jobtitle) ||
				"Prof Adj Assoc".equals(jobtitle) ||
				"Prof Adj Asst".equals(jobtitle) ||
				"Prof Courtesy".equals(jobtitle) ||
				"Professor Associate Courtesy".equals(jobtitle) ||
				"Professor Assistant Courtesy".equals(jobtitle) );

	}

	public Resource getPositionType(String jobtitle, Map<String,String> titlemap) {
		if (jobtitle == null ||  jobtitle.trim().length() == 0) {
			return null;
		}
		String family = titlemap.get(jobtitle);
		if (jobtitle.contains("Dean") || "Department Chairperson".equals(jobtitle) ||"Academic Administrative".equals(family)) {
			return FACULTY_ADMINISTRATIVE_POSITION;
		} else if ("Professorial".equals(family) || isSpecialFacultyTitle(jobtitle) 
				|| (jobtitle.contains("Prof") && !jobtitle.contains("Temp"))
				) {
			return FACULTY_POSITION;
		} else if ("Library - Academic".equals(family) || jobtitle.contains("Archiv") || jobtitle.contains("Librarian")) {
			return LIBRARIAN_POSITION;
		} else if (jobtitle.contains("Fellow") || jobtitle.contains("Lecturer") || "Scient Visit".equals(jobtitle) || jobtitle.contains("Chair") || "Academic Other".equals(family) || "Research/Extension".equals(family) || "Teaching".equals(family)) {
			//was return this.ACADEMIC_STAFF_POSITION; (why?)
			return ACADEMIC_STAFF_POSITION;
		} else if (!jobtitle.contains("Director") && !jobtitle.contains("Dir ") && !jobtitle.contains("- SP") && family == null) {
			cdm.addUnrecognizedTitle(jobtitle);
			return null;
		} else {
			return NONACADEMIC_STAFF_POSITION;
		}
	}

	public Resource getEmployeeType(Resource positionType) {
    if ((positionType == FACULTY_ADMINISTRATIVE_POSITION) || ( positionType == FACULTY_POSITION)) {
	   return FACULTY;
    } else if (positionType == LIBRARIAN_POSITION) {
    	 return  LIBRARIAN;
    } else if (positionType == ACADEMIC_STAFF_POSITION) {
	  return ACADEMIC_STAFF;
    } else {
    	//was STAFF
	  return NON_ACAD;
     }
    } //end method
}  // end class