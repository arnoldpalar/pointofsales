package storemanagementsystem

import items.ProductItem
import items.StockItem
import items.SaleItem
import transaction.SalesTransaction
import transaction.SalesTransactionItem

class PointOfSalesService {

    static transactional = true

    def commonService

    javax.sql.DataSource dataSource

    def serviceMethod() {

    }

    def getItemDetail(def itemCode){

        ProductItem productItem = ProductItem.findByCode(itemCode)

        if(productItem){
            def saleItems = SaleItem.findAll("from SaleItem where productItem = ? and isActive = true order by seq desc", [productItem])

            return [productItem:productItem, saleItems:saleItems]
        }

        return []
    }

    def submitSalesTransaction(def transItems, def discount){
        def saleTransactionItems = []
        BigDecimal salesVolume = 0

        transItems.each {
            if(it.saleItemCode){
                SaleItem saleItem = SaleItem.findByCode(it.saleItemCode)
                if(saleItem){
                    saleItem.quantity += "${it.quantity?:0}".toBigInteger()
                    saleTransactionItems << new SalesTransactionItem(saleItem: saleItem, quantity: "${it.quantity?:0}".toInteger(), discount: "${it.discount?:0}".toBigDecimal())
                    saleItem.save()

                    salesVolume += (saleItem.salePrice * "${it.quantity?:0}".toBigInteger()) - "${it.discount?:0}".toBigDecimal()
                }
            }
        }

        if(saleTransactionItems && saleTransactionItems.size() > 0){
            SalesTransaction salesTransaction = new SalesTransaction()
            salesTransaction.transactionDate = new Date()
            salesTransaction.seq = commonService.getNextSeq(SalesTransaction)
            salesTransaction.code = commonService.genSeqCode(salesTransaction.seq)
            salesTransaction.salesVolume = salesVolume
            salesTransaction.discount = "${discount?:0}".toBigDecimal()

            if(!salesTransaction.save()){
                throw new Exception("${salesTransaction.errors?.toString()}")
            }

            saleTransactionItems.each {
                it.transaction = salesTransaction
            }

            salesTransaction.items = saleTransactionItems

            if(!salesTransaction.save()){
                throw new Exception("${salesTransaction.errors?.toString()}")
            }

            return salesTransaction.code
        }

        return null
    }
}
