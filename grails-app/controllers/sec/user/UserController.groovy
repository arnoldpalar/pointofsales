package sec.user

import grails.converters.JSON

class UserController {

    def userService

    def index = {
        [roles:Role.list()]
    }

    def getList = {
        def res = userService.getUserList(params)

        def jqGridJSON = [rows:res.rows,records:res.totalRecords,page:params.page,total:res.totalPage]

        render jqGridJSON as JSON
    }
}
