package edu.cornell.mannlib.vitro.bjl23.ingest.hr;

public class HRNameProcessor {

	public String process(String string) {
		return string.replaceAll(",",", ");
	}

}
