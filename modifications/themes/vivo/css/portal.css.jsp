<%
// Make sure the browser knows this is a stylsheet
response.setContentType("text/css");
boolean browserNetscape4=false;
String userAgent=request.getHeader("User-Agent");
if ( userAgent != null && userAgent.startsWith( "Mozilla/4" ) && userAgent.indexOf("MSIE") < 0 ) {
	browserNetscape4=true;
}

/**
 * @version 1 2004-00-00
 * @author Jon Corson-Rikert
 *
 * CHANGE HISTORY
 * 2005-10-25 jc55  changed classPublicName font color
 * 2005-09-30 jc55  moved several classes over from global.css.jsp so that about.jsp can use head.jsp and foot.jsp
 * 2005-07-07 jc55  changed form-item and nowrap text alignment to LEFT for filterbrowse; changed entitiesEditOptions to align with relationship names for filter value display
 * 2005-07-05 jc55  added photoCitation, tweaks to citation
 * 2005-06-21 jc55  added h3.redcentered for old editing screen headers
 * 2005-06-10 jc55  replaced p.entityAnnotationDescription with span.entityAnnotationDescription as part of revamping annotation display in EntityServlet,EntitiesServlet, and EntitiesResultsServlet
 * 2005-05-24 jc55	replaced padding element with margin element in pageGroupDescription and pageGroupBody to correct alignment issues in Sponsored Projects tab
 * 2005-05-24 jc55	added form.indented to control search boxes within tab entries
 */

String verdanaGenevaSansSerif	=	"Verdana, Geneva, Arial, Helvetica, sans-serif";
String verdanaArialSansSerif		=	"Verdana, Arial, Helvetica, sans-serif";
String arialHelveticaSansSerif	=	"Arial, Helvetica, sans-serif";
String arialVerdanaSansSerif		=	"Arial, Verdana, Geneva, sans-serif";
String georgiaSerif				   =	"Georgia, \"Times New Roman\", Times, serif";

// colors
String WHITE                    = "white";
String BLACK                    = "black";
String DARK_GRAY                = "#333333";
String MEDIUM_GRAY              = "#999999";
String LIGHT_GRAY               = "#AAA";   //DDC";    //#DEDEDF"; //"#cccccc";
String DARK_TEAL                = "#39526B"; //"#5d81a3";
String LIGHT_TEAL               = "#33A6C7"; //"#78b9de";
String PALE_GREEN               = "#EFFBE7";     // even paler is #F5F5E1
String LIGHT_GREEN              = "#F3F9BD";
String GRAY_GREEN               = "#999966";
String DARK_OLIVE               = "#2E440C"; //CCRP
String IVORY_TINT               = "#F5F5E1";
String LIGHT_IVORY              = "#F1F1D1";
String MEDIUM_IVORY             = "#E4E4C8";
String DARK_IVORY               = "#C5C5A3";
String LIGHT_CREAM_YELLOW       = "#EEEE99";
String MEDIUM_CREAM_YELLOW      = "#EEEE66";
String MUSTARD_YELLOW           = "#EADD6C"; // CCRP
String SAND                     = "#DEB887"; // CCRP form button
String DARK_BROWN               = "#BC6015"; // CCRP
String MEDIUM_BLUE              = "#6A5ACD";
String CALS_PURPLE              = "#9A99FF";
String ORANGE                   = "#C25D04"; //"#ff9900"; "#DF7503" (reddish)
String SEPIA                    = "#CC9933";
// pairings of colors with roles
String BODY_BACKGROUND_COLOR    = WHITE;
String BODY_DEFAULT_FONT_COLOR  = BLACK;
String HIGHLIGHT_COLOR          = "#EEEE99"; //LIGHT_CREAM_YELLOW
String DEFAULT_TITLE_FONT       = verdanaGenevaSansSerif;
// link colors in body elements (other than tabbed menus)
String BODY_LINK_VISITED_COLOR  = MEDIUM_BLUE;
String BODY_LINK_DEFAULT_COLOR  = MEDIUM_BLUE;
String BODY_LINK_HOVER_COLOR    = ORANGE;
String BODY_LINK_ACTIVE_COLOR   = DARK_BROWN;

// menu table cell background colors
StringBuffer requestURL=request.getRequestURL();
//String queryString=request.getQueryString();

String MENU_DEFAULT_COLOR=null;
if (requestURL.toString().indexOf("http://research.cals.cornell.edu/")>=0) {
	MENU_DEFAULT_COLOR=CALS_PURPLE;
} else {
	MENU_DEFAULT_COLOR=LIGHT_TEAL;
}
String MENU_SELECTED_COLOR      = DARK_TEAL;
// link default, visited, hover, and active color
String MENU_SELECTED_LINK_COLOR = WHITE;
// link colors in non-selected menu table cells
String MENU_LINK_VISITED_COLOR  = WHITE;
String MENU_LINK_DEFAULT_COLOR  = WHITE;
String MENU_LINK_HOVER_COLOR    = MEDIUM_CREAM_YELLOW;
String MENU_LINK_ACTIVE_COLOR   = ORANGE;
// link colors in gallery images
String GALLERY_LINK_VISITED_COLOR = "red"; //MEDIUM_GRAY;
String GALLERY_LINK_DEFAULT_COLOR = "green"; //DARK_IVORY;
String GALLERY_LINK_HOVER_COLOR   = SAND;
String GALLERY_LINK_ACTIVE_COLOR  = DARK_BROWN;
// margins
String OUTER_MARGIN  = "0"; 				// 1em 1em 1em";
String INNER_MARGIN  = "0.5em";
String INNER_PADDING = "2px 5px";
// font stuff
String FONT_SIZE_NORMAL   =  "90%"; //"1.15em";
String FONT_SIZE_MENU     =  "94%"; //"1.25em";
String FONT_SIZE_BIG      = "110%"; //"1.5em";
String FONT_SIZE_BIGGER   = "125%"; //"1.75em";
String FONT_SIZE_BIGGEST  = "150%"; //"2em";
String FONT_SIZE_SMALL    = " 85%"; 
String FONT_SIZE_SMALLER  =  "80%"; //"1em";
String FONT_SIZE_SMALLEST =  "75%"; //"0.85em";

