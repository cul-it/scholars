/**
 * Transform the output of the inner data distributor (select/json output)
 * to the form expected by SCORconn:
 */

function convertToScorconnFormat(selectOutput) {
    return JSON.stringify(transformAll(selectOutput), null, 2);

    function transformAll(selectOutput) {
        return selectOutput.results.bindings.map(transformArticle)
    }

    function transformArticle(article) {
        var result = {
            workType : "journal-article",
            title : article.pubLabel.value,
            externalIds : transformExternalIds(article)
        }
        var journalName = findJournalTitle(article);
        if (journalName != null) {
          result.journalTitle = journalName;
        }
        
        return result;

        function transformExternalIds(article) {
            var ids = [];
            ids.push({
                type : "other-id",
                url : article.pub.value,
                displayValue : "Scholars@Cornell:" + getLocalname(article.pub.value)
            });
            if (article.doi) {
                ids.push({
                    type : "doi",
                    url : "http://dx.doi.org/" + article.doi.value,
                    displayValue : article.doi.value
                });
            }
            return ids;
            
            function getLocalname(url) {
                return url.split("/").pop()
            }
        }
        
        function findJournalTitle(article) {
            if (article.journalName) {
              return article.journalName.value;
            } else {
              return null;
            }
        }
    }
}
