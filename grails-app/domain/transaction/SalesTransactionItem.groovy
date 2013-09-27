package transaction

import items.SaleItem

class SalesTransactionItem implements Serializable{

    Integer quantity
    BigDecimal discount = 0

    SalesTransaction transaction
    SaleItem saleItem

    static constraints = {
        discount(nullable: true)
    }

    static mapping = {
        id composite:['transaction', 'saleItem']
    }
}
