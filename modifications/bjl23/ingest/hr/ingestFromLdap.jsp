
<%@page import="java.util.Enumeration"%>
<%@page import="com.novell.ldap.LDAPAttributeSet"%>
<%@page import="com.novell.ldap.LDAPAttribute"%>
<%@page import="com.novell.ldap.LDAPEntry"%>
<%@page import="com.novell.ldap.LDAPConstraints"%>
<%@page import="com.novell.ldap.LDAPConnection"%>
<%@page import="com.novell.ldap.LDAPException"%>
<%@page import="com.novell.ldap.LDAPSearchResults"%>
<%
	// code copied from CheckFacultyInLdap.java
%>

<%!

private String makeLdapSearchFilter(String fullname){
	int comma = fullname.indexOf(','),space1=-1,space2=-1;
	if(comma<0){
		System.out.print("name lacks a comma: " + fullname);
		return null;
	}
	StringBuffer filter=new StringBuffer("(&(!(type=student*))"); //no students from ldap
	String cn=null, strictGivenNames=null, looseGivenNames=null;
	String first=null,middle=null,last=null; 
	last=fullname.substring(0,comma).trim();
	space1=fullname.indexOf(' ',comma+1);
	space2=fullname.indexOf(' ',space1+1);
	if(space2 < 0){ //nothing after first name
		first=fullname.substring(space1).trim();
	}else{ //there is a middle name there
		first=fullname.substring(space1,space2).trim();
		middle=fullname.substring(space2+1).trim();
	}
	
	if(first!=null && first.indexOf('(')>0)
		first=first.replace('(',' ');
	if(first!=null && first.indexOf(')')>0)
		first=first.replace(')',' ');
	
	if(middle!=null && middle.indexOf('(')>0)
		middle=middle.replace('(',' ');		
	if(middle!=null && middle.indexOf(')')>0)
		middle=middle.replace(')',' ');
	
	if(first!=null) //check for initials
		if(first.indexOf('.')>0)
			first=first.replace('.','*');
		else
			first=first+"*";

	if(middle!=null) //check for initials
		if( middle.indexOf('.')>0)
			middle=middle.replace('.','*');
		else
			middle=middle+"*";
	
	cn="(cn="; //put together common name query
	if(first!=null){
		if(middle!=null)
			cn=cn+first+middle;
		else
			cn=cn+first;
	}
	cn=cn+last+")";
	filter.append(cn);		
		
	filter.append(")");		
	return filter.toString();
}

	/**
   @param searchFilter - eduora uses the searchFilter:(|(cn=*^0*)(uid=*^0*)(edupersonnickname=*^0*)) where 
   ^0 gets replaced by the search str.
   @param attributes - the attributes that you want from ldap, one att name per an array item. ex:
   String[] attr = new String[] {"cornelledunetid","cn","cornelledutype","mail","mailRoutingAddress"};
*/
public LDAPSearchResults searchLdap(String searchFilter)throws LDAPException{

	int ldapPort = LDAPConnection.DEFAULT_PORT;
	int searchScope = LDAPConnection.SCOPE_SUB;
	int ldapVersion  = LDAPConnection.LDAP_V3;        
	String ldapHost = "directory.cornell.edu";
	String loginDN  = ""; //no login id needed
	String password = "";// no password needed	  

	String searchBase = "o=Cornell University, c=US";
	String attributes[]={LDAPConnection.ALL_USER_ATTRS,"cn"};
	
	LDAPConnection lc = new LDAPConnection();
	LDAPSearchResults thisResult = null;
	try {
		lc.connect( ldapHost, ldapPort );

		LDAPConstraints constraints = new LDAPConstraints(0,true,null,0);
		lc.bind( ldapVersion, loginDN, password, constraints );

		thisResult = lc.search(  searchBase, searchScope, searchFilter, attributes, false);
	} catch( LDAPException e ) {
		System.out.println( "error: " + e );
		String serverError = null;
		if( (serverError = e.getLDAPErrorMessage()) != null) 
			System.out.println("Server: " + serverError);
		return null;
	}
	return thisResult;
}

/**
   tab delimited output string fomrat:	   
   name	netId	deptHRcode	type	moniker	keywords	URL	anchor
*/
private String ldapResult2String(LDAPSearchResults res, String orgName,String ldapFilter){
	/*the strings are ldap attribute names for tab field i*/
	String map[][]= {
		//	{"cn","displayName"}, //we'll use the original vivo name
		{"mail","uid"},       
		{"cornelledudeptname1","cornelledudeptname2"},
		{"cornelledutype","edupersonprimaryaffiliation"},
		{"cornelleduwrkngtitle1","cornelleduwrkngtitle2"},
		{},
		{"labeledUri"},
		{"description"},
		{"cornelledudeptname2"}};
	StringBuffer output=new StringBuffer("");
	output.append(orgName).append("\t"); //just stick the original name on the front.
	while(res.hasMoreElements()){
		LDAPEntry entry = null;
		Object obj = res.nextElement();
		if (obj instanceof LDAPException) {
			((LDAPException)obj).printStackTrace();
		} else {
			entry=(LDAPEntry)obj;	
		}			
		//for tab field i look in map[i] for ldap attribute names, output first non-null value
		for(int iField=0;iField<map.length;iField++){
			
			for(int iName=0;iName< map[iField].length; iName++){
				LDAPAttribute lAtt=entry.getAttribute(map[iField][iName]);

				if(lAtt!=null){
					String value=lAtt.getStringValue();
					if(value!=null && value.length()>0 ){
						output.append(value);
						break;
					}
				}
			}
			output.append("\t");
		}
		output.append(ldapFilter);
		if(res.hasMoreElements()){
			output.append("\n").append(orgName).append("\t");
		}
	}
	return output.toString();
}

%>


<%

 //   String filter = makeLdapSearchFilter("Lowe, Brian");
	String filter = "(&(!(type=student*))(cornelledunetid=bjl23))";
	out.print(filter+"\n\n");
	LDAPSearchResults results = searchLdap(filter);
	while (results.hasMoreElements()) {
		LDAPEntry entry = (LDAPEntry) results.next();
		LDAPAttributeSet las = entry.getAttributeSet();
		Enumeration lasEnumeration = las.getAttributes();
		while (lasEnumeration.hasMoreElements()) {
			LDAPAttribute att = (LDAPAttribute) lasEnumeration.nextElement();
			out.write(att.getName()+" : "+att.getStringValue()+"\n");
		}
		out.write("\n-------------------------------------------------\n\n");
	}
	
	//String resultStr = ldapResult2String(results, "test", filter);
	//out.write(resultStr);
	out.flush();

%>