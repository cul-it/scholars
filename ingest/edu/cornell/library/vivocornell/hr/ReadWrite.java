package edu.cornell.library.vivocornell.hr;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;

import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;

public class ReadWrite {

	private final Logger logger = Logger.getLogger(this.getClass());
	
	public String getLiteralValue(OntResource ontRes, Property property) throws Exception{
		RDFNode vivoNode = null; 
		String value = "";
		try {
			logger.debug("property " + property);	
			vivoNode = ontRes.getPropertyValue(property);
			logger.debug("vivoNode " + vivoNode);
			if (vivoNode != null) {

				if (vivoNode.isLiteral() ) {
					logger.debug("vivoNode is literal.");
					value = vivoNode.asLiteral().getLexicalForm();
				} else {
					logger.debug("vivoNode is NOT literal.");
					value = vivoNode.toString();
				}
			} else {
				logger.debug("vivoNode is null.");
			}
			//logger.debug("node " + vivoNode);	
			return value;
		} catch ( Exception e ){
			logger.error("That didn't work- problem getting literal value.  Error" , e );
			throw e; 
		}
		// if vivoNode is not null AND vivoNode isLiteral, then return vivoNode.asLiteral.getLexicalForm else return null

	}
	
	public String[] getQueryArgs(Resource vivoIndiv, String vivoPersonEmplId, String vivoPersonNetId) throws IOException  {
		// setup query for grabbing VIVO rdf

		String HRISRDFBaseQuery = ReadQueryString(IngestMain.fileQryPath + "qStrOnePersonHRISRDF.txt");
		String HRISRDFnetIdQuery = ReadQueryString(IngestMain.fileQryPath + "qStrOnePersonHRISNetIDRDF.txt");

		if (vivoPersonEmplId.equals(""))  {
			//String vivoPersonNetId = getLiteralValue(vivoIndiv, HR_NETID);
			// pass VIVO netID to HRIS query to get HRIS RDF
			logger.info("constructing HRIS RDF for " + vivoPersonNetId + "...");
			String[] temp =  {HRISRDFnetIdQuery, "VARVALUE", vivoPersonNetId};
			return temp;

		} else {
			// pass VIVO emplId to HRIS query to get HRIS RDF
			logger.info("constructing HRIS RDF for " + vivoPersonEmplId + "...");
			String[] temp = {HRISRDFBaseQuery, "VARVALUE", vivoPersonEmplId};
			return temp;


		}

	}
	
	public String ReplaceRegex(String[] args) 
			throws Exception {
		String returnString = "";
		String startString = args[0];
		String findString = args[1];
		String replString = args[2];

		String finishString = "";

		// Create a pattern to match FindString
		Pattern p = Pattern.compile(findString);
		// Create a matcher with an input string
		Matcher m = p.matcher(startString);
		StringBuffer sb = new StringBuffer();
		boolean result = m.find();
		boolean found = false; 
		// Loop through and create a new String 
		// with the replacements
		while(result) {
			m.appendReplacement(sb, replString);
			result = m.find();
			found = true;
		}
		// Add the last segment of input to 
		// the new String
		m.appendTail(sb);
		finishString = (sb.toString());
		if (!found) {
			logger.debug(findString + " not found." + "\n");
			returnString = startString;
		} else {
			returnString = finishString;
		}
		return returnString;
	}
	

	public String ModifyQuery(String[] args) throws Exception {
		String modifiedString = "";
		String interimString = "";	    		 
		// baseQuery is original query string from text file
		String baseQuery = args[0];

		try {
			if (args.length == 5) {
				//two replacements to be done, use 3,4
				String[] replArgs = {baseQuery, args[3], args[4]};
				interimString = ReplaceRegex(replArgs);
			} else {
				// only one replacement, use 1,2
				interimString = baseQuery;
			}
			String[] replArgs = {interimString, args[1], args[2]};
			String tempString = ReplaceRegex(replArgs);
			modifiedString = tempString;
		} catch (Exception e) {
			logger.error("whoops.  Query mod threw error " , e);
		} finally {

		}

		return modifiedString;
	}
	
	public String ReadQueryString(String filePath) throws IOException {
		String queryString = "";
		String serviceVIVO = "";
		String modifiedString = "";
		boolean useProductionVIVO = false;

		try {
			StringBuffer fileData = new StringBuffer(1000);
			BufferedReader reader = new BufferedReader(new FileReader(filePath));
			char[] buf = new char[1024];
			int numRead=0;
			while((numRead=reader.read(buf)) != -1){
				fileData.append(buf, 0, numRead);
			}
			reader.close();
			queryString = fileData.toString();

			// look for 

			if (useProductionVIVO) {
				serviceVIVO = "http://vivoprod01.library.cornell.edu:2020/sparql"; 
			} else {
				serviceVIVO = "http://bailey.mannlib.cornell.edu:2520/sparql"; 
			}


			String substring = "VIVOSERV";


			if (queryString.contains(substring)) {
				String [] replArgs = {queryString, "VIVOSERV", serviceVIVO };
				modifiedString = ReplaceRegex(replArgs);
				queryString = modifiedString;
			} 

		} catch (Exception e) {
			logger.error("whoops.  What happened?  " + e);
		} finally {

		}
		return queryString;
	}
	
	public Model ReadRdf(String args[]) throws IOException {
		String filename = args[0];
		String basename = args[1];
		String readformat = args[2];

		Model mdlReadModel = ModelFactory.createDefaultModel();
		// now read in the HRIS emplID model
		FileInputStream readstream = null;
		try {
			readstream = new FileInputStream(filename);
			mdlReadModel.read(readstream, basename, readformat);
		} finally {
			if (readstream != null) {
				//            readstream.flush();
				readstream.close();
			}
			logger.info(" Successfully read in the nt data from " + filename);
		}  //end try for read hrisEmplId
		return mdlReadModel;
	}
	
	public void WriteRdf(String filename, Model model, String RDFFormat) throws IOException  {
		//now, use RDFWriter to write the VIVO emplIDs to N-TRIPLES file
		FileOutputStream fstream = null;
		try {
			fstream = new FileOutputStream(filename);
			model.write(fstream, RDFFormat);
		} catch (Exception e) { 
			// do we have file exists/overwrite/backup logic to insert here?
			logger.error("problem with write process?, Error" + e);

		} finally {
			// close filestream
			if (fstream != null) {
				fstream.flush();
				fstream.close();

			}
		}
	}
	
	public void LogRDF(Model model, String RDFFormat) throws IOException  {
		//now, use RDFWriter to write the VIVO emplIDs to N-TRIPLES file

		try {

			logger.info(model);
			//model.write(System.out, "N-TRIPLE");
		} catch (Exception e) { 
			// do we have file exists/overwrite/backup logic to insert here?
			logger.error("problem with write process?, Error" + e);

		} finally {

		}
	}
	
}
