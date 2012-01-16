maintainer       "Peter Donald"
maintainer_email "peter@realityforge.org"
license          "Apache 2.0"
description      "Installs/Configures bonita"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.30"

depends "tomcat"

attribute "bonita/package_url",
  :display_name => "URL of bonita package",
  :description => "The url of package to download to install bonita.",
  :type => "string"

attribute "bonita/package_checksum",
  :display_name => "Bonita Package Checksum",
  :description => "The checksum for the bonita package",
  :type => "string"
