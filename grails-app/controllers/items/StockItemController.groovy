package items

import grails.converters.JSON
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class StockItemController {

    def stockItemService

    def index = { }

    def getStockItemList = {
        //println params
        session.stockItemListParams = params

        def res = stockItemService.getStockItemList(params)

        def rows = res?.records?.collect{
          [id:it.code, cell:[
                it.code
                ,it.quantity
                ,it.purchaseDate?.format(grailsApplication.config.dateformatjava)
                ,it.purchasePrice
                ,it.supplierName
          ]]
        }

        def jqGridJSON = [rows:rows,records:res.totalRecords,page:params.page,total:res.totalPage]

        render jqGridJSON as JSON
    }

    def exportService

    def exportStockItemList = {
        if (params?.format && params.format != "html") {
            def reportParams = session.stockItemListParams ?: [:]
            reportParams.rows = '1000000'
            reportParams.page = '1'

            ProductItem productItem = ProductItem.findByCode(reportParams.productItemCode)

            def res = stockItemService.getStockItemList(reportParams)
            def repRows = []
            def numFoo = 1

            res?.records?.each {
                repRows << [
                    code          :it.code
                    ,quantity     :it.quantity
                    ,purchaseDate :it.purchaseDate
                    ,purchasePrice:it.purchasePrice
                    ,supplierName :it.supplier?.name
                ]
            }

            response.contentType = ConfigurationHolder.config.grails.mime.types[params.format]
            response.setHeader("Content-disposition", "attachment; filename=${productItem?.name} - StockItemList(${new Date().format("dd-MM-yyyy")}).${params.extension}")

            List fields = [
                'code'
                ,'quantity'
                ,'purchaseDate'
                ,'purchasePrice'
                ,'supplierName'
            ]

            Map labels = [
                code          : 'Code'
                ,quantity     : 'Quantity'
                ,purchaseDate : 'Purchase Date'
                ,purchasePrice: 'Purchase Price'
                ,supplierName : 'Supplier'
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

    def editStockItemList = {
        //println params

        try {
            switch(params.oper){
              case "edit" :

                stockItemService.editStockItem(params)

              break
              case "add" :

                stockItemService.addStockItem(params)

              break
            }
        } catch (ex) {
            params.errormessage = ex.message?:ex.cause?.message
            ex.printStackTrace()
        }

        render params as JSON
    }
}
