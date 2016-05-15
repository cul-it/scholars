/**
 * central-click.js
 */
d3.svg.BubbleChart.define("central-click", function (options) {
  var self = this;
  var centralNode;

  self.setup = (function (node) {
    var original = self.setup;
    return function (node) {
      var fn = original.apply(this, arguments);
      self.event.on("click", function(node) {
        var d = node[0][0].__data__.item;
        self.tip.show(d);
        $(".close").click(function() {
          self.tip.hide();
        })
        $("#alphabetical").click(function() {
          // sort alphabetically
          // DOM -> text array -> DOM
          var texts = [];
          var textsToItems = {};
          $.each($(".d3-tip-item"), function(i, el) {
            texts.push($(el).text());
            textsToItems[$(el).text()] = el;
          });
          texts.sort();
          var resultHtml = "";
          for(var i = 0; i < texts.length; i++) {
            resultHtml += "<p class='d3-tip-item'>" + $(textsToItems[texts[i]]).html() + "</p>";
          }
          $(".item-container").html(resultHtml);
        });
        $("#citations").click(function() {
          // sort by citations
          // DOM -> array of objects {text: text, citations: citations} -> sort by citations -> DOM
          var citationObjects = [];
          var textsToItems = {};
          $.each($(".d3-tip-item"), function(i, el) {
            var obj = {text: $(el).text(), citations: $(el).find("a").attr("data-citations")}
            citationObjects.push(obj);
            textsToItems[obj.text] = el;
          });
          citationObjects.sort(function(c1, c2) {
            if(c1.citations < c2.citations) {
              return -1;
            }
            if(c1.citations > c2.citations) {
              return 1;
            }
            return 0;
          });
          var resultHtml = "";
          for(var i = 0; i < citationObjects.length; i++) {
            resultHtml += "<p class='d3-tip-item'>" + $(textsToItems[citationObjects[i].text]).html() + "</p>";
          }
          $(".item-container").html(resultHtml);
        })
      });
      return fn;
    };
  })();

  self.reset = (function (node) {
    var original = self.reset;
    return function (node) {
      var fn = original.apply(this, arguments);
      node.select("text.central-click").remove();
      return fn;
    };
  })();

  self.moveToCentral = (function (node) {
    var original = self.moveToCentral;
    return function (node) {
      if(typeof centralNode != "undefined") {
        if(node[0][0].textContent != centralNode[0][0].textContent) {
          self.tip.hide();
          centralNode = node;
        }
      }
      else {
        centralNode = node;
      }
      var fn = original.apply(this, arguments);
      var transition = self.getTransition().centralNode;
      transition.each("end", function() {
        node.append("text").classed({"central-click": true})
          .attr(options.attr)
          .style(options.style)
          .attr("x", function (d) {return d.cx;})
          .attr("y", function (d) {return d.cy;})
          .text(options.text)
          .style("opacity", 0).transition().duration(self.getOptions().transitDuration / 2).style("opacity", "0.8");
      });
      return fn;
    };
  })();
});