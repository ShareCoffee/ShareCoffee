ShareCoffee 0.0.11

See detailed tutorials on https://github.com/ThorstenHans/ShareCoffee

See also available addons
  - ShareCoffee.Search

Release Notes
  - 0.0.11 - ShareCoffee allows you now to inject a custom load method for ShareCoffee.Commons.getFormDigest(). You can either set a method to ShareCoffee.commons.formDigestValue or a string. depending of the type either the function will be invoked or the actual string will be returned; ShareCoffee.Commons.loadAppWebUrlFrom and ShareCoffee.Commons.loadHostWebUrlFrom are now also supporting strings and functions.
  - 0.0.10 - Added $s as a shortcut for ShareCoffee; getFormDigest will now only be called when not executing GET requests
  - 0.0.9 - With ShareCoffee 0.0.9 the class ShareCoffee.CrossDomain.SharePointRestProperties has been removed from the project. Use ShareCoffee.REST.RequestProperties insted.
  - 0.0.8 - With ShareCoffee 0.0.8 the classes ShareCoffee.REST.angularProperties,
    ShareCoffee.REST.reqwestProperties and ShareCoffee.REST.jQueryProperties
    has been removed from the project. Instead you should either use a plain
    JSON object for configuring REST requests or you can create instances from the
    ShareCoffee.REST.RequestProperties class.


