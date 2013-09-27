package items

import supplier.Supplier

class StockItem {

    String code
    Date purchaseDate
    BigDecimal purchasePrice
    BigInteger quantity
    BigInteger seq

    ProductItem productItem
    Supplier supplier

    static constraints = {
        code(maxSize: 50)
        supplier(nullable: true)
    }

    static mapping = {
        id generator:'assigned', name:'code'
    }
}