String LINE_HEIGHT_NORMAL     = "120%";          // normal, 1.5
String LINE_HEIGHT_COMPRESSED = "90%";           // 1.2
String LINE_HEIGHT_EXPANDED   = "150%";          // 1.8 or 1.7
String TITLE_LINE_HEIGHT      = "120%";          // 2.0
%>

body {
	font-family     : "Lucida Grande", Verdana, Lucida, Arial, Helvetica, sans-serif;
	background-color: <%=BODY_BACKGROUND_COLOR%>; 
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	line-height     : <%=LINE_HEIGHT_NORMAL%>;
	}

h1 {
	font-size       : <%=FONT_SIZE_BIGGEST%>;
	font-weight     : bold;
	}

h2 {
	font-size       : <%=FONT_SIZE_BIGGER%>;
	font-weight     : bold;
	margin          : <%=INNER_MARGIN%> 0;
	}

h3 {	
	display         : block;
	font-size       : <%=FONT_SIZE_BIG%>;
	margin          : <%=INNER_MARGIN%> 0;
	padding-bottom  : 2px;
	text-transform  : none;
	}

h3.centered {
	text-align      : center;
	}

h3.redcentered {
	text-align      : center;
	color           : red;
	}
	
h4 {	
	font-size       : <%=FONT_SIZE_NORMAL%>;
	margin          : <%=INNER_MARGIN%>;
	}

h4.entityAnnotationHeading {	
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-style      : bold;
	margin          : <%=INNER_MARGIN%>;
	}

h5 {	
	font-size       : <%=FONT_SIZE_NORMAL%>;
	margin          : 0.5em 0 0.5em 0;
	}


p {
/*	margin          : 0; */
	margin-top      : 1px;
	margin-bottom   : 1px;
	padding-bottom  : 4px;
	}

p.normal {
/*	margin          : 0; */
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	margin-top      : 1px;
	margin-bottom   : 1px;
	padding-bottom  : 4px;
	}

p.small {
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_SMALL%>;
	margin-top      : 1px;
	margin-bottom   : 1px;
	padding-bottom  : 4px;
	}

p.small ul {
	margin-top      : 0;
	padding-top     : 0;
	margin-bottom   : 1px;
	padding-bottom	  : 2px;
	margin-left     : 15px;
	padding-left    : 2px;
	list-style-type : disc;
	vertical-align  : top;
	}

p.small ul li {
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_SMALL%>;
	margin-left     : 5px;
	padding         : 0;
	vertical-align  : top;
	}

p.padded {
	font-size       : <%=FONT_SIZE_NORMAL%>;
	padding         : <%=INNER_PADDING%>;
	}
	
/* see also gallery section below */
p.caption {
	color           : <%=LIGHT_GRAY%>;
	font-style      : italic;
	text-align      : left;
	}

#main {
	margin          : <%=OUTER_MARGIN%>;
	}

.squeeze td {
	line-height     : 2px;
	}
	
.smallcapstitle {
	font-family  : <%=DEFAULT_TITLE_FONT%>;
	font-size    : 130%;
	font-style   : normal;
	font-variant : small-caps;
	font-weight  : normal;
	}
	
.bannertitle {
	font-family : <%=DEFAULT_TITLE_FONT%>;
	font-weight : bold;
	font-style  : normal;
	font-size   : <%=FONT_SIZE_BIGGEST%>;
	}


.subtitle {
	font-family  : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size    : <%=FONT_SIZE_MENU%>;
	font-style   : normal;
	font-weight  : bold;
	margin-top   : 0.5em;
	}

P.rednormal {
	color: red;
	}
	
P.redbold {
	color       : red;
	font-weight : bold;
	}

.nohighlight {
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-weight     : normal;
	}
	
.highlight {
	color           : red;
	font-weight     : bold;
	}
	

/******************* unstructured pages (e.g., search.jsp *******************/
td.attName {
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-weight     : normal;
	line-height     : <%=LINE_HEIGHT_EXPANDED%>; 
	text-align      : left;
	vertical-align  : top;
	}

td.attName input.top_padded {
	margin          : 0.5em 0 0 0;
	}

td.attValue {
	background-color: transparent;
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-weight     : normal;
	line-height     : <%=LINE_HEIGHT_EXPANDED%>;
	text-align      : left;
	vertical-align  : top;
	}

