<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<c:set var="n3ForEdit" scope="page" >
    PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        ?EdBackground
          vivo:year       ?year;
          vivo:degree     ?degree;
          vivo:instution  ?instution;
          vivo:majorfield ?majorfield.

        ?EdBackground rdf:type vivo:EdBackground.
        ?Person vivo:hasEdBackground ?EdBackground.
</c:set>



<%
    //set n3rdf in session scope

    request.getSession(true);
    String n3rdf = (String)pageContext.getAttribute("n3ForEdit");
    session.setAttribute("n3",n3rdf);

    //set other structures in session scope

    List<String> newResources  = new ArrayList();
    newResources.add("EdBackground");
    session.setAttribute("newResources", newResources);

    Map<String,String> varsInScope = new HashMap<String,String>();
    varsInScope.put("Person","vivo:individual585858");
    varsInScope.put("EdBackground","vivo:individual2833ii3");
    session.setAttribute("varsInScope",varsInScope);

    List<String> varsOnForm = new ArrayList();
    varsOnForm.add("year");
    varsOnForm.add("degree");
    varsOnForm.add("instution");
    varsOnForm.add("majorfield");
    session.setAttribute("varsOnForm", varsOnForm);

//draw form

%>

<html>

<body>
<h1>test form</h1>
  <form action="processRdfForm.jsp">

      year<input type="text" name="year"/>
      degree<input type="text" name="degree"/>
      instution<input type="text" name="instution"/>
      majorfield<input type="text" name="majorfield"/>

      <input type=submit />

  </form>

<p/>
<code>
  <c:out value="${sessionScope.n3}" escapeXml="false"/>
</code>

<p/>
<c:url var="url" value="/edit/forms/defaultObjPropForm.jsp">
    <c:param name="subjectUri" value="http://vivo.library.cornell.edu/ns/0.1#individual25316"/>
    <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonHasResearchArea" />
</c:url>
<a href="${url}">test default object prop form</a>


<p/>
<c:url var="url" value="/edit/editRequestDispatch.jsp">
    <c:param name="subjectUri" value="http://vivo.library.cornell.edu/ns/0.1#individual25316"/>
    <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonTeacherOfSemesterCourse" />
</c:url>
<a href="${url}">test PersonTeacherOfSemesterCourse form</a>


<a href="testreferer.jsp"> test referer.jsp</a>
</body>
</html>
