function transform_bubble_chart_data(rawData) {
	return rawData;
}

function draw_bubble_chart(items, target) {
  var size = Math.min($(target).height(), $(target).width());
  var bubbleChart2 = new d3.svg.BubbleChart({
    supportResponsive: true,
    container: target,
    size: size,
    //viewBoxSize: => use @default
    innerRadius: size / 3.5,
    //outerRadius: => use @default
    radiusMin: size / 12,
    //radiusMax: use @default
    //intersectDelta: use @default
    //intersectInc: use @default
    //circleColor: use @default
    data: {
      items: items,
      eval: function (item) {return 50;},
      classed: function (item) {return item.text.split(" ").join("");}
    },
    plugins: [
      {
        name: "central-click",
        options: {
          text: "(See more detail)",
          style: {
            "font-size": "12px",
            "font-style": "italic",
            "font-family": "Source Sans Pro, sans-serif",
            //"font-weight": "700",
            "text-anchor": "middle",
            "fill": "black"
          },
          attr: {dy: "75px"},
          centralClick: function() {
            alert("Here is more details!!");
          }
        }
      },
      {
        name: "lines",
        options: {
          format: [
            {// Line #0
              textField: "text",
              classed: {text: true},
              style: {
                "font-size": "14px",
                "font-family": "Source Sans Pro, sans-serif",
                "text-anchor": "middle",
                fill: "black"
              },
              attr: {
                dy: "0px",
                x: function (d) {return d.cx;},
                y: function (d) {return d.cy;}
              }
            },
            {// Line #1
              textField: "count",
              classed: {count: true},
              style: {
                "font-size": "12px",
                "font-family": "Source Sans Pro, sans-serif",
                "text-anchor": "middle",
                fill: "black"
              }
              ,
              attr: {
                dy: "20px",
                x: function (d) {return d.cx;},
                y: function (d) {return d.cy;}
              }
            }
          ],
          centralFormat: [
            {// Line #0
              style: {"font-size": "35px"},
              attr: {}
            },
            {// Line #1
              style: {"font-size": "25px"},
              attr: {dy: "40px"}
            }
          ]
        }
      }]
  });
  bubbleChart2.tip = d3.tip().attr('class', 'd3-tip').html(function(data) { 
      var resultHtml = "<p class='close-container'><b class='close'>X</b></p><p class='sortContainer'>Sort by: <a href='#' id='alphabetical'>[Alphabetically] </a>";
      if(data.text == "Journal Articles"){
         resultHtml += "<a href='#' id='citations'> [Citation count]</a></p>";
      }
      else{
         resultHtml += "</p><h3>" + data.text + "</h3>";
      }
     
      resultHtml += "<div class='item-container'>"
      if(typeof data.children != "undefined") {
        for(var i = 0; i < data.children.length; i++) {
          resultHtml += "<p class='d3-tip-item'><a data-citations=" + data.children[i].citations + " data-child-index=" + i + " href='" + data.children[i].url + "'>" + data.children[i].name + "</a></p>";
        }
        resultHtml += "</ul>";
      }
       resultHtml += "</div>";
    return resultHtml;
  });
  d3.select("svg").call(bubbleChart2.tip);
}