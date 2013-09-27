package transaction

class SalesTransaction {

    String code
    Date transactionDate
    String remark
    String personInCharge
    BigInteger seq

    BigDecimal salesVolume
    BigDecimal discount

    static hasMany = [items:SalesTransactionItem]

    static constraints = {
        code(maxSize: 50)
        remark(nullable: true)
        personInCharge(nullable: true)
    }

    static mapping = {
        id generator:'assigned', name:'code'
    }
}
