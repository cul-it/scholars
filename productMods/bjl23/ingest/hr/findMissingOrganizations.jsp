<html>
<head>
	<title>Find missing orgs</title>
</head>
<body>
    <h1>Find missing orgs</h1>
    <p>Make sure the raw HR model is attached to the webapp, containing the VIVO knowledgebase</p>
    <a href="http://localhost:8080/vivo/admin/sparqlquery?query=PREFIX+rdf%3A+++%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0D%0APREFIX+rdfs%3A++%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0D%0APREFIX+vitro%3A+%3Chttp%3A%2F%2Fvitro.mannlib.cornell.edu%2Fns%2Fvitro%2F0.7%23%3E%0D%0APREFIX+vivo%3A++%3Chttp%3A%2F%2Fvivo.library.cornell.edu%2Fns%2F0.1%23%3E%0D%0APREFIX+mann%3A++%3Chttp%3A%2F%2Fvivo.cornell.edu%2Fns%2Fmannadditions%2F0.1%23%3E%0D%0A%23%0D%0A%23+This+query+gets+all+range+entities+labels+and+types+of+a+person%0D%0A%23+A+query+like+this+could+be+used+to+get+enough+info+to+create+a+display%0D%0A%23+page+for+an+entity.%0D%0A%23%0D%0ASELECT+DISTINCT+%3Flabel+%3Fcode%0D%0AWHERE+%0D%0A{%0D%0A+%3Forg+%3Chttp%3A%2F%2Fvitro.mannlib.cornell.edu%2Fns%2Fbjl23%2Fhr%2F1%23job_Deptid%3E+%3Fcode+.%0D%0A+%3Forg+%3Chttp%3A%2F%2Fvitro.mannlib.cornell.edu%2Fns%2Fbjl23%2Fhr%2F1%23job_DeptidLdesc%3E+%3Flabel%0D%0A+OPTIONAL+{%0D%0A+++%3FexistOrg+vivo%3AactivityHRcode+%3Fcode%0D%0A+}+OPTIONAL+{%0D%0A+++%3FexistOrg+vivo%3AdepartmentHRcode+%3Fcode%0D%0A+}%0D%0A+FILTER+(!bound(%3FexistOrg))%0D%0A}%0D%0A%0D%0A&resultFormat=RS_TEXT">Find Orgs</a>
</body>
</html>
