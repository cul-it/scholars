/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.authenticate;

import static edu.cornell.mannlib.vitro.webapp.controller.authenticate.LoginExternalAuthSetup.ATTRIBUTE_REFERRER;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.cornell.mannlib.vedit.beans.LoginStatusBean.AuthenticationSource;
import edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingIdentifierFactory;
import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.dao.IndividualDao;
import edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory;

/**
 * Handle the return from the external authorization login server. If we are
 * successful, record the login. Otherwise, display the failure.
 */
public class LoginExternalAuthReturn extends BaseLoginServlet {
	private static final Log log = LogFactory
			.getLog(LoginExternalAuthReturn.class);

	/**
	 * <pre>
	 * Returning from the external authorization server. If we were successful,
	 * the header will contain the name of the user who just logged in.
	 * 
	 * Deal with these possibilities: 
	 * - The header name was not configured in deploy.properties. Complain.
	 * - No username: the login failed. Complain 
	 * - User corresponds to a User acocunt. Record the login. 
	 * - User corresponds to an Individual (self-editor). 
	 * - User is not recognized.
	 * </pre>
	 */
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		String username = ExternalAuthHelper.getHelper(req)
				.getExternalUsername(req);
		List<String> associatedUris = getAuthenticator(req)
				.getAssociatedIndividualUris(username);

		if (username == null) {
			log.debug("No username.");
			complainAndReturnToReferrer(req, resp, ATTRIBUTE_REFERRER,
					MESSAGE_LOGIN_FAILED);
		} else if (getAuthenticator(req).isExistingUser(username)) {
			log.debug("Logging in as " + username);
			getAuthenticator(req).recordLoginAgainstUserAccount(username,
					AuthenticationSource.EXTERNAL);
			removeLoginProcessArtifacts(req);
			checkBlacklistAndRedirect(req, resp, username, associatedUris);
		} else if (!associatedUris.isEmpty()) {
			log.debug("Recognize '" + username + "' as self-editor for "
					+ associatedUris);
			String uri = associatedUris.get(0);

			getAuthenticator(req).recordLoginWithoutUserAccount(username, uri,
					AuthenticationSource.EXTERNAL);
			removeLoginProcessArtifacts(req);
			checkBlacklistAndRedirect(req, resp, username, associatedUris);
		} else {
			log.debug("User is not recognized: " + username);
			removeLoginProcessArtifacts(req);
			new LoginRedirector(req, resp)
					.redirectUnrecognizedExternalUser(username);
		}
	}

	private void checkBlacklistAndRedirect(HttpServletRequest req,
			HttpServletResponse resp, String username,
			List<String> associatedUris) throws IOException {
		String black = checkForBlacklisted(req, associatedUris);
		if (black == null) {
			log.debug("Associated individual for user '" + username
					+ "' is not blacklisted.");
			new LoginRedirector(req, resp).redirectLoggedInUser();
		} else {
			log.debug("Associated individual for user '" + username
					+ "' is blacklisted: '" + black + "'");
			new LoginRedirector(req, resp).redirectBlacklistedUser(username,
					getBlacklistMessage(req, black));
		}
	}

	private String checkForBlacklisted(HttpServletRequest req,
			List<String> associatedUris) {
		if (associatedUris.isEmpty()) {
			return null;
		}

		String uri = associatedUris.get(0);

		ServletContext ctx = req.getSession().getServletContext();
		WebappDaoFactory wdf = (WebappDaoFactory) ctx
				.getAttribute("webappDaoFactory");
		IndividualDao indDao = wdf.getIndividualDao();
		Individual ind = indDao.getIndividualByURI(uri);
		return SelfEditingIdentifierFactory.checkForBlacklisted(ind, ctx);
	}

	private String getBlacklistMessage(HttpServletRequest req, String black) {
		try {
			File messageFile = selectBlacklistFile(req, black);
			InputStream stream = new FileInputStream(messageFile);
			byte[] buffer = new byte[stream.available()];
			stream.read(buffer);
			return new String(buffer);
		} catch (Exception e) {
			log.error(e, e);
		}
		return "A problem occurred while accessing your account.";
	}

	/**
	 * Can we find a message file with a name that matches the blacklist code?
	 * If not, use the default message file.
	 */
	private File selectBlacklistFile(HttpServletRequest req, String black) {
		ServletContext context = req.getSession().getServletContext();
		String realPath = context.getRealPath("/admin/selfEditBlacklist");
		
		File customFile = new File(realPath, "message_" + black + ".txt");
		if (customFile.exists()) {
			return customFile;
		}
		
		return new File(realPath, "message_default.txt");
	}

	private void removeLoginProcessArtifacts(HttpServletRequest req) {
		req.getSession().removeAttribute(ATTRIBUTE_REFERRER);
	}

	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}
}
