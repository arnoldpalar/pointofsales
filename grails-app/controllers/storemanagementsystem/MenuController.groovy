package storemanagementsystem

import grails.converters.JSON

class MenuController {

    def index = { }

    def getMenuItems = {
        def menus = []

        //[cell:[it.name,it.caption,link,"${it.isActionOnly}","${it.openInNewWindow}",level.toString(),nodeid,it.childs?'false':'true','false']]
        menus << [cell:['POS','Point of Sales',"${request.contextPath}/pointOfSales","false","true",0,'null','true','false']]
        menus << [cell:['PROD_ITEM','Product Item',"${request.contextPath}/productItem","false","true",0,'null','true','false']]
        menus << [cell:['SALES_TRANS','Sales Transactions',"${request.contextPath}/salesTransaction","false","false",0,'null','true','false']]
        menus << [cell:['DASHBOARD','Dashboard',"${request.contextPath}/dashboard","false","true",0,'null','true','false']]

        def jqGridJSON = [rows:menus,page:1,total:1,records:1]
        
        render jqGridJSON as JSON
    }
}
