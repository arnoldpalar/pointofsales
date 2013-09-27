package items

import grails.converters.JSON

class SaleItemService {

    static transactional = true

    def commonService

    def serviceMethod() {

    }

    def getSaleItemList(def params){
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
                if (params.salePrice) {
                    whereClause += ("salePrice = ? and ")
                    filterDatas.add("${params.salePrice}".toBigDecimal())
                }
                if (params.isActive) {
                    whereClause += ("isActive = ? and ")
                    filterDatas.add(params.isActive == 'true')
                }
                if (params.remark) {
                    whereClause += ("upper(remark) like '%'||upper(?)||'%' and ")
                    filterDatas.add(params.remark)
                }

                whereClause += " 1 = 1 "
            }

        }

        String query = """
            from SaleItem where productItem.code = '${params.productItemCode}' ${whereClause} ${(sort&&order?("order by ${sort} ${order}"):"order by seq desc")}
        """

        SaleItem.findAll(query, filterDatas, [max:max,offset:offset])?.each{
            records << [
                code       :it.code
                ,quantity  :it.quantity
                ,salePrice :it.salePrice
                ,isActive  :it.isActive
                ,remark    :it.remark
            ]
        }

        totalRecords = SaleItem.executeQuery("select count(*) from SaleItem where productItem.code = '${params.productItemCode}' ${whereClause}", filterDatas)[0]

        int totalPage = Math.ceil(totalRecords / max)

        return [records: records, totalRecords: totalRecords, totalPage: totalPage]
    }

    def addSaleItem = {def params ->
        //println params

        SaleItem saleItem = new SaleItem()
        saleItem.seq = commonService.getNextSeq(SaleItem)
        saleItem.code = commonService.genSeqCode(saleItem.seq)
        saleItem.quantity = "${params.quantity?:0}".toInteger()
        saleItem.salePrice = "${params.salePrice}".toBigDecimal()
        saleItem.isActive = params.isActive == 'true'
        saleItem.remark = params.remark

        saleItem.productItem = ProductItem.findByCode(params.productItemCode)

        if (!saleItem.save()) {
            throw new Exception("Cannot Sale Stock Item, " + saleItem.errors?.toString())
        }
    }

    def editSaleItem(def params){
        //println params

        SaleItem saleItem = SaleItem.findByCode(params.id)
        if (saleItem) {
            saleItem.quantity = "${params.quantity}".toInteger()
            saleItem.salePrice = "${params.salePrice}".toBigDecimal()
            saleItem.isActive = params.isActive == 'true'
            saleItem.remark = params.remark
            if (!saleItem.save()) {
                throw new Exception("Cannot Sale Stock Item, ${saleItem.errors?.toString()}")
            }
        }else{
            throw new Exception("Cannot find Sale Item with code ${params.id}")
        }
    }
}
