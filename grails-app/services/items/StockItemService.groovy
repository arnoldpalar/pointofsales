package items

import grails.converters.JSON
import supplier.Supplier

class StockItemService {

    static transactional = true

    def commonService
    def grailsApplication

    def serviceMethod() {

    }

    def getStockItemList(def params){
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
            whereClause = "and "
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
                            whereClause += (it.field + " < ${it.data} ")
                            break
                        case "le":
                            whereClause += (it.field + " <= ${it.data} ")
                            break
                        case "gt":
                            whereClause += (it.field + " > ${it.data} ")
                            break
                        case "ge":
                            whereClause += (it.field + " >= ${it.data} ")
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
                if (params.quantity) {
                    whereClause += ("quantity = ? and ")
                    filterDatas.add("${params.quantity}".toBigInteger())
                }
                if (params.purchaseDate) {
                    whereClause += ("purchaseDate = ? and ")
                    filterDatas.add(Date.parse("${grailsApplication.config.dateformatjava}", params.purchaseDate))
                }
                if (params.purchasePrice) {
                    whereClause += ("purchasePrice = ? and ")
                    filterDatas.add("${params.purchasePrice}".toBigDecimal())
                }
                if (params.supplier) {
                    whereClause += ("supplier.code like ? and ")
                    filterDatas.add(params.supplier)
                }

                whereClause += " 1 = 1 "
            }

        }

        String query = """
            from StockItem where productItem.code = '${params.productItemCode}' ${whereClause} ${(sort&&order?("order by ${sort} ${order}"):"order by seq desc")}
        """

        StockItem.findAll(query, filterDatas, [max:max,offset:offset])?.each{
            records << [
                code          :it.code
                ,quantity     :it.quantity
                ,purchaseDate :it.purchaseDate
                ,purchasePrice:it.purchasePrice
                ,supplierName:it.supplier?.name
            ]
        }

        totalRecords = StockItem.executeQuery("select count(*) from StockItem where productItem.code = '${params.productItemCode}' ${whereClause}", filterDatas)[0]

        int totalPage = Math.ceil(totalRecords / max)

        return [records: records, totalRecords: totalRecords, totalPage: totalPage]
    }

    def addStockItem(def params){
        //println params

        StockItem stockItem = new StockItem()
        stockItem.seq = commonService.getNextSeq(StockItem)
        stockItem.code = commonService.genSeqCode(stockItem.seq)
        stockItem.quantity = "${params.quantity}".toInteger()
        stockItem.purchaseDate = Date.parse("${grailsApplication.config.dateformatjava}" , params.purchaseDate)
        stockItem.purchasePrice = "${params.purchasePrice}".toBigDecimal()
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
        }else if(params.supplier){
            stockItem.supplier = Supplier.findByCode(params.supplier)
        }

        stockItem.productItem = ProductItem.findByCode(params.productItemCode)

        if (!stockItem.save()) {
            throw new Exception("Cannot Save Stock Item, " + stockItem.errors?.toString())
        }
    }

    def editStockItem(def params){
        //println params

        StockItem stockItem = StockItem.findByCode(params.id)
        if (stockItem) {
            stockItem.quantity = "${params.quantity}".toInteger()
            stockItem.purchaseDate = Date.parse("${grailsApplication.config.dateformatjava}" , params.purchaseDate)
            stockItem.purchasePrice = "${params.purchasePrice}".toBigDecimal()
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
            }else if(params.supplier){
                stockItem.supplier = Supplier.findByCode(params.supplier)
            }
            if (!stockItem.save()) {
                throw new Exception("Cannot Save Stock Item, ${stockItem.errors?.toString()}")
            }
        }else{
            throw new Exception("Cannot find Stock Item with code ${params.id}")
        }
    }
}
