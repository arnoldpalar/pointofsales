package sec.user

class Role {
    String name

    static hasMany = [ users: User, permissions: String ]
    static belongsTo = User

    static constraints = {
        name(maxSize: 50, blank: false)
    }

    static mapping = {
        id generator: "assigned", name: "name"
        table name: "SEC_ROLE"
    }

    public String toString(){
        return name
    }
}
