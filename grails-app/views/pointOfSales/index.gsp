<%--
  User: Arnold
  Date: 12/17/11
  Time: 9:03 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
  <head>
    <title>Store Management System - Point Of Sales</title>
    <meta name="layout" content="main" />

    <style type="text/css">
        .ui-autocomplete-loading {
            background: white url('${request.contextPath}/images/spinner.gif') right center no-repeat;
        }

        #POS-Form, #POS-GridContainer{
            display: table;
        }

        #POS-Form label, .POS-FormItem{
            display: block;
            margin-left: 10px
        }

        #POS-Form label{
            margin-top: 10px;
            font-size: larger;
        }

        #POS-Form .POS-FormItem{
            margin-bottom: 10px;
            padding: 5px 5px 5px 5px;
            height: 20px;
            width: 250px;
            border: #777777 solid 1px;
            font-size: larger;
            font-weight: bolder;
        }

        #POS-Form div{
            float: left;
            margin-right: 10px;
            display: table-column;
        }

        #POS-ItemCode, #POS-SaleItemCode{
            text-align: center;
        }

        #POS-Quantity{
            text-align: right;
        }

        #POS-Discount{
            text-align: right;
        }

        #POS-ItemPrice{
            text-align: right;
        }

        #POS-GrandTotalDisplay{
            height: 205px;
            width: 700px;
            text-align: center;
            font-size: 70px;
            margin: 25px 0 0 0;
        }
    </style>

    %{--Pop Up--}%
    <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir:'css',file:'popUp.css')}" />
    <script src="${resource(dir:'js',file:'popUp.js')}" type="text/javascript"></script>
    %{--Pop Up--}%

    <script type="text/javascript">

        var itemDetailSrc = new Array();

        jQuery(function(){

            jQuery('input[type="button"]').button();

            jQuery("#POS-Form").bind('click', function() {
              jQuery("#POS-ItemCode").focus();
            });


            jQuery("#POS-ItemCode").focus().keypress(function(e){
                var code = (e.keyCode ? e.keyCode : e.which);
                if(code == 13) { //Enter keycode
                    getItemDetail(jQuery("#POS-ItemCode").val());
                }else if(code == 43 || code == 61){
                    if (confirm('Submit Transaction?')) {
                        submitPOSGrid();
                    }
                    return false;
                }
            });

            jQuery("#POS-Quantity").keypress(function(e){
                var code = (e.keyCode ? e.keyCode : e.which);
                if(code == 13) { //Enter keycode
                    jQuery("#POS-Discount").focus();
                    jQuery("#POS-Discount").select();
                }
            });

            jQuery("#POS-Discount").keypress(function(e){
                var code = (e.keyCode ? e.keyCode : e.which);
                if(code == 13) { //Enter keycode
                    setItemToGrid();
                }
            });

            initPOSGrid();

            initProductItemGrid();
        });

        function getItemDetail(itemCode){
            jQuery( "#POS-ItemCode" ).removeClass( "ui-autocomplete-loading" ).addClass( "ui-autocomplete-loading" );
            jQuery.getJSON('${request.getContextPath()}/pointOfSales/getItemDetail',{itemCode:itemCode},function(data){
                jQuery( "#POS-ItemCode" ).removeClass( "ui-autocomplete-loading" );
                if(data.saleItems != null && data.saleItems.length > 0){
                    if (data.saleItems.length > 1) {
                        jQuery.each(data.saleItems, function(idx, saleItem){
                            itemDetailSrc.push({
                                value: saleItem.code,
                                label: saleItem.salePrice + ' - ' + saleItem.remark,
                                price: saleItem.salePrice,
                                name : data.productItem.name,
                                det  : data.productItem.details,
                                desc : saleItem.remark
                            });
                        });

                        jQuery("#POS-SaleItemCode").autocomplete({
                            minLength: 0,
                            source: itemDetailSrc,
                            autoFocus: true,
                            focus: function( event, ui ) {
                                jQuery( "#POS-SaleItemCode" ).val( ui.item.value );
                                return false;
                            },
                            select: function( event, ui ) {

                                setItemDetail(ui.item.name, ui.item.price, ui.item.det);

                                itemDetailSrc = new Array();

                                return true;
                            }

                        });

                        jQuery("#POS-SaleItemCode").focus().autocomplete( "search");
                    } else {
                        var saleItem = data.saleItems[0];
                        jQuery( "#POS-SaleItemCode" ).val( saleItem.code );

                        setItemDetail(data.productItem.name, saleItem.salePrice, data.productItem.details);
                    }

                }else{
                    alert('No Sale Detail Found!!');
                    jQuery("#POS-ItemCode").select();
                }

            });

        }

        function setItemDetail(name, price, details){
            jQuery( "#POS-ItemName" ).val( name );
            jQuery( "#POS-ItemPrice" ).val( price );
            jQuery( "#POS-ItemDetails" ).val( details);

            jQuery("#POS-Quantity").focus();
            jQuery("#POS-Quantity").select();
        }

        var gridSec = 0;

        function setItemToGrid(){

            jQuery("#POS-Grid").jqGrid('addRowData',gridSec++,{
                itemCode      : jQuery("#POS-ItemCode").val()
                ,saleItemCode : jQuery("#POS-SaleItemCode").val()
                ,name         : jQuery("#POS-ItemName").val()
                ,price        : jQuery("#POS-ItemPrice").val()
                ,discount     : jQuery("#POS-Discount").val()
                ,quantity     : jQuery("#POS-Quantity").val()
                ,totalPrice   : (parseFloat(jQuery("#POS-ItemPrice").val()) * parseFloat(jQuery("#POS-Quantity").val())) - parseFloat(jQuery("#POS-Discount").val())
            });

            //jQuery("#POS-Grid").trigger("reloadGrid");

            jQuery("#POS-ItemCode").focus();
            jQuery("#POS-ItemCode").val('');
            jQuery("#POS-ItemName").val('');
            jQuery("#POS-ItemDetails").val('');
            jQuery("#POS-ItemPrice").val('');
            jQuery("#POS-Quantity").val(1);
            jQuery("#POS-Discount").val(0);
            jQuery("#POS-SaleItemCode").val('');
        }

        function submitPOSGrid(){
            var discount = prompt("Discount for this transaction", 0);
            var ids = jQuery("#POS-Grid").jqGrid('getDataIDs');
            if(ids.length > 0){
                var posGridDataStr = '['

                jQuery.each(ids, function(idx, id){
                    var rd = jQuery("#POS-Grid").jqGrid('getRowData',id);

                    posGridDataStr += '{';
                    posGridDataStr += ('"saleItemCode":"' + rd.saleItemCode + '",');
                    posGridDataStr += ('"quantity":"' + rd.quantity + '",');
                    posGridDataStr += ('"discount":"' + rd.discount + '",');
                    posGridDataStr += '},';
                });

                posGridDataStr += '{end:"true"}]';


                jQuery.getJSON('${request.contextPath}/pointOfSales/submitSalesTransaction',{posGridDataStr:posGridDataStr, discount:discount},function(data){
                    if(data.error){
                        alert(data.error);
                    }else if(data.salesTransactionCode != null && data.salesTransactionCode != 'null'){
                        alert('Transaction Has Been Submitted with code : ' + data.salesTransactionCode);
                        jQuery("#POS-Grid").jqGrid('clearGridData',true);

                        exportSalesTransaction(data.salesTransactionCode);
                    }else{
                        alert('No Sales Transaction Submitted');
                    }

                    jQuery("#POS-ItemCode").focus();
                });
            }else{
                alert('No Data to Submit');
            }

            jQuery("#POS-ItemCode").focus();
        }

        function exportSalesTransaction(salesTransactionCode){
            jQuery("#POS-Export-TransactionCode").val(salesTransactionCode);
            jQuery("#POS-Export-Name").val("BILL" + salesTransactionCode);

            jQuery("#POS-ExportForm").submit();
        }

        function initPOSGrid(){
            jQuery("#POS-Grid").jqGrid({
                datatype: "local",
                colNames:[
                    'Item Code'
                    ,'Sale Item Code'
                    ,'Name'
                    ,'Price'
                    ,'Quantity'
                    ,'Discount'
                    ,'Total Price'
                ],
                colModel :[
                    {name:'itemCode'    , index:'itemCode'    , width:200, align:'center', editable:false},
                    {name:'saleItemCode', index:'saleItemCode', width:0  , align:'center', editable:false, hidden: true},
                    {name:'name'        , index:'name'        , width:300, align:'left'  , editable:false},
                    {name:'price'       , index:'price'       , width:200, align:'right' , editable:false, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                    {name:'quantity'    , index:'quantity'    , width:100, align:'right' , editable:false},
                    {name:'discount'    , index:'discount'    , width:200, align:'right' , editable:false, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                    {name:'totalPrice'  , index:'totalPrice'  , width:200, align:'right' , editable:false, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}}
                ],
                height: 'auto',
                pager: '#POS-Pager',
                rowNum:20,
                rowList:[10,20,30],
                viewrecords: true,
                sortable: true,
                loadonce: true,
                gridview: true,
                forceFit: true,
                loadui: 'block',
                rownumbers: true,
                caption: 'Item List',
                footerrow: true,
                onSelectRow: function(rowid){
                    //TODO
                },
                gridComplete: function(){
                    var ids = jQuery("#POS-Grid").jqGrid('getDataIDs');
                    var totalQty = 0;
                    var grandTotalPrice = 0;

                    jQuery.each(ids, function(idx, id){
                      var rd = jQuery("#POS-Grid").jqGrid('getRowData',id);
                      totalQty += parseInt(rd.quantity);
                      grandTotalPrice += parseFloat(rd.totalPrice);
                    });

                    jQuery("#POS-Grid").jqGrid('footerData', "set", {
                        itemCode:'Grand TOTAL'
                        ,quantity:totalQty
                        ,totalPrice:grandTotalPrice
                    });

                    jQuery("#POS-GrandTotalDisplay").val(jQuery("#POS-Grid").jqGrid('footerData', "get").totalPrice);
                }
            });

            jQuery("#POS-Grid").jqGrid(
              'navGrid','#POS-Pager',
              {edit:false,add:false,del:false,search:false,view:true}, // options
              {}, // edit options
              {}, // add options
              {reloadAfterSubmit:false}, // del options
              {}, // search options
              {width:500} // view options
            ).jqGrid('navButtonAdd',"#POS-Pager",{
                buttonicon:'ui-icon-trash'
                ,title:'Remove Selected Item'
                ,caption:''
                ,position:'last'
                ,onClickButton:function(){
                    var selRow = jQuery("#POS-Grid").jqGrid('getGridParam','selrow');
                    if(selRow != null){
                        jQuery("#POS-Grid").jqGrid('delRowData',selRow);
                    }else{
                        alert('Please Select Row to Remove');
                    }
                }
            });
        }

        function initProductItemGrid(){
            jQuery("#ProductItem-Grid").jqGrid({
                url: '${request.getContextPath()}/productItem/getProductItemList',
                datatype: "json",
                mtype: 'POST',
                colNames:[
                    'Product Code'
                    ,'Product Name'
                    ,'Details'
                    ,'Group'
                    ,'Remaining Stock'
                    ,'Total Sales Quantity'
                    ,'Total Sales Amount'
                ],
                colModel :[
                    {name:'code'                , index:'code'                , width:150, align:'center', editable:true , editoptions:{size:30, maxLength:50} , editrules:{required:false}, searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                    {name:'name'                , index:'name'                , width:250, align:'left'  , editable:true , editoptions:{size:50, maxLength:100}, editrules:{required:true} , searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                    {hidden:true, name:'details'             , index:'details'             , width:350, align:'left'  , editable:true , editoptions:{cols:40, rows:5} , editrules:{required:false}, edittype:'textarea', searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                    {name:'item_group'          , index:'item_group'          , width:150, align:'left'  , editable:true , editoptions:{dataUrl:'${request.getContextPath()}/productItem/getGroupsSelect'} , edittype:'select', editrules:{required:false}, searchoptions:{sopt:['eq','ne'], dataUrl:'${request.getContextPath()}/productItem/getGroupsSelect'}, stype:'select'},
                    {name:'stock_quantity'      , index:'stock_quantity'      , width:150, align:'right' , editable:false, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'integer' , formatoptions:{thousandsSeparator: ",", defaultValue: '0'}},
                    {hidden:true, name:'total_sales_quantity', index:'total_sales_quantity', width:150, align:'right' , editable:false, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'integer' , formatoptions:{thousandsSeparator: ",", defaultValue: '0'}},
                    {hidden:true, name:'total_sales_amount'  , index:'total_sales_amount'  , width:150, align:'right' , editable:false, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}}
                ],
                height: 250,
                //sortname: 'code',
                pager: '#ProductItem-Pager',
                rowNum:10,
                rowList:[10,20,30],
                viewrecords: true,
                sortable: true,
                gridview: true,
                forceFit: true,
                loadui: 'block',
                rownumbers: true,
                caption: 'Product Items',
                onSelectRow: function(rowid){
                    //NA
                },
                gridComplete: function(){
                    //NA
                },
                ondblClickRow:function(rowid){
                    pickItem(rowid);
                }
            });

            jQuery("#ProductItem-Grid").jqGrid(
                    'navGrid','#ProductItem-Pager',
                    {edit:false,add:false,del:false,view:false}, // options
                    {}, // edit options
                    {}, // add options
                    {}, // del options
                    {multipleSearch:true, showOnLoad:true,
                        onInitializeSearch : function(form_id) {
                            jQuery(".vdata",form_id).keypress(function(e){
                                var code = (e.keyCode ? e.keyCode : e.which);
                                if(code == 13) { //Enter keycode
                                    e.preventDefault();
                                    jQuery(".ui-search").click();
                                }
                            });
                        }
                    }, // search options
                    {width:600} // view options
            ).jqGrid('navButtonAdd',"#ProductItem-Pager",{caption:"", buttonicon:"ui-icon-plus", onClickButton:function(){
                var id = jQuery("#ProductItem-Grid").jqGrid('getGridParam','selrow');
                pickItem(id);
            }, position: "first", title:"Pick Item", cursor: "pointer"});

            jQuery("#ProductItem-Grid").jqGrid('filterToolbar',{stringResult: false, searchOnEnter: true});
        }

        function pickItem(id){
            if (id) {
                var rd = jQuery("#ProductItem-Grid").jqGrid('getRowData',id);
                jQuery('#POS-ItemCode').val(rd.code);
                getItemDetail(jQuery("#POS-ItemCode").val());
                outClosePopUpSplash('popUpContainer','POS-ItemLookUpCont','POS-GridContainer',function(){});
            }
        }

    </script>

  </head>
  <body>
    <div id="POS-Form">
        <div>
            <label for="POS-ItemCode">Item Code</label>
            <input id="POS-ItemCode" class="POS-FormItem" style="display: inline; width: 210px;">
            <input type="button" id="POS-ItemLookUp" value="..." onclick="splashPopUp('POS-ItemLookUpCont', 'POS-GridContainer', '740px', '350px', function(){}, function(){})">

            <label for="POS-ItemName">Name</label>
            <input id="POS-ItemName" class="POS-FormItem" disabled="true">

            <label for="POS-ItemPrice">Price</label>
            <input id="POS-ItemPrice" class="POS-FormItem" disabled="true">

            <label for="POS-Quantity">Quantity</label>
            <input id="POS-Quantity" class="POS-FormItem" value="1">
        </div>
        <div>
            <label for="POS-SaleItemCode">Sale Item Code</label>
            <input id="POS-SaleItemCode" class="POS-FormItem">

            <label for="POS-ItemDetails">Details</label>
            <textarea id="POS-ItemDetails" class="POS-FormItem" style="height: 79px;" disabled="true"></textarea>

            <label for="POS-Discount">Discount</label>
            <input id="POS-Discount" class="POS-FormItem" value="0">
        </div>
        <div>
            <input id="POS-GrandTotalDisplay" class="POS-ITEM" disabled="true">
        </div>
    </div>

    <div id="POS-GridContainer">
        <table id="POS-Grid"></table>
        <div id="POS-Pager"></div>
    </div>

    <form action="${request.getContextPath()}/jasperExport/export" target="_self" id="POS-ExportForm" style="display: none;">
        <input type="hidden" name="_format" value="PDF">
        <input type="hidden" name="_name" value="BILL" id="POS-Export-Name">
        <input type="hidden" name="_file" value="POSBill">
        <input type="hidden" name="transaction_code" value="xxx" id="POS-Export-TransactionCode">
    </form>

    <div id="POS-ItemLookUpCont" style="display: none;">
        <table id="ProductItem-Grid"></table>
        <div id="ProductItem-Pager"></div>
    </div>

  </body>
</html>