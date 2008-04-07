<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.PropertyInstanceDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.DataPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.PropertyInstance" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Property" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.KeywordProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.PropertyGroup" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.PropertyGroupDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ObjectPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.themes.editdefault.jsp.dashboardPropsList.jsp");
%>
<%
boolean showSelfEdits=false;
boolean showCuratorEdits=false;
if( VitroRequestPrep.isSelfEditing(request) ) {
    showSelfEdits=true;
}
if (loginHandler!=null && loginHandler.getLoginStatus()=="authenticated" && Integer.parseInt(loginHandler.getLoginRole())>=loginHandler.getEditor()) {
	showCuratorEdits=true;
}%>
<c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
<c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
<%
	log.debug("Starting dashboardPropsList.jsp");

	// The goal here is to retrieve a list of object and data properties appropriate for the vclass
	// of the individual, by property group, and sorted the same way they would be in the public interface

	Individual subject = (Individual) request.getAttribute("entity");
	if (subject==null) {
    	throw new Error("Subject individual must be in request scope for dashboardPropsList.jsp");
	}
	
	VitroRequest vreq = new VitroRequest(request);
	WebappDaoFactory wdf = vreq.getWebappDaoFactory();
	PropertyInstanceDao piDao = wdf.getPropertyInstanceDao();
	ObjectPropertyDao opDao = wdf.getObjectPropertyDao();
	List<Property> mergedList = new ArrayList<Property>();
	Collection<PropertyInstance> allPropInstColl = piDao.getAllPossiblePropInstForIndividual(subject.getURI(),false);
	if (allPropInstColl != null) {
	    for (PropertyInstance pi : allPropInstColl) {
			if (pi!=null) {
			    ObjectProperty op = opDao.getObjectPropertyByURI(pi.getPropertyURI());
			    op.setSubjectSide(pi.getSubjectSide());
			    op.setEditLabel(pi.getSubjectSide() ? op.getDomainPublic() : op.getRangePublic());
	        	mergedList.add(op);
	    	} else {
				log.error("property instance null from Collection created in PropertyInstanceDao.getAllPossiblePropInstForIndividual()");
			}
	    }
	} else {
		log.error("null Collection returned from PropertyInstanceDao.getAllPossiblePropInstForIndividual()");
	}
	
	DataPropertyDao dpDao = wdf.getDataPropertyDao();
    Collection <DataProperty> allDatapropColl = dpDao.getAllPossibleDatapropsForIndividual(subject.getURI(),false);
    if (allDatapropColl != null) {
        for (DataProperty dp : allDatapropColl ) {
            if (dp!=null) {
                dp.setEditLabel(dp.getPublicName());
                mergedList.add(dp);
            } else {
                log.error("data property null from Collection created in DataPropertyDao.getAllPossibleDatapropsForIndividual())");
            }
        }
    } else {
        log.error("null Collection returned from DataPropertyDao.getAllPossibleDatapropsForIndividual())");
    }

    // now add keywords
    PropertyGroupDao pgDao = wdf.getPropertyGroupDao();
    List<PropertyGroup> pgList = pgDao.getPublicGroupsWithoutProperties();
    String keywordGroupURI = null;
    int newTopRank=0;
    if (pgList != null) {
        for (PropertyGroup pg : pgList) {
            if ((pg.getName().indexOf("research"))>=0 || (pg.getName().indexOf("Research"))>=0) {
                keywordGroupURI = pg.getURI();
                if (pg.getDisplayRank()>newTopRank) {
                    newTopRank=pg.getDisplayRank();
                }
            } else if ((pg.getName().indexOf("keywords"))>=0 || (pg.getName().indexOf("Keywords"))>=0) {
                keywordGroupURI = pg.getURI();
                if (pg.getDisplayRank()>newTopRank) {
                    newTopRank=pg.getDisplayRank();
                }
            }
        }
    } else {
        log.error("null List returned from PropertyGroupDao.getPublicGroupsWithoutProperties()");
    }
    if (keywordGroupURI==null) { //still
        PropertyGroup pg = new PropertyGroup();
    	pg.setName("keywords");
    	pg.setDisplayRank(newTopRank + 1);
    	keywordGroupURI = pgDao.insertNewPropertyGroup(pg);
    	if (keywordGroupURI==null) {
    	    log.error("PropertyGroupDao.insertNewPropertyGroup() returned null URI");
    	}
    }
    if (keywordGroupURI!=null) {
        // note that the display rank of a property within a property group is something different
        // than the display rank of the property group relative to other property groups
    	mergedList.add(new KeywordProperty("has keyword","add keyword",newTopRank+1,keywordGroupURI));
    }
    
    if (mergedList!=null) {
    	Collections.sort(mergedList,new PropertyRanker(vreq));
        String lastGroupName = null;
		int groupCount=0;%>
		<ul id="dashboardNavigation">
<%		for (Property p : mergedList) {
		    String groupName=pgDao.getGroupByURI(p.getGroupURI()).getName();
		    if (!groupName.equals(lastGroupName)) {
		    	lastGroupName=groupName;
		        ++groupCount;
		        if (groupCount>1) { // close existing group %>
		        	</ul></li>
<%		    	}%>
		    	<li>
		    	<h2><a href="#"><%=groupName%></a></h2>
		    	<ul class="dashboardCategories">
<%			}%>
			<edLnk:editLinks item="<%=p %>" var="links" />
            <li class="dashboardProperty"><a href="${links[0].href}"><%=p.getEditLabel()%></a>
<%			if (showCuratorEdits) {
    			if (p instanceof ObjectProperty) {
				    ObjectProperty op = (ObjectProperty)p;%>
				    (o<%=p.isSubjectSide() ? op.getDomainDisplayTier() : op.getRangeDisplayTier()%>)
<%			    } else if (p instanceof DataProperty) {
    			    DataProperty dp = (DataProperty)p;%>
				    (d<%=dp.getDisplayTier() %>)
<%			    } else if (p instanceof KeywordProperty) {
				    KeywordProperty kp = (KeywordProperty)p;%>
				    (k<%=kp.getDisplayRank()%>)
<%			    } else {
				    log.error("unknown class of property "+p.getClass().getName()+" in merging properties for edit list");
			    }
			}%>
            </li>
<%      }%>
        </ul></li></ul>
<%    }
%>
<%!
private class PropertyRanker implements Comparator {
	VitroRequest vreq;
	WebappDaoFactory wdf;
    PropertyGroupDao pgDao;

    
    private PropertyRanker(VitroRequest vreq) {
	    this.vreq = vreq;
    	this.wdf = vreq.getWebappDaoFactory();
        this.pgDao = wdf.getPropertyGroupDao();
	}
	
