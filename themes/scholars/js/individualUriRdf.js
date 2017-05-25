/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function(){
    
    $.extend(this, i18nStringsUriRdf);
    
    // This function creates and styles the "qTip" tooltip that displays the resource uri and the rdf link when the user clicks the uri/rdf icon.
    $('img#uriIcon').each(function()
    {
        $(this).qtip(
        {
            content: {
                prerender: true, // We need this for the .click() event listener on 'a.close'
                text: '<h5 style="font-size:16px;padding:6px 0 6px 2px;color:#595b5b">Share the URI of this profile</h5> <input id="uriLink" type="text" style="background-color:#f1f2ee;margin-bottom:4px" value="' + $('#uriIcon').attr('data') + '" /><h5 style="font-size:14px"><a class ="rdf-url" href="' + individualRdfUrl + '">View this profile in RDF format</a></h5><a class="close" href="#" style="margin-top:4px;color:#595b5b;opacity:.8">Close</a>'
            },
            position: {
                    my: 'top right',
                    at: 'bottom left'
            },
            show: {event: 'click'
			},

            hide: { 
				fixed: true,
				target: $('a.close'),
				event: 'click'
			},

            style: {
				//def: false,
                classes: 'qtip-light qtip-scholars'
            }
        });
    });

    $('span#iconControlsVitro').children('img#uriIcon').each(function()
    {
        $(this).qtip(
        {
            content: {
                prerender: true, // We need this for the .click() event listener on 'a.close'
                text: '<h5 style="font-size:16px;padding:6px 0 6px 2px;color:#595b5b">Share the URI of this profile</h5> <input id="uriLink" type="text" value="' + $('#uriIcon').attr('title') + '" /><h5 style="font-size:14px"><a class ="rdf-url" href="' + individualRdfUrl + '">' + i18nStringsUriRdf.viewRDFProfile + '</a></h5><a class="close" href="#">' + i18nStringsUriRdf.closeString + '</a>'
            },
            position: {
                    my: 'top left',
                    at: 'bottom right'
            },
            show: {event: 'click'
			},

            hide: { 
				fixed: true,
				target: $('a.close'),
				event: 'click'
			},

            style: {
				//def: false,
                classes: 'qtip-light qtip-scholars'
            }
        });
    });

    $('span#iconControlsRightSide').children('img#uriIcon').each(function()
    {
        $(this).qtip(
        {
            content: {
                prerender: true, // We need this for the .click() event listener on 'a.close'
                text: '<h5>' + i18nStringsUriRdf.shareProfileUri + '</h5> <input id="uriLink" type="text" value="' + $('#uriIcon').attr('title') + '" /><h5><a class ="rdf-url" href="' + individualRdfUrl + '">' + i18nStringsUriRdf.viewRDFProfile + '</a></h5><a class="close" href="#">' + i18nStringsUriRdf.closeString + '</a>'
            },
            position: {
                corner: {
                    target: 'bottomRight',
                    tooltip: 'topRight'
                }
            },
            show: {
                when: {event: 'click'}
            },
            hide: {
                fixed: true, // Make it fixed so it can be hovered over and interacted with
                when: {
                    target: $('a.close'),
                    event: 'click'
                }
            },
            style: {
                padding: '1em',
                width: 400,
                backgroundColor: '#f1f2ee'
            }
        });
    });

    // Prevent close link for URI qTip from requesting bogus '#' href
    $('a.close').click(function() {
        $('#uriIcon').qtip("hide");
        return false;
    });
});