## v0.1.1:

* Rename the attributes used to define the bonita database urls and support configuration of database schemas.
* Replace the usage of the `node['bonita']['database']['driver_package_url']` attribute with the
  `node['bonita']['extra_libraries']` attributes that contains a list of jars to add to classpath.
* Ensure compliance with foodcritic recommendations and enforce via TravisCI.
* Remove the default usernames and passwords for all the database connections. Add guards in recipe to ensure they
  are specified.
* Remove the requirement for setting the checksum for packages as guards where already in place.
* Force the overriding of the tomcat attributes for bonita rather than setting normal attributes if not already
  specified.

## v0.1.0:

* Initial release