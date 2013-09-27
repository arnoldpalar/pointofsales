package chart

class TransactionChartService {

    static transactional = true

    def grailsApplication
    def commonService

    def serviceMethod() {

    }

    def getTransChartData(Date dateBegin, Date dateEnd) {
        String query = """
            select to_char(t.transaction_date,'yyyy-mm-dd') transaction_date, (t.sales_volume - t.discount) ttl_sales, count(ti.transaction_id) ttl_item from sales_transaction t
            join sales_transaction_item ti
              on ti.transaction_id = t.code
            where trunc(t.transaction_date) >= ? and trunc(t.transaction_date) <= ?
            group by t.code, t.transaction_date, t.sales_volume, t.discount
            order by t.transaction_date
        """
        
        def sql = commonService.getSQLInstance()

        def ret = []

        try {
            sql.eachRow(query, [dateBegin?.format('dd-MMM-yyyy'), dateEnd?.format('dd-MMM-yyyy')]){
                ret << [transactionDate:it.transaction_date, totalSales:it.ttl_sales, totalItem:it.ttl_item]
            }
        } catch (ex) {
            ex.printStackTrace()
        } finally {
            sql.close()
        }

        return ret
    }

    def getTransChartMonthlyData(Date dateBegin, Date dateEnd) {
        String query = """
            select transaction_month, sum(ttl_sales) ttl_sales, sum(ttl_item) ttl_item from (
                select to_char(t.transaction_date,'yyyy-mm')||'-01' transaction_month, (t.sales_volume - t.discount) ttl_sales, count(ti.transaction_id) ttl_item from sales_transaction t
                join sales_transaction_item ti
                  on ti.transaction_id = t.code
                where trunc(t.transaction_date) >= ? and trunc(t.transaction_date) <= ?
                group by t.code, t.transaction_date, t.sales_volume, t.discount
                order by t.transaction_date
            ) group by transaction_month
        """

        def sql = commonService.getSQLInstance()

        def ret = []

        try {
            sql.eachRow(query, [dateBegin?.format('dd-MMM-yyyy'), dateEnd?.format('dd-MMM-yyyy')]){
                ret << [transactionMonth:it.transaction_month, totalSales:it.ttl_sales, totalItem:it.ttl_item]
            }
        } catch (ex) {
            ex.printStackTrace()
        } finally {
            sql.close()
        }

        return ret
    }
}
