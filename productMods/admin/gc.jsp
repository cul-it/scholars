<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%@page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.Controllers" %>
<%@ page import="org.joda.time.DateTime"%>

<%@page import="org.apache.commons.logging.LogFactory"%>
<%@page import="org.apache.commons.logging.Log"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%-- <%@ taglib prefix="vitro" uri="/WEB-INF/tlds/VitroUtils.tld" %> --%>

<%-- <vitro:confirmLoginStatus level="DBA" /> --%>

<% 
  Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.edit.processRdfForm2.jsp");
  long startBytesFree = Runtime.getRuntime().freeMemory();
  log.info("starting full GC");    
  System.gc(); 
  long endBytesFree = Runtime.getRuntime().freeMemory();
  log.info("finished full GC");
%>

<%= new DateTime() %> finished_full_GC  <%= startBytesFree %>b  <%= endBytesFree %>b
