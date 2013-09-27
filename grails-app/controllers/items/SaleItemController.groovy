package items

import grails.converters.JSON
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class SaleItemController {

    def saleItemService

    def index = { }

    def getSaleItemList = {
        //println params
        session.saleItemListParams = params

        def res = saleItemService.getSaleItemList(params)

        def rows = res?.records?.collect{
          [id:it.code, cell:[
                it.quantity
                ,it.salePrice
                ,it.isActive
                ,it.remark
          ]]
        }

        def jqGridJSON = [rows:rows,records:res.totalRecords,page:params.page,total:res.totalPage]

        render jqGridJSON as JSON
    }

    def exportService

    def exportSaleItemList = {
        if (params?.format && params.format != "html") {
            def reportParams = session.saleItemListParams ?: [:]
            reportParams.rows = '1000000'
            reportParams.page = '1'

            ProductItem productItem = ProductItem.findByCode(reportParams.productItemCode)

            def res = saleItemService.getSaleItemList(reportParams)
            def repRows = []
            def numFoo = 1

            res?.records?.each {
                repRows << [
                    code       :it.code
                    ,quantity  :it.quantity
                    ,salePrice :it.salePrice
                    ,isActive  :it.isActive
                    ,remark    :it.remark
                ]
            }

            response.contentType = ConfigurationHolder.config.grails.mime.types[params.format]
            response.setHeader("Content-disposition", "attachment; filename=${productItem?.name} - SaleItemList(${new Date().format("dd-MM-yyyy")}).${params.extension}")

            List fields = [
                'code'
                ,'quantity'
                ,'salePrice'
                ,'isActive'
                ,'remark'
            ]

            Map labels = [
                code       : 'Code'
                ,quantity  : 'Quantity'
                ,salePrice : 'Sale Price'
                ,isActive  : 'is Active'
                ,remark    : 'Remark'
            ]

            /* Formatter closure in previous releases
            def upperCase = {
                value -> return value.toUpperCase()
            }
            */

            // Formatter closure
            /*def upperCase = { domain, value ->
                return value.toUpperCase()
            }
            Map formatters = [customerName: upperCase]*/

            Map formatters = [:]
            Map parameters = [title: "${productItem?.name} (${productItem?.code})", "column.widths": [0.175, 0.175, 0.175, 0.175, 0.3]]

            exportService.export(params.format, response.outputStream, repRows, fields, labels, formatters, parameters)
        }
    }

    def editSaleItemList = {
        //println params

        try {
            switch(params.oper){
              case "edit" :

                saleItemService.editSaleItem(params)

              break
              case "add" :

                saleItemService.addSaleItem(params)

              break
            }
        } catch (ex) {
            params.errormessage = ex.message?:ex.cause?.message
            ex.printStackTrace()
        }

        render params as JSON
    }
}
