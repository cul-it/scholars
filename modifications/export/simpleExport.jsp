<%@ page import="com.hp.hpl.jena.ontology.OntModel" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="com.hp.hpl.jena.rdf.model.RDFNode" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Statement" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Property" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Literal" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%@ page contentType="text/plain; charset=UTF-8"%>

<%
final String rdf  = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
final String dc   = "http://purl.org/dc/elements/1.1/";
final String rdfs = "http://www.w3.org/2000/01/rdf-schema#";
final String owl  = "http://www.w3.org/2002/07/owl#";
final String vitro = "http://vitro.mannlib.cornell.edu/ns/vitro/0.7#";
final String vivo  = "http://vivo.library.cornell.edu/ns/0.1#";
final String akts  = "http://www.aktors.org/ontology/support#";
final String aktp  = "http://www.aktors.org/ontology/portal#";
final String hr    = "http://vivo.cornell.edu/ns/hr/0.9/hr.owl#";
final String mann  = "http://vivo.cornell.edu/ns/mannadditions/0.1#";
final String socsci= "http://vivo.library.cornell.edu/ns/vivo/socsci/0.1#";
final String thomson="http://vivo.mannlib.cornell.edu/ns/ThomsonWOS/0.1#";

ServletContext context = getServletConfig().getServletContext();

OntModel model = (OntModel) context.getAttribute("baseOntModel");

// from SelfEditingPolicy.java
HashSet<String> vitroWhitelistedProps = new HashSet<String>();
vitroWhitelistedProps.add(VitroVocabulary.MONIKER);
vitroWhitelistedProps.add(VitroVocabulary.BLURB);
vitroWhitelistedProps.add(VitroVocabulary.MODTIME);
vitroWhitelistedProps.add(VitroVocabulary.TIMEKEY);
vitroWhitelistedProps.add(VitroVocabulary.CITATION);
vitroWhitelistedProps.add(VitroVocabulary.IMAGEFILE);
vitroWhitelistedProps.add(VitroVocabulary.IMAGETHUMB);
vitroWhitelistedProps.add(VitroVocabulary.LINK);
vitroWhitelistedProps.add(VitroVocabulary.PRIMARY_LINK);
vitroWhitelistedProps.add(VitroVocabulary.ADDITIONAL_LINK);
vitroWhitelistedProps.add(VitroVocabulary.LINK_ANCHOR);
vitroWhitelistedProps.add(VitroVocabulary.LINK_URL);
vitroWhitelistedProps.add(VitroVocabulary.KEYWORD_INDIVIDUALRELATION);
vitroWhitelistedProps.add(VitroVocabulary.KEYWORD_INDIVIDUALRELATION_INVOLVESKEYWORD);
vitroWhitelistedProps.add(VitroVocabulary.KEYWORD_INDIVIDUALRELATION_INVOLVESINDIVIDUAL);
vitroWhitelistedProps.add(VitroVocabulary.KEYWORD_INDIVIDUALRELATION_MODE);

// mysql won't accept tablenames longer than 64 bytes
HashMap<String,String> longTablenames = new HashMap<String,String>();
longTablenames.put("vivo_AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember","vivo_hasGraduateFieldMember");
longTablenames.put("vivo_OrganizedEndeavorHasOtherParticipantLiaisonCornellLibrarian","vivo_hasLibraryLiaison");
longTablenames.put("vivo_EducationalOrganizationOtherParticipantAsAcademicAffiliateInOrganizedEndeavor","vivo_organizationIsAcademicAffiliateOf");
longTablenames.put("vivo_GeographicalRegionReferencedAsAffectedAreaInImpactStatement","vivo_regionReferencedInImpactStatement");
longTablenames.put("vivo_GeographicalRegionAssociatedWithActivitiesOfOrganizedEndeavor","vivo_regionAssociatedWithOrganizedEndeavor");
longTablenames.put("vivo_AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative","vivo_memberOfGraduateField");
longTablenames.put("vivo_OrganizedEndeavorIsAdministrativeOrganizationForOrganizedEndeavor","vivo_isAdminOrganizationFor");
longTablenames.put("vivo_OrganizedEndeavorHasOtherParticipantAcademicAffiliateEducationalOrganization","vivo_hasAcademicAffiliateOrganization");


