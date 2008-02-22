<jsp:include page="facultyheader.jsp" />
        
        <div id="contentWrap">
            <div id="content">
                
                <h2 class="initial">Graduate Fields and Associated Faculty Members</h2>
                <div id="exhibit-control-panel"></div>
               
                <div ex:role="viewPanel">
                    
                    <div ex:role="exhibit-lens" class="faculty member">
                        <a ex:href-content=".url" target="_new"><span ex:content=".label"></span></a>
                        <span class="researchArea" ex:if-exists=".research-area" ex:content=".research-area"></span>
                    </div>

                     <div ex:role="exhibit-view"
                          ex:viewClass="Exhibit.TileView"
                          ex:orders=".graduate-field, .label"
                          ex:showAll="true"
                          ex:grouped="true" >
                     </div>
                 </div>
                
            </div><!-- content -->
        
            <div id="sidebar">
                    <div ex:role="facet" ex:expression=".research-area" ex:facetLabel="Research Area"></div>
            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />