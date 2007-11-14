<%
// Make sure the browser knows this is a stylsheet
response.setContentType("text/css");
// Netscape 4.x?
boolean browserNetscape4=false;
String userAgent=request.getHeader("User-Agent");
	if ( userAgent != null && userAgent.startsWith( "Mozilla/4" ) && userAgent.indexOf("MSIE") < 0 ) {
	browserNetscape4=true;
}
String HIGHLIGHT_COLOR      = "#EEEE99"; //LIGHT_CREAM_YELLOW

%>

.editingForm A {
	/* color: #BC6015; */
	/* color: #111188; */
	/* font-weight: bold; */
	/* color: #9E66CC; */
	color: #6A5ACD;
	text-decoration: none;
}

.editingForm A:hover {
	color: #CC9933;
}

.editingForm P LI TD {
	color: #444444;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	line-height : 16px;
}

td.editformcell {
	font-size: 9px;
	}

td.editformcell select {
	margin: 0;
	}

img.CUrestricted {
	margin-left    : 5px;
	vertical-align : middle;
	}

.entityName {
	color       : #444444;
	font-weight : bold;
	}

.entityNameAnchor {
	color       : #6A5ACD;
	font-weight : bold;
	}
	
.entityNameHighlight {
/*	background-color : <%=HIGHLIGHT_COLOR%>; */
	color            : red;
	font-weight      : bold;
	}
	
.moniker {
	color       : #444444;
	}
	
.monikerHighlight {
/*	background-color : <%=HIGHLIGHT_COLOR%>; */
	color       : red;
	font-weight : bold;
	}
	
.blurb {
	color       : #444444;
	}

.blurbHighlight {
/*	background-color : <%=HIGHLIGHT_COLOR%>; */
	color       : red;
	font-weight : bold;
	}

.description {
	color: #444444;
	}

.descriptionHighlight {
/*	background-color : <%=HIGHLIGHT_COLOR%>; */
	color       : red;
	font-weight : bold;
	}

.nowrap {
	/* white-space:nowrap; */
	}
	
P {
	margin-top: 1px;
	margin-bottom: 1px;
	padding-bottom: 4px; /* was 12px, then 8 */
	}

P.classPublicNames {
	margin          : 1em 0 0 0;
	padding         : 0 0 0 2px;
	font-weight     : bold;
	font-size       : 1.3em;
	font-style      :  normal;
	color           : #AA3; /* #BC6015; */
	background-color: #DEDEDF;
	font-variant    : small-caps;
	}

P.entityTypes {
	margin          : 0.6em 0 0 1.33em;
	font-weight     : bold;
	font-size       : 1.1em;
	font-style      : italic;
	color           : #C93315; /* #BC6015; */
	}

P.entityFields {
	margin          : 0 0 0 4em;
	font-weight     : normal;
	font-size       : 1em;
/*	background-color: #DEDEDF;*/
	color			: black;
	text-indent     : -1em;
	}

.entityRelations {
	margin          : 0 0 0 6em;
	font-weight     : normal;
	font-size       : 1em;
/*	background-color: #DEDEDF;*/
	color			: black;
/*	text-indent     : -1em; */
	}

.servletForm {
	margin          : 0 0 0 6em;
	font-weight     : normal;
	font-size       : 1em;
/*	background-color: #DEDEDF;*/
	color			     : black;
/*	text-indent     : -1em; */
	}

.editingForm UL {
	margin-top: 1px;
	padding-top: 0px;
	margin-bottom: 1px;
	padding-bottom: 1px; /* was 18, then 4 */
	margin-left: 15px; /* was 17px */
	padding-left: 0px;
	list-style-type : square;
}

UL.entityListElements {
	margin: 1px 0 1px 8em;
	padding-top: 0px;
	padding-bottom: 1px; /* was 18, then 4 */
	padding-left: 0px;
	list-style-type : square;
}




.editingForm TH {
	color: #444444;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	line-height : 16px;
}

.editingForm H1 {
	/* color: #4B0082; */
	font-family : Arial, Helvetica, sans-serif;
	font-size: 20px;
	line-height: 20px;
	font-weight: bold;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-bottom: 1px; /* was 8*/
}

.editingForm H2, H3, H4, H5 {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	color: #4B0082;
	}

.editingForm H2 {
	font-size : 14px; /* was 15 p */
	font-weight: bold;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-top: 3px;
	padding-bottom: 4px;
}

.editingForm libraryH2 {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size : 15px;
	font-weight: bold;
	color: #4B0082;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-top: 3px;
	padding-bottom: 3px;
}


