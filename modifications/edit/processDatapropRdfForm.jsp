<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ResourceFactory" %>
<%@ page import="com.hp.hpl.jena.shared.Lock" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%-- 2nd prototype of processing, adapted for data property editing

This one takes one list of n3 for a single data property statement field,
and there will be no optional fields.  If the variables in the required n3
are not bound or it cannot be processed as n3 by Jena then it is an error
in processing the form.
--%>
<%
    Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.processDatapropRdfForm.jsp");
    log.debug("Starting processDatapropRdfForm.jsp");

    if( session == null)
        throw new Error("need to have session");
%>
<%
    if (!VitroRequestPrep.isSelfEditing(request) && !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
        %><c:redirect url="/about.jsp"></c:redirect><%
    }

    List<String> errorMessages = new ArrayList<String>();
    Model jenaOntModel = (Model)application.getAttribute("jenaOntModel");
    Model persistentOntModel = (Model)application.getAttribute("persistentOntModel");

    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    EditSubmission submission = new EditSubmission(request,jenaOntModel,editConfig);

    Map<String,String> errors = submission.getValidationErrors();
    EditSubmission.putEditSubmissionInSession(session,submission);

    if( errors != null && ! errors.isEmpty() ){
        String form = editConfig.getFormUrl();
        request.setAttribute("formUrl", form);
        %><jsp:forward page="${formUrl}"/><%
        return;
    }

    EditN3Generator n3Subber = editConfig.getN3Generator();
    List<String> n3Required = editConfig.getN3Required();

    Map<String,List<String>> fieldAssertions = null;
    String subjectUri=null, predicateUri=null;
    Individual subject=null;
    if( editConfig.getDatapropKey() != null && editConfig.getDatapropKey().length() > 0){
        // we are editing an existing data property statement
        subjectUri   = editConfig.getSubjectUri();
        if (subjectUri == null || subjectUri.trim().length()==0) {
            log.error("No subjectUri parameter available via editConfig for datapropKey "+editConfig.getDatapropKey());
            throw new Error("No subjectUri parameter available via editConfig in processDatapropRdfForm.jsp");
        }
        predicateUri = editConfig.getPredicateUri();
        if (predicateUri == null || predicateUri.trim().length()==0) {
            log.error("No predicateUri parameter available via editConfig for datapropKey "+editConfig.getDatapropKey());
            throw new Error("No predicateUri parameter available via editConfig in processDatapropRdfForm.jsp");
        }

        VitroRequest vreq = new VitroRequest(request);
        WebappDaoFactory wdf = vreq.getWebappDaoFactory();

        // need to get subject because have to iterate through all its data property statements to match datapropKey hashcode
        subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
        if( subject == null ) {
            log.error("Could not find subject Individual via editConfig's subjectUri while proceessing update to datapropKey "+editConfig.getDatapropKey());
            throw new Error("In processDatapropRdfForm.jsp, could not find subject Individual via uri " + subjectUri);
        }
        fieldAssertions = fieldsToMap(editConfig.getFields());
//  }else{
//      fieldAssertions = new HashMap<String,List<String>>();
    }


    /* ********** URIs and Literals on Form/Parameters *********** */
    //sub in resource uris off form
    n3Required = n3Subber.subInUris(submission.getUrisFromForm(), n3Required);

    //sub in literals from form
    n3Required = n3Subber.subInLiterals(submission.getLiteralsFromForm(), n3Required);

    fieldAssertions = n3Subber.substituteIntoValues(submission.getUrisFromForm(), submission.getLiteralsFromForm(), fieldAssertions );

    /* ****************** URIs and Literals in Scope ************** */
    n3Required = n3Subber.subInUris(  editConfig.getUrisInScope(), n3Required);

    n3Required = n3Subber.subInLiterals( editConfig.getLiteralsInScope(), n3Required);

    fieldAssertions = n3Subber.substituteIntoValues(editConfig.getUrisInScope(),editConfig.getLiteralsInScope(), fieldAssertions );

    /* ****************** New Resources ********************** */
    Map<String,String> varToNewResource = newToUriMap(editConfig.getNewResources(),jenaOntModel);

    //if we are editing an existing prop, no new resources will be substituted since the var will
    //have already been substituted in by urisInScope.
    n3Required = n3Subber.subInUris( varToNewResource, n3Required);

    fieldAssertions = n3Subber.substituteIntoValues(varToNewResource, null, fieldAssertions );

    /* ***************** Build Models ******************* */
    /* bdc34: we should check if this is an edit of an existing
    or a new individual.  If this is a edit of an existing then
    we don't need to do the n3required or the n3optional; only the
    the assertions and retractions from the fields are needed.
     */
    List<Model> requiredAssertions  = null;
    List<Model> requiredRetractions = null;

    if( editConfig.getDatapropKey() != null && editConfig.getDatapropKey().trim().length() > 0 ){
        //editing an existing statement
        List<Model> requiredFieldAssertions  = new ArrayList<Model>();
        List<Model> requiredFieldRetractions = new ArrayList<Model>();
        for(String fieldName: fieldAssertions.keySet()){
            Field field = editConfig.getFields().get(fieldName);
            /* CHECK that field changed, then add assertions and retractions */
            if( hasFieldChanged(fieldName, editConfig, submission) ){
                log.debug("Field "+fieldName+" has changed for datapropKey "+editConfig.getDatapropKey());
                List<String> assertions = fieldAssertions.get(fieldName);
                for( String n3 : assertions){
                    try{
                        log.debug("Adding assertion '"+n3+"' to requiredFieldAssertions");
                        Model model = ModelFactory.createDefaultModel();
                        StringReader reader = new StringReader(n3);
                        model.read(reader, "", "N3");
                        requiredFieldAssertions.add(model);
                    }catch(Throwable t){
                        log.warn("processing N3 assertions string from field "+fieldName+"\n"+t.getMessage()+'\n'+"n3: \n"+n3);
                        errorMessages.add("error processing N3 assertion string from field " + fieldName + "\n"+
                                t.getMessage() + '\n' +
                                "n3: \n" + n3 );
                    }
                }
                for( String n3 : field.getRetractions()){
                    try{
                        log.debug("Adding retraction '"+n3+"' to requiredFieldRetractions");
                        Model model = ModelFactory.createDefaultModel();
                        StringReader reader = new StringReader(n3);
                        model.read(reader, "", "N3");
                        requiredFieldRetractions.add(model);
                    }catch(Throwable t){
                        log.warn("processing N3 retraction string from field "+fieldName+"\n"+t.getMessage()+'\n'+"n3: \n"+n3);
                        errorMessages.add("error in processDatapropRdfForm.jsp processing N3 retraction string from field "+fieldName+"\n"+t.getMessage()+'\n'+"n3: \n"+n3);
                    }
                }
            }
        }
        requiredAssertions = requiredFieldAssertions;
        requiredRetractions = requiredFieldRetractions;

    } else { //deal with required N3
        log.debug("Not editing an existing statement since no datapropKey in editConfig");
        List<Model> requiredNewModels = new ArrayList<Model>();
        for(String n3 : n3Required){
            try{
                log.debug("Adding assertion '"+n3+"' to requiredNewModels");
                Model model = ModelFactory.createDefaultModel();
                StringReader reader = new StringReader(n3);
                model.read(reader, "", "N3");
                requiredNewModels.add( model );
            }catch(Throwable t){
                log.warn("error processing required n3 string \n"+t.getMessage()+'\n'+"n3: \n"+n3);
                errorMessages.add("error processing required n3 string \n"+t.getMessage()+'\n'+"n3: \n"+n3);
            }
        }
        if( !errorMessages.isEmpty() ){
            for( String error : errorMessages){
                log.error(error);
                log.debug(error);
            }
            throw new JspException("errors processing required N3 in processDatapropRdfForm.jsp, check logs for details");
        }
        requiredAssertions = requiredNewModels;
        requiredRetractions = Collections.EMPTY_LIST;
    }

    Lock lock = null;
    try{
        lock =  persistentOntModel.getLock();
        lock.enterCriticalSection(Lock.WRITE);
        for( Model model : requiredAssertions ) {
            persistentOntModel.add(model);
        }
        for(Model model : requiredRetractions ){
            persistentOntModel.remove( model );
        }
    }catch(Throwable t){
        errorMessages.add("In processDatapropRdfForm.jsp, error adding edit change n3required model to persistent model \n"+ t.getMessage() );
    }finally{
        lock.leaveCriticalSection();
    }

    try{
        lock =  jenaOntModel.getLock();
        lock.enterCriticalSection(Lock.WRITE);
        for( Model model : requiredAssertions) {
            jenaOntModel.add(model);
        }
        for(Model model : requiredRetractions ){
            jenaOntModel.remove( model );
        }
    }catch(Throwable t){
        errorMessages.add("In processDatapropRdfForm.jsp, error adding edit change n3required model to in memory model \n"+ t.getMessage() );
    }finally{
        lock.leaveCriticalSection();
    }
