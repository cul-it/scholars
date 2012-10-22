package edu.cornell.mannlib.vivo.webimagecapture;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecuteResultHandler;
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
	
	private DefaultExecuteResultHandler resultHandler ;	

	/**use this to write to the process stdin */
	private PipedOutputStream toProcess; 
	
	/** use this to read to process stdout */
	private PipedInputStream fromProcess;
	
	private boolean started = false;
	private File workingDir = null;
	
	public WebImageCatpureProcess(File workingDir){
		this.workingDir = workingDir;		
	}
	
	public synchronized void returnImageV2(
			String webPageUrl, 
			HttpServletResponse resp) throws IOException{
		
		CommandLine cmdLine = new CommandLine( cmd );
		cmdLine.addArgument("\""+webPageUrl+"\"");
		
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
	
	public synchronized void returnImage(
			String webPageUrl, 
			HttpServletResponse resp) throws IOException{	
		if( !started )
			startProcess();
		
		toProcess.write( webPageUrl.getBytes() );
		toProcess.write("\r\n".getBytes() );		
		toProcess.flush();		
		
		//set header to MIME type of image
		resp.setContentType("image/png");
				
		//write out data		
		ServletOutputStream httpOut = resp.getOutputStream();
		
		byte[] buf = new byte[1024];
		int count = 0;
		while((count = this.fromProcess.read(buf)) >=0 ){
			httpOut.write(buf,0, count );
		}							
	}
	
	public void closeProcess(){		
		try {
			toProcess.flush();
		} catch (IOException e) {
			log.debug(e);
		}
		try {
			toProcess.close();
		} catch (IOException e) {
			log.debug(e);
		}
//		try {
//			fromProcess.close();
//		} catch (IOException e) {
//			log.debug(e);
//		}		
		started = false;
	}
	
	public synchronized void startProcess() throws IOException{
		if( started == true){		
			log.debug("attempt to restart process");
			return;
		}
		
		CommandLine cmdLine = new CommandLine( cmd );
		DefaultExecutor executor = new DefaultExecutor();
		executor.setWorkingDirectory(workingDir);	
		
//		PipedInputStream to = new PipedInputStream();		
//		this.toProcess = new PipedOutputStream( to );
//		
//		PipedOutputStream from = new PipedOutputStream();
//		this.fromProcess = new PipedInputStream( from );
//		
//		PumpStreamHandler streamHandler = new PumpStreamHandler(
//					from,
//					System.err, 
//					to);		

		 ByteArrayInputStream input =
		        new ByteArrayInputStream("http://vivo.cornell.edu".getBytes("ISO-8859-1"));
		 
	    ByteArrayOutputStream output = new ByteArrayOutputStream();
	    PumpStreamHandler streamHandler = 
	    	new PumpStreamHandler(output, System.err, input);
		    
		executor.setStreamHandler( streamHandler );				
		
		resultHandler = new DefaultExecuteResultHandler();
		executor.execute( cmdLine, resultHandler );
		
		started = true;
	}

	Log log = LogFactory.getLog(WebImageCatpureProcess.class);
}
