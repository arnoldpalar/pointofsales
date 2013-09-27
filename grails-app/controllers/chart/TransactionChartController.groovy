package chart

import grails.converters.JSON

class TransactionChartController {
    
    def transactionChartService
    def grailsApplication

    def index = { }

    def daily = {}
    
    def getTransChartData = {

        def ret = [:]

        try {
            Date dateBegin = Date.parse("${grailsApplication.config.dateformatjava}",params.dateBegin);
            Date dateEnd = Date.parse("${grailsApplication.config.dateformatjava}",params.dateEnd);

            def res = transactionChartService.getTransChartData(dateBegin, dateEnd)
            ret = [
                dateBegin:Date.parse("${grailsApplication.config.dateformatjava}",params.dateBegin)?.format('yyyy-MM-dd'),
                dateEnd:Date.parse("${grailsApplication.config.dateformatjava}",params.dateEnd)?.format('yyyy-MM-dd'),
                data:res
            ]
        } catch (ex) {
            ex.printStackTrace()
        }

        render ret as JSON
    }

    def monthly = {}

    def getTransChartMonthlyData = {

        def ret = [:]

        try {
            Date dateBegin = Date.parse("${grailsApplication.config.dateformatjava}",params.dateBegin);
            Date dateEnd = Date.parse("${grailsApplication.config.dateformatjava}",params.dateEnd);

            def res = transactionChartService.getTransChartMonthlyData(dateBegin, dateEnd)
            ret = [
                    dateBegin:Date.parse("${grailsApplication.config.dateformatjava}",params.dateBegin)?.format('yyyy-MM-01'),
                    dateEnd:Date.parse("${grailsApplication.config.dateformatjava}",params.dateEnd)?.format('yyyy-MM-01'),
                    data:res
            ]
        } catch (ex) {
            ex.printStackTrace()
        }

        render ret as JSON
    }
}
