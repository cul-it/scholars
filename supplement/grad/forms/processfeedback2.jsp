<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.1" prefix="mt" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/regexp-1.0" prefix="rx" %>



<%-- create the match regexp "m/test1/mi" --%>
<%-- http://fightingforalostcause.net/misc/2006/compare-email-regex.php --%>
<rx:regexp id="rx1">
^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$
</rx:regexp>
<%-- set the text to match on --%>
<rx:text id="test">
miles@unthunk.org
</rx:text>
See if a match exists...<br>
<rx:existsMatch regexp="rx1" text="test">
     A match was found!<br>
</rx:existsMatch>
<rx:existsMatch regexp="rx1" text="test" value="false">
     A match was not found!<br>
</rx:existsMatch>

