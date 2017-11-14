/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var biboDocument = {
	
	onLoad: function() {
		this.bindEventListeners();
		var altmetricsHidden = false;
	},
	// Usually the PlumX callbacks hit before the Altmetrics, but not always. So account
	// account for both possibilities. That's why there *appears* to be redundant code.
	hidePlumX: function() {
		// PlumX attribute calls this function. Remove the plumx text container
		console.log("hide plumx");
		$("#plum-container").hide();
		$("span#metric-divider").remove();
	},
	
	showPlumX: function() {
		// PlumX attribute calls this function. Remove the plumx text container
		console.log("show plumx");
		$("#metrics-container").show();
		$("#title-container").removeClass("col-sm-9");
		$("#title-container").addClass("col-sm-8");
		$("#title-container").css("margin-left","0");
		if ( biboDocument.altmetricsHidden ) {
			$("#plum-container").html("PlumX");
			$(".ppp-container").css("padding-top","6px");
			$("#plumx").show();
			$("#alt-container").hide();
			$("#metric-divider").remove();
			$("#title-container").css("margin-left","0");
		}
	},

	bindEventListeners: function() {
		$('#plumx-link').on("click", function(){
			$("#altmetrics").hide();
			$("#plumx").show();
			$("#alt-container").html('<a id="altmetrics-link" href="javascript:" style="font-weight:bold">Altmetrics</a>');
			$("#plum-container").html("PlumX");
			$(".ppp-container").css("padding-top","6px");
			biboDocument.bindEventListeners();
		});
		$('#altmetrics-link').on("click", function(){
			$("#plumx").hide();
			$("#altmetrics").show();
			$("#plum-container").html('<a id="plumx-link" href="javascript:" style="font-weight:bold">PlumX</a>');
			$("#alt-container").html("Altmetrics");
			biboDocument.bindEventListeners();
		});
		// When no altmetrics, check to see if
		$('div.altmetric-embed').on('altmetric:hide', function () {
			console.log("hide altmetrics");
			if ( $("#plum-container").is(":visible") ) {
				console.log("plumx visible");
				biboDocument.altmetricsHidden = true;
				$("#plum-container").html("PlumX");
				$(".ppp-container").css("padding-top","6px");
				$("#plumx").show();
				$("#alt-container").hide();
				$("#metric-divider").remove();
				$("#title-container").css("margin-left","0");
			}
			else {
				console.log("plumx not visible");
				$("#metrics-container").hide();
				$("#title-container").removeClass("col-sm-8");
				$("#title-container").addClass("col-sm-9");
			}
	    });
		$('div.altmetric-embed').on('altmetric:show', function () {
			console.log("show altmetrics");
			$("#metrics-container").show();			
			$("#title-container").css("margin-left","0");
		});
	}
};

$(document).ready(function() {
    biboDocument.onLoad();
});