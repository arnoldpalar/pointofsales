dataSource {
    pooled = true
    driverClassName = "oracle.jdbc.driver.OracleDriver" //"org.hsqldb.jdbcDriver"
    username = "sms" //"sa"
    password = "sms" //""
    dialect = org.hibernate.dialect.Oracle10gDialect
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {
    development {
        dataSource {
            dbCreate = "create" // one of 'create', 'create-drop','update'
            url = "jdbc:oracle:thin:@localhost:1521:xe" //"jdbc:hsqldb:mem:devDB"
        }
    }
    test {
        dataSource {
            dbCreate = "update"
            url = "jdbc:oracle:thin:@localhost:1521:xe" //"jdbc:hsqldb:mem:testDb"
        }
    }
    production {
        dataSource {
            dbCreate = "update"
            url = "jdbc:oracle:thin:@localhost:1521:xe" //"jdbc:hsqldb:file:prodDb;shutdown=true"
        }
    }
}
