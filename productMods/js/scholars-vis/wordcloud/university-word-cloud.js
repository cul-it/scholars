function transformUniversityWordcloud(rawData) {
    // Working from fake data - no transformation needed.
    return rawData;
}

function drawUniversityWordCloud(transformed, target) {
    var fill = d3.scale.category20();

	var height = $(target).height();
    var width = $(target).width();

    var keywordScale = d3.scale.linear().range([5, 50]);

    var tip = d3.tip().attr('class', 'd3-tip choices triangle-isosceles').html(function(d) {
        var repr = "";
        for (var i = 0; i < d.entities.length; i++) {
            repr += "<div class='hoverable'><a href='" + d.entities[i].uri + "'>" + (i + 1) + ". " + d.entities[i].text + " (" + d.entities[i].artcount + ")</a></div>";
        }
        return repr;
    })

    var keywords;

    keywords = transformed.filter(function(d) {
        return + d.countByPerson > 0;
    }).map(function(d) {
        var entities = [];
        for (var i = 0; i < d.persons.length; i++) {
            entities.push({
                text: d.persons[i].personName,
                uri: d.persons[i].personURI,
                artcount: d.persons[i].articleCount
            });
        }

        entities.sort(function(a, b) {
            return b.artcount - a.artcount;
        });

        return {
            text: d.keyword,
            size: +d.countByPerson,
            articleCount: +d.countOfArticle,
            entities: entities
        };
    }).sort(function(a, b) {
        return d3.descending(a.size, b.size);
    });

    keywordScale.domain([d3.min(keywords,
    function(d) {
        return d.size;
    }), d3.max(keywords,
    function(d) {
        return d.size;
    })]);
    
    var wordsToFills = {};

    d3.layout.cloud().size([width, height]).words(keywords).rotate(function() {
        return~~ (Math.random() * 2) * 90;
    }).font("Tahoma").fontSize(function(d) {
        return keywordScale(d.size);
    }).on("end", draw).start();

    function parseRgb(rgbString) {
        var commaString = rgbString.substring(4, rgbString.length - 1);
        var numberStrings = commaString.split(",");
        var nums = [];
        for (var i = 0; i < numberStrings.length; i++) {
            nums.push(parseInt(numberStrings[i]));
        }
        return nums;
    }

    function brighten(rgbs, p) {
        var result = [];
        for (var i = 0; i < rgbs.length; i++) {
            if (rgbs[i] + 20 <= 255) {
                result.push(rgbs[i] + p);
            } else {
                result.push(255);
            }
        }
        return result;
    }

    function toRgbString(rgbs) {
        return "rgb(" + rgbs[0] + "," + rgbs[1] + "," + rgbs[2] + ")";
    }

    function draw(words) {
        d3.select(target).append("svg").attr("width", width).attr("height", height).attr("id", "stage").append("g").attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")").selectAll("text").data(words).enter().append("text").style("font-size",
        function(d) {
            return d.size + "px";
        }).style("font-family", "Tahoma").style("fill",
        function(d, i) {
            var wordFill = fill(i);
            wordsToFills[d.text] = wordFill;
            return wordFill;
        }).attr("text-anchor", "middle").attr("transform",
        function(d) {
            return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        }).text(function(d) {
            return d.text;
        }).call(tip).on('click', tip.show).on('mouseover',
        function(d) {
            d3.select(this).style("cursor", "pointer");
            var currentColor = d3.select(this).style("fill");
            var rgbs = parseRgb(currentColor);
            var brighterFill = toRgbString(brighten(rgbs, 40));
            d3.select(this).style("fill", brighterFill);
            d3.select("#content").html(getHtmlString(d));
        }).on('mouseout',
        function(d) {
            d3.select(this).style("fill", wordsToFills[d.text]);
        });
    }

    function getHtmlString(d) {
        var text = '<b>' + d.text + '</b>,' + '<font class="text-muted"> person count: ' + findEntityLength(d.text) + '</font>, ' + '<font class="text-warning">article count: ' + d.articleCount + '</font>';
        return text;
    }

    function findEntityLength(t) {
        for (var i = 0; i < keywords.length; i++) {
            var item = keywords[i];
            if (item.text === t) {
                return item.entities.length;
            }
        }
    }

    $(document).click(function(e) {
        if ((!$(e.target).closest('text').length && !$(e.target).is('text')) || (!$(e.target).closest('#stage').length && !$(e.target).is('#stage'))) {
            tip.hide();
            d3.select("#content").text('');
        }
    });
}