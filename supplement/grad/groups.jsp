<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="groups"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content">

                    <h2 class="groupLabel ${param.groupClass}">${param.groupLabel}</h2>
                                      
                    <h3>Graduate Fields:</h3>
                    <ul class="fields">
                        <jsp:include page="part/listfields.jsp">
                            <jsp:param name="uri" value="${param.uri}"/>
                        </jsp:include>  
                    </ul>
                    <div id="groupList" class="small">
                        <!-- <h3>Other Areas</h3> -->
                        <jsp:include page="part/listgroups.jsp"/>
                    </div>
                    
            </div><!-- content -->

        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />