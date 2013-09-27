package items

import grails.converters.deep.JSON
import supplier.Supplier
import transaction.SalesTransactionItem

class ProductItemService {

    static transactional = true

    def commonService
    def grailsApplication

    javax.sql.DataSource dataSource

    def serviceMethod() {

    }

    def getProductItemList(def params) {
        //println params

        def sort = params.sidx && !"".equals(params.sidx) ? params.sidx : null
        def order = params.sord && !"".equals(params.sord) ? params.sord : null
        int max = params.rows ? params.int('rows') : 10
        int offset = ((params.page ? params.int('page') : 1) - 1) * max
        int totalRecords = 0

        def whereClause = ''
        def filterDatas = new ArrayList();

        def records = new ArrayList();

        if (params.boolean('_search')) {
            whereClause = "where "
            if (params.filters) {
                def filters = JSON.parse(params.filters)
                boolean is1st = true
                filters.rules.each {
                    if (!is1st) {
                        whereClause += (filters.get('groupOp') + " ")
                    } else {
                        is1st = false
                    }
                    switch (it.op) {
                        case "eq":
                            if (it.data != null && it.data != '') {
                                whereClause += ("upper(" + it.field + ") = upper(?) ")
                                filterDatas.add(it.data)
                            } else {
                                whereClause += ("upper(" + it.field + ") is null ")
                            }
                            break
                        case "ne":
                            if (it.data != null && it.data != '') {
                                whereClause += ("upper(" + it.field + ") != upper(?) ")
                                filterDatas.add(it.data)
                            } else {
                                whereClause += ("upper(" + it.field + ") is not null ")
                            }
                            break
                        case "lt":
                            whereClause += (it.field + " < ? ")
                            filterDatas.add(it.data)
                            break
                        case "le":
                            whereClause += (it.field + " <= ? ")
                            filterDatas.add(it.data)
                            break
                        case "gt":
                            whereClause += (it.field + " > ? ")
                            filterDatas.add(it.data)
                            break
                        case "ge":
                            whereClause += (it.field + " >= ? ")
                            filterDatas.add(it.data)
                            break
                        case "bw":
                            whereClause += ("upper(" + it.field + ") like upper(?)||'%' ")
                            filterDatas.add(it.data)
                            break
                        case "bn":
                            whereClause += ("upper(" + it.field + ") not like upper(?)||'%' ")
                            filterDatas.add(it.data)
                            break
                        case "ew":
                            whereClause += ("upper(" + it.field + ") like '%'||upper(?) ")
                            filterDatas.add(it.data)
                            break
                        case "en":
                            whereClause += ("upper(" + it.field + ") not like '%'||upper(?) ")
                            filterDatas.add(it.data)
                            break
                        case "cn":
                            whereClause += ("upper(" + it.field + ") like '%'||upper(?)||'%' ")
                            filterDatas.add(it.data)
                            break
                        case "nc":
                            whereClause += ("upper(" + it.field + ") not like '%'||upper(?)||'%' ")
                            filterDatas.add(it.data)
                            break
                        case "in":
                            def inArr = it.data?.split(",")
                            whereClause += (it.field + " in (")
                            inArr?.each { n ->
                                whereClause += "?,"
                                filterDatas.add(n?.trim())
                            }
                            whereClause += "'xxx') "
                            break
                        case "ni":
                            def inArr = it.data?.split(",")
                            whereClause += (it.field + " not in (")
                            inArr?.each { n ->
                                whereClause += "?,"
                                filterDatas.add(n?.trim())
                            }
                            whereClause += "'xxx') "
                            break
                        default:
                            whereClause += (it.field + " = ? ")
                            filterDatas.add(it.data)
                    }
                }
            } else if (params.searchField) {
                //TODO NA
            } else {
                if (params.code) {
                    whereClause += ("upper(code) like upper(?)||'%' and ")
                    filterDatas.add(params.code)
                }
                if (params.name) {
                    whereClause += ("upper(name) like upper(?)||'%' and ")
                    filterDatas.add(params.name)
                }
                if (params.item_group) {
                    whereClause += ("item_group = ? and ")
                    filterDatas.add(params.item_group)
                }
                if (params.details) {
                    whereClause += ("upper(details) like upper(?)||'%' and ")
                    filterDatas.add(params.details)
                }
                if (params.stock_quantity) {
                    whereClause += ("nvl(stock_quantity, 0) = ${params.stock_quantity} and ")
                }
                if (params.total_sales_quantity) {
                    whereClause += ("nvl(total_sales_quantity, 0) = ${params.total_sales_quantity} and ")
                }
                if (params.total_sales_amount) {
                    whereClause += ("nvl(total_sales_amount, 0) = ${params.total_sales_amount} and ")
                }

                whereClause += " 1 = 1 "
            }

        }

        String query = """
            SELECT * FROM (
                SELECT this.*, rownum rownum_ FROM (
                    select * from (
                        select
                            p.seq, p.code, p.name, g.code item_group, g.name item_group_name, p.details
                            ,(sum(nvl(st.quantity,0)) - sum(nvl(sl.quantity,0))) stock_quantity
                            ,sum(nvl(sl.quantity,0)) total_sales_quantity
                            ,nvl(sl.total_sales_amount, 0) total_sales_amount
                        from product_item p
                        left join item_group g
                            on g.code = p.item_group
                        left join (
                          select
                            product_item_id, sum(nvl(quantity,0)) quantity
                          from stock_item
                          group by product_item_id
                        ) st on st.product_item_id = p.code
                        left join (
                          select
                            product_item_id, sum(nvl(quantity,0)) quantity, sum(nvl(quantity,0) * sale_price) total_sales_amount
                          from sale_item
                          group by product_item_id
                        ) sl on sl.product_item_id = p.code
                        group by p.seq, p.code, p.name, g.code, g.name, p.details, sl.total_sales_amount
                    )
                    ${whereClause}
                    ${(sort&&order?("order by ${sort} ${order}"):"order by seq desc")}
                ) this where rownum <= ${offset + max}
            ) WHERE rownum_ >= ${offset + 1}
        """

        String queryTotal = """
            select count(*) ttl from (
                select
                    p.code, p.name, g.code item_group, g.name item_group_name, p.details
                    ,sum(st.quantity) stock_quantity
                    ,sum(sl.quantity) total_sales_quantity
                    ,sum(sl.quantity * sl.sale_price) total_sales_amount
                from product_item p
                left join item_group g
                    on g.code = p.item_group
                left join stock_item st
                    on st.product_item_id = p.code
                left join sale_item sl
                    on sl.product_item_id = p.code
                group by p.code, p.name, g.code, g.name, p.details
            )
            ${whereClause}
        """

        def sql = new groovy.sql.Sql(dataSource)

        sql.eachRow(query,filterDatas){
            records << [
                    code:it.code,
                    name:it.name,
                    item_group:it.item_group_name,
                    details:it.details,
                    stock_quantity:it.stock_quantity,
                    total_sales_quantity:it.total_sales_quantity,
                    total_sales_amount:it.total_sales_amount
            ]
        }

        totalRecords = sql.firstRow(queryTotal, filterDatas)?.ttl

        sql.close()

        int totalPage = Math.ceil(totalRecords / max)

        return [records: records, totalRecords: totalRecords, totalPage: totalPage]
    }

    def addProductItem(def params){

        try {
            ProductItem instance = new ProductItem()
            instance.seq = commonService.getNextSeq(ProductItem)
            instance.code = (params.newGroupCode?:params.item_group) + "${ProductItem.executeQuery("select count(*) from ProductItem p where p.itemGroup = ?", [params.newGroupCode?:params.item_group])[0]?:0}".padLeft(6,'0')
            instance.name = params.name
            instance.details = params.details
            instance.itemGroup = params.newGroupCode?:params.item_group

            if(instance.save()){
                if(params.initStockQty){
                    StockItem stockItem = new StockItem()
                    stockItem.productItem = instance
                    stockItem.seq = commonService.getNextSeq(StockItem)
                    stockItem.code = commonService.genSeqCode(stockItem.seq)
                    stockItem.quantity = "${params.initStockQty}".toInteger()
                    stockItem.purchaseDate = Date.parse("${grailsApplication.config.dateformatjava}", params.initPurchaseDate)
                    stockItem.purchasePrice = "${params.initPurchasePrice}".toBigDecimal()
                    if(params.newSupplier){
                        Supplier supplier = new Supplier()
                        supplier.seq = commonService.getNextSeq(Supplier)
                        supplier.code = commonService.genSeqCode(supplier.seq)
                        supplier.name = params.newSupplier

                        if(supplier.save()){
                            stockItem.supplier = supplier
                        }else{
                            throw new Exception("Cannot Save Supplier Data")
                        }
                    }else if(params.initSupplier){
                        stockItem.supplier = Supplier.findByCode(params.initSupplier)
                    }

                    if(!stockItem.save()){
                        throw new Exception("Cannot Save Stock Data")
                    }
                }

                if(params.initSalePrice){
                    SaleItem saleItem = new SaleItem()
                    saleItem.seq = commonService.getNextSeq(SaleItem)
                    saleItem.code = commonService.genSeqCode(saleItem.seq)
                    saleItem.salePrice = "${params.initSalePrice}".toBigDecimal()
                    saleItem.isActive = true
                    saleItem.remark = 'initial sale price'
                    saleItem.productItem = instance

                    if(!saleItem.save()){
                        throw new Exception("Cannot Save Sale Item Data")
                    }
                }

                if(params.newGroupCode){
                    def group = new ItemGroup(code: params.newGroupCode, name: params.newGroupName)
                    if(!group.save()){
                        //TODO
                        //throw new Exception("Cannot Save Item Group Data")
                    }
                }
            }else{
                throw new Exception("Cannot Save Product Item, " + instance.errors?.toString())
            }
        } catch (ex) {
            ex.printStackTrace()

            throw ex
        }
    }

    def editProductItem(def params){
        try {
            ProductItem instance = ProductItem.findByCode(params.id)
            if(instance){
                instance.name = params.name
                instance.details = params.details
                instance.itemGroup = params.newGroupCode?:params.item_group

                if(!instance.save()){
                    throw new Exception("Cannot Save Product Item, " + instance.errors?.toString())
                }

                if(params.newGroupCode){
                    def group = new ItemGroup(code: params.newGroupCode, name: params.newGroupName)
                    if(!group.save()){
                        //TODO
                        //throw new Exception("Cannot Save Item Group Data")
                    }
                }
            }
        } catch (ex) {
            ex.printStackTrace()

            throw ex
        }
    }

    def deleteProductItem(def params){
        try {
            def productItem = ProductItem.findByCode(params.id)

            if (productItem) {
                def saleItems = SaleItem.findAllByProductItem(productItem)
                saleItems?.each {
                    SalesTransactionItem.findAllBySaleItem(it)?.each { sti ->
                        sti.delete()
                    }
                    it.delete()
                }

                StockItem.findAllByProductItem(productItem)?.each {
                    it.delete()
                }

                productItem.delete()
            }
        } catch (ex) {
            ex.printStackTrace()

            throw ex
        }
    }
}
