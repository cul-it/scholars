function CustomTooltip(tooltipId, width){
	var tooltipId = tooltipId;
  $("body").append("<div class='tip' id='"+tooltipId+"'></div>");
	if(width){
		$("#"+tooltipId).css("width", width);
	}
	
	hideTooltip();
	
	function showTooltip(content, event){
		$("#"+tooltipId).html(content);
		$("#"+tooltipId).show();
		
		updatePosition(event);
	}
	
	function hideTooltip(){
		$("#"+tooltipId).hide();
	}
	
	function updatePosition(event){
		var ttid = "#"+tooltipId;
		var xOffset = 20;
		var yOffset = 10;
		
		 var ttw = $(ttid).width();
		 var tth = $(ttid).height();
		 var wscrY = $(window).scrollTop();
		 var wscrX = $(window).scrollLeft();
		 var curX = (document.all) ? event.clientX + wscrX : event.pageX;
		 var curY = (document.all) ? event.clientY + wscrY : event.pageY;
		 var ttleft = ((curX - wscrX + xOffset*2 + ttw) > $(window).width()) ? curX - ttw - xOffset*2 : curX + xOffset;
		 if (ttleft < wscrX + xOffset){
		 	ttleft = wscrX + xOffset;
		 } 
		 var tttop = ((curY - wscrY + yOffset*2 + tth) > $(window).height()) ? curY - tth - yOffset*2 : curY + yOffset;
		 if (tttop < wscrY + yOffset){
		 	tttop = curY + yOffset;
		 } 
		 $(ttid).css('top', tttop + 'px').css('left', ttleft + 'px');
	}
	
	return {
		showTooltip: showTooltip,
		hideTooltip: hideTooltip,
		updatePosition: updatePosition
	}
}


function showDetail(d) {
    // change outline to indicate hover state.

    d3.select(this).attr('stroke', 'black');

    if (clicked != true){

      var content = '<span class="value">' +
      d.name +
      '</span><br/>';

      //console.log(content);
      tooltip.showTooltip(content, d3.event);


    }
  }

  function moreDetail(data){
     // change outline to indicate hover state.
    //d3.select(this).attr('stroke', 'black');
    var content;
    content = "<p><span id='close' onclick ='ttip()'><img src= './images/whiteX.png' ID='closeIcon' alt='close'></span></p>";
    content += "<span class=\"name\">Title: </span><span class=\"value\"><a href='" + data.grant.uri + "'>" + data.name + "</a></span><br/>";
    content += this.format_people(data.people);
    content += "<span class=\"name\">Academic Unit: </span><span class=\"value\"><a href='" + data.dept.uri + "'>" + data.dept.name + "</a></span><br/>";
    content += "<span class=\"name\">Funding agency: </span><span class=\"value\"><a href='" + data.funagen.uri + "'>" + data.funagen.name + "</a></span><br/>";
    content += "<span class=\"name\">Start Year: </span><span class=\"value\"> " + data.start + "</span><br>";
    content += "<span class=\"name\">End Year: </span><span class=\"value\"> " + data.end + "</span>";
    tooltip.showTooltip(content, d3.event);
  }

  /*
   * Hides tooltip
   */
   function hideDetail(d) {


   	if(d && ('group' in d)){
      //console.log(d);
      d3.select(this).attr('stroke', d3.rgb(fillColor(d.group)).darker());
    }
    else{
     // console.log('test');
    }

    if (clicked!= true){
      tooltip.hideTooltip();
    }


  }
  function addCommas(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }

    return x1 + x2;
  }

  function clickFunction(d){
  	clicked = true; 
    moreDetail(d);
  }


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
        results.push(this.format_person(p));
      }
      return results;
    }).call(this);
    return spans.join("");
  };

  function format_person(p) {
    var role;
    if (p.role === "PI") {
      role = "Investigator";
    } else {
      role = "Co-Investigator";
    }
    return "<span class=\"name\">" + role + ": </span><span class=\"value\"><a href='" + p.uri + "'>" + p.name + "</a></span><br/>";
  };


  function ttip(){
    tooltip.hideTooltip();
    clicked = false; 
  }


