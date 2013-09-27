<%--
  Created by IntelliJ IDEA.
  User: yanno
  Date: 9/4/12
  Time: 4:02 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>User</title>
  <meta name="layout" content="main" />

  <script type="text/javascript">

      function initUserGrid(){
          jQuery("#User-Grid").jqGrid({
              url: '${request.getContextPath()}/user/getList',
              editurl: '${request.getContextPath()}/user/editList',
              datatype: "json",
              mtype: 'POST',
              colNames:[
                  'Username'
                  ,'Roles'
              ],
              colModel :[
                  {name:'username' , index:'username' , width:200, align:'center' , editable:true, editoptions:{size:30, maxLength:50} , editrules:{required:true}, searchoptions:{sopt:['eq','ne','bw','ew','bn','en','cn','nc']}},
                  {name:'roles'    , index:'roles'    , width:250, align:'center' , editable:true, editoptions:{size:30, maxLength:50} , editrules:{required:false}, searchoptions:{sopt:['cn']}}
              ],
              height: 'auto',
              pager: '#User-Pager',
              rowNum:10,
              rowList:[10,20,30],
              viewrecords: true,
              sortable: true,
              gridview: true,
              forceFit: true,
              loadui: 'block',
              rownumbers: true,
              caption: 'User List',
              onSelectRow: function(rowid){
                  var rd = jQuery("#User-Grid").jqGrid('getRowData', rowid);
                  //TODO
              },
              gridComplete: function(){
                  //TODO
              }
          });

          jQuery("#User-Grid").jqGrid(
                  'navGrid','#User-Pager',
                  {edit:true,add:true,del:false,view:true}, // options
                  {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:function(formid){
                      /*jQuery("#tr_roles").remove();
                      jQuery("#tr_username").after("<tr rowpos='2' class='FormData' id='tr_roles'><td class='CaptionTD'>Roles</td><td id='td_roles' class='DataTD' style='padding-left: 5px;'></td></tr>");
                      jQuery("#td_roles").append("<select id='roles' multiple></select>");*/
                      jQuery("#roles").attr("hidden", true);
                      jQuery("#roles_select").remove();
                      jQuery("#roles").after("<select id='roles_select' multiple></select>");
                      var rolesStr = jQuery("#roles").val();
                      <%
                        roles?.each {
                      %>
                      if (rolesStr.indexOf("${it.name}") >= 0) {
                          jQuery("#roles_select").append("<option value='${it.name}' selected>${it.name}</option>");
                      }else{
                          jQuery("#roles_select").append("<option value='${it.name}'>${it.name}</option>");
                      }
                      <%
                        }
                      %>
                  }, afterSubmit: function(response, postdata){}}, // edit options
                  {reloadAfterSubmit:true, height:'auto', width:'auto', afterShowForm:function(formid){}, afterSubmit: function(response, postdata){}}, // add options
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
          );

          //jQuery("#User-Grid").jqGrid('filterToolbar',{stringResult: false, searchOnEnter: true});
      }

      jQuery(function(){
          initUserGrid();
      });

  </script>

</head>
<body>
    <table id="User-Grid"></table>
    <div id="User-Pager"></div>
</body>
</html>