HashMap<String,String> namespaceHash = new HashMap<String,String>();
for (Iterator iter = model.listNameSpaces(); iter.hasNext();) {
    String theName = (String)iter.next();
    if (vitro.equals(theName)) {
    	namespaceHash.put(theName,"vitro_");
    } else if (dc.equals(theName)) {
        namespaceHash.put(theName,"dc_");
    } else if (rdf.equals(theName)) {
        namespaceHash.put(theName,"rdf_");
    } else if (rdfs.equals(theName)) {
        namespaceHash.put(theName,"rdfs_");
    } else if (vivo.equals(theName)) {
        namespaceHash.put(theName,"vivo_");
    } else if (owl.equals(theName)) {
        namespaceHash.put(theName,"owl_");
    } else if (akts.equals(theName)) {
        namespaceHash.put(theName,"akts_");
    } else if (aktp.equals(theName)) {
        namespaceHash.put(theName,"aktp_");
    } else if (hr.equals(theName)) {
        namespaceHash.put(theName,"hr_");
    } else if (mann.equals(theName)) {
        namespaceHash.put(theName,"mann_");
    } else if (socsci.equals(theName)) {
        namespaceHash.put(theName,"socsci_");
    } else if (thomson.equals(theName)) {
        namespaceHash.put(theName,"thomson_");
    } else {
        System.out.println("Found unexpected namespace "+theName+"; not added to HashMap");
    }
}

HashSet<Property> propsHash = new HashSet<Property>();

for (Iterator iter = model.listStatements(); iter.hasNext();) {
    propsHash.add(((Statement)iter.next()).getPredicate());
}

for (Property p : propsHash) {
    // find out which namespace it has
    String prefix = namespaceHash.get(p.getNameSpace());
    if (prefix != null) {
        // remove any hyphen in localName
        String localName = p.getLocalName();
        if (localName!=null && localName.indexOf("Non-Academic")>=0) {
            System.out.println("attempting to remove hyphen from "+localName);
            int pos = localName.indexOf("Non-Academic");
            if (pos==0) {
            	localName = "NonAcademic"+localName.substring(12);
            } else {
                localName = localName.substring(0,pos)+"NonAcademic"+localName.substring(pos+12);
            }
            System.out.println("new localName: "+localName);
        }
        String newTableName = prefix + localName;
    	if (prefix.equals("vitro_")) {
    	    if (!vitroWhitelistedProps.contains(p.getURI())) {
    	        continue;
    	    }
    	} else if (prefix.equals("vivo_")) {
    	    String shorterName = longTablenames.get(newTableName);
    	    if (shorterName != null) {
    	        System.out.println("replacing "+newTableName+" with "+shorterName+"\n");
    	        newTableName = shorterName;
    	    }
    	}
    	newTableName = org.apache.commons.lang.StringEscapeUtils.escapeSql(newTableName); // can't deal with hyphens in table names
    	%>
        create table <%=newTableName%> (subj text, obj text);
<%      // iterate through to find all the statements in the model for this property
    	for (Iterator iter = model.listStatements((Resource)null,p,(RDFNode)null); iter.hasNext();) {
    	    Statement stmt = (Statement)iter.next();
    	    String subj = stmt.getSubject().getURI();
    	    if (subj == null) {
    	    	subj = stmt.getSubject().getId().toString();
    	    }
    	    RDFNode obj = stmt.getObject();
    	    String value=null;
    	    if (obj.isResource()) {
    	        Resource r = (Resource)obj;
    	        value = r.getURI();
    	        if (value == null) {
    	            value = r.getId().toString();
    	        }
    	    } else { // a literal
    	        Literal lit = (Literal)obj;
    	    	value = lit.getLexicalForm();
    	    }
    	    %>
    		insert into <%=newTableName%>(subj,obj) values ('<%=org.apache.commons.lang.StringEscapeUtils.escapeSql(subj)%>','<%=org.apache.commons.lang.StringEscapeUtils.escapeSql(value)%>');
<%		}
	}
}

%>