<%--
  User: Arnold
  Date: 1/2/12
  Time: 6:53 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
  <head>
    <title>Sales Transaction List</title>
    <meta name="layout" content="main" />

    <export:resource />

    <script type="text/javascript">
      function initSalesTransactionGrid(){
        jQuery("#SalesTransaction-Grid").jqGrid({
            url: '${request.getContextPath()}/salesTransaction/getSalesTransactionList',
            datatype: "json",
            mtype: 'POST',
            colNames:[
                 'code'
                ,'Transaction Date'
                ,'Remark'
                ,'Person in Charge'
                ,'Sales Volume'
                ,'Discount'
                ,'Total Sales'
            ],
            colModel :[
                {name:'code'             , index:'code'             , width:150, align:'center', editable:false , searchoptions:{sopt:['eq','ne']}},
                {name:'transaction_date' , index:'transaction_date' , width:150, align:'center', editable:false , searchoptions:{sopt:['eq','ne']}},
                {name:'remark'           , index:'remark'           , width:250, align:'left'  , editable:false , searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                {name:'person_in_charge' , index:'person_in_charge' , width:200, align:'center', editable:false , searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                {name:'sales_volume'     , index:'sales_volume'     , width:200, align:'right' , editable:false , searchoptions:{sopt:['eq','ne','lt','le','gt','ge']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                {name:'discount'         , index:'discount'         , width:200, align:'right' , editable:false , searchoptions:{sopt:['eq','ne','lt','le','gt','ge']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}},
                {name:'total_sales'      , index:'total_sales'      , width:200, align:'right' , editable:false , searchoptions:{sopt:['eq','ne','lt','le','gt','ge']}, formatter:'currency', formatoptions:{decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'}}
            ],
            height: 'auto',
            //sortname: 'transaction_date',
            pager: '#SalesTransaction-Pager',
            rowNum:20,
            rowList:[10,20,30],
            viewrecords: true,
            sortable: true,
            //gridview: true,
            forceFit: true,
            loadui: 'block',
            rownumbers: true,
            subGrid: true,
            subGridUrl:'${request.getContextPath()}/salesTransaction/getSaleTransactionItems',
            subGridModel : [
              {
              name  : ['Item Code', 'Name', 'Quantity', 'Sale Price', 'Discount', 'Remark'],
              width : [100, 200, 100, 80, 80, 200],
              align : ['center', 'left', 'right', 'right', 'right', 'center'],
              params: ['code']
              }
            ],
            caption: 'Sales Transaction',
            onSelectRow: function(rowid){
              //TODO
            },
            gridComplete: function(){
              //TODO
            }
        });

        jQuery("#SalesTransaction-Grid").jqGrid(
          'navGrid','#SalesTransaction-Pager',
          {edit:false,add:false,del:false,view:true}, // options
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
          {width:'auto'} // view options
        );

        jQuery("#SalesTransaction-Grid").jqGrid('filterToolbar',{stringResult: false, searchOnEnter: true});

        initDatePicker('#gs_transaction_date', 'SalesTransaction-Grid');
      }

      jQuery(function(){
          initSalesTransactionGrid();
      });
    </script>
  </head>
  <body>

    <table id="SalesTransaction-Grid"></table>
    <div id="SalesTransaction-Pager"></div>

  </body>
</html>