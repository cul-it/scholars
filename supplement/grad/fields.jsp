<jsp:include page="header.jsp" />
        
        <div id="contentWrap">
            <div id="content">

                    <h2 class="groupLabel ${param.groupClass}">${param.groupLabel}</h2>
                    
                            <jsp:include page="part/listfields.jsp">
                                <jsp:param name="uri" value="${param.uri}"/>
                            </jsp:include>  
                                
            </div><!-- content -->
        
            <div id="sidebar">
                <jsp:include page="part/listgroups.jsp"/>
            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />