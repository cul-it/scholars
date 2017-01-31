ScholarsVis["UniversityWordCloud"] = function(options) {
  var defaults = {
      url : applicationContextPath + "/api/dataRequest/university_word_cloud",
      transform : transformUniversityWordcloud,
      display : drawUniversityWordCloud,
      closer : closeUniversityWordcloud
  };
  return new ScholarsVis.Visualization(options, defaults);
};

function transformUniversityWordcloud(rawData) {
  return rawData.map(keywordStructToWordCloudData).sort(descendingBySize);
  
  function keywordStructToWordCloudData(kwStruct) {
    return {
      text : kwStruct.keyword,
      size : kwStruct.countByPerson,
      articleCount : kwStruct.countOfArticle,
      entities : kwStruct.persons.map(personToEntity).sort(
          descendingByArticleCount),
    }
    
    function personToEntity(pStruct) {
      return {
        text : pStruct.personName,
        uri : toDisplayPageUrl(pStruct.personURI),
        artcount : pStruct.articleCount
      }
    }
    
    function descendingByArticleCount(a, b) {
      return b.artcount - a.artcount;
    }
  }
  
  function descendingBySize(a, b) {
    return b.size - a.size;
  }
}

function closeUniversityWordcloud(target) {
  $(target).children("svg").remove();
  $('div#tooltip').remove();
  $('div.d3-tip').remove();
}

function drawUniversityWordCloud(keywords, target) {
  var tip = createTooltip();
  activateInfoButton();
  refreshWordCloud();
  
  function activateInfoButton() {
    $('[data-toggle="tooltip"]').tooltip();
  }
  
  function createTooltip() {
    return d3.tip()
    .attr('class', 'sitewc d3-tip choices triangle-isosceles')
    .html(produceTooltipHtml);
    
    function produceTooltipHtml(d) {
      return d.entities.map(htmlForEntity).join('');
      
      function htmlForEntity(ent, i) {
        return "<div class='hoverable'>" 
        + "<a href='" + ent.uri + "'>" + (i + 1) + ". " + ent.text + " (" + ent.artcount + ")</a>"
        + "</div>";
      }
    }
  }
  
  function refreshWordCloud() {
    var fills = d3.scale.category20();
    
    var margin_height = 20;
    var margin_width = 20;
    var height = $(target).height() - margin_height;
    var width = $(target).width() - margin_width;
    
    keywords.forEach((kw, i) => kw.fillColor=fills(i));
    
    var keywordScale = d3.scale.linear().range([ 5, 50 ]).domain(
        [ d3.min(keywords, d => d.size), d3.max(keywords, d => d.size) ]);
    
    d3.layout.cloud()
    .size([ width, height ])
    .words(keywords)
    .rotate(d => ~~(Math.random() * 2) * 90)
    .font("Tahoma")
    .fontSize(d => keywordScale(d.size))
    .on("end", draw)
    .start();
    
    function draw(words) {
      d3.select(target)
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("id", "stage")
      .append("g")
      .attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")")
      .selectAll("text")
      .data(words)
      .enter()
      .append("text")
      .style("font-size", d => d.size + "px")
      .style("font-family", "Tahoma")
      .style("fill", d => d.fillColor)
      .attr("text-anchor", "middle")
      .attr("transform", d => "translate(" + [ d.x, d.y ] + ")rotate(" + d.rotate + ")")
      .text(d => d.text)
      .call(tip)
      .on('click', tip.show)
      .on('mouseover', handleMouseover)
      .on('mouseout', restoreColor);
      
      function handleMouseover(d) {
        d3.select(this).style("cursor", "pointer");
        d3.select(this).style("fill", brightenColor(d));
        d3.select("#content").html(getHtmlString(d));
        
        function brightenColor(d) {
          return toRgbString(brighten(parseRgb(d.fillColor), 40));
          
          function parseRgb(color) {
            return [ parseInt(color.substr(1, 2), 16),
              parseInt(color.substr(3, 2), 16),
              parseInt(color.substr(5, 2), 16) ];
          }
          
          function brighten(rgbs, p) {
            return rgbs.map(i => Math.min(i + p, 255));
          }
          
          function toRgbString(rgbs) {
            return "rgb(" + rgbs.join(',') + ")";
          }
        }
        
        function getHtmlString(d) {
          return '<b>' + d.text + '</b>,'
          + '<font class="text-muted"> person count: ' + d.entities.length
          + '</font>, ' + '<font class="text-warning">article count: '
          + d.articleCount + '</font>';
        }
      }
      
      function restoreColor(d) {
        d3.select(this).style("fill", d.fillColor);
      }
    }
  }
  
  $(document).click(
      function(e) {
        if (!$(e.target).closest('text').length && !$(e.target).is('text')) {
          tip.hide();
          d3.select("#content").text('');
        }
      }
  );

}