    public int compare (Object o1, Object o2) {
        Property p1 = (Property) o1;
        Property p2 = (Property) o2;
        
        int diff=0;
        if (p1.getGroupURI()==null || p2.getGroupURI()==null) {
            return p1.getEditLabel().compareTo(p2.getEditLabel());
        } else {
	        PropertyGroup pg1 = pgDao.getGroupByURI(p1.getGroupURI());
	        PropertyGroup pg2 = pgDao.getGroupByURI(p2.getGroupURI());
	        if (pg1==null || pg2==null) {
	            return p1.getEditLabel().compareTo(p2.getEditLabel());
	        } else {
			   	diff = pg1.getDisplayRank() - pg2.getDisplayRank();
			    if (diff==0) {
			       	diff = determineDisplayRank(p1) - determineDisplayRank(p2);
			       	if (diff==0) {
			           	return p1.getEditLabel().compareTo(p2.getEditLabel());
			       	} else {
			           	return diff;
			       	}
			    }
	        }
        }
        return diff;
    }
    
    private int determineDisplayRank(Property p) {
        if (p instanceof DataProperty) {
        	DataProperty dp = (DataProperty)p;
        	return dp.getDisplayTier();
        } else if (p instanceof ObjectProperty) {
			ObjectProperty op = (ObjectProperty)p;
			String tierStr = p.isSubjectSide() ? op.getDomainDisplayTier() : op.getRangeDisplayTier();
			try {
			    return Integer.parseInt(tierStr);
			} catch (NumberFormatException ex) {
			    log.error("Cannot decode object property display tier value "+tierStr+" as an integer");
			}
        } else if (p instanceof KeywordProperty) {
			KeywordProperty kp = (KeywordProperty)p;
            return kp.getDisplayRank();
        } else {
			log.error("Property is of unknown class in PropertyRanker()");	
        }
        return 0;
    }
}

%>
