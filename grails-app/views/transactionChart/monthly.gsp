<%--
  User: arnold
  Date: 4/16/12
  Time: 7:17 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Transaction Chart</title>

    <link rel="stylesheet" type="text/css" href="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/jquery.jqplot.min.css" />
    <style type="text/css">
    .jqplot-target {
        margin: 10px;
        height: 450px;
        width: 830px;
        color: #dddddd;
    }

    #TransactionChart {
        background: rgb(57,57,57);
    }

    table.jqplot-table-legend {
        border: 0px;
        background-color: rgba(100,100,100, 0.0);
    }

    .jqplot-highlighter-tooltip {
        background-color: rgba(57,57,57, 0.9);
        padding: 7px;
        color: #dddddd;
    }
    </style>

    <!--jQuery-->
    <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir:'frameworks',file:'jquery-ui-1.8.16/css/redmond/jquery-ui-1.8.16.custom.css')}" />
    <script src="${request.contextPath}/frameworks/jquery-ui-1.8.16/js/jquery-1.6.2.min.js" type="text/javascript"></script>
    <script src="${request.contextPath}/frameworks/jquery-ui-1.8.16/js/jquery-ui-1.8.16.min.js" type="text/javascript"></script>
    <!--jQuery-->

    <script type="text/javascript" src="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/plugins/jqplot.dateAxisRenderer.min.js"></script>
    <script type="text/javascript" src="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/plugins/jqplot.logAxisRenderer.min.js"></script>
    <script type="text/javascript" src="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/plugins/jqplot.canvasTextRenderer.min.js"></script>
    <script type="text/javascript" src="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
    <script type="text/javascript" src="${request.getContextPath()}/frameworks/jquery.jqplot.1.0.0b2/plugins/jqplot.highlighter.min.js"></script>

    <script type="text/javascript">

        function initECFChart(){

            var totalSales;
            var totalItem;

            jQuery.post('${request.contextPath}/transactionChart/getTransChartMonthlyData',{dateBegin:jQuery('#transChartBeginDate').val(), dateEnd:jQuery('#transChartEndDate').val()},function(data){
                totalSales = new Array();
                totalItem  = new Array();

                jQuery.each(data.data,function(idx, val){

                    totalSales.push([val.transactionMonth, parseFloat(val.totalSales)]);

                });

                $.jqplot._noToImageButton = true;

                var monthlyPlot = $.jqplot("TransactionChart", [totalSales], {
                    seriesColors: ["rgba(78, 135, 255, 0.6)"],
                    title: 'Sales Transaction Monthly Chart',
                    highlighter: {
                        show: true,
                        sizeAdjust: 1,
                        tooltipOffset: 9
                    },
                    grid: {
                        background: 'rgba(57,57,57,0.0)',
                        drawBorder: false,
                        shadow: false,
                        gridLineColor: '#666666',
                        gridLineWidth: 2
                    },
                    legend: {
                        show: false,
                        placement: 'outside'
                    },
                    seriesDefaults: {
                        rendererOptions: {
                            smooth: true,
                            animation: {
                                show: true
                            }
                        },
                        showMarker: false
                    },
                    series: [
                        {
                            fill: true,
                            label: 'Sales Transaction Monthly',
                            markerOptions:{style:'square'}
                        }
                    ],
                    axesDefaults: {
                        rendererOptions: {
                            baselineWidth: 1.5,
                            baselineColor: '#444444',
                            drawBaseline: false
                        }
                    },
                    axes: {
                        xaxis: {
                            renderer: $.jqplot.DateAxisRenderer,
                            tickRenderer: $.jqplot.CanvasAxisTickRenderer,
                            tickOptions: {
                                formatString: "%b %Y",
                                angle: -30,
                                textColor: '#dddddd'
                            },
                            min: data.dateBegin,
                            max: data.dateEnd,
                            tickInterval: "1 month",
                            drawMajorGridlines: false
                        },
                        yaxis: {
                            renderer: $.jqplot.LogAxisRenderer,
                            pad: 0,
                            rendererOptions: {
                                minorTicks: 1
                            },
                            tickOptions: {
                                formatString: "%'d",
                                showMark: false
                            }
                        }
                    }
                });

                $('.jqplot-highlighter-tooltip').addClass('ui-corner-all');
            });

        }

        jQuery(function(){
            jQuery('.datePicker').datepicker({
                changeMonth: true,
                changeYear: true,
                dateFormat: '${grailsApplication.config.dateformatjs}'
            });

            //jQuery('.button').button();

            jQuery('.transChartBtn').button().click(function(){
                jQuery('#TransactionChart').empty();
                initECFChart();
            });
        });

    </script>

</head>
<body>

<div style="margin: 0 auto; width: 850px">
    <div style="font-size: 12px; margin: 10px">
        <input type="text" id="transChartBeginDate" class="datePicker">
        <input type="text" id="transChartEndDate" class="datePicker">
        <input type="button" class="transChartBtn button" value="Show Chart">
    </div>

    <div id="TransactionChart"></div>
</div>

</body>
</html>