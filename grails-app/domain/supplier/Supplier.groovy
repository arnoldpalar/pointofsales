package supplier

class Supplier {

    String code
    String name
    String contactDetails
    BigInteger seq

    static constraints = {
        code(maxSize: 50)
        name(maxSize: 100)
        contactDetails(maxSize: 500, nullable: true)
    }

    static mapping = {
        id generator:'assigned', name:'code'
    }
}