ul {
	margin-top      : 0;
	padding-top     : 0;
	margin-bottom   : 1px;
	padding-bottom	  : 2px;
	margin-left     : 15px;
	padding-left    : 2px;
	list-style-type : disc;
	vertical-align  : top;
	}

ul li {
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
/*	font-size       : <%=FONT_SIZE_NORMAL%>; */
	margin-left     : 5px;
	padding         : 0;
	vertical-align  : top;
	}

/******************* Forms *******************/

form {
   color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-weight     : normal;
	margin          : 0;
}

form.old-global-form 	{color:#000000; font-size:9px; font-family:arial,helvetica,"sans serif";font-weight:normal; margin:1px;}

form.indented {
   color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : 100%;
	font-weight     : normal;
	margin          : 0 0 0 1em;
}

label {
   color           : <%=ORANGE%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-weight	     : normal;
	text-align      : right;
	vertical-align  : middle;
	}

select {
	background-color: <%=WHITE%>;
	border-color    : <%=DARK_OLIVE%>;
	border-width    : 1px;
   color           : <%=DARK_OLIVE%>;
   font-size       : <%=FONT_SIZE_NORMAL%>;
	font-weight     : normal;
	vertical-align  : middle;
	}
	
form.padded { 
   color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size		  : <%=FONT_SIZE_NORMAL%>;
	font-weight	     : normal;
	padding         : <%=INNER_PADDING%>;     
}

.form-item {
	background-color	: <%=WHITE%>;
	border-color		: <%=DARK_OLIVE%>;
	font-size        : <%=FONT_SIZE_NORMAL%>;
	border-width 		: 1px;
	text-align       : left;
	vertical-align   : middle;
}

.form-button {
	background-color	: <%=MEDIUM_IVORY%>;
	border-color		: <%=DARK_IVORY%>;
	font-size			: <%=FONT_SIZE_NORMAL%>;
	border-width		: 1px;
	margin-bottom    : 2px;
	vertical-align   : middle;
}

a.formlink {
	font-size        : <%=FONT_SIZE_SMALLER%>;
	}

.nowrap {
	text-align       : left;
   white-space      : nowrap;
   }

/******************* LINKS (in body) *******************/

a:visited {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=BODY_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}

a:link {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=BODY_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}

a:hover {
	font-weight     : normal; 
	text-decoration : underline;
	color           : <%=BODY_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

a:active {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=BODY_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
	}

/******************* QUICK REFERENCES (in header) *******************/
td.quickreferences  {
	border-top      : 0;
	border-right    : 1px solid <%=LIGHT_GRAY%>;
	border-bottom   : 0;
	border-left     : 0;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	padding         : 0 0.5em;
	text-align      : center;
	vertical-align  : middle;
	} 
	
/******************* LOGIN (in header) *******************/
td.logintop {
	border          : 0;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	padding         : 0 0 0 1em;
	text-align      : center;
	vertical-align  : bottom;
	}

td.loginbottom {
	border-top      : 1px solid <%=LIGHT_GRAY%>;
	border-right    : 0;
	border-bottom   : 0;
	border-left     : 0;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	padding         : 0 0 0 1em;
	text-align      : center;
	vertical-align  : bottom;
	vertical-align  : top;
	}

#login hr {
	margin          : 0;
	}

/******************* LOGOTYPE IMAGE AREA (header) *******************/

td#cuLogotypeArea {
   padding         : 0 0 0 2px; /* was 1em bottom, 1.5em left */
	text-align      : center;
	vertical-align  : top;
	}	

td#cuLogotypeArea img {
	border          : 0;
	margin          : 0;
	padding         : 0;
	vertical-align  : top;
	}

td#logotypeArea {
   padding         : 0; /* was 1em bottom */
	vertical-align  : top;
	}
	
td#logotypeArea img {
	border          : 0;
	margin          : 0;
	padding         : 0;
	vertical-align  : top;
	}

td#logotypeArea a img {
	border          : 0;
	}
	
td#logotypeArea a:visited {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=GALLERY_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}

/*
td#logotypeArea a {
	vertical-align  : top;
	} */
	
/******************* INTERPORTAL NAVIGATION AREA (head.jsp,PrintWrapper.java) *******************/

/* Navigation bar components */

td#topspanSelected	{ /* has no links */
	background     : <%=GRAY_GREEN%>; /* white url(../site_icons/selectpat.gif) repeat; */
	border-right   : 1px solid <%=LIGHT_IVORY%>; /* SAND */
	border-top     : 1px solid <%=LIGHT_IVORY%>;
	color          : white;
	font-family    : <%=georgiaSerif%>;
	font-size      : <%=FONT_SIZE_BIGGEST%>;
	font-weight    : normal;
	line-height    : 15px;
	text-align     : center;
	vertical-align : bottom;
 	}

table#interportalnav	{ /* table has the only left and bottom borders */
	border-bottom  : 1px solid <%=LIGHT_IVORY%>;
	border-left    : 1px solid <%=LIGHT_IVORY%>;
	margin-bottom  : 0;
	vertical-align : top;
	width          : 100%;
	}

table#interportalnav td	{ /* each cell has right and top borders */
	background     : <%=LIGHT_IVORY%>; /* transparent url(../site_icons/bgpat.gif) repeat; */
	border-right   : 1px solid <%=LIGHT_IVORY%>;
	border-top     : 1px solid <%=LIGHT_IVORY%>;
	font-size      : <%=FONT_SIZE_SMALLER%>;
	font-weight    : normal;
	text-align     : center;
 	}

