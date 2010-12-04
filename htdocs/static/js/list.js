$(function(){
    var rank_width = $("#rank").width();
    var rrd_width = $("#qps_rrd").width();
    var tbl = tableToGrid("#list", {
        width : $(window).width()*0.9,
        height: '100%',
        hoverrows: true,
//        autowidth: true,
//        shrinkToFit: false,
//        forceFit: true,
        colModel: [
            {name: 'rank',      align: 'right', width: rank_width, sorttype: 'int', fixed: true, key: true, resizable: false},
            {name: 'alltime',   align: 'right', sorttype: 'float'},
            {name: 'count',     align: 'right', sorttype: 'int'},
            {name: 'qps',       align: 'right', sorttype: 'float'},
            {name: 'avg',       align: 'right', sorttype: 'float'},
            {name: 'pct95',     align: 'right', sorttype: 'float'},
            {name: 'fp',        sortable: false},
            {name: 'qps_rrd',   width: rrd_width, fixed: true, sortable: false, resizable: false},
            {name: 'avg_rrd',   width: rrd_width, fixed: true, sortable: false, resizable: false},
            {name: 'pct95_rrd', width: rrd_width, fixed: true, sortable: false, resizable: false},
        ],
    });

});

//$(window).bind('resize', function() {
//    $("#list").setGridWidth($(window).width());
//}).trigger('resize');

