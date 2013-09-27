package sec.user

import grails.converters.JSON

class UserService {

    static transactional = true

    def serviceMethod() {

    }

    def getUserList(def params){
        def sort = params.sidx && !"".equals(params.sidx) ? params.sidx : null
        def order = params.sord && !"".equals(params.sord) ? params.sord : null
        def max = Math.min(params.rows ? params.int('rows') : 10, 1000)
        def offset = ((params.page ? params.int('page') : 1) - 1) * max

        def whereClause = ""
        def filterData = []

        if (params.boolean('_search')) {
            if (params.filters) {
                def filters = JSON.parse(params.filters)
                def whereClauseItems = []
                filters.rules.each {
                    switch (it.op) {
                        case "eq":
                            switch (it.field) {
                                case 'nothing':

                                    break
                                default:
                                    whereClauseItems << "upper(${it.field}) = upper(?)"
                                    filterData << it.data == 'true' || it.data == 'false' ? Boolean.parseBoolean(it.data) : it.data
                                    break
                            }
                            break
                        case "ne":
                            switch (it.field) {
                                case 'nothing':

                                    break
                                default:
                                    whereClauseItems << "upper(${it.field}) != upper(?)"
                                    filterData << it.data == 'true' || it.data == 'false' ? Boolean.parseBoolean(it.data) : it.data
                                    break
                            }
                            break
                        case "lt":
                            //NA
                            break
                        case "le":
                            //NA
                            break
                        case "gt":
                            //NA
                            break
                        case "ge":
                            //NA
                            break
                        case "bw":
                            whereClauseItems << "upper(${it.field}) like upper(?)||'%'"
                            filterData << it.data
                            break
                        case "bn":
                            whereClauseItems << "upper(${it.field}) not like upper(?)||'%'"
                            filterData << it.data
                            break
                        case "ew":
                            whereClauseItems << "upper(${it.field}) like '%'||upper(?)"
                            filterData << it.data
                            break
                        case "en":
                            whereClauseItems << "upper(${it.field}) not like '%'||upper(?)"
                            filterData << it.data
                            break
                        case "cn":
                            whereClauseItems << "upper(${it.field}) like '%'||upper(?)||'%'"
                            filterData << it.data
                            break
                        case "nc":
                            whereClauseItems << "upper(${it.field}) not like '%'||upper(?)||'%'"
                            filterData << it.data
                            break
                        case "in":
                            def inArr = it.data?.split(",")
                            String foo = "${it.field} in ("
                            inArr?.each { n ->
                                foo += "?,"
                                filterData << n?.trim()
                            }
                            foo += "'xxx')"
                            whereClauseItems << foo
                            break
                        case "ni":
                            def inArr = it.data?.split(",")
                            String foo = "${it.field} not in ("
                            inArr?.each { n ->
                                foo += "?,"
                                filterData << n?.trim()
                            }
                            foo += "'xxx')"
                            whereClauseItems << foo
                            break
                        default:
                            whereClauseItems << "upper(${it.field}) = upper(?)"
                            filterData << it.data == 'true' || it.data == 'false' ? Boolean.parseBoolean(it.data) : it.data
                    }
                }

                whereClause = whereClauseItems?" where ${whereClauseItems.join(" ${filters.get('groupOp')} ")}":""

            } else if (params.searchField) {
                //NA
            } else {
                //NA
            }
        } else {
            //NA
        }

        String query = """
            from User ${whereClause} ${(sort&&order?("order by ${sort} ${order}"):"")}
        """

        def rows = []
        int totalRecords = 0
        int totalPage = 0

        int counter = 0

        try {
            User.findAll(query, filterData, [max:max,offset:offset])?.each{
                rows << [
                        id: counter++,
                        cell:[
                            it.username,
                            "${it.roles}"
                        ]
                ]
            }

            totalRecords = User.findAll(query, filterData)?.size()
        } catch (e) {
            e.printStackTrace()
        }

        totalPage = Math.ceil(  totalRecords / max)

        return [rows: rows, totalRecords: totalRecords, page: params.page, totalPage: totalPage]
    }
}
