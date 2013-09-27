package transaction

import grails.converters.JSON

class SalesTransactionService {

    def grailsApplication
    javax.sql.DataSource dataSource

    static transactional = true

    def serviceMethod() {

    }

    def getSalesTransactionList(def params){
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
                if (params.transaction_date) {
                    //whereClause += ("to_char(transaction_date, '${grailsApplication.config.dateformatdb}') = ? and ")
                    whereClause += ("transaction_date = ? and ")
                    filterDatas.add(params.transaction_date)
                }
                if (params.remark) {
                    whereClause += ("upper(remark) like '%'||upper(?)||'%' and ")
                    filterDatas.add(params.remark)
                }
                if (params.person_in_charge) {
                    whereClause += ("upper(person_in_charge) like upper(?)||'%' and ")
                    filterDatas.add(params.person_in_charge)
                }
                if (params.sales_volume) {
                    whereClause += ("nvl(sales_volume, 0) = ${params.sales_volume} and ")
                }

                whereClause += " 1 = 1 "
            }

        }

        String query = """
            SELECT * FROM (
                SELECT this.*, rownum rownum_ FROM (
                    select * from (
                        select
                          st.seq,
                          st.code,
                          to_char(st.transaction_date, '${grailsApplication.config.dateformatdb}') transaction_date,
                          st.remark,
                          st.person_in_charge,
                          --sum((si.sale_price * sti.quantity) - nvl(sti.discount,0)) sales_volume,
                          st.sales_volume,
                          nvl(st.discount,0) discount,
                          (st.sales_volume - st.discount) total_sales
                        from sales_transaction st
                        left join sales_transaction_item sti
                               on sti.transaction_id = st.code
                        left join sale_item si
                               on si.code = sti.sale_item_id
                        group by
                          st.code,
                          st.transaction_date,
                          st.remark,
                          st.person_in_charge,
                          st.sales_volume,
                          st.discount,
                          st.seq
                    )
                    ${whereClause}
                    ${(sort&&order?("order by ${sort} ${order}"):"order by seq desc")}
                ) this where rownum <= ${offset + max}
            ) WHERE rownum_ >= ${offset + 1}
        """

        String queryTotal = """
            select count(*) ttl from (
                select
                  st.code,
                  to_char(st.transaction_date, '${grailsApplication.config.dateformatdb}') transaction_date,
                  st.remark,
                  st.person_in_charge,
                  --sum((si.sale_price * sti.quantity) - nvl(sti.discount,0)) sales_volume,
                  st.sales_volume,
                  nvl(st.discount,0) discount,
                  (st.sales_volume - st.discount) total_sales
                from sales_transaction st
                left join sales_transaction_item sti
                       on sti.transaction_id = st.code
                left join sale_item si
                       on si.code = sti.sale_item_id
                group by
                  st.code,
                  st.transaction_date,
                  st.remark,
                  st.person_in_charge,
                  st.sales_volume,
                  st.discount
            )
            ${whereClause}
        """

        def sql = new groovy.sql.Sql(dataSource)

        sql.eachRow(query,filterDatas){
            records << [
                code             : it.code,
                transaction_date : it.transaction_date,
                remark           : it.remark,
                person_in_charge : it.person_in_charge,
                sales_volume     : it.sales_volume,
                discount         : it.discount,
                total_sales      : it.total_sales
            ]
        }

        totalRecords = sql.firstRow(queryTotal, filterDatas)?.ttl

        sql.close()

        int totalPage = Math.ceil(totalRecords / max)

        return [records: records, totalRecords: totalRecords, totalPage: totalPage]
    }

    def getSaleTransactionItems(def transactionCode){
        String query = """
            from SalesTransactionItem where transaction.code = ?
        """

        def records = []

        SalesTransactionItem.findAll(query, [transactionCode])?.each{
            records << [
                 code           :it.saleItem?.productItem?.code
                ,name           :it.saleItem?.productItem?.name
                ,quantity       :it.quantity
                ,salePrice      :it.saleItem?.salePrice
                ,discount       :it.discount?:0
                ,saleItemRemark :it.saleItem?.remark
            ]
        }

        return records
    }

}
