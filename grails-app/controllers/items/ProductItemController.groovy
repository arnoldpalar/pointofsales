package items

import grails.converters.JSON
import supplier.Supplier
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class ProductItemController {

    def productItemService
    def commonService

    def index = { }

    def getProductItemList = {
        //println params
        session.productItemListParams = params

        def res = productItemService.getProductItemList(params)

        def rows = res?.records?.collect{
          [id:it.code, cell:[
                  it.code,
                  it.name,
                  it.details,
                  it.item_group,
                  it.stock_quantity,
                  it.total_sales_quantity,
                  it.total_sales_amount
          ]]
        }

        def jqGridJSON = [rows:rows,records:res.totalRecords,page:params.page,total:res.totalPage]

        render jqGridJSON as JSON
    }

    def editProductItemList = {
        //println params

        try {
            switch(params.oper){
              case "del" :

                productItemService.deleteProductItem(params)

              break
              case "edit" :

                productItemService.editProductItem(params)

              break
              case "add" :

                productItemService.addProductItem(params)

              break
            }
        } catch (ex) {
            params.errormessage = ex.message?:ex.cause?.message
            ex.printStackTrace()
        }

        render params as JSON
    }

    def getGroupsSelect = {
        String select = "<select><option value=''></option>"

        commonService.getGroups()?.each {
            select += "<option value='${it.code}'>${it.name}</option>"
        }

        select += "</select>"

        render select
    }

    def getSuppliersSelect = {
        String select = "<select><option value=''></option>"

        commonService.getSuppliers()?.each {
            select += "<option value='${it.code}'>${it.name}</option>"
        }

        select += "</select>"

        render select
    }

    def exportService

    def exportProductItemList = {
        if (params?.format && params.format != "html") {
            def reportParams = session.productItemListParams ?: [:]
            reportParams.rows = '1000000'
            reportParams.page = '1'

            def res = productItemService.getProductItemList(reportParams)
            def repRows = []
            def numFoo = 1

            res?.records?.each {
                repRows << [
                    code                :it.code,
                    name                :it.name,
                    item_group          :it.item_group,
                    details             :it.details,
                    stock_quantity      :it.stock_quantity,
                    total_sales_quantity:it.total_sales_quantity,
                    total_sales_amount  :it.total_sales_amount
                ]
            }

            response.contentType = ConfigurationHolder.config.grails.mime.types[params.format]
            response.setHeader("Content-disposition", "attachment; filename=ProductItemList(${new Date().format("dd-MM-yyyy")}).${params.extension}")

            List fields = [
                'code'
                ,'name'
                ,'item_group'
                ,'details'
                ,'stock_quantity'
                ,'total_sales_quantity'
                ,'total_sales_amount'
            ]

            Map labels = [
                code                  : 'Code'
                ,name                 : 'Name'
                ,item_group           : 'Item Group'
                ,details              : 'Details'
                ,stock_quantity       : 'Remaining Stock'
                ,total_sales_quantity : 'Total Sales Quantity'
                ,total_sales_amount   : 'Total Sales Amount'
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
            Map parameters = [title: "Product Item List", "column.widths": [0.1, 0.15, 0.1, 0.3, 0.1, 0.1, 0.15]]

            exportService.export(params.format, response.outputStream, repRows, fields, labels, formatters, parameters)
        }
    }
}
