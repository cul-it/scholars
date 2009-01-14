<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
	<title>Incremental HR Ingest</title>
</head>

<body>
	<h1>Incremental HR Ingest</h1>

	<p><strong>Note: </strong> You must connect to the hrcumulative database first using the ingest menu.</p>

	<c:if test="${!empty param.errorMsg}">
		<p><strong style="color:red;">${param.errorMsg}</strong></p>
	</c:if>

	<label for="pathInput">Path to CSV files (on localhost):</label><br/>
	<form action="./incrementalIngestExec.jsp" method="post">
		<input type="text" size="40" id="pathInput" name="csvPath"/>
		<input type="submit" id="submit" value="Ingest data"/>
	</form>

</body>

</html>