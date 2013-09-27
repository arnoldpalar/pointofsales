package common

import items.ProductItem
import supplier.Supplier
import items.ItemGroup

class CommonService {

    static transactional = true

    javax.sql.DataSource dataSource

    def serviceMethod() {

    }

    def getSQLInstance(){
        return new groovy.sql.Sql(dataSource)
    }

    def getNextSeq(def domainClass){
        return (domainClass.executeQuery("select max(seq) from ${domainClass.name}")[0]?:0) + 1
    }

    def genSeqCode(def seq){
        return "${seq}".padLeft(10,'0')
    }

    def getGroups(){
        def groups = ItemGroup.list()

        return groups
    }

    def getSuppliers(){
        def suppliers = Supplier.list()

        return suppliers
    }
}
