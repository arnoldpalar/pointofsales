<%--
  User: Arnold
  Date: 1/12/12
  Time: 12:46 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Dashboard</title>

    <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir:'frameworks',file:'jquery-ui-1.8.16/css/redmond/jquery-ui-1.8.16.custom.css')}" />
    <script src="${request.contextPath}/frameworks/jquery-ui-1.8.16/js/jquery-1.6.2.min.js" type="text/javascript"></script>
    <script src="${request.contextPath}/frameworks/jquery-ui-1.8.16/js/jquery-ui-1.8.16.min.js" type="text/javascript"></script>

    %{--Pop Up--}%
    <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir:'css',file:'popUp.css')}" />
    <script src="${resource(dir:'js',file:'popUp.js')}" type="text/javascript"></script>
    %{--Pop Up--}%

    %{--Spinner--}%
    <script src="${resource(dir:'js',file:'spinner.js')}" type="text/javascript"></script>
    %{--Spinner--}%

    <style type="text/css">
        .slideContainer{
            margin-left : auto;
            margin-right : auto;
            width : 800px;
            height : 500px;
            background-color : #7fffd4;
            position : relative;
            overflow : hidden;
            text-align : left;
        }

        .binder {
            background: #e8e8e8;
            float: left;
            width: 0;
            height: 500px;
            position: relative;
            overflow: hidden;
        }

        .slider {

        }

        .slideContent {
            width : 800px;
            height : 500px;
            float : left;
            position : relative;
        }

        .contentFrame{
            width: 100%;
            height: 100%;
            border: none;
        }

        .navButton{
            width: 100px;
            height: 50px;
            font-size: 14px;
            text-align: center;
        }

        .dashboardIcon {
            width: 120px;
            height: 100px;
            float: left;
            font-size: 12pt;
            text-align: center;
            vertical-align: middle;
            margin: 5px;
        }
    </style>

    <script type="text/javascript">
        var transition = 650;
        var contentWidth = 800;
        var binderWidth = 0;

        var marginCounter = 0;

        jQuery(document).ready(function(){
            jQuery('.button').button();

            var ttlSlides = jQuery(".slideContent").size();
            var ttlWidth = ttlSlides * contentWidth;

            jQuery(".binder").css('width',ttlWidth);

            jQuery("#prevButton").click(function(){
                if(marginCounter < 0){
                    marginCounter = marginCounter + contentWidth;
                    jQuery('.slider').animate({marginLeft: "+="+contentWidth+"px"}, transition);
                }else{
                    //TODO
                }
            });

            jQuery("#nextButton").click(function(){
                if(marginCounter > -(ttlWidth - contentWidth)){
                    marginCounter = marginCounter - contentWidth;
                    jQuery('.slider').animate({marginLeft: "-="+contentWidth+"px"}, transition);
                }else{
                    jQuery('.slider').animate({marginLeft: "0px"}, transition);
                    marginCounter = 0;
                }
            });

        });

        function loadContent(divID, url, afterLoaded){
            jQuery("#"+divID).empty();
            jQuery.ajax({
                url: url,
                type: "GET",
                dataType: "html",
                complete : function (req, err) {
                    jQuery("#"+divID).append(req.responseText);

                    if (afterLoaded) {
                        afterLoaded();
                    }
                }
            });
        }

    </script>
</head>
<body style="background-image: url('${request.contextPath}/images/hd_logo.png');">

    <div id="loading_spinner"></div>

    <div class="slideContainer">
        <div class="binder">
            <div class="slider">
                <div class="slideContent" id="slide1" style="background-color:#606060;">

                    <div class="dashboardIcon button"
                         onclick="splashPopUp('STC01', 'slide1', '850px', '500px', function(){loadContent('STC01','${request.contextPath}/transactionChart/daily',function(){});}, function(){jQuery('#STC01').empty();})"
                    >Sales Transaction Chart</div>
                    <div id="STC01"> </div>

                    <div class="dashboardIcon button"
                           onclick="splashPopUp('STC02', 'slide1', '850px', '500px', function(){loadContent('STC02','${request.contextPath}/transactionChart/monthly',function(){});}, function(){jQuery('#STC02').empty();})"
                    >Sales Transaction Chart (Monthly)</div>
                    <div id="STC02"> </div>

                </div>
                <div class="slideContent" id="slide2" style="background-color:#79b7e7;">PAGE 2</div>
                <div class="slideContent" id="slide3" style="background-color:#79b7e7;">PAGE 3</div>
                <div class="slideContent" id="slide4" style="background-color:#79b7e7;">PAGE 4</div>
                <div class="slideContent" id="slide5" style="background-color:#79b7e7;">PAGE 5</div>
            </div>
        </div>
    </div>

    <div style="width:800px; margin-left:auto; margin-right:auto; text-align:center; padding-top:5px;">
        <button id="prevButton" class="navButton button">&lt;&lt;PREV</button>
        <button id="nextButton" class="navButton button">NEXT&gt;&gt;</button>
    </div>

</body>
</html>