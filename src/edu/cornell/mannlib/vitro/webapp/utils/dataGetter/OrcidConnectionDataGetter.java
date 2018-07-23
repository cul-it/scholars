/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.utils.dataGetter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.http.client.fluent.Request;
import org.apache.http.conn.HttpHostConnectException;

import com.fasterxml.jackson.databind.ObjectMapper;

import edu.cornell.mannlib.vitro.webapp.config.ConfigurationProperties;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;

/**
 * When a person's profile is displayed, check their ORCID status.
 * 
 * Note that an empty map means we were unable to obtain the status. A map with
 * empty status means that we were successful, but the ORCID connection has no
 * record of the person.
 * 
 * If we obtain the status, it will be in one of two forms: either an empty
 * structure, like this:
 * 
 * <pre>
 * {}
 * </pre>
 * 
 * or a populated structure like this:
 * 
 * <pre>
 * {
 *   "orcid_id": "1234-2345-3456-4567",
 *   "orcid_name": "Jim Blake",
 *   "orcid_page_url": "https://sandbox.orcid.org/1234-2345-3456-4567"
 *   "publications_pushed": 16,
 *   "last_update": "1239083124900"
 * }
 * </pre>
 * 
 * A value of 0 for last_update means that no publications have been pushed.
 */
public class OrcidConnectionDataGetter implements DataGetter {
    private static final Log log = LogFactory
            .getLog(OrcidConnectionDataGetter.class);

    private static final String PROPERTY_ORCID_CONNECTION_URL = "orcidConnection.baseUrl";
    private static final String KEY_ORCID_STATUS = "orcidStatus";
    private static final String KEY_NETID = "netID";
    private static final String KEY_ORCID_URL = "orcidConnectionUrl";

    private static final String STATUS_KEY_ORCID_ID = "orcid_id";
    private static final String STATUS_KEY_ORCID_NAME = "orcid_name";
    private static final String STATUS_KEY_ORCID_PAGE_URL = "orcid_page_url";
    private static final String STATUS_KEY_PUBLICATION_PUSHED = "publications_pushed";
    private static final String STATUS_KEY_LAST_UPDATE = "last_update";
    private static final Set<String> STATUS_KEYS = new HashSet<>(
            Arrays.asList(STATUS_KEY_ORCID_ID, STATUS_KEY_ORCID_NAME,
                    STATUS_KEY_ORCID_PAGE_URL, STATUS_KEY_PUBLICATION_PUSHED,
                    STATUS_KEY_LAST_UPDATE));

    private VitroRequest vreq;

    /**
     * Constructor with display model and data getter URI that will be called by
     * reflection.
     */
    public OrcidConnectionDataGetter(VitroRequest vreq) {
        this.vreq = vreq;
    }

    @Override
    public Map<String, Object> getData(Map<String, Object> pageData) {
        String netId = getNetIdFromRequestUrl();
        if (netId == null) {
            netId = getNetIdFromPageData(pageData);
        }
        if (netId == null) {
            return Collections.emptyMap();
        }
        log.debug("Get ORCID status for " + netId);

        String orcidUrl = getOrcidConnectionUrlFromConfigurationProperties();
        if (orcidUrl == null) {
            return Collections.emptyMap();
        }

        String personStatusString = queryOrcidConnection(orcidUrl, netId);
        if (personStatusString == null) {
            return Collections.emptyMap();
        }

        Map<String, Object> personStatusMap = parsePersonStatus(
                personStatusString);
        if (personStatusMap == null) {
            return addEntry(KEY_NETID, netId, //
                    addEntry(KEY_ORCID_URL, orcidUrl, //
                            new HashMap<String, Object>()));
        }

        log.debug(String.format("ORCID status for %s is %s", netId,
                personStatusMap));
        return addEntry(KEY_ORCID_STATUS, personStatusMap, //
                addEntry(KEY_NETID, netId, //
                        addEntry(KEY_ORCID_URL, orcidUrl,
                                new HashMap<String, Object>())));
    }

