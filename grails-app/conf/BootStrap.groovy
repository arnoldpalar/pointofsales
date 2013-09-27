import org.apache.shiro.crypto.hash.Sha512Hash
import sec.user.Role
import sec.user.User

class BootStrap {

    def init = { servletContext ->

        /*for(i in 1..100){
            def productItem = ProductItem.findByCode("${i}".padLeft(4,'0')) ?: new ProductItem(code: "${i}".padLeft(4,'0'), name: "Product Item ${i}", details: "Details of Product Item ${i}", seq: i)
            productItem.save(flush:true)
        }*/

        def adminRole = Role.findByName("ADMINISTRATOR")?:new Role(name: "ADMINISTRATOR")
        adminRole.addToPermissions("*:*")
        adminRole.save()

        def cashierRole = Role.findByName("CASHIER")?:new Role(name: "CASHIER")
        adminRole.addToPermissions("pointOfSales:*")
        adminRole.addToPermissions("productItem:getProductItemList")
        adminRole.save()

        def adminUser = User.findByUsername("administrator")?:new User(username: "administrator", passwordHash: new Sha512Hash("admin123").toHex())
        adminUser.addToRoles(adminRole)
        adminUser.save()

        adminRole.addToUsers(adminUser)
        adminRole.save()

        def casierUser1 = User.findByUsername("cashier1")?:new User(username: "cashier1", passwordHash: new Sha512Hash("cashier123").toHex())
        casierUser1.addToRoles(cashierRole)
        casierUser1.save()

        cashierRole.addToUsers(casierUser1)
        cashierRole.save()



    }

    def destroy = {
    }
}