table#interportalnav td.inlineSelected	{ /* has no links */
	background     : <%=LIGHT_IVORY%>; /* transparent url(../site_icons/bgpat.gif) repeat; */
	border-right   : 1px solid <%=LIGHT_IVORY%>;
	border-top     : 1px solid <%=LIGHT_IVORY%>;
	color          : <%=ORANGE%>;
	font-size      : <%=FONT_SIZE_SMALLER%>;
	font-weight    : normal;
	line-height    : 13px; /* this is what centers the text vertically */
	margin         : 0;
	padding        : 3px;
	text-align     : center;
 	}


table#interportalnav td.unselected a	{ /* only unselected cells have links */
	background      : <%=LIGHT_IVORY%>; /* white url(../site_icons/nopat.gif) repeat; */
	font-weight     : normal;
	text-decoration : none;
	display         : block;
	line-height     : 13px; /* this is what centers the text vertically */
	margin          : 0;
	padding         : 3px;
	}
	
table#interportalnav td.unselected a:link, table#interportalnav td.unselected a:visited { /*only unselected cells have links*/
	background  : <%=LIGHT_IVORY%>; /* transparent url(../site_icons/bgpat.gif) repeat; */
	color       : <%=GRAY_GREEN%>;
	display     : block;
	font-weight : normal;
	line-height : 13px; /* this is what centers the text vertically */
	margin      : 0;
	padding     : 3px;
	} 

table#interportalnav td.unselected a:hover { /* only unselected cells have links */
	background      : <%=LIGHT_IVORY%>; /* white url(../site_icons/selectpat.gif) repeat; */
	color           : <%=ORANGE%>;
	display         : block;
	text-decoration : none;
	}

/******************* BANNER IMAGE AREA in heading when not showing inter-portal naviagation *******************/

td.shadedBannerArea {
	background      : <%=LIGHT_IVORY%>;
	vertical-align  : top;
	align           : right;
	}

td.plainBannerAreaRight {
	background      : transparent;
	vertical-align  : top;
	align           : right;
	}


#plainBannerArea {
	background      : transparent;
	vertical-align  : top;
	}

td.light_ivory {
	background      : <%=LIGHT_IVORY%>;
	}
	
td.light_ivory_bottom_bordered {
	background      : <%=LIGHT_IVORY%>;
	border-bottom   : 1px solid <%=MEDIUM_GRAY%>; /* watch out -- separates primary from its secondary tabs, not used much for CALS */
	}
	
td.light_ivory_label {
	background      : <%=LIGHT_IVORY%>;
	padding         : 0.5em 0 0 0.1em;
	text-align      : center;
	vertical-align  : top;
	}
	
/******************* SearchBoxes *******************/

td#shadedSearchBox {
	background      : <%=LIGHT_IVORY%>;
	color           : <%=DARK_TEAL%>;
/*	display         : block; */
	font-size       : <%=FONT_SIZE_NORMAL%>;
	line-height     : 20px;
	margin          : 0;
	padding         : 0.25em 0.5em 0.5em 0.5em;
	vertical-align  : middle;
	}

td#plainSearchBox {
	background      : transparent;
	color           : <%=DARK_TEAL%>;
/*	display         : block; */
	font-size       : <%=FONT_SIZE_BIGGER%>;
	margin          : 0;
	padding         : 0.25em 0.5em 0.5em 0.5em;
	vertical-align  : middle;
	}


/******************* PRIMARY MENU TABS (top row) *******************/
#primarytabs {
	font-size       : <%=FONT_SIZE_MENU%>;
	margin          : 1px 0 0 0;
	text-align      : center;
	white-space     : normal; /*nowrap*/
	}

#primarytabs td {
	background-color: <%=MENU_DEFAULT_COLOR%>;
	border-top      : 0;
	border-right    : 2px solid <%=SAND%>;   
	border-bottom   : 0;
	border-left     : 0;
	padding         : 4px;
	text-align      : left;
	vertical-align  : top;
	}

#primarytabs td.selected {
	background-color: <%=MENU_SELECTED_COLOR%>; 
	}

#primarytabs td.spacer {
	background-color: <%=LIGHT_IVORY%>; /* transparent; */
	border-bottom   : 0;
	border-top      : 0;
	}
	
#primarytabs td.alerttab {
	background-color: <%=LIGHT_CREAM_YELLOW%>; /* <%=GRAY_GREEN%>; */
	}

#primarytabs td.alerttab a:link, #primarytabs td.alerttab a:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=GRAY_GREEN%>;
	background      : transparent; 
	}

#primarytabs td.alerttab a:hover {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=ORANGE%>;
	background      : transparent; 
	}

	
#primarytabs a:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}
		
#primarytabs a:link {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}
	
#primarytabs a:hover {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

#primarytabs a:active {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
	}

#primarytabs a.activeTab:link, #primarytabs a.activeTab:visited, #primarytabs a.activeTab:hover, #primarytabs a.activeTab:active {
	background      : <%=MENU_SELECTED_COLOR %>;
	color           : <%=WHITE%>;
	font-weight     : bold;
/*	padding         : 2px 5px 3px 5px; */
	text-decoration : none;
	}

