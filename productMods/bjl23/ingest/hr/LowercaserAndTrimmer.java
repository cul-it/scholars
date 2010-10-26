package edu.cornell.mannlib.vitro.bjl23.ingest.hr;

public class LowercaserAndTrimmer {

	public String process(String string) {
		if ( string == null ) {
			return null;
		}
		return string.toLowerCase().trim();
	}

}
