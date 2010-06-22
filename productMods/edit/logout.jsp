<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%@ page contentType="text/html; charset=UTF-8"%>

<%
    VitroRequestPrep.forceOutOfSelfEditing(request);
%>
        <c:redirect url="/"/>
<%
        return;
%>