/******************* FIXED MENU TABS (top row, right justified) *******************/
#fixedtabs {
	font-size       : <%=FONT_SIZE_MENU%>;
	margin          : 1px 0 0 0;
	text-align      : center;
	white-space     : normal; /*nowrap*/
	}

#fixedtabs td {
	background-color: <%=MENU_DEFAULT_COLOR%>;
	border-top      : 0;
	border-left     : 2px solid <%=SAND%>;   
	border-bottom   : 0;
	border-right    : 0;
	padding         : 4px;
	text-align      : left;
	vertical-align  : top;
	}

#fixedtabs td.selected {
	background-color: <%=MENU_SELECTED_COLOR%>; 
	}

#fixedtabs td.spacer {
	background-color: <%=LIGHT_IVORY%>; /* transparent; */
	border-bottom   : 0;
	border-top      : 0;
	}
	
#fixedtabs td.alerttab {
	background-color: <%=LIGHT_CREAM_YELLOW%>; /* <%=GRAY_GREEN%>; */
	}

#fixedtabs td.alerttab a:link, #fixedtabs td.alerttab a:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=GRAY_GREEN%>;
	background      : transparent; 
	}

#fixedtabs td.alerttab a:hover {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=ORANGE%>;
	background      : transparent; 
	}

	
#fixedtabs a:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}
		
#fixedtabs a:link {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}
	
#fixedtabs a:hover {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

#fixedtabs a:active {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
	}

#fixedtabs a.activeTab:link, #fixedtabs a.activeTab:visited, #fixedtabs a.activeTab:hover, #fixedtabs a.activeTab:active {
	background      : <%=MENU_SELECTED_COLOR %>;
	color           : <%=WHITE%>;
	font-weight     : bold;
/*	padding         : 2px 5px 3px 5px; */
	text-decoration : none;
	}


/******************* SECONDARY MENU TABS (bottom row) *******************/

td#secondarytabBox {
	background-color: <%=MENU_SELECTED_COLOR %>;
	border          : 0;
	margin          : 0;
	padding         : 0;
	}
	
#secondarytabs {
	font-size       : <%=FONT_SIZE_MENU%>;            
	margin          : 0;
	text-align      : center;
	white-space     : normal;
	}

#secondarytabs td {
	background-color: <%=MENU_SELECTED_COLOR%>;
	border-top      : 0;
	border-right    : 1px solid <%=MEDIUM_GRAY%>;   
	border-bottom   : 0;
	border-left     : 1px solid <%=MEDIUM_GRAY%>;
	padding         : <%=INNER_PADDING%>;
	text-align      : left;
	vertical-align  : top;
	}

#secondarytabs td.selected {
	background-color: <%=DARK_IVORY%>;
	border-top      : 2px solid <%=MENU_SELECTED_COLOR%>;
	border-bottom   : 2px solid <%=DARK_IVORY%>;
	padding         : 2px 1em 0 1em;
	}

#secondarytabs td.spacer {
	background-color: transparent;
	border-bottom   : 0;
	border-top      : 0;
	}
	
#secondarytabs a:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}
		
#secondarytabs a:link {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}
	
#secondarytabs a:hover {
	font-weight     : bold; 
	text-decoration : underline;
	color           : <%=MENU_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

#secondarytabs a:active {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=MENU_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
	}

#secondarytabs a.activeTab:link, #secondarytabs a.activeTab:visited, #secondarytabs a.activeTab:hover, #secondarytabs a.activeTab:active {
	background      : <%=DARK_IVORY%>;
	color           : <%=DARK_BROWN%>;
	font-weight     : bold;
/*	padding         : 2px 5px 3px 5px; */
	text-decoration : none;
	}

/******************* BreadCrumbs *******************/

td#breadCrumbs {
	background		  : <%=LIGHT_IVORY%>;
	color           : <%=DARK_TEAL%>;
	font-size       : <%=FONT_SIZE_SMALL%>;
	padding         : <%=INNER_PADDING%>;
	vertical-align  : middle;
	}

/******************* Leading Tab Styles *******************/

h1.leadingTabTitle {
	background      : <%=DARK_IVORY%>;
	color           : <%=DARK_GRAY%>;
	font-size       : <%=FONT_SIZE_BIG%>;
	font-weight     : bold;
	margin          : 0 0 1em 0;
	padding         : <%=INNER_PADDING%>;
	}
	
p.leadingTabDescription {
	font-size       : <%=FONT_SIZE_NORMAL%>;
	color           : <%=DARK_GRAY%>;
	padding         : <%=INNER_PADDING%>;
	}
	
.leadingTabBody {
/*	background      : <%=IVORY_TINT%>; */
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_GRAY%>;
	}

.leadingTabBody p {
	padding         : <%=INNER_PADDING%>;
	}
	
ul.secondaryTabEntities {
	margin-top      : 1px;
	padding-top     : 0px;
	margin-bottom   : 1px;
	padding-bottom	  : 2px;
	margin-left     : 15px;
	padding-left    : 2px;
	list-style-type : disc;
	vertical-align  : middle;
	}
	
ul.secondaryTabEntities li {
	color           : <%=DARK_GRAY%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	margin-left     : 5px;
	padding         : 0; /* <%=INNER_PADDING%>; */
	vertical-align  : middle;
	}

ul.secondaryTabEntities li.collectionTitles {
	color           : <%=DARK_GRAY%>;
	font-size       : <%=FONT_SIZE_SMALLER%>;
	margin-left     : 3px;
	padding         : 1px 5px;
	vertical-align  : middle;
	}

