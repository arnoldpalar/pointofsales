<%--
  User: Arnold
  Date: 12/10/11
  Time: 7:44 PM
--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>Store Management System</title>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.png')}" type="image/x-icon" />

    <style type="text/css">

    </style>

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

    <script type="text/javascript">

      function initDatePicker(selector, gridID){
        jQuery(selector).datepicker({
            dateFormat:"${grailsApplication.config.dateformatjs}",
            changeMonth: true,
            changeYear: true,
            onSelect: function (dateText, inst) {
              if (gridID) {
                  jQuery("#" + gridID)[0].triggerToolbar();
              }
            }
        });
      }

    </script>

    <g:layoutHead />
    <g:javascript library="application" />

  </head>

  <body style="font-size: 12px;">
    <g:layoutBody />
  </body>
</html>