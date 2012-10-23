package edu.cornell.mannlib.vivo.webimagecapture;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Represents the process that runs the script for the
 * web image capture. 
 *
 */
public class WebImageCatpureProcess {
	private String cmd = "./capture.py";
	
	private File workingDir = null;
	
	public WebImageCatpureProcess(File workingDir){
		this.workingDir = workingDir;		
	}
	
	public synchronized void returnImageV2(
			String webPageUrl, boolean thumbnail,
			HttpServletResponse resp) throws IOException{
		
		CommandLine cmdLine = new CommandLine( cmd );
		cmdLine.addArgument("\""+webPageUrl+"\"");
		if( thumbnail ){
			cmdLine.addArgument("thumbnail");
		}
		
		DefaultExecutor executor = new DefaultExecutor();
		executor.setWorkingDirectory(workingDir);	
		
		//setup to read output of command
	    ByteArrayOutputStream output = new ByteArrayOutputStream();	    
		executor.setStreamHandler( 
		    	new PumpStreamHandler(output, System.err, null));
		
		//execute the command and block for output 
		executor.execute( cmdLine );
		
		//set header to MIME type of image
		resp.setContentType("image/png");
				
		//write out data to the HTTP client		
		ServletOutputStream httpOut = resp.getOutputStream();		
		httpOut.write(output.toByteArray());
		try{
			output.close();
		}catch(Exception ex){
			log.debug( ex);
		}
	}
		
	Log log = LogFactory.getLog(WebImageCatpureProcess.class);
}
