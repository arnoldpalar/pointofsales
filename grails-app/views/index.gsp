<html>
<head>
    <title>Store Management System</title>
    <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.png')}" type="image/x-icon" />

    <!--jQuery-->
    <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir:'frameworks',file:'jquery-ui-1.8.16/css/redmond/jquery-ui-1.8.16.custom.css')}" />
    <script src="${request.contextPath}/frameworks/jquery-ui-1.8.16/js/jquery-1.6.2.min.js" type="text/javascript"></script>
    <script src="${request.contextPath}/frameworks/jquery-ui-1.8.16/js/jquery-ui-1.8.16.min.js" type="text/javascript"></script>
    <!--jQuery-->

    <!--jqGrid-->
    <link rel="stylesheet" type="text/css" media="screen" href="${request.contextPath}/frameworks/jqGrid-3.8.2/css/ui.jqgrid.css" />
    <script src="${request.contextPath}/frameworks/jqGrid-3.8.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
    <script src="${request.contextPath}/frameworks/jqGrid-3.8.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>
    <!--jqGrid-->

    <!--jQueryLayout-->
    <link rel="stylesheet" type="text/css" media="screen" href="${request.contextPath}/frameworks/jQuery.layout/layout-default-latest.css" />
    <script src="${request.contextPath}/frameworks/jQuery.layout/jquery.layout-latest-1.3.0.js" type="text/javascript"></script>
    <!--jQueryLayout-->

    <style type="text/css">
        table{
            font-size: 12px;
        }

        .ui-layout-pane{
            padding: 1px 1px 1px 1px !important;
        }

        .ui-tabs-panel{
            padding: 1px 1px 1px 1px !important;
        }

        #mainLogo{
            background: url("images/hd_logo.png") no-repeat;
            width: 253px;
            height: 125px;
        }

        #mainLogo:hover{
            background: url("images/hd_logo_hover.png") no-repeat;
            width: 253px;
            height: 125px;
        }

        .tradeMark{
            text-align: center;
            font-size: smaller;
        }

        .contentFrame{
            width: 100%;
            height: 100%;
            border: none;
        }
    </style>

    <script type="text/javascript">

        var maintab;

        jQuery(function(){
            jQuery('body').layout({
                //applyDefaultStyles: true,
                //resizerClass: 'ui-state-default',

                west__onresize: function (pane, $Pane) {
                    //jQuery(".menu-grid").jqGrid('setGridWidth',$Pane.innerWidth());
                },
                center__onresize: function (pane, $Pane) {
                    //jQuery(".rezisable-grid").jqGrid('setGridWidth',$("#tabs").innerWidth()-30);
                }

                //	some resizing/toggling settings
                ,	north__togglerLength_closed: '100%'	// toggle-button is full-width of resizer-bar
                ,	north__spacing_closed:	5		// resizer-bar when open (zero height)
                ,	north__spacing_open:	2		// resizer-bar when open (zero height)
                ,	north__resizable:		false	// OVERRIDE the pane-default of 'resizable=true'
                ,	south__resizable:		false	// OVERRIDE the pane-default of 'resizable=true'
                ,	south__spacing_closed:	5		// big resizer-bar when open (zero height)
                ,	south__spacing_open:	1		// no resizer-bar when open (zero height)

                //	some pane-size settings
                ,   north__size:            137
                ,   south__size:            30
                ,	west__minSize:			200
                ,	west__maxSize:			250
                ,	east__size:				100
                ,	east__minSize:			100
                ,	east__maxSize:			Math.floor(screen.availWidth / 2) // 1/2 screen width
            });

            maintab = jQuery('#tabs','#CenterPaneDiv').tabs({
                add: function(e, ui) {
                    jQuery(ui.tab).parents('li:first').append('<span class="ui-tabs-close ui-icon ui-icon-close" title="Close Tab"></span>');

                    // select just added tab
                    maintab.tabs('select', '#' + ui.panel.id);
                }
            });

            jQuery( "#tabs span.ui-tabs-close" ).live( "click", function() {

                var contentDivID = jQuery(jQuery(this).parents('li:first')[0]).children('a').attr('href').replace('#','');

                document.getElementById(contentDivID).innerHTML = '';

                maintab.tabs('remove', jQuery('li', maintab).index(jQuery(this).parents('li:first')[0]));
            });

            jQuery("#MenuGrid").jqGrid({
                url: "${request.contextPath}/menu/getMenuItems",
                datatype: "json",
                height: "auto",
                shrinkToFit:false,
                pager: false,
                loadui: "disable",
                colNames: ["id","Menu","url","isActionOnly","openInNewWindow"],
                colModel: [
                    {name: "id",width:0,hidden:true, key:true},
                    {name: "caption", width:195, resizable: false, sortable:false},
                    {name: "url",width:0,hidden:true},
                    {name: "isActionOnly",width:0,hidden:true},
                    {name: "openInNewWindow",width:0,hidden:true}
                ],
                treeGrid: true,
                treeGridModel: 'adjacency',
                ExpandColumn: "caption",
                ExpandColClick: true,
                treeIcons: {leaf:'ui-icon-document-b'},
                caption: "Menu",
                onSelectRow: function(rowid) {
                    var treedata = jQuery("#MenuGrid").jqGrid('getRowData',rowid);
                    if(treedata.isLeaf=="true") {
                        if(treedata.isActionOnly == "true"){
                            window.location = treedata.url;
                        }if(treedata.openInNewWindow == "true"){
                            window.open(treedata.url,'_blank');
                        }else {
                            var st = "#t"+treedata.id;
                            loadTab(treedata.caption,treedata.url,st);
                        }
                    }

                }
            });

        });

        function loadTab(caption,url,st,reloadIfExist){
            if (jQuery(st).html() != null) {
                maintab.tabs('select',st);
                if (reloadIfExist) {
                    jQuery(st, "#tabs").empty();
                    jQuery(st, "#tabs").append('<iframe src="' + url + '" class="contentFrame" id="' + st + '_frame">');
                    resizeFrame(document.getElementById(st + '_frame'));
                }
            } else {
                maintab.tabs('add', st, caption);
                jQuery(st, "#tabs").append('<iframe src="' + url + '" class="contentFrame" id="' + st + '_frame">');
                resizeFrame(document.getElementById(st + '_frame'));
            }
        }

        function resizeFrame(f) {
            f.style.height = f.contentWindow.document.body.scrollHeight + "px";
            //f.style.height = "200px";
        }

        function resizeIframe(dynheight){
            document.getElementById("childframe").height=parseInt(dynheight)+10;
        }

    </script>

</head>
<body style="font-size: 12px;">
    <div class="ui-layout-north" style="background-image: url('images/hd_bg.png'); padding: 5px 0px 5px 5px;"> %{--Top Panel--}%
        <div id="mainLogo"></div>
    </div>
    <div class="ui-layout-south"> %{--Bottom Panel--}%
        <div class="tradeMark">Copyright 2011</div>
    </div>

    <div id="CenterPaneDiv" class="ui-layout-center"> %{--Center Panel--}%
        <div id="tabs" style="font-size:11px">
            <ul>
                <li><a href="#tHOME_LINK">Home</a></li>
            </ul>
            <div id="tHOME_LINK">

            </div>
        </div>
    </div>

    <div class="ui-layout-west" style="padding:0;"> %{--Left Panel--}%
        <table id="MenuGrid"></table>
    </div>

    %{--<div class="ui-layout-east"> Right Panel

    </div>--}%
</body>
</html>
