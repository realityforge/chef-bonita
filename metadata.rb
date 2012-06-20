maintainer       "Peter Donald"
maintainer_email "peter@realityforge.org"
license          "Apache 2.0"
description      "Installs/Configures the bonita BPM server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.0"

depends "tomcat"

attribute "bonita/package_url",
  :display_name => "URL of bonita package",
  :description => "The url of package to download to install bonita.",
  :type => "string"