.editingForm H3 {
	font-size : 11px; /* was 12 */
	font-weight: bold;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-top: 3px;     /* was 4 */
	padding-bottom: 5px;  /* was 8, recently then 6 */
}

.capitalized { text-transform: capitalize; }


.editingForm H4 {
	font-size : 10px;
	font-weight: bold;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-top: 1px;     /* was 4 */
	padding-bottom: 4px;  /* was 8, recently then 6 */
}

.textLikeH4 {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	font-weight: bold;
	margin-top: 0px;
	padding-top: 0px;     /* was 4 */
}

.editingForm H5 {
	font-size: 12px;
	line-height: 16px;
	font-weight: bold;
	margin-top: 1px;
	margin-bottom: 1px;
<% if ( browserNetscape4 ) { %>
	padding-top: 15px;
	padding-bottom: 0px;
<% } else { %>
	padding-top: 0px;
	padding-bottom: 6px;
<% } %>
}

.editingForm H6 {
	font-family: Georgia, "Times New Roman", Times, serif;
	font-size : 16px;
	font-weight: normal;
	font-style: italic;
	line-height: 24px;
	color: #353535;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-bottom: 32px;
}

.editingForm H7 {
	color: #F5F5E1;
	font-family: Georgia, "Times New Roman", Times, serif;
	font-size: 12px;
	line-height: 20px;
	font-weight: bold;
	margin-top: 1px;
	margin-bottom: 1px;
	padding-bottom: 8px;
}

A.headerlink {
	font-size: 11px;
	font-weight : bold;
	color : #F5F5E1;
	text-decoration: none;
}

A.headerlink:HOVER {
	color : #EADD6C;
}

A.headerlinkOn {
	font-size: 11px;
	font-weight : bold;
	color : #EADD6C;
	text-decoration: none;
}

A.headerlinkOn:HOVER {
	color : #F5F5E1;
}

A.subNav {
	color: #191970;
	font-size: 9px;
	font-weight: bold;
	line-height: 12px;
	text-decoration: none;
	margin-top: 4px;
	margin-bottom: 1px;
	padding-bottom: 1px;
}

A.subNav:HOVER {
	color: #333333;
}

A.subNavOn {
	color: #333333;
	font-size: 9px;
	font-weight: bold;
	line-height: 11px;
	text-decoration: none;
	margin-top: 4px;
	margin-bottom: 1px;
	padding-bottom: 1px;
}

.bannertitle {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-weight : bold;
	font-style  : normal;
	font-size   : 200%;
	}

.biggerbold {
	font-weight : bold;
	font-size   : 120%;
	padding     : 1px;
	}

.footerlink {
	color : #F5F5E1;
	font-family: arial, verdana, geneva, sans-serif;
	font-size: 10px;
	margin-top: 0px;
	margin-bottom: 0px;
	padding-bottom: 0px;
}

.footerlink:HOVER {
	color : #EADD6C;
	font-family: arial, verdana, geneva, sans-serif;
	font-size: 10px;
	margin-top: 0px;
	margin-bottom: 0px;
	padding-bottom: 0px;
}

.footertext {
	color: #62812E;
	font-family: arial, verdana, geneva, sans-serif;
	font-size: 9px;
}


 
.editingForm .form-item {
	background-color : #FAFAD2; /*#EADD6C;*/
	border-color : #2E440C;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
}


.editingForm .form-button {
	background-color : #CCCCFF; /* #DEB887; */
	border-color : #CCFFFF; /*#2E440C; */
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
	width:auto;
	overflow:visible;
}



.form-background {
	background-color : #C8D8F8; /* #DEB887; */
	border-color : #CCCCFF; /*#2E440C; */
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}

.form-background.vclass {
	background-color : #E05550;
}

.form-background.property {
	background-color:#A8F0A0;
}

.form-table-head {
	background-color : #ccf;
	border-color : #eec; 
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}

.form-row-even {
	background-color : #e9f0ff;
	border-color : #eec; 
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}

.form-row-odd {
	background-color : #e9f9ff;
	border-color : #eec; 
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}


.form-editingRow {
	background-color : #ff9;
	border-color : #eec; 
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}

.form-subEditingRow {
	background-color : #ffb;
	border-color : #eec; 
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}

.cornflowerblue { background-color	: #C8D8F8;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 9pt;
		font-style		: normal;
}

.medpurple {	background-color	: #CCCCFF;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10px;
		font-style		: normal;
		text-align      : center;
}

.pulldown {
	font-size: 9px;
	background-color : #EADD6C;
	border-style: none;
	font-family : Arial, Helvetica, "sans-serif";
}

.newsItem {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	line-height: 15px;
}

.sidebarlink {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	line-height: 10px;
}

