/**
 * User: nmeylan
 * Date: 07.12.14
 * Time: 15:39
 */
function bind_agile_board_reports() {
    createOverlay("#statistics-help", 150);
    $('#statistics-info').click(function (e) {
        jQuery('#statistics-help').overlay().load();
    });

    if (gon.action === 'burndown') {
        burndown_chart();
    }
}

function burndown_chart() {
    var el = $("#burndown-chart");
    var path = el.data('link');
    var json;
    var parseDate = d3.time.format("%Y-%m-%d").parse;
    var max_date, min_date;
    d3.json(path, function (error, data) {

        data['actual'].forEach(function (d) {
            d.date = parseDate(d.date);
            d.values.stories = JSON.parse(d.values.stories);
        });

        max_date = d3.max(data['actual'], function (d) {
            return d.date;
        });
        min_date = d3.min(data['actual'], function (d) {
            return d.date;
        });
        if (data['projected'] !== undefined) {
            data['projected'].forEach(function (d) {
                d.date = parseDate(d.date);
            });
        }
        json = data;
        draw_burndown_chart(json, el, min_date, max_date);
    });

    $(window).resize(function () {
        $("#burndown-chart svg").remove();
        $("#burndown-chart .chart-tooltip").remove();
        draw_burndown_chart(json, el, min_date, max_date);
    });
}

function draw_burndown_chart(data, el, min_date, max_date) {
    var margin = {top: 20, right: 30, bottom: 30, left: 90},
        width = el.width() - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;


    var x = d3.time.scale()
        .range([0, width]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")
        .tickSize(-height)
        .tickPadding(9);

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .tickSize(-width)
        .tickPadding(9);

    x.domain([min_date, max_date]);
    var max_projected = data['projected'] !== undefined ? d3.max(data['projected'], function (d) {
        return d.values.points;
    }) : 0;
    y.domain([0,
        d3.max([
            max_projected,
            d3.max(data['actual'], function (d) {
                return d.values.points;
            })
        ])
    ]);
    var line = d3.svg.line()
        .x(function (d) {
            return x(d.date);
        })
        .y(function (d) {
            return y(d.values.points);
        });

    var tooltip = d3.select("body")
        .append("div").attr("class", "chart-tooltip");

    var svg = d3.select("#burndown-chart").append("svg")
        .attr("width", width + margin.left + 3 )
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


    svg.append("g")
        .attr("class", "x axis")
        .attr("width", width + margin.left + margin.right)
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
        .attr("dx", ".71em");

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", -60)
        .attr("x", -height / 2 + 60)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Points remaining");


    svg.append("path")
        .datum(data['actual'])
        .attr("class", "line")
        .attr("d", line);

    if (data['projected'] !== undefined) {
        svg.append("path")
            .datum(data['projected'])
            .attr("class", "line projected")
            .attr("d", line);
    }

    var actual_circles = data['actual'].filter(function (e) {
        return Object.keys(e.values.stories).length > 0;
    });

    svg.selectAll("dot")
        .data(actual_circles)
        .enter().append("circle")
        .attr('class', 'chart-dot')
        .attr("r", 3)
        .attr("cx", function (d) {
            return x(d.date);
        })
        .attr("cy", function (d) {
            return y(d.values.points);
        })
        .on("click", function (d) {
            tooltip.transition()
                .duration(200)
                .style("opacity", 1.0);
            tooltip.html(tooltip_builder(d))
                .style("left", ( d3.event.pageX + 20 ) + "px")
                .style("top", (d3.event.pageY + 10 - ($(tooltip[0]).height() / 2)) + "px");
        });
    $(document).mouseup(function (e) {
        var container = $(".chart-dot");

        if (!container.is(e.target) // if the target of the click isn't the container...
            && container.has(e.target).length === 0) // ... nor a descendant of the container
        {
            tooltip.transition()
                .duration(200)
                .style("opacity", 0);
        }
    });
}


function tooltip_builder(d) {

    var formatTime = d3.time.format("%d %B %Y");
    var output = "<div>";
    output += "<h2>" + d.values.points + " points remaining</h2>";
    var stories = d.values.stories;
    output += "<table style='margin-bottom:10px'>";
    for (var key in stories) {
        output += "<tr style='vertical-align:middle;'>";
        output += "<td style='font-size:14px; font-weight: bold; text-align: right'>" + stories[key].object + " : </h3></td>";
        output += "<td style='font-size:12px; font-weight: bold; text-align: left'>&Delta; Story points " + stories[key].variation + "</td>";
        output += "</tr>";
    }
    output += "</table>";

    output += "<b>" + formatTime(d.date) + "</b>";
    output += "</div>";
    return output
}