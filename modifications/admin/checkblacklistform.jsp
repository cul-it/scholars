<div>
<% if( request.getParameter("netid") == null ) { %>
<p>Please enter a Cornell NetId to check:</p>
<% }else{ %>
<h3>Check Another NetId</h3>
<p>Enter another Cornell NetId to check:</p>
<% } %>
<form action="checkblacklist.jsp">
   <input type="text" name="netid"></input>
   <input type="submit"/>
</form>
</div>
