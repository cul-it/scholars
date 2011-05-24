<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<!-- BEGIN div elements for special usability testing slide out panel -->
${scripts.add("/js/SOTCAnimator.js")}

<div id="panelContainer" class="panelContainer">
  <div id="panelHeader" onclick="slideDiagonally('hiddenPanel', this, 'panelContainer');" onmouseover="this.style.cursor='pointer'">
   <div id="arf" style="margin-top:4px">&nbsp; + Help Improve VIVO</div>
  </div>
  <div id="hiddenPanel" 
       style="position:absolute;
    z-index:1;
	width:0px;
    height:0px;
    top:0px;
	left:649px;
    background:#ffd;
	overflow:hidden;
	border-style:solid;
	border-color:#9db841;
	border-width:0px;
 	border-bottom-left-radius: 15px;
	border-top-left-radius: 15px;
	-moz-border-radius-bottomleft: 15px;
	-moz-border-radius-topleft: 15px;
	-webkit-border-bottom-left-radius: 15px;
	-webkit-border-top-left-radius: 15px;">

	<div class="infomaki">
      <span class="imSpanOne">Do you have time to answer one question?</span>
      <p style="margin-top:15px">&nbsp;</p>
      <span class="imSpanTwo">Help VIVO enable the national networking of scientists!</span>
      <p style="margin-top:15px">&nbsp;</p>
      <span class="imSpanThree">We're looking for feedback on our semantic web application. Your answer to even</span>
      <p style="margin-top:3px"></p>
      <span class="imSpanThree">a single question will be a great help.</span>
      <div class="tableDiv" >
        <table>
          <tr>
            <td class="yesTD" nowrap>
	          <a id="yesHref" href="http://www.vivo-usability.mannlib.cornell.edu/about/agree/?source=cornell" >Yes, I'd like to help!</a>
	        </td> <td>&nbsp;</td>
            <td class="noTD" style="text-align:center">
	          <a id="noHref" href="javascript:slideDiagonally('hiddenPanel', document.getElementById('panelHeader'));">No thanks, not right now.</a>
	        </td>
          </tr>
        </table>
      </div>
    </div>
  </div>  <!-- end hiddenPanel div -->
</div>  <!-- end panelContainer div -->
<!-- END div elements for special usability testing slide out panel -->



<!-- footer -->
