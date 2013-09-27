package items

class SaleItem {

    String code
    BigDecimal salePrice
    BigInteger seq
    BigInteger quantity = 0
    Boolean isActive = false
    String remark

    ProductItem productItem

    static constraints = {
        remark(maxSize: 100, nullable: true)
    }

    static mapping = {
        id generator:'assigned', name:'code'
    }
}
