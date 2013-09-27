<%--
  User: Arnold
  Date: 12/10/11
  Time: 10:54 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
  <head>
    <title>Product Item List</title>
    <meta name="layout" content="main" />

    <export:resource />

    <script type="text/javascript">

        function initProductItemGrid(){
            jQuery("#ProductItem-Grid").jqGrid({
                url: '${request.getContextPath()}/productItem/getProductItemList',
                editurl: '${request.getContextPath()}/productItem/editProductItemList',
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
                    ,'New Group Code'
                    ,'New Group Name'
                    ,'Initial Stock Quantity'
                    ,'Initial Purchase Date'
                    ,'Initial Purchase Price'
                    ,'Initial Sale Price'
                    ,'Initial Supplier'
                    ,'New Supplier'
                ],
                colModel :[
                    {name:'code'                , index:'code'                , width:150, align:'center', editable:true , editoptions:{size:30, maxLength:50} , editrules:{required:false}, searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                    {name:'name'                , index:'name'                , width:250, align:'left'  , editable:true , editoptions:{size:50, maxLength:100}, editrules:{required:true} , searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                    {name:'details'             , index:'details'             , width:350, align:'left'  , editable:true , editoptions:{cols:40, rows:5} , editrules:{required:false}, edittype:'textarea', searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                    {name:'item_group'          , index:'item_group'          , width:150, align:'left'  , editable:true , editoptions:{dataUrl:'${request.getContextPath()}/productItem/getGroupsSelect'} , edittype:'select', editrules:{required:false}, searchoptions:{sopt:['eq','ne'], dataUrl:'${request.getContextPath()}/productItem/getGroupsSelect'}, stype:'select'},
                    {name:'stock_quantity'      , index:'stock_quantity'      , width:150, align:'right' , editable:false, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'integer' , formatoptions:{thousandsSeparator: ",", defaultValue: '0'}},
                    {name:'total_sales_quantity', index:'total_sales_quantity', width:150, align:'right' , editable:false, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'integer' , formatoptions:{thousandsSeparator: ",", defaultValue: '0'}},
                    {name:'total_sales_amount'  , index:'total_sales_amount'  , width:150, align:'right' , editable:false, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                    {name:'newGroupCode'        , index:'newGroupCode'        , width:1  , align:'left'  , editable:true , editoptions:{size:30, maxLength:50} , editrules:{required:false, edithidden:true}, search:false, hidden:true},
                    {name:'newGroupName'        , index:'newGroupName'        , width:1  , align:'left'  , editable:true , editoptions:{size:30, maxLength:50} , editrules:{required:false, edithidden:true}, search:false, hidden:true},
                    {name:'initStockQty'        , index:'initStockQty'        , width:1  , align:'left'  , editable:true , editoptions:{size:20, maxLength:10} , editrules:{required:false, edithidden:true, integer:true}, search:false, hidden:true},
                    {name:'initPurchaseDate'    , index:'initPurchaseDate'    , width:1  , align:'left'  , editable:true , editoptions:{size:20, maxLength:10} , editrules:{required:false, edithidden:true}, search:false, hidden:true},
                    {name:'initPurchasePrice'   , index:'initPurchasePrice'   , width:1  , align:'left'  , editable:true , editoptions:{size:20, maxLength:10} , editrules:{required:false, edithidden:true, number:true}, search:false, hidden:true},
                    {name:'initSalePrice'       , index:'initSalePrice'       , width:1  , align:'left'  , editable:true , editoptions:{size:20, maxLength:10} , editrules:{required:false, edithidden:true, number:true}, search:false, hidden:true},
                    {name:'initSupplier'        , index:'initSupplier'        , width:1  , align:'left'  , editable:true , editoptions:{dataUrl:'${request.getContextPath()}/productItem/getSuppliersSelect'} , edittype:'select', editrules:{required:false, edithidden:true}, search:false, hidden:true},
                    {name:'newSupplier'         , index:'newSupplier'         , width:1  , align:'left'  , editable:true , editoptions:{size:50, maxLength:100} , editrules:{required:false, edithidden:true}, search:false, hidden:true}
                ],
                height: 'auto',
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
                    var rd = jQuery("#ProductItem-Grid").jqGrid('getRowData', rowid);

                    jQuery("#StockItem-Grid").jqGrid('GridUnload');
                    initStockItemGrid(rowid, rd.name);

                    jQuery("#SaleItem-Grid").jqGrid('GridUnload');
                    initSaleItemGrid(rowid, rd.name);
                },
                gridComplete: function(){
                  //TODO
                }
            });

            jQuery("#ProductItem-Grid").jqGrid(
              'navGrid','#ProductItem-Pager',
              {edit:true,add:true,del:true,view:true}, // options
              {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:productItemAfterShowEdit, afterSubmit: productItemAfterSubmit}, // edit options
              {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:productItemAfterShowAdd, afterSubmit: productItemAfterSubmit}, // add options
              {reloadAfterSubmit:true, afterSubmit: productItemAfterSubmit}, // del options
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
            );

            jQuery("#ProductItem-Grid").jqGrid('filterToolbar',{stringResult: false, searchOnEnter: true});
        }

        function productItemAfterShowEdit(formid){
            jQuery('#code').attr('disabled',true);
            jQuery('#tr_initStockQty').css('display','none');
            jQuery('#tr_initPurchaseDate').css('display','none');
            jQuery('#tr_initPurchasePrice').css('display','none');
            jQuery('#tr_initSupplier').css('display','none');
            jQuery('#tr_initSalePrice').css('display','none');
            jQuery('#tr_newSupplier').css('display','none');

            productItemAfterShowForm(formid);
        }

        function productItemAfterShowAdd(formid){
            jQuery('#code').attr('disabled',true);
            jQuery('#tr_initStockQty').css('display','');
            jQuery('#tr_initPurchaseDate').css('display','');
            jQuery('#tr_initPurchasePrice').css('display','');
            jQuery('#tr_initSupplier').css('display','');
            jQuery('#tr_initSalePrice').css('display','');
            jQuery('#tr_newSupplier').css('display','');

            initDatePicker('#initPurchaseDate');

            productItemAfterShowForm(formid);
        }

        function productItemAfterShowForm(formid){

        }

        function productItemAfterSubmit(response, postdata){
            var json = eval('(' + response.responseText + ')');

            if(json.errormessage){
                return [false, json.errormessage]
            }

            return [true,''];
        }

        function initStockItemGrid(productItemCode, productItemName){
            jQuery("#StockItem-Grid").jqGrid({
                url: '${request.getContextPath()}/stockItem/getStockItemList',
                editurl: '${request.getContextPath()}/stockItem/editStockItemList?productItemCode='+productItemCode,
                postData:{productItemCode:productItemCode},
                datatype: "json",
                mtype: 'POST',
                colNames:[
                    'Stock Code'
                    ,'Quantity'
                    ,'Purchase Date'
                    ,'Purchase Price'
                    ,'Supplier'
                    ,'New Supplier'
                ],
                colModel :[
                    {name:'code'         , index:'code'         , width:150, align:'center', editable:false, hidden:true},
                    {name:'quantity'     , index:'quantity'     , width:150, align:'right' , editable:true, editoptions:{size:20, maxLength:10}, editrules:{required:true, integer:true}, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'integer', formatoptions:{thousandsSeparator: ",", defaultValue: '0'}},
                    {name:'purchaseDate' , index:'purchaseDate' , width:150, align:'center', editable:true, editoptions:{size:20, maxLength:10}, editrules:{required:true}, searchoptions:{sopt:['eq','ne']}},
                    {name:'purchasePrice', index:'purchasePrice', width:150, align:'right' , editable:true, editoptions:{size:20, maxLength:10}, editrules:{required:true, number:true}, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                    {name:'supplier'     , index:'supplier'     , width:200, align:'center', editable:true, editoptions:{dataUrl:'${request.getContextPath()}/productItem/getSuppliersSelect'}, editrules:{required:false}, edittype:'select', searchoptions:{sopt:['eq','ne'], dataUrl:'${request.getContextPath()}/productItem/getSuppliersSelect'}, stype:'select'},
                    {name:'newSupplier'  , index:'newSupplier'  , width:1  , hidden:true   , editable:true, editoptions:{size:50, maxLength:100, edithidden:true}, editrules:{required:false}, search:false}
                ],
                height: 'auto',
                pager: '#StockItem-Pager',
                rowNum:10,
                rowList:[10,20,30],
                viewrecords: true,
                sortable: true,
                sortname: 'purchaseDate',
                sortorder: 'desc',
                gridview: true,
                forceFit: true,
                loadui: 'block',
                rownumbers: true,
                caption: 'Stock Items - (' + productItemCode + ') ' + productItemName,
                gridComplete: function(){
                  //TODO
                }
            });

            jQuery("#StockItem-Grid").jqGrid(
              'navGrid','#StockItem-Pager',
              {edit:true,add:true,del:false,view:true}, // options
              {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:stockItemAfterShowEdit, afterSubmit: stockItemAfterSubmit}, // edit options
              {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:stockItemAfterShowEdit, afterSubmit: stockItemAfterSubmit}, // add options
              {reloadAfterSubmit:true, afterSubmit: productItemAfterSubmit}, // del options
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
            );

            jQuery("#StockItem-Grid").jqGrid('filterToolbar',{stringResult: false, searchOnEnter: true});

            initDatePicker('#gs_purchaseDate', 'StockItem-Grid');
        }

        function stockItemAfterShowEdit(formid){
            jQuery('#tr_newSupplier').show();

            stockItemAfterShowForm(formid);
        }

        function stockItemAfterShowAdd(formid){
            jQuery('#tr_newSupplier').hide();

            stockItemAfterShowForm(formid);
        }

        function stockItemAfterShowForm(formid){
            initDatePicker('#purchaseDate');
        }

        function stockItemAfterSubmit(response, postdata){
            var json = eval('(' + response.responseText + ')');

            if(json.errormessage){
                return [false, json.errormessage]
            }

            return [true,''];
        }

        function initSaleItemGrid(productItemCode, productItemName){
            jQuery("#SaleItem-Grid").jqGrid({
                url: '${request.getContextPath()}/saleItem/getSaleItemList',
                editurl: '${request.getContextPath()}/saleItem/editSaleItemList?productItemCode='+productItemCode,
                postData:{productItemCode:productItemCode},
                datatype: "json",
                mtype: 'POST',
                colNames:[
                    'Quantity'
                    ,'Sale Price'
                    ,'Is Active'
                    ,'Remark'
                ],
                colModel :[
                    {name:'quantity' , index:'quantity' , width:150, align:'right' , editable:true, editoptions:{size:20, maxLength:10} , editrules:{required:false, integer:true}, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'integer', formatoptions:{thousandsSeparator: ",", defaultValue: '0'}},
                    {name:'salePrice', index:'salePrice', width:150, align:'right' , editable:true, editoptions:{size:20, maxLength:10} , editrules:{required:true, number:true}, searchoptions:{sopt:['eq','ne','ge','gt','le','lt']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                    {name:'isActive' , index:'isActive' , width:150, align:'center', editable:true, edittype:'checkbox', editoptions:{value:"true:false"} , editrules:{required:false}, stype:'select', searchoptions:{sopt:['eq','ne'], value:{'':'', true:'true', false:'false'}}/*, formatter:'checkbox'*/},
                    {name:'remark'   , index:'remark'   , width:250, align:'left'  , editable:true, editoptions:{size:50, maxLength:100}, editrules:{required:false}, searchoptions:{sopt:['eq','ne','bw','bn','ew','en','cn','nc']}}
                ],
                height: 'auto',
                pager: '#SaleItem-Pager',
                rowNum:10,
                rowList:[10,20,30],
                viewrecords: true,
                sortable: true,
                gridview: true,
                forceFit: true,
                loadui: 'block',
                rownumbers: true,
                caption: 'Sale Items - (' + productItemCode + ') ' + productItemName,
                gridComplete: function(){
                  //TODO
                }
            });

            jQuery("#SaleItem-Grid").jqGrid(
              'navGrid','#SaleItem-Pager',
              {edit:true,add:true,del:false,view:true}, // options
              {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:saleItemAfterShowEdit, afterSubmit: saleItemAfterSubmit}, // edit options
              {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:saleItemAfterShowEdit, afterSubmit: saleItemAfterSubmit}, // add options
              {reloadAfterSubmit:true, afterSubmit: productItemAfterSubmit}, // del options
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
            );

            jQuery("#SaleItem-Grid").jqGrid('filterToolbar',{stringResult: false, searchOnEnter: true});
        }

        function saleItemAfterShowEdit(formid){

        }

        function saleItemAfterShowAdd(formid){

        }

        function saleItemAfterShowForm(formid){

        }

        function saleItemAfterSubmit(response, postdata){
            var json = eval('(' + response.responseText + ')');

            if(json.errormessage){
                return [false, json.errormessage]
            }

            return [true,''];
        }

        jQuery(function(){
            initProductItemGrid();

            var productItemTabs = jQuery('#ProductItem-Tabs').tabs({});
        });

    </script>

  </head>
  <body>

    <div style="display: block; margin: 0 0 7px 0;">
        <export:formats formats="['excel', 'pdf', 'csv', 'ods', 'rtf'/*, 'xml'*/]" controller="productItem" action="exportProductItemList"/>
    </div>

    <table id="ProductItem-Grid"></table>
    <div id="ProductItem-Pager"></div>

    <div style="padding: 10px 0 10px 0;">
        <div id="ProductItem-Tabs">
            <ul>
              <li><a href="#StockItem-Tab">Stock List</a></li>
              <li><a href="#SaleItem-Tab">Sale Item List</a></li>
            </ul>

            <div id="StockItem-Tab">
                <div style="display: block; margin: 0 0 7px 0;">
                    <export:formats formats="['excel', 'pdf', 'csv', 'ods', 'rtf'/*, 'xml'*/]" controller="stockItem" action="exportStockItemList"/>
                </div>
                <table id="StockItem-Grid"></table>
                <div id="StockItem-Pager"></div>
            </div>

            <div id="SaleItem-Tab">
                <div style="display: block; margin: 0 0 7px 0;">
                    <export:formats formats="['excel', 'pdf', 'csv', 'ods', 'rtf'/*, 'xml'*/]" controller="saleItem" action="exportSaleItemList"/>
                </div>
                <table id="SaleItem-Grid"></table>
                <div id="SaleItem-Pager"></div>
            </div>
        </div>
    </div>

  </body>
</html>