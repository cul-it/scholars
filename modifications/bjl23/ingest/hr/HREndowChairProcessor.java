package edu.cornell.mannlib.vitro.bjl23.ingest.hr;

public class HREndowChairProcessor {

    public String process (String endowChair) {
        String[] words = endowChair.split(" ");
        for (int i=0; i<words.length; i++) {
            words[i]=words[i].toLowerCase();
            if ((words[i].length()>1) && !(words[i].equals("of") || words[i].equals("in"))) {
                String init = words[i].substring(0,1);
                init=init.toUpperCase();
                words[i] = init+words[i].substring(1);
            }
        }
        String endowChairStr = "";
        for (int i=0; i<words.length; i++) {
            endowChairStr += words[i];
            if (i+1 < words.length)
                endowChairStr += " ";
        }
        return endowChairStr;
    }

}