ul.secondaryTabEntities p {
	color           : black; /* <%=MEDIUM_GRAY%>; */
/*	font-size       : <%=FONT_SIZE_NORMAL%>; */
	font-style      : normal; /*italic*/
	}
	
p.leadingTabEnding {
	margin          : 0.1em 0; // was 0.5em
	}

/******************* gallery images (in leading tab or page sections *******************/

td.gallerycell {
	text-align      : center;
	vertical-align  : top;
	}

td.gallerycelltextonly {
	text-align      : center;
	vertical-align  : middle;
	}

td.gallerycell p {
	font-style      : italic;
	text-align      : center;
	}

td.gallerytextcell {
	text-align      : center;
	vertical-align  : top;
	}
	
td.gallerytextcell p {
	font-style      : italic;
	text-align      : center;
	}

td.alphagallery {
 	text-align      : left;
 	vertical-align  : top;
 	padding         : 0 0 0.5em 0.5em;
 	}

td.alphagallery p {
	color           : <%=BODY_DEFAULT_FONT_COLOR%>;
	font-size       : <%=FONT_SIZE_SMALL%>;
	text-align      : left;
	}
	
/* note it is the <a>element</a> that is of class gallery, not the table cell */
.gallery a:visited {
	color           : <%=GALLERY_LINK_VISITED_COLOR%>;
	}

.gallery a:link {
	color           : red; /* <%=GALLERY_LINK_DEFAULT_COLOR%>; */
	}

.gallery a:hover {
	color           : green; /* <%=GALLERY_LINK_HOVER_COLOR%>; */
	}

.gallery a:active {
	color           : <%=GALLERY_LINK_ACTIVE_COLOR%>;
	}
	
.gallery img {
	align      : center;
	border          : 0;
	margin          : 0;
	}

.gallery img.padBottom {
/*	border          : 2px; */
	margin          : 0 0 1.5em 0;
	}

/******************* Page Groupings (columns within page) *******************/

h2.pageGroupTitle {
	background      : <%=MEDIUM_IVORY%>;
	color           : <%=DARK_GRAY%>;
	font-size       : <%=FONT_SIZE_BIG%>;
	font-weight     : normal;
	margin-right    : 5px;
	margin-top      : 0;
	padding         : <%=INNER_PADDING%>;
	}
	
h2.pageGroupTitleRight {
	background      : <%=MEDIUM_IVORY%>;
	color           : <%=DARK_GRAY%>;
	font-size       : <%=FONT_SIZE_BIG%>;
	font-weight     : normal;
	margin-right    : 0;
	margin-top      : 0;
	padding         : <%=INNER_PADDING%>;
	}
	
p.pageGroupDescription {
	font-size       : <%=FONT_SIZE_NORMAL%>;
	color           : <%=DARK_OLIVE%>;
	margin          : 0.5em 0 0.5em 0.5em;
/*	padding         : <%=INNER_PADDING%>; */
	}
	
.pageGroupBody {
	font-size       : <%=FONT_SIZE_SMALLER%>;
	color           : <%=DARK_OLIVE%>;
	margin          : 0.5em 0 0.5em 0.5em;
/*	padding         : <%=INNER_PADDING%>; */
	}

.pageGroupBody p {
	padding         : <%=INNER_PADDING%>;
	}

ul.pageGroupEntities {
	margin-top      : 1px;
	padding-top     : 0px;
	margin-bottom   : 5px;
	padding-bottom	  : 2px;
	margin-left     : 15px;
	padding-left    : 2px;
	list-style-type : disc;
	vertical-align  : middle;
	}
	
ul.pageGroupEntities li {
	color           : <%=DARK_OLIVE%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	margin-left     : 5px;
	margin-bottom   : 10px;
	padding         : 0 3px 0 0; /* <%=INNER_PADDING%>; */
	vertical-align  : middle;
	}

ul.pageGroupEntities p {
	color           : black; /*<%=MEDIUM_GRAY%>;*/
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-style      : normal; /* italic */
	}

ul.pageGroupEntities img {
	border          : 0px;
	margin          : 5px 1em 0 0;
	vertical-align  : bottom;
	}

div.imageFloatLeft { /* could not make this work right */
/*	display         : block; */
	float           : left;
	margin          : 0;
	width           : 30%;
	}

.pageGroupBlurb {
	color           : <%=MEDIUM_GRAY%>;
	}

td.pageGroupBlurb { /* was td.pageGroupBlurb */
	color           : <%=MEDIUM_GRAY%>;
/* font-size       : <%=FONT_SIZE_NORMAL%>; */
	margin          : 3px 0 0 5px;
	padding         : 3px 3px 0 0;
	vertical-align  : baseline;
	}

td.pageGroupBlurb img {
	vertical-align  : top;
	}

/******************* SubCollections (within columns) *******************/

h3.subCollectionTitle {
	background      : <%=LIGHT_IVORY%>;
	color           : <%=DARK_GRAY%>;
	font-size       : <%=FONT_SIZE_MENU%>;
	font-weight     : normal;
	margin-right    : 5px;
	padding         : <%=INNER_PADDING%>;
	}
	
p.subCollectionDescription {
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	padding         : <%=INNER_PADDING%>;
	}
	
