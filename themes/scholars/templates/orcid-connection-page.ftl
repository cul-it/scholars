<div class="row scholars-row orcid-page">
  <div class="col-sm-12 col-md-12 col-lg-12 scholars-container">
    <h1>
      ORCID connection
    </h1>

    <#if orcidStatus.orcid_id??>
      <p>
        ${orcidStatus.publications_pushed} publications on this page have been added to the ORCID record for 
        <a href="${orcidStatus.orcid_page_url}" target="_blank">${orcidStatus.orcid_name}</a>.
      </p><p>
        <#if orcidStatus.last_update??>
        The most recent update was on ${orcidStatus.last_update?string("EEEE, MMMM dd, yyyy")}.
        </#if>
      </p>
      <p style="float: right;">
        <a class="scholars-btn-link" href="${urls.base}/display/${netID}" title="Return to profile page">
          Return to profile page
        </a>
        <a class="orcid-btn-link" 
            href="${orcidConnectionUrl}?localID=${netID}" 
            title="link to ORCID connection" style="color:#fff">
          Update publications in ORCID
        </a>
      </p>
    <#else>
      <p>
        Is this your page?
      </p><p>
        Scholars can add your publications to your ORCID record.
      </p><p>
        Publications that are already in your ORCID record will not be affected.
        If a publication in Scholars matches one in your ORCID record, ORCID lets
        you decide which one is the "preferred" source.
      </p><p>
        To authorize the transfer, you will log in to your Cornell NetID account,
        then log in to ORCID and grant permission.
      </p><p style="float: right;">
        <a class="scholars-btn-link" href="${urls.base}/display/${netID}" title="Return to profile page">
          Return to profile page
        </a>
        <a class="orcid-btn-link" 
            href="${orcidConnectionUrl}?localID=${netID}" 
            title="link to ORCID connection" style="color:#fff">
          Enable ORCID connection
        </a>
      </p>
    </#if>

  </div>
</div>