ShareCoffee 0.0.13

See detailed tutorials on https://github.com/ThorstenHans/ShareCoffee

See also available addons
  - ShareCoffee.Search
  - ShareCoffee.UserProfiles

Release Notes
  - 0.0.13 - Fixed broken NuGet Package
  - 0.0.12 - HashUrls are removed by ShareCoffee.Commons in order to provide a even better angularJS integration.
  - 0.0.11 - ShareCoffee allows you now to inject a custom load method for ShareCoffee.Commons.getFormDigest(). You can either set a method to ShareCoffee.commons.formDigestValue or a string. depending of the type either the function will be invoked or the actual string will be returned; ShareCoffee.Commons.loadAppWebUrlFrom and ShareCoffee.Commons.loadHostWebUrlFrom are now also supporting strings and functions.
  - 0.0.10 - Added $s as a shortcut for ShareCoffee; getFormDigest will now only be called when not executing GET requests
  - 0.0.9 - With ShareCoffee 0.0.9 the class ShareCoffee.CrossDomain.SharePointRestProperties has been removed from the project. Use ShareCoffee.REST.RequestProperties insted.
  - 0.0.8 - With ShareCoffee 0.0.8 the classes ShareCoffee.REST.angularProperties,
    ShareCoffee.REST.reqwestProperties and ShareCoffee.REST.jQueryProperties
    has been removed from the project. Instead you should either use a plain
    JSON object for configuring REST requests or you can create instances from the
    ShareCoffee.REST.RequestProperties class.


# ShareCoffee

ShareCoffee is a lightweight library for creating SharePoint Apps. It’s fully written in CoffeeScript by using Mocha, Chai and SinonJS.

### Installation

You can install ShareCoffee by 
  * copying the files from dist folder to your project :) (dirty one)
  * install it by using bower.io using `bower install ShareCoffee`
  * install it by using nuget using `Install-Package ShareCoffee`
  * install it by including ShareCoffee as git submodule

#### Integration
ShareCoffee integrates perfectly with 
  * [jQuery](https://github.com/jquery/jquery)
  * [AngularJS](https://github.com/angular/angular.js)
  * [Reqwest](https://github.com/ded/reqwest)

#### Samples

Check out the [sample repository here on github](https://github.com/ThorstenHans/ShareCoffee.Samples/)
#### ShareCoffee API 
ShareCoffee allows you to easily solve common requirements in SharePoint Apps such as
  * [SharePoint UI Notifications](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.UI)
  * [SharePoint UI Status-Messages](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.UI#sharecoffeeuishowstatus)
  * [SharePoint UI Chrome-Control](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.UI#sharecoffeeuiloadappchrome)
  * [Gathering contextual information](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.Commons)
  * [SharePoint JSOM (JavaScript Client Object Model) helpers](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.CSOM)
  * [SharePoint REST abstraction](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.REST) (SharePoint-Hosted) 
    * [ShareCoffee.REST for jQuery](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.REST.jQuery)
    * [ShareCoffee.REST for AngularJS](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.REST.angularJS)
    * [ShareCoffee.REST for reqwest](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.REST.reqwest)
  * [SharePoint CrossDomain-Query](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.CrossDomain) Support (Auto-Hosted/Provider-Hosted)
    * [CrossDomain Support for JSOM](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.CrossDomain.CSOM)
    * [CrossDomain Support for REST](https://github.com/ThorstenHans/ShareCoffee/wiki/ShareCoffee.CrossDomain.REST)


#### Wiki

See all documentation within the [ShareCoffee Wiki](https://github.com/ThorstenHans/ShareCoffee/wiki/_pages)
  
###The MIT License (MIT)

Copyright (c) 2013 Thorsten Hans 

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

        
          
