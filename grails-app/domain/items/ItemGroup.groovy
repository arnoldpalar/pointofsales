package items

class ItemGroup {
    
    String code
    String name

    static constraints = {
        code(maxSize: 50)
        name(maxSize: 200)
    }

    static mapping = {
        id generator:'assigned', name:'code'
    }
}
