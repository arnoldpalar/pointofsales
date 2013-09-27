package transaction

import grails.converters.JSON

class SalesTransactionController {

    def salesTransactionService

    def index = { }

    def getSalesTransactionList = {
        //println params

        session.saleTransactionListParams = params

        def res = salesTransactionService.getSalesTransactionList(params)

        def rows = res?.records?.collect{
          [id:it.code, cell:[
                 it.code
                ,it.transaction_date
                ,it.remark
                ,it.person_in_charge
                ,it.sales_volume
                ,it.discount
                ,it.total_sales
          ]]
        }

        def jqGridJSON = [rows:rows,records:res.totalRecords,page:params.page,total:res.totalPage]

        render jqGridJSON as JSON
    }

    def getSaleTransactionItems = {
        //println params

        def records = [rows:salesTransactionService.getSaleTransactionItems(params.code)?.collect {
            [cell:[
                 it.code
                ,it.name
                ,it.quantity
                ,it.salePrice
                ,it.discount
                ,it.saleItemRemark
            ]]
        }]

        render records as JSON
    }
}