.smallcaps {
	font-variant : small-caps;
	}

.smallcapstitle {
	font-family  : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size    : 130%;
	font-style   : normal;
	font-variant : small-caps;
	font-weight  : normal;
	}

.subtitle {
	font-family  : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size    : 100%;
	font-style   : normal;
	font-weight  : bold;
	margin-top   : 0.5em;
	}

.popup {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	color: #F5F5E1;
	font-size: 10px;
}

A.popup {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	color: #F5F5E1;
	font-size: 10px;
}

.bluebutton {
	background-color : #C8D8F8;
	border-color : #CCCCDD;
	color: #6655CD;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	line-height : 13px;
	width:auto;
	overflow:visible;
}

.yellowbutton {
	background-color : #FAFAD2;
	border-color : #CCCCDD;
	color: #0000CD;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	line-height : 14px;
	width:auto;
	overflow:visible;
}

.servletbutton {
	background-color : #FAFAD2;
	border-color : #CCCCDD;
	color: #0000CD;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height : 12px;
	width:auto;
	overflow:visible;
}


.plainbutton {
	background-color : #EEEEEE;
	border-color : #CCCCDD;
	color: #0000CD;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	line-height : 14px;
	width:auto;
	overflow:visible;
}

.captions {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 11px;
}

.citation {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 11px;
}

.credits {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 11px;
	color: #666666;
}

.darkbackground {
	background-color	: #444466;
}

.lightbackground {
	background-color	: #a0c5ce; /* #AADDCC;  #66CDAA; #8FbC8F; #BDB76B; #E0FFFF; */
}

.lightbackground2 {
	background-color	: #F8F8C8; /* #FFFF99; #8FBC8F; #BDB76B; #E0FFFF; */
}

.whitebackground {
	background-color : #FFFFFF;
	color		: black;
	font-family	: Verdana, Arial, Helvetica, sans-serif;
	font-size	: 8pt;
	font-style	: normal;
	vertical-align  : top;
}

.header {	background-color	: #B0C4DE;
		color 			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.database_header {	background-color	: #B0C4DE;
		color 			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.database_upperleftcorner {	background-color	: #B0C4DE;
		color 			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.database_upperleftcenter {
		background-color	: #B0C4DE;
		color 			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: center;
}

.rownumheader {	background-color	: #B0C4DE;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: center;
}


.headercenter {
		background-color	: #9370DB;
		color 			:  black;
		font-family		:  Arial, Helvetica, sans-serif;
		font-size		:  10pt;
		font-style		:  normal;
		text-align		:  center;
}

.postheader {	background-color	: #E6E6FA;
		/*color			: #4682B4;*/
		color			: #777777;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.database_postheader {	background-color	: #E6E6FA;
		/*color			: #4682B4;*/
		color			: #777777;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.postheadercenter {
		background-color	: #E6E6FA;
		color			: #4682B4;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: center;
}

.postheaderright {
		background-color	: #E6E6FA;
		color			: #4682B4;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: right;
}

.verticalfieldlabel {
		background-color        : #DEDEDF;
		color			: black;
		font-family		: Verdana, Arial, Helvetica, sans-serif;
		font-size		: 8pt;
		font-style		: normal;
		text-align		: right;
		vertical-align		: top;
}

.row, .rowvert {		background-color	: #F0FFFF;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.rowalternate {	background-color	: #F8F8FF;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.rowbold {	background-color	: #FFFAFA;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		font-weight	: bold;
		text-align		: left;
}

.rownum {	background-color	: #87CEFA;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: center;
}

.firstcol {	background-color	: #90EE90;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: left;
}

.postrow {	background-color	: #E6E6BB;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
		text-align		: right;
}

.ltyellow {	background-color	: #FAFAD2;
		color			: black;
		font-family		: Arial, Helvetica, sans-serif;
		font-size		: 10pt;
		font-style		: normal;
}

.classes,.properties,.entities,.valuetypes,.attributes,.elements,.qualifiers,.keywords {
		/*background-color	: #87CEFA;*/
		/*background-color	: #D3D3D3;*/
		background-color        : #DEDEDF;
		color			: black;
		font-family		: Verdana, Arial, Helvetica, sans-serif;
		font-size		: 8pt;
		font-style		: normal;
}

.navlinkblock {
		/*background-color	: #E0EEFF;*/
		color			: black; /*#4B0082;*/
		font-family 		: Verdana,Arial, Helvetica, sans-serif;
		font-size 		: 10px;
		font-weight		: normal;
		margin-top		: 1px;
		margin-bottom		: 1px;
		padding-top		: 1px;
		padding-bottom		: 4px;
}




