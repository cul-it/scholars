package edu.cornell.mannlib.vitro.bjl23.ingest.calsFacultyReporting;

public class LongKeywordRemover {

	public String process (String in) {
		String[] tokens = in.split(" ");
		if (tokens.length > 6) {
			return "";
		} else {
			return in;
		}
	}		

}
