<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="fields"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content" class="sevenUnit">

                    <h2 class="groupLabel ${param.groupClass}">${param.groupLabel}</h2>
                     
                    <h3 class="floatLeft">Graduate Fields:</h3>
                    <ul class="fields">
                    
                        <jsp:include page="part/listfields.jsp">
                            <jsp:param name="uri" value="${param.uri}"/>
                        </jsp:include>  
                    
                    </ul>
            </div><!-- content -->
        
            <div id="sidebar" class="fiveUnit cornered">
                <jsp:include page="part/listgroups.jsp"/>
            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />