<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingIdentifierFactory"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.LoginEvent"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.controller.edit.Authenticate"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundleFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>

<jsp:include page="../edit/formPrefix.jsp"/>

<h3>Check Blacklist</h3>

<p>This is a test of the VIVO specific blacklisting.  Several Colleges have requested
that their faculty members be prohibited from editing their profiles in the VIVO
system.  This page allows one to test if a given NetId is prohibited from editing
access.</p>

<p>You do not need to be logged in to use this form.  The results of the form are
based on the SelfEditIdentifierFactory and the NetId you enter.  They do not use
any other parts of the Authentication system.  </p>
<%
    ServletIdentifierBundleFactory factories = ServletIdentifierBundleFactory.getIdentifierBundleFactory(application);
    SelfEditingIdentifierFactory selfEditFactory = null;
    for( IdentifierBundleFactory fac : factories )
        if( fac instanceof SelfEditingIdentifierFactory)
            selfEditFactory = (SelfEditingIdentifierFactory)fac;                    
        
    if( selfEditFactory != null ){
        String netid = request.getParameter("netid");
        if( netid != null ){            
           %><h3>Is there a user in the system for the Cornell NetId <em><%=netid%></em>?</h3><%
                   
           VitroRequest vreq = new VitroRequest(request);
           WebappDaoFactory wdf = vreq.getWebappDaoFactory();    
           String uri = null;
           Individual ind = null;
           boolean individualFound = false;           
           try{
               if( netid != null )
                   uri =wdf.getIndividualDao().getIndividualURIFromNetId(netid);    
               if( uri != null )
                   ind = wdf.getIndividualDao().getIndividualByURI(uri);                      
               if( uri == null || ind == null ){
                   %><p>No individual in the system has the NetId <%=netid%>.</p><%
               } else {
                   individualFound = true;
                   %><p>There is an individual in the system for the NetId <%=netid%>.</p><%
               }
           }catch(RuntimeException rx){
               String exStr = rx.toString();
               %><p>There was an error looking up the NetId.</p>
               <!--  <%=exStr%> -->
               <%
           }    

           if( individualFound ){
               String name = ind.getName();
               %><h3>Is <em><%=name%></em> blacklisted?</h3><%
               String cause = selfEditFactory.checkForBlacklisted(ind,application);
               if( cause !=  null ){
                   %><p>Yes, and the cause for that is <em><%=cause%></em>.</p><%
               }else{
                   %><p>No, <em><%=name%></em> should be able to log in and self edit. </p><%
               }
           }
        }
        %><jsp:include page="checkblacklistform.jsp"/><%
    } else { 
        %><p>Self Editing and logging in via CUWebAuth is not enabled on this system.</p><%
    }    
%>   
<jsp:include page="../edit/formSuffix.jsp"/>