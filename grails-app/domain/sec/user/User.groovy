package sec.user

class User {
    String username
    String passwordHash
    
    static hasMany = [ roles: Role, permissions: String ]

    static constraints = {
        username(maxSize: 100, blank: false)
    }

    static mapping = {
        id generator: "assigned", name: "username"
        table name: "SEC_USER"
    }

    public String toString(){
        return username
    }
}
