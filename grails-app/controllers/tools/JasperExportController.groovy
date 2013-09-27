package tools

import org.codehaus.groovy.grails.plugins.jasper.JasperReportDef

class JasperExportController {

    def jasperService

    def index = { }

    def export = {

        params.IS_IGNORE_PAGINATION = true

        JasperReportDef reportDef = jasperService.buildReportDefinition(params, request.getLocale(), null)

        generateResponse(reportDef)

    }

    def generateResponse = {reportDef ->
        try {
            if (!reportDef.fileFormat.inline && !reportDef.parameters._inline) {
              response.setHeader("Content-disposition", "attachment; filename=${(reportDef.parameters._name ?: reportDef.name)}.${reportDef.fileFormat.extension}");
              //response.contentType = reportDef.fileFormat.mimeTyp
              //response.characterEncoding = "UTF-8"
              response.outputStream << reportDef.contentStream.toByteArray()
            } else {
              render(text: reportDef.contentStream, contentType: reportDef.fileFormat.mimeTyp, encoding: reportDef.parameters.encoding ? reportDef.parameters.encoding : 'UTF-8');
            }
        } catch(org.apache.catalina.connector.ClientAbortException ex) {
            //TODO nothing
        }
    }
}
