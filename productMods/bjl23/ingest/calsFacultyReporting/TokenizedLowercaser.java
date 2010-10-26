package edu.cornell.mannlib.vitro.bjl23.ingest.calsFacultyReporting;

/**
 * This is a simplistic class for lowercasing words with initial caps
 * while leaving acronyms and initialisms untouched.
 * If the first character of a word is uppercase, and the second is not,
 * then the entire word is lowercase.  Otherwise it is copied directly
 * to the output string.
 */
public class TokenizedLowercaser {

	public String process( String in ) {

		StringBuffer out = new StringBuffer();

		String[] token = in.split(" ");
		for (int i=0; i<token.length; i++) {
			String s = token[i];
			if ( s.length() > 0 ) {
					if ( Character.isUpperCase(s.charAt(0)) && ( (s.length() == 1) || !(Character.isUpperCase(s.charAt(1)))) )  {
						out.append(s.toLowerCase());
					} else {
						out.append(s);
					}
					if ( i < (token.length-1) ) {
						out.append(" ");
					}
			}
		}

		return out.toString();

	}

}
