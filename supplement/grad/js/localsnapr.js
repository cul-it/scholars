/*
        link-preview v1.4 by frequency-decoder.com

        Released under a creative commons Attribution-ShareAlike 2.5 license (http://creativecommons.org/licenses/by-sa/2.5/)

        Please credit frequency-decoder in any derivative work - thanks.

        You are free:

        * to copy, distribute, display, and perform the work
        * to make derivative works
        * to make commercial use of the work

        Under the following conditions:

                by Attribution.
                --------------
                You must attribute the work in the manner specified by the author or licensor.

                sa
                --
                Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under a license identical to this one.

        * For any reuse or distribution, you must make clear to others the license terms of this work.
        * Any of these conditions can be waived if you get permission from the copyright holder.

        References:
        
        Wesnapr: http://www.websnapr.com
        Dustan Diaz: http://www.dustindiaz.com/sweet-titles-finalized
        Arc90: http://lab.arc90.com/2006/07/link_thumbnail.php
*/
var webSnapr = {
        x:0,
        y:0,
        obj:{},
        img:null,
        lnk:null,
        timer:null,
        opacityTimer:null,
        errorTimer:null,
        hidden:true,
        linkPool: {},
        baseURI: "images/screenshots/",
        imageCache: [],
        init: function() {
                var lnks = document.getElementsByTagName('img');
                var i = lnks.length || 0;
                var cnt = 0;
                while(i--) {
                        if(lnks[i].className && lnks[i].className.search(/localsnapr/) != -1) {
                                webSnapr.addEvent(lnks[i], ["focus", "mouseover"], webSnapr.initThumb);
                                webSnapr.addEvent(lnks[i], ["blur",  "mouseout"],  webSnapr.hideThumb);
                                webSnapr.linkPool[lnks[i].alt] = cnt++;
                        }
                }
                if(cnt) {
                        webSnapr.preloadImages();
                        webSnapr.obj = document.createElement('div');

                        webSnapr.ind = document.createElement('div');
                        webSnapr.ind.className= "imageLoaded";
                        webSnapr.img = document.createElement('img');
                        webSnapr.img.alt = "preview";
                        webSnapr.img.id = "fdImage";
                        webSnapr.addEvent(webSnapr.img, ["load"], webSnapr.imageLoaded);
                        webSnapr.addEvent(webSnapr.img, ["error"], webSnapr.imageError);
                        webSnapr.obj.id = "fdImageThumb";
                        webSnapr.obj.style.visibility = "hidden";
                        webSnapr.obj.style.top = "0";
                        webSnapr.obj.style.left = "0";
                        webSnapr.addEvent(webSnapr.img, ["mouseout"],  webSnapr.hideThumb);
                        webSnapr.obj.appendChild(webSnapr.ind);
                        webSnapr.obj.appendChild(webSnapr.img);
                        webSnapr.addEvent(webSnapr.obj, ["mouseout"], webSnapr.hideThumb);
                        document.getElementsByTagName('body')[0].appendChild(webSnapr.obj);
                }
        },
        preloadImages: function() {
                var imgList = ["lt.png", "lb.png", "rt.png", "rb.png", "error.gif", "loading.gif"];
                var imgObj  = document.createElement('img');

                for(var i = 0, img; img = imgList[i]; i++) {
                        webSnapr.imageCache[i] = imgObj.cloneNode(false);
                        webSnapr.imageCache[i].src = webSnapr.baseURI + img;
                }
        },
        imageLoaded: function() {
                if(webSnapr.errorTimer) clearTimeout(webSnapr.errorTimer);
                if(!webSnapr.hidden) webSnapr.img.style.visibility = "visible";
                webSnapr.ind.className= "imageLoaded";
                webSnapr.ind.style.visibility = "hidden";
        },
        imageError: function(e) {
                if(webSnapr.errorTimer) clearTimeout(webSnapr.errorTimer);
                webSnapr.ind.className= "imageError";
                webSnapr.errorTimer = window.setTimeout("webSnapr.hideThumb()",2000);
        },
        initThumb: function(e) {
                e = e || event;

                webSnapr.lnk       = this;
                var positionClass  = "left";

                var heightIndent;
                var indentX = 0;
                var indentY = 0;
                var trueBody = (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body;

                if(String(e.type).toLowerCase().search(/mouseover/) != -1) {
                        if (document.captureEvents) {
                                webSnapr.x = e.pageX;
                                webSnapr.y = e.pageY;
                        } else if ( window.event.clientX ) {
                                webSnapr.x = window.event.clientX+trueBody.scrollLeft;
                                webSnapr.y = window.event.clientY+trueBody.scrollTop;
                        }
                        indentX = 10;
                        heightIndent = parseInt(webSnapr.y-(webSnapr.obj.offsetHeight))+'px';
                } else {
                        var obj = this;
                        var curleft = curtop = 0;
                        if (obj.offsetParent) {
                                curleft = obj.offsetLeft;
                                curtop = obj.offsetTop;
                                while (obj = obj.offsetParent) {
                                        curleft += obj.offsetLeft;
                                        curtop += obj.offsetTop;
                                }
                        }
                        curtop += this.offsetHeight;

                        webSnapr.x = curleft;
                        webSnapr.y = curtop;

                        heightIndent = parseInt(webSnapr.y-(webSnapr.obj.offsetHeight)-this.offsetHeight)+'px';
                }
                
                if ( parseInt(trueBody.clientWidth+trueBody.scrollLeft) < parseInt(webSnapr.obj.offsetWidth+webSnapr.x) + indentX) {
                        webSnapr.obj.style.left = parseInt(webSnapr.x-(webSnapr.obj.offsetWidth+indentX))+'px';
                        positionClass = "right";
                } else {
                        webSnapr.obj.style.left = (webSnapr.x+indentX)+'px';
                }
                if ( parseInt(trueBody.clientHeight+trueBody.scrollTop) < parseInt(webSnapr.obj.offsetHeight+webSnapr.y) + indentY ) {
                        webSnapr.obj.style.top = heightIndent;
                        positionClass += "Top";
                } else {
                        webSnapr.obj.style.top = (webSnapr.y + indentY)+'px';
                        positionClass += "Bottom";
                }

                webSnapr.obj.className = positionClass;
                webSnapr.timer = window.setTimeout("webSnapr.showThumb()",250);
        },
        showThumb: function(e) {
                webSnapr.hidden = false;
                webSnapr.obj.style.visibility = webSnapr.ind.style.visibility = 'visible';
                webSnapr.obj.style.opacity = webSnapr.ind.style.opacity = '0';
                webSnapr.img.style.visibility = "hidden";
                
                var addy = String(webSnapr.lnk.alt);

                webSnapr.errorTimer = window.setTimeout("webSnapr.imageError()",15000);
                webSnapr.img.src = '/vivo/images/' + addy;

                /*@cc_on@*/
                /*@if(@_win32)
                return;
                /*@end@*/
                
                webSnapr.fade(10);
        },
        hideThumb: function(e) {
                // Don't mouseout if over the bubble
                e = e || window.event;

                // Check if mouse(over|out) are still within the same parent element
                if(e.type == "mouseout") {
                        var elem = e.relatedTarget || e.toElement;
                        if(elem.id && elem.id.search("fdImage") != -1) return false;
                }

                webSnapr.hidden = true;
                if(webSnapr.timer) clearTimeout(webSnapr.timer);
                if(webSnapr.errorTimer) clearTimeout(webSnapr.errorTimer);
                if(webSnapr.opacityTimer) clearTimeout(webSnapr.opacityTimer);
                webSnapr.obj.style.visibility = 'hidden';
                webSnapr.ind.style.visibility = 'hidden';
                webSnapr.img.style.visibility = 'hidden';
                webSnapr.ind.className= "imageLoaded";
        },
        fade: function(opac) {
                var passed  = parseInt(opac);
                var newOpac = parseInt(passed+10);
                if ( newOpac < 90 ) {
                        webSnapr.obj.style.opacity = webSnapr.ind.style.opacity = '.'+newOpac;
                        webSnapr.opacityTimer = window.setTimeout("webSnapr.fade('"+newOpac+"')",20);
                } else {
                        webSnapr.obj.style.opacity = webSnapr.ind.style.opacity = '1';
                }
        },
        addEvent: function( obj, types, fn ) {
                var type;
                for(var i = 0; i < types.length; i++) {
                        type = types[i];
                        if ( obj.attachEvent ) {
                                obj['e'+type+fn] = fn;
                                obj[type+fn] = function(){obj['e'+type+fn]( window.event );}
                                obj.attachEvent( 'on'+type, obj[type+fn] );
                        } else obj.addEventListener( type, fn, false );
                }
        }
}

webSnapr.addEvent(window, ['load'], webSnapr.init);

