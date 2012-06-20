Description
===========

[![Build Status](https://secure.travis-ci.org/realityforge-cookbooks/bonita.png?branch=master)](http://travis-ci.org/realityforge-cookbooks/bonita)


Download BonitaSoft from a remote location and install it into the tomcat directories according to the directions. The
cookbook has been tested with the "Subscription Pack" 5.6.2 version of the Bonita product. First you need to download the
"Bonita Open Solution Deployment" package from the downloads page (http://www.bonitasoft.com/products/BPM_downloads/all)
and upload it to a local location. We install it in a local Maven repository with coordinates
"com.bonitasoft:bonitasoft-server-sp:5.6.2:tomcat:zip".

Unfortunately the install can not be completely automated as BonitaSoft requires that you generate a license for the
specific host that the product is deployed upon. So after the initial install you need to generate a license key as per
the directions given by BonitaSoft (i.e. Run either /usr/local/bonita-5.6.2/licenses/generateRequestForAnyEnvironment.sh
or /usr/local/bonita-5.6.2/licenses/generateRequestForDevelopmentEnvironment.sh and send of request to bonita and wait
for a response). The license needs to be made available over http. We make this license also available in a local Maven
 repository.

The cookbook has only been tested when deploying to MS SQL server but it is expected that modifying the configuration
settings will make the cookbook work with other database vendors.

Attributes
==========

* `node['bonita']['package_url']` - The url to package containing the bonita software. Must be specified.
* `node['bonita']['license_url']` - The url to the license file for the bonita software.
* `node['bonita']['database']['hibernate']['dialect']` - = 'org.hibernate.dialect.SQLServerDialect'.
* `node['bonita']['database']['exo_jcr']['dialect']` - The xCMIS jcr dialect. Defaults to 'mssql'.
* `node['bonita']['database']['hibernate']['interceptor']` - The Bonita hibernate interceptor. Defaults to 'org.ow2.bonita.env.interceptor.MSSQLServerDescNullsFirstInterceptor'.
* `node['bonita']['database']['jdbc']['driver']` - The class name of the database driver. Defaults to 'net.sourceforge.jtds.jdbc.Driver'.
* `node['bonita']['database']['jdbc']['history']['url']` - The database jdbc url for bonita history database. Must be specified.
* `node['bonita']['database']['jdbc']['history']['schema']` - The database schema for the bonita history database. May be specified.
* `node['bonita']['database']['jdbc']['journal']['url']` - The database jdbc url for bonita journal database. Must be specified.
* `node['bonita']['database']['jdbc']['journal']['schema']` - The database schema for the bonita journal database. May be specified.
* `node['bonita']['database']['jdbc']['xcmis']['url']` - The database jdbc url for xcmis. Must be specified.
* `node['bonita']['database']['jdbc']['username']` - The database username.
* `node['bonita']['database']['jdbc']['password']` - The database username.
* `node['bonita']['xcmis']['username']` - The xCMIS username.
* `node['bonita']['xcmis']['password']` - The xCMIS password.

Usage
=====

Here is some example properties defined on a role that includes bonita.

    :bonita =>
      {
        :package_url => 'http://repo.example.com/com/bonitasoft/bonitasoft-server-sp/5.6/bonitasoft-server-sp-5.6-tomcat.zip',
        :license_url => 'http://repo.example.com/com/bonitasoft/bonitasoft-server-sp/license/5.6/license-5.6-MyUser-bonita.example.com-20111128-20120226.lic',
        :extra_libraries => ['http://repo.example.com/net/sourceforge/jtds/jtds/1.2.4/jtds-1.2.4.jar'],
        :database =>
          {
            :jdbc =>
              {
                :journal => {:url => 'jdbc:jtds:sqlserver://db.example.com/BONITA', :schema => 'journal'},
                :history => {:url => 'jdbc:jtds:sqlserver://db.example.com/BONITA', :schema => 'history'},
                :xcmis => {:url => 'jdbc:jtds:sqlserver://db.example.com/xCMIS'},
                :username => 'username',
                :password => 'password',
              }
          },
      :xcmis =>
        {
          :username => 'xcmis_username',
          :password => 'xcmis_password'
        }
      }
