<html>
display info for a single grad field
${param.uri}

<div> department list
    <jsp:include page="/part/deptinfieldlist.jsp">
        <jsp:param name="uri" value="${param.uri}"/>
    </jsp:include></div>

<div> faculty in field
    <jsp:include page="/part/facultyinfieldlist.jsp">
        <jsp:param name="uri" value="${param.uri}"/>
    </jsp:include>
</div>

<div> keywords on faculty in Field
    <jsp:include page="/part/researchareasinfieldlist.jsp">
        <jsp:param name="uri" value="${param.uri}"/>
    </jsp:include>
</div>

</html>