    private Map<String, Object> addEntry(String key, Object value,
            Map<String, Object> map) {
        map.put(key, value);
        return map;
    }

    private String getNetIdFromRequestUrl() {
        return vreq.getParameter("localID");
    }

    private String getNetIdFromPageData(Map<String, Object> pageData) {
        String individualUri = (String) pageData.get("individualURI");
        if (individualUri == null || individualUri.isEmpty()) {
            log.warn("Couldn't find 'individualURI' in pageData map.");
            return null;
        }

        int lastSlash = individualUri.lastIndexOf('/');
        if (lastSlash == -1) {
            log.warn("'individualURI' is not a valid URI: " + individualUri);
            return null;
        }

        String netId = individualUri.substring(lastSlash + 1);
        if (netId.isEmpty()) {
            log.warn("'individualURI' is not a valid URI: " + individualUri);
            return null;
        }

        return netId;
    }

    private String getOrcidConnectionUrlFromConfigurationProperties() {
        ConfigurationProperties props = ConfigurationProperties.getBean(vreq);
        String url = props.getProperty(PROPERTY_ORCID_CONNECTION_URL);
        if (url == null) {
            log.debug("No connection URL in runtime.properties");
            return null;
        }

        if (url.endsWith("/")) {
            url = url.substring(0, url.length() - 1);
        }

        return url;
    }

    private String queryOrcidConnection(String baseUrl, String netId) {
        try {
            String apiUrl = baseUrl + "/personStatus?localId=" + netId;
            String response = Request.Get(apiUrl).connectTimeout(1000)
                    .socketTimeout(1000).execute().returnContent().asString();
            log.debug(response);
            if (response.isEmpty()) {
                log.warn("Scholars-ORCID connection sent an empty response.");
                return null;
            } else {
                return response;
            }
        } catch (HttpHostConnectException e) {
            log.warn("Could not connect to Scholars-ORCID server: " + e);
            return null;
        } catch (IOException e) {
            log.warn("Failed to get personStatus data from "
                    + "Scholars-ORCID connection.", e);
            return null;
        }
    }

    private Map<String, Object> parsePersonStatus(String rawPersonStatus) {
        try {
            @SuppressWarnings("unchecked")
            HashMap<String, Object> json = new ObjectMapper()
                    .readValue(rawPersonStatus, HashMap.class);
            if (json.isEmpty()) {
                return Collections.emptyMap();
            }
            if (!json.keySet().equals(STATUS_KEYS)) {
                log.warn(String.format(
                        "Expected these fields: %s, but found these: %s",
                        STATUS_KEYS, json.keySet()));
                return Collections.emptyMap();
            }

            Map<String, Object> status = new HashMap<>();
            status.put(STATUS_KEY_ORCID_ID, json.get(STATUS_KEY_ORCID_ID));
            status.put(STATUS_KEY_ORCID_NAME, json.get(STATUS_KEY_ORCID_NAME));
            status.put(STATUS_KEY_ORCID_PAGE_URL,
                    json.get(STATUS_KEY_ORCID_PAGE_URL));
            status.put(STATUS_KEY_PUBLICATION_PUSHED,
                    json.get(STATUS_KEY_PUBLICATION_PUSHED));

            Date updated = parseLastUpdate(json.get(STATUS_KEY_LAST_UPDATE));
            if (updated != null) {
                status.put(STATUS_KEY_LAST_UPDATE, updated);
            }

            return status;
        } catch (IOException e) {
            log.warn("Failed to parse personStatus data: " + rawPersonStatus,
                    e);
            return null;
        }
    }

    private Date parseLastUpdate(Object rawValue) {
        long millis = Long.valueOf((String) rawValue);
        if (millis == 0) {
            return null;
        } else {
            return new Date(millis);
        }
    }
}
