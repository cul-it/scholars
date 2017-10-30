/**
 * The tooltip behaves as follows: calls to showName() and hideName() are only
 * acted upon until showDetails() is called. Once details are displayed, the
 * tooltip is locked until closed, or until different details are requested.
 */
function GrantsTooltip(tooltipId, width) {
    var showingDetails = false;

    var tooltip = $("<div>", {
            class : "tip",
            id: tooltipId,
            width: width
        });
    $("body").append(tooltip);

    hideTooltip();

    return {
        showName : showName,
        hideName : hideName,
        showDetails : showDetails,
        hideTooltip : hideTooltip
    }

    function showName(data) {
        if (!showingDetails) {
            var content = '<span class="value">' + data.name + '</span><br/>';
            showTooltip(content, d3.event);
        }
    }

    function hideName() {
        if (!showingDetails) {
            hideTooltip();
        }
    }

    function showDetails(data) {
        showingDetails = true;

        var content = "<span class=\"name\">Title: </span><span class=\"value\"><a href='"
                + data.grant.uri + "'>" + data.name + "</a></span><br/>";
        content += format_people(data.people);
        content += "<span class=\"name\">Academic Unit: </span><span class=\"value\"><a href='"
                + data.dept.uri + "'>" + data.dept.name + "</a></span><br/>";
        content += "<span class=\"name\">Funding agency: </span><span class=\"value\"><a href='"
                + data.funagen.uri + "'>" + data.funagen.name + "</a></span><br/>";
        content += "<span class=\"name\">Start Year: </span><span class=\"value\"> "
                + data.start + "</span><br>";
        content += "<span class=\"name\">End Year: </span><span class=\"value\"> "
                + data.end + "</span>";
        showTooltip(content, d3.event, true);

        function format_people(people) {
            var p, spans;
            people.sort(function(a, b) {
                if (a.role > b.role) {
                    return -1;
                } else if (a.role < b.role) {
                    return 1;
                } else {
                    return 0;
                }
            });
            spans = (function() {
                var j, len, results;
                results = [];
                for (j = 0, len = people.length; j < len; j++) {
                    p = people[j];
                    results.push(format_person(p));
                }
                return results;
            }).call(this);
            return spans.join("");

            function format_person(p) {
                var role;
                if (p.role === "PI") {
                    role = "Investigator";
                } else {
                    role = "Co-Investigator";
                }
                return "<span class=\"name\">" + role
                        + ": </span><span class=\"value\"><a href='" + p.uri + "'>"
                        + p.name + "</a></span><br/>";
            };
        };

    }

    function showTooltip(content, event, addCloser) {
        var closebox = $("<p>").append(
                $("<span>", {
                    id: "close", 
                    on: {click: hideTooltip}
                }).append(
                    $("<img>", {
                        id: "closeIcon",
                        alt: "close",
                        src: ScholarsVis.Utilities.baseUrl + "/images/whiteX.png"
                    }))
                );
                
        $("#" + tooltipId).html(content);
        if (addCloser) {
            tooltip.prepend(closebox);
        }
        $("#" + tooltipId).show();
        updatePosition(event);
    }

    function hideTooltip() {
        showingDetails = false;
        $("#" + tooltipId).hide();
    }
    
    function updatePosition(event) {
        var ttid = "#" + tooltipId;
        var xOffset = 20;
        var yOffset = 10;

        var ttw = $(ttid).width();
        var tth = $(ttid).height();
        var wscrY = $(window).scrollTop();
        var wscrX = $(window).scrollLeft();
        var curX = (document.all) ? event.clientX + wscrX : event.pageX;
        var curY = (document.all) ? event.clientY + wscrY : event.pageY;
        var ttleft = ((curX - wscrX + xOffset * 2 + ttw) > $(window).width()) ? curX
                - ttw - xOffset * 2
                : curX + xOffset;
        if (ttleft < wscrX + xOffset) {
            ttleft = wscrX + xOffset;
        }
        var tttop = ((curY - wscrY + yOffset * 2 + tth) > $(window).height()) ? curY
                - tth - yOffset * 2
                : curY + yOffset;
        if (tttop < wscrY + yOffset) {
            tttop = curY + yOffset;
        }
        $(ttid).css('top', tttop + 'px').css('left', ttleft + 'px');
    }
}
