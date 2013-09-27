package items

class ProductItem {

    String code
    String name
    String itemGroup
    String details
    BigInteger seq

    static constraints = {
        code(maxSize: 50)
        name(maxSize: 100)
        details(maxSize: 300, nullable: true)
        itemGroup(maxSize: 50, nullable: true)
    }

    static mapping = {
        id generator:'assigned', name:'code'
    }

    String toString(){
        return name
    }
}
