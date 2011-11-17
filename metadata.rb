maintainer       "Fire Information Systems Group"
maintainer_email "peter@realityforge.org"
license          "Apache 2.0"
description      "Installs/Configures bonita"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.6"

depends "tomcat"

attribute "bonita/version",
  :display_name => "Bonita Version",
  :description => "The version of the product installed",
  :type => "string",
  :default => "5.6"

attribute "bonita/package_url",
  :display_name => "URL of bonita package",
  :description => "The url of package to download to install bonita.",
  :type => "string",
  :default => "The zip package in a maven2 style repository based at maven/repository_url at coordinates com.bonitasoft:bonitasoft-server:$version:zip"

attribute "bonita/package_checksum",
  :display_name => "Bonita Package Checksum",
  :description => "The checksum for the bonita package",
  :type => "string",
  :default => "e8570411241c0fdaef2f886f64bb10be8f659db3"