%>
<jsp:forward page="postEditCleanUp.jsp"/>

<%!

    /* ********************************************************* */
    /* ******************** utility functions ****************** */
    /* ********************************************************* */

    public Map<String,List<String>> fieldsToMap( Map<String,Field> fields){
        Map<String,List<String>> out = new HashMap<String,List<String>>();
        for( String fieldName : fields.keySet()){
            Field field = fields.get(fieldName);

            List<String> copyOfN3 = new ArrayList<String>();
            for( String str : field.getAssertions()){
                copyOfN3.add(str);
            }
            out.put( fieldName, copyOfN3 );
        }
        return out;
    }

//    public Map<String,List<String>> substituteIntoValues(Map<String,String> varsToUris,
//                                                      Map<String,String> varsToLiterals,
//                                                      Map<String,List<String>> namesToN3,
//                                                      EditConfiguration editConfig ){
//        Map<String,List<String>> outHash = new HashMap<String,List<String>>();
//
//        if (namesToN3==null) {
//            return outHash;
//        } else if (namesToN3.isEmpty()) {
//            return outHash;
//        } else {
//            for(String fieldName : namesToN3.keySet()){
//                List<String> n3strings = namesToN3.get(fieldName);
//                List<String> newList  = new ArrayList<String>();
//                if( varsToUris != null)
//                    newList = editConfig.getN3Generator().subInUris(varsToUris, n3strings);
//                if( varsToLiterals != null)
//                    newList = editConfig.getN3Generator().subInLiterals(varsToLiterals, newList);
//                outHash.put(fieldName, newList);
//            }
//        }
//        return outHash;
//    }

    public Map<String,String> newToUriMap(Map<String,String> newResources, Model model){
        HashMap<String,String> newUris = new HashMap<String,String>();
        for( String key : newResources.keySet()){
            newUris.put(key,makeNewUri(newResources.get(key), model));
        }
         return newUris;
    }

    public String makeNewUri(String prefix, Model model){
        if( prefix == null || prefix.length() == 0 )
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
%>


<%!
    private boolean hasFieldChanged(String fieldName, EditConfiguration editConfig, EditSubmission submission) {
        String orgValue = editConfig.getUrisInScope().get(fieldName);
        String newValue = submission.getUrisFromForm().get(fieldName);
        if( orgValue != null && newValue != null){
            if( orgValue.equals(newValue))
              return false;
            else
              return true;
        }

        orgValue = editConfig.getLiteralsInScope().get(fieldName);
        newValue = submission.getLiteralsFromForm().get(fieldName);
        if( orgValue != null && newValue != null ){
            if( orgValue.equals(newValue))
                return false;
            else
                return true;
        }
        Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.forms.processDatapropRdfForm.jsp");
        log.debug("**************************** odd condition in hasFieldchanged() ********************");
        throw new Error("in hasFieldChanged() for field " + fieldName + ", both old and new values are null, this should not happen");
    }

    private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.forms.processDatapropRdfForm.jsp");
        log.debug( "*******************************************************************" );
        log.debug( name );
        log.debug(xstream.toXML( fff ));
    }
%>