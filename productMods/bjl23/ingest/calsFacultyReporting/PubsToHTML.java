package edu.cornell.mannlib.vitro.bjl23.ingest.calsFacultyReporting;

public class PubsToHTML {

	public String process (String pubStr) {

		if (pubStr == null || pubStr.length()<1) {
			return null;
		}

		String html = "<ul>";

		String[] pubs = pubStr.split("||");
		for (int i=0; i<pubs.length; i++) {
			html += "<li>" + pubs[i] + "</li>";
		}

		html += "</ul>";

		return html;

	}

}
