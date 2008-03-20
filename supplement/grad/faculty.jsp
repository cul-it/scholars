<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="faculty"/>
</jsp:include>
        
        <div id="contentWrap">
            
            <div id="content" class="faculty">
                
                <h2><span class="exhibit-collectionView-group">Graduate Fields</span> and Associated Faculty Members</h2>
                <div id="exhibit-control-panel"></div>
               
                <div ex:role="viewPanel">
                    
                    <div ex:role="exhibit-lens" class="facultyMember">
                        <a ex:href-content=".url" target="_new"><span ex:content=".label"></span></a>

                    </div>

                     <div ex:role="exhibit-view"
                          ex:viewClass="Exhibit.TileView"
                          ex:orders=".graduate-field, .label"
                          ex:showAll="true"
                          ex:grouped="true"
                          ex:showDuplicates="true" >
                     </div>
                 </div>
                
            </div><!-- content -->
        
            <div id="sidebar" class="faculty">
                    <!-- <div ex:role="facet" ex:facetClass="TextSearch"></div> -->
                    <div ex:role="facet" ex:expression=".graduate-field" ex:facetLabel="Graduate Fields" ex:height="20em" id="exhibitGradFields"></div>
                    <div ex:role="facet" ex:expression=".research-area" ex:facetLabel="Research Areas" ex:height="20em" id="exhibitResearchAreas"></div>

            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />