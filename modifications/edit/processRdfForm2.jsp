<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ResourceFactory" %>
<%@ page import="com.hp.hpl.jena.shared.Lock" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%-- 2nd prototype of processing.

This one takes two lists of n3, on required and one optional.  If
all of the variables in the required n3 are not bound or it cannot
be processed as n3 by Jena then it is an error in processing the form.
The optional n3 blocks will proccessed if their variables are bound and
are well formed.

{
    "n3required"    : [ ${n3ForEdit} ],
    "n3optional"    : [ ],
    "newResources"  : { "newCourse" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"   : ["subject" : ${subjectUri},
                       "predicate":${predicateUri},
                       "building" :${building}],
    "literalsInScope": [ ],
    "urisOnForm"    : ["object" ],
    "literalsOnForm":  [ ],
    "sparqlForAdditonalLiteralsInScope" : [ ],
    "sparqlForAdditonalUrisInScope":[ "inverse" : ${queryForInverse} ],
    "entityToReturnTo" : [ ${subjectUri} ],
    "basicValidation" : {"object" : ["nonempty",  "inmodel" ] }
    "optionsForFields" : {
        "object" : "http://vivo.cornell.edu/ns/0.1#someVitroClass",
        "buildings" : "http://vivo.cornell.edu/ns/0.1#Building",
        "moniker" : ["first person", "second person", "third person"]
    }
}
--%>
<%
    System.out.println("in processRdfForm2.jsp");
    if( session == null)
        throw new Error("need to have session");
%>
<%
    if (!VitroRequestPrep.isSelfEditing(request) && !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
        %><c:redirect url="/about.jsp"></c:redirect>      <%
    }

    List<String>  errorMessages = new ArrayList<String>();
    Model jenaOntModel =  (Model)application.getAttribute("jenaOntModel");
    Model persistentOntModel = (Model)application.getAttribute("persistentOntModel");

    String editJson = (String)session.getAttribute("editjson");
    if( editJson == null || editJson.trim().length() == 0 )
            throw new Error("need edit object in session");

    System.out.println("editJson:\n" + editJson);


    EditConfiguration editConfig = new EditConfiguration(editJson);

    EditSubmission submission = new EditSubmission(request,editConfig);
    Map<String,String> errors =  submission.getValidationErrors();
    EditSubmission.putEditSubmissionInSession(session,submission);

    if(  errors != null && ! errors.isEmpty() ){
        System.out.println("seems to be a validation error");
        String form = editConfig.getFormUrl();
        request.setAttribute("formUrl", form);
        %><jsp:forward page="${formUrl}"/><%
      	return;
                }

                List<String> n3Required = editConfig.getN3Required();
                List<String> n3Optional = editConfig.getN3Optional();

                /* ****************** URIs and Literals in Scope ************** */
                Map<String,String> urisInScope = editConfig.getUrisInScope();
                n3Required = subInUris( urisInScope, n3Required);
                n3Optional = subInUris( urisInScope, n3Optional);

                //sub in values from sparql queries
                SparqlEvaluate sparqlEval = new SparqlEvaluate((Model)application.getAttribute("jenaOntModel"));
                Map<String,String> varToUris = sparqlEval.sparqlEvaluateToUris(editConfig.getSparqlForAdditionalUrisInScope());
                n3Required = subInUris(varToUris, n3Required);
                n3Optional = subInUris(varToUris, n3Optional);

                Map<String,String> varToLiterals = sparqlEval.sparqlEvaluateToUris(editConfig.getSparqlForAdditionalLiteralsInScope());
                n3Required = subInLiterals(varToLiterals, n3Required);
                n3Optional = subInLiterals(varToLiterals, n3Optional);

                /* ****************** New Resources ********************** */
                Map<String,String> varToNewResource = newToUriMap(editConfig.getNewResources(),jenaOntModel);

                n3Required = subInUris( varToNewResource, n3Required);
                n3Optional = subInUris( varToNewResource, n3Optional);

                /* ********** URIs and Literals on Form/Parameters *********** */

                
                //sub in resource uris off form
                n3Required = subInUris(submission.getUrisFromForm(), n3Required);
                n3Optional = subInUris(submission.getUrisFromForm(), n3Optional);

                //sub in literals from form
                n3Required = subInLiterals(submission.getLiteralsFromForm(), n3Required);
                n3Optional = subInLiterals(submission.getLiteralsFromForm(), n3Optional);

                /* ***************** Build Models ******************* */
                request.setAttribute("n3RequiredProcessed",n3Required);
                request.setAttribute("n3OptionalProcessed",n3Optional);
                
                List<Model> requiredNewModels = new ArrayList<Model>();
                for(String n3 : n3Required){
                    try{
                        Model model = ModelFactory.createDefaultModel();
                        StringReader reader = new StringReader(n3);
                        model.read(reader, "", "N3");
                        requiredNewModels.add(model);
                    }catch(Throwable t){
                        errorMessages.add("error processing required n3 string \n"+
                                t.getMessage() + '\n' +
                                "n3: \n" + n3 );
                    }
                }
                if( !errorMessages.isEmpty() ){
                    System.out.println("problems processing required n3: \n" );
                    for( String error : errorMessages){
                        System.out.println(error);
                    }
                    throw new JspException("errors processing required n3, check catalina.out");
                }

                List<Model> optionalNewModels = new ArrayList<Model>();
                for(String n3 : n3Optional){
                    try{
                        Model model = ModelFactory.createDefaultModel();
                        StringReader reader = new StringReader(n3);
                        model.read(reader, "", "N3");
                        optionalNewModels.add(model);
                    }catch(Throwable t){
                        errorMessages.add("error processing optional n3 string  \n"+
                                t.getMessage() + '\n' +
                                "n3: \n" + n3);

                    }
                }
                 if( !errorMessages.isEmpty() ){
                    System.out.println("problems processing optional n3: \n" );
                    for( String error : errorMessages){
                        System.out.println(error);
                    }
                    //throw new JspException("errors processing optional n3, check catalina.out");
                }
                
                //The requiredNewModels and the optionalNewModels should be handled differently
                //but for now we'll just do them the same
                requiredNewModels.addAll(optionalNewModels);

                Lock lock = null;
                try{
                    lock =  persistentOntModel.getLock();
                    lock.enterCriticalSection(Lock.WRITE);
                    for( Model model : requiredNewModels )
                        persistentOntModel.add(model);
                }catch(Throwable t){
                    errorMessages.add("error adding required model to persistent model \n"+ t.getMessage() );
                }finally{
                    lock.leaveCriticalSection();
                }

                 try{
                    lock =  jenaOntModel.getLock();
                    lock.enterCriticalSection(Lock.WRITE);
                    for( Model model : requiredNewModels)
                        jenaOntModel.add(model);
                }catch(Throwable t){
                    errorMessages.add("error processing required model to in memory model \n"+ t.getMessage() );
                }finally{
                    lock.leaveCriticalSection();
                }
      %>

<jsp:forward page="postEditCleanUp.jsp"/>

<%!

    /* ********************************************************* */
    /* ******************** utility functions ****************** */
    /* ********************************************************* */


    public List<String> subInUris(Map<String,String> varsToVals, List<String> targets){
        if( varsToVals == null || varsToVals.isEmpty() ) return targets;
        ArrayList<String> outv = new ArrayList<String>();
        for( String target : targets){
            String temp = target;
            for( String key : varsToVals.keySet()) {
                temp = subInUris( key, varsToVals.get(key), temp)  ;
            }
            outv.add(temp);
        }
        return outv;
    }


    public String subInUris(String var, String value, String target){
        if( var == null || var.length() == 0 || value==null )
            return target;
        String varRegex = "\\?" + var;
        String out = target.replaceAll(varRegex,"<"+value+">");
        if( out != null && out.length() > 0 )
            return out;
        else
            return target;
    }

    public List<String>subInUris(String var, String value, List<String> targets){
        ArrayList<String> outv =new ArrayList<String>();
        for( String target : targets){
            outv.add( subInUris( var,value, target) ) ;
        }
        return outv;
    }

    public List<String> subInLiterals(Map<String,String> varsToVals, List<String> targets){
        if( varsToVals == null || varsToVals.isEmpty()) return targets;

        ArrayList<String> outv =new ArrayList<String>();
        for( String target : targets){
            String temp = target;
            for( String key : varsToVals.keySet()) {
                temp = subInLiterals( key, varsToVals.get(key), temp);
            }
            outv.add(temp);
        }
        return outv;
    }

    public List<String>subInLiterals(String var, String value, List<String> targets){
        ArrayList<String> outv =new ArrayList<String>();
        for( String target : targets){
            outv.add( subInLiterals( var,value, target) ) ;
        }
        return outv;
    }

    public String subInLiterals(String var, String value, String target){
        String varRegex = "\\?" + var;
        String out = target.replaceAll(varRegex,'"'+value+'"');  //*** THIS  NEEDS TO BE ESCAPED!
        if( out != null && out.length() > 0 )
            return out    ;
        else
            return target;
    }

    public Map<String,String> newToUriMap(Map<String,String> newResources, Model model){
        HashMap<String,String> newUris = new HashMap<String,String>();
        for( String key : newResources.keySet()){
            newUris.put(key,makeNewUri(newResources.get(key), model));
        }
         return newUris;
    }

    public String makeNewUri(String prefix, Model model){
        if( prefix == null || prefix.length() == 0 || "default".equalsIgnoreCase(prefix) )
            prefix = defaultUriPrefix;
        
        String uri = prefix + random.nextInt();
        Resource r = ResourceFactory.createResource(uri);
        while( model.containsResource(r) ){
            uri = prefix + random.nextInt();
            r = ResourceFactory.createResource(uri);
        }
        return uri;
    }

    static Random random = new Random();
    static String defaultUriPrefix = "http://vivo.library.cornell.edu/ns/0.1#individual";

//    public String getNewUri(){
//        return "http://vivo.cornell.edu/ns/need/way/to/make/new/uri/bunk#" + random.nextInt();
//    }

%>