.subCollectionBody {
	font-size       : <%=FONT_SIZE_SMALLER%>;
	color           : <%=DARK_OLIVE%>;
	}

.subCollectionBody p {
	padding         : <%=INNER_PADDING%>;
	}

ul.subCollectionEntities {
	margin-top      : 1px;
	padding-top     : 0px;
	margin-bottom   : 1px;
	padding-bottom	  : 2px;
	margin-left     : 15px;
	padding-left    : 2px;
	list-style-type : circle;
	vertical-align  : middle;
	}
	
ul.subCollectionEntities li {
	color           : <%=DARK_OLIVE%>;
	font-size       : <%=FONT_SIZE_SMALL%>;
	margin-left     : 5px;
	padding         : 0; /* <%=INNER_PADDING%>; */
	}

ul.subCollectionEntities p {
	font-style      : italic;
	}

/******************* Alphabet Choice Links *******************/

p.alphaChoices {
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	margin          : 1px 0 1em 0;
	padding         : <%=INNER_PADDING%>;
	}
	
p.alphaChoices a.alphaSelected:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : red; /* <%=BODY_LINK_VISITED_COLOR%>; */
	background      : transparent; 
	}

p.alphaChoices a.alphaSelected:link {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=BODY_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}

p.alphaChoices a.alphaSelected:hover {
	font-weight     : bold; 
	text-decoration : underline;
	color           : <%=BODY_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

p.alphaChoices a.alphaSelected:active {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=BODY_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
	}

p.alphaChoices a.alphaUnselected:visited {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=BODY_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}

p.alphaChoices a.alphaUnselected:link {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=BODY_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}

p.alphaChoices a.alphaUnselected:hover {
	font-weight     : normal; 
	text-decoration : underline;
	color           : <%=BODY_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

p.alphaChoices a.alphaUnselected:active {
	font-weight     : normal; 
	text-decoration : none;
	color           : <%=BODY_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
	}

/******************* image styles *******************/

img.closecrop {
	margin          : 0;
	padding         : 0;
	}

/******************* old global.css.jsp styles for entity display *******************/

img.CUrestricted {
	margin-left    : 5px;
	vertical-align : middle;
	}

p.classPublicNames {
	margin          : 1em 0 0.5em 0;
	padding         : 0 0 0 2px;
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_MENU%>;
	font-style      :  normal;
	color           : <%=DARK_OLIVE%>; /* #AA3; #BC6015; */
	background-color: #DEDEDF;
	font-variant    : small-caps;
	}

p.entityIndented {
	margin          : 0em 0 0.2em 3em;
	padding         : 0 0 0 2px;
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_SMALL%>;
	font-style      :  normal;
	}
	
span.entityIndented {
	margin          : 0.2em 0 0.2em 3em;
	padding         : 0 0 0 2px;
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_SMALL%>;
	font-style      :  normal;
	}

.entityIndentedLink {
	margin          : 0 0 0.5em 6.5em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
/*	color           : <%=DARK_OLIVE%>; */
	}

p.entitiesIndented {
	margin          : 0em 0 0.2em 2em;
	padding         : 0 0 0 2px;
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_SMALL%>;
	font-style      :  normal;
	}
	
span.entitiesIndented {
	margin          : 0.2em 0 0.2em 2em;
	padding         : 0 0 0 2px;
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_SMALL%>;
	font-style      :  normal;
	}

.entitiesIndentedLink {
	margin          : 0 0 0.5em 3em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
/*	color           : <%=DARK_OLIVE%>; */
	}

p.entitiesTypeParagraph {
	font-size       : 100%;
	margin          : 0;
	}
	

p.entityTypeParagraph {
	margin          : 0 0 0 1em;
	}

.entitiesTypeText {
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_MENU%>;
	font-style      : normal;
	color           : #C933;
	margin          : 1em 0 1em 0;
	}


.entityTypeText {
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_MENU%>;
	font-style      : normal;
	color           : #C933;
	}

.entityTypeCounts {
	font-size       : <%=FONT_SIZE_SMALL%>;
	font-weight     : normal;
	}

p.thumbnail {
	margin          : 1em 0 1em 1em;
	}
	
p.thumbnail img {
	border          : 0;
	}

p.thumbnailIndented {
	margin          : 1em 0 1em 5em;
	}

p.thumbnailIndented img {
	border          : 0;
	}

p.entityRelations {
	margin          : 0.5em 0 0 1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	}

p.entityRelationsIndented {
	margin          : 0.75em 0 0 6em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	}


span.entityRelationsSpan { /* was p.entityRelations */
	padding-top     : 4px; /* from P */
	margin          : 0 0 0 1em; /* was 0 0 0 1em; */
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	color           : <%=DARK_OLIVE%>; /* DARK_OLIVE */
	}

span.entitiesRelationsSpan { /* was p.entityRelations */
	padding-top     : 4px; /* from P */
	margin          : 0 0 0 6.5em; /* was 0 0 0 1em; */
	font-weight     : bold;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	color           : <%=DARK_OLIVE%>; /* DARK_OLIVE */
	}

span.entityMoreSpan { 
	padding-top     : 0;
	margin          : 0 0 0 2.1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-style      : italic;
	color           : <%=DARK_OLIVE%>;
	}

span.entitiesMoreSpan { 
	padding-top     : 0;
	margin          : 0 0 0 9em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-style      : italic;
	color           : <%=DARK_OLIVE%>;
	}

span.typeMoreSpan { 
	padding-top     : 0;
	margin          : 0 0 0 3em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	font-style      : italic;
	color           : <%=DARK_OLIVE%>;
	}


p.entityAnnotationTitle {
	margin          : 0 0 0 1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	}

span.entityAnnotationDescription {
	margin          : 0 0 0 1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	font-style      : italic;
	color           : <%=DARK_OLIVE%>;
	}

p.entityAnnotationBody {
	margin          : 0 0 0 1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALLER%>;
	font-style      : italic;
	color           : <%=DARK_OLIVE%>;
	}

p.entityEditOptions {
	margin          : 1em 0 0 1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALLER%>;
/*	color           : <%=DARK_OLIVE%>; */
	}

p.entitiesEditOptions {
	margin          : 1em 0 0 6em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALLER%>;
/*	color           : <%=DARK_OLIVE%>; */
	}

.entityBody {
	margin          : 1em 0 0 1em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	}

.entitiesBody {
	margin          : 1em 0 0 4em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	}

.entityIndent {
	margin          : 0 0 0 2em;
	font-weight     : normal;
	font-size       : <%=FONT_SIZE_SMALL%>;
	color           : <%=DARK_OLIVE%>;
	}

ul.entityListElements {
	font-size       : <%=FONT_SIZE_SMALLER%>;
	margin          : 1px 0 1px 3em;
	padding-top     : 0px;
	padding-bottom  : 1px;
	padding-left    : 0px;
	list-style-type : square;
}

ul.entitiesListElements {
	font-size       : <%=FONT_SIZE_SMALLER%>;
	margin          : 1px 0 1px 10em;
	padding-top     : 0px;
	padding-bottom  : 1px;
	padding-left    : 0px;
	list-style-type : square;
}


p.entityTopMargin {
	margin          : 1em 0 0.5em 0.3em;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	color           : <%=DARK_OLIVE%>;
}	

.entityName {
	color           : #444444;
	font-weight     : bold;
	}

.entityNameAnchor {
	color           : #6A5ACD;
	font-weight     : bold;
	}

a.entityLink:visited {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=BODY_LINK_VISITED_COLOR%>;
	background      : transparent; 
	}

a.entityLink:link {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=BODY_LINK_DEFAULT_COLOR%>;
	background      : transparent; 
	}

a.entityLink:hover {
	font-weight     : bold; 
	text-decoration : underline;
	color           : <%=BODY_LINK_HOVER_COLOR%>;
	background      : transparent; 
	}

a.entityLink:active {
	font-weight     : bold; 
	text-decoration : none;
	color           : <%=BODY_LINK_ACTIVE_COLOR%>;
	background      : transparent;  
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

.captions {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 11px;
}

.citation {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 11px;
	margin: 0 0 0 1.5em;
}

.citationHighlight {
   color       : red;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size   : 9px;
	font-weight : bold;
	line-height : 11px;
}

.photoCitation {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 15px;
	margin: 1em 0 0 0em;
}


.entitiesCitation {
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	line-height: 11px;
	margin: 0 0 0 3em;
}


.navlinkblock {
		color               : black; /*#4B0082;*/
	/*	font-family         : Verdana,Arial, Helvetica, sans-serif; */
		font-size           : <%=FONT_SIZE_NORMAL%>;
		font-weight         : normal;
		margin              : 0.4em 0 0.2em 6em;
		padding-top         : 1px;
		padding-bottom      : 4px;
		text-indent         : -6em; /* means any line after first is at margin setting above, while first line is further toward left margin */
}

.servletForm {
	margin          : 0 0 0 1em;
	font-weight     : normal;
	font-size       : 1em;
	color			     : black;
	}

.servletbutton {
	background-color : #FAFAD2;
	border-color     : #CCCCDD;
	color            : #0000CD;
	font-family      : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size        : <%=FONT_SIZE_SMALLER%>;
	line-height      : <%=LINE_HEIGHT_NORMAL%>;
	margin           : 1em 0 1em 2em;
}


/******************* footer *******************/

td#footer {
	background      : <%=DARK_IVORY%>;
	color           : <%=DARK_TEAL%>;
	font-size       : <%=FONT_SIZE_NORMAL%>;
	margin          : 1em 0;
	padding         : <%=INNER_PADDING%>;
	text-align      : center;
	vertical-align  : middle;
	}

/******************* from global.css.jsp ****************/
.lightbackground {
	background-color	: #a0c5ce; //#AADDCC;  //#66CDAA; //#8FbC8F; //#BDB76B; #E0FFFF;
}

.lightbackground2 {
	background-color	: #F8F8C8; //#FFFF99; //#8FbC8F; //#BDB76B; #E0FFFF;
}

.whitebackground {
	background-color : #FFFFFF;
	color		: black;
	font-family	: Verdana, Arial, Helvetica, sans-serif;
	font-size	: 8pt;
	font-style	: normal;
	vertical-align  : top;
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

.form-item {
	background-color : #FAFAD2; /*#EADD6C;*/
	border-color : #2E440C;
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
}

.form-button {
	background-color : #CCCCFF; /* #DEB887; */
	border-color : #CCFFFF; /*#2E440C; */
	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	border-width : 1px;
	margin-top : 2px;
}


