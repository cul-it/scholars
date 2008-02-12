<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%
    /*
    Issues:
    authorization
       Can we process the result models to create RequestedAction objects?
    updating
       We can create a existingState model and then after the form submission,
       we can take the difference of the existingState and the result model
       to create a list of retractions.

       retractions = relative complement( existingModel, intersection ( resultModel, existingModel))
       additions   = relative complement( resultModel, intersection (resultModel, existingModel))
    
    */

    if( session == null)
        throw new Error("need to have session");

    %>
%>
<c:if test="${sessionScope.loginHandler == null ||
              sessionScope.loginHandler.loginStatus != 'authenticated' ||
              sessionScope.loginHandler.loginRole < sessionScope.loginHandler.editor }">
    <c:redirect url="/about"/>
</c:if>

    <%

    //get n3rdf from scope
    String n3 = (String)session.getAttribute("n3");
    if( n3 == null || n3.trim().length() == 0 )
            throw new Error("need n3 in session");

    //make new resources
    Model model = ModelFactory.createDefaultModel();
    Random random = new Random();

    List<String> newResources = (List<String>)session.getAttribute("newResources");
    if( newResources == null )
        throw new Error("need newResources in session");

    HashMap <String,Resource> varToNewResource = new HashMap<String,Resource>();
    for( String var : newResources ){
        Resource resource = model.createResource("http://needWaytoMakeNewURI/individual"+ random.nextInt() );
        varToNewResource.put(var,resource);
    }

    //sub in var in scope
    Map<String,String> urisInScope = (Map<String,String>)session.getAttribute("urisInScope");
    for( String var : urisInScope.keySet()){
        String varRegex = "\\?" + var;
        n3 = n3.replaceAll(varRegex,"<"+urisInScope.get(var) +">");
    }

    //sub new resources' URIs into n3rdf
    for( String var : varToNewResource.keySet()){
        String varRegex = "\\?" + var;
        n3 = n3.replaceAll(varRegex,"<"+varToNewResource.get(var).getURI() +">");
    }

    //sub in resource uris from form
    for( String var : (List<String>)session.getAttribute("urisOnForm")){
        String varRegex = "\\?" + var;
        n3 = n3.replaceAll(varRegex,'<'+ request.getParameter(var) +'>');
    }

    //sub in literals from form
    for( String var : (List<String>)session.getAttribute("literalsOnForm")){
        String varRegex = "\\?" + var;
        n3 = n3.replaceAll(varRegex,'"'+ request.getParameter(var) +'"');
    }

    request.setAttribute("n3processed",n3);

    try{
        //add the n3 to the model
        StringReader reader = new StringReader(n3);

        model.read(reader, "", "N3");

        Model persistentOntModel = (Model)application.getAttribute("persistentOntModel");
        Model jenaOntModel =  (Model)application.getAttribute("jenaOntModel");
        
        persistentOntModel.add(model);
        jenaOntModel.add(model);

    }catch(Throwable t){
        %><%=t.getMessage()%> <%
        return;
    }
    request.setAttribute("forwardToThisEntity", session.getAttribute("requestedFromEntity"));
%>

<jsp:forward page="postEditCleanUp.jsp"/>



