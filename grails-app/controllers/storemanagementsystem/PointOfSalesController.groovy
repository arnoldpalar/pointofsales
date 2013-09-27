package storemanagementsystem

import grails.converters.JSON

class PointOfSalesController {

    def pointOfSalesService

    def index = { }

    def getItemDetail = {
        //println params
        def ret = [:]

        try {
            def itemDetail = pointOfSalesService.getItemDetail(params.itemCode)

            render itemDetail as JSON
        } catch (ex) {
            ex.printStackTrace()

            ret.error = "${ex.message?:ex.cause?.message}"

            render ret as JSON
        }
    }

    def submitSalesTransaction = {

        def ret = [:]

        try {
            def gridData = grails.converters.JSON.parse(params.posGridDataStr)

            ret.salesTransactionCode = pointOfSalesService.submitSalesTransaction(gridData, params.discount)

            ret.message = 'SUCCESS'

        } catch (ex) {
            ex.printStackTrace()
            ret.error = ex.message?:ex.cause?.message
        }

        render ret as JSON
    }
}
