###
ShareCoffee (c) 2013 Thorsten Hans 
| dotnet-rocks.com | https://github.com/ThorstenHans/ShareCoffee/ | under MIT License |
###

# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.CSOM
# The ShareCoffee.CSOM class is providing functionality which can be used when working with the SharePoint's CSOM
# **Important** These methods are designed to use in non CrossDomain scenarios
root.ShareCoffee.CSOM = class
  
  # ##getHostWeb
  # getHost web uses the SP.AppContextSite in order to receive the SPHostWeb requested by it's url
  #
  # ### Parameters
  #   * [Object] appWebCtx - The current AppWeb Context
  #   * [String] hostWebUrl - The HostWebUrl you're looking for
  #
  # ### Return Value
  # getHostWeb returns the suggested HostWeb Context
  @getHostWeb = (appWebCtx, hostWebUrl) ->
    hostWebCtx = new SP.AppContextSite appWebCtx, hostWebUrl
    hostWebCtx.get_web()


# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.Commons
# This class offers different helper functions which makes your life as App-Dev easier
root.ShareCoffee.Commons = class 

  # ##getQueryString
  # getQueryString returns the entire QueryString from the current document's URL
  # 
  # ### ReturnValue
  # The entire QueryString
  @getQueryString = () ->
    document.URL.split("?")[1]

  # ##getQueryStringParameter
  # getQueryStringParameter returns a single parameter value from the current document's QueryString
  # 
  # ### Parameters
  #   * [String] parameterName - The name of the parameter
  # 
  # ### ReturnValue
  # Returns the value of the parameter, if no parameter is found by the name, an empty string is returned
  @getQueryStringParameter = (parameterName) ->
    params = document.URL.split("?")[1].split("&")
    parameterValue = (p.split("=")[1] for p in params when p.split("=")[0] is parameterName)
    parameterValue[0] ? ''

  # ##getAppWebUrl
  # getAppWebUrl will return the AppWebUrl. if a custom load method is associated to 
  # **ShareCoffee.Commons.loadAppWebUrlFrom** only this injected method will be executed
  # in all other cases getAppWebUrl will first try to get the AppWebUrl from **_spPageContextInfo** 
  # if this object isn't present the method looks inside of the **QueryString**
  #
  # ### ReturnValue
  # Returns the current AppWebUrl or returns an empty String if no method contains a value
  @getAppWebUrl = () ->
    if ShareCoffee.Commons.loadAppWebUrlFrom?
      return ShareCoffee.Commons.loadAppWebUrlFrom()
    else if _spPageContextInfo? && _spPageContextInfo.webAbsoluteUrl?
      return _spPageContextInfo.webAbsoluteUrl

    appWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter "SPAppWebUrl"
    if appWebUrlFromQueryString
      return decodeURIComponent appWebUrlFromQueryString
    else
      console.error "_spPageContextInfo is not defined" if console and console.error
      return ""

  # ##getHostWebUrl
  # getHostWebUrl will return the HostWebURl. If a custom load method is associated to
  # **ShareCoffee.Commons.loadHostWebUrlFrom** only this injected method will be executed
  # in all other cases getHostWebUrl looks inside of the QueryString for SPHostUrl parameter
  #
  # ### ReturnValue
  # Returns the current HostWebUrl or returns an empty string if neither custom load method associated nor QueryString parameter is present
  @getHostWebUrl = () ->
    if ShareCoffee.Commons.loadHostWebUrlFrom?
      return ShareCoffee.Commons.loadHostWebUrlFrom()
    
    hostWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter "SPHostUrl"
    if hostWebUrlFromQueryString
      return decodeURIComponent hostWebUrlFromQueryString
    else
      console.error "SPHostUrl is not defined in the QueryString" if console and console.error
      return ""

  # ##getApiRootUrl
  # getApiRootUrl will return the the root path to SharePoint's REST endpoint {AppWebUrl}/_api/
  #
  # ### ReturnValue
  # REST API entrypoint {AppWebUrl}/_api/
  @getApiRootUrl = () ->
    "#{ShareCoffee.Commons.getAppWebUrl()}/_api/"

  # ##getFormDigest
  # getFormDigest returns the Form Digest Control value using plain old JavaScript instead of relying on jQuery
  #
  # ### ReturnValue
  # Form Digest's value
  @getFormDigest = () ->
    document.getElementById('__REQUESTDIGEST').value

# Node.JS doesn't offer window... 
root = global ? window

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.Core
# This class is used internally because these methods are used more frequently within the entire project
root.ShareCoffee.Core = class
  
  # ##checkConditions 
  # checkConditions evaluates the method provided as 2nd parameter and throw's an error as far as the return value is false.
  #
  # ### Parameters
  #  * [String] errorMessage - the error message which will be logged and thrown
  #  * [function] condition - the condition which will be evaluated
  #
  @checkConditions = (errorMessage, condition) ->
    if condition() is false
      console.error errorMessage if console and console.error
      throw errorMessage

  # ##loadScript 
  # loadScript loads JavaScript resources from any url and adds it to the current <head> tag.
  #
  # ### Parameters
  #   * [String] scriptUrl - The script's location
  #   * [function] onLoaded - Callback which will be executed as soon as the script is loaded
  #   * [function] onError - Callback which will be invoked as soon as the script loading failes
  #
  @loadScript = (scriptUrl, onLoaded, onError) ->
    s = document.createElement 'script'
    head = document.getElementsByTagName('head').item(0)
    s.type = 'text/javascript'
    s.async = true
    s.src = scriptUrl
    s.onload = onLoaded
    s.onerror = onError
    head.appendChild(s)


# Node.JS doesn't offer window...
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.CrossDomainRESTFactory
# This class is an internal class which is used for translating an instance of ShareCoffee.CrossDomain.SharePointRestProperties to the format that SP.RequestExecutor understands
root.ShareCoffee.CrossDomainRESTFactory = class
  constructor: (@method, @updateQuery = false) ->

  SPCrossDomainLib: (sharePointRestProperties) =>
    if sharePointRestProperties? and sharePointRestProperties.getRequestProperties?
      sharePointRestProperties = sharePointRestProperties.getRequestProperties()
    options = new ShareCoffee.REST.RequestProperties()
    options.extend sharePointRestProperties

    throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the CrossDomain REST libraries' if ShareCoffee.CrossDomain.crossDomainLibrariesLoaded is false

    options.eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not options.eTag?)

    result =
      url: if options.hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppContextSite(@target)/#{options.url}?@target='#{options.hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{options.url}"
      method: @method
      success: options.onSuccess
      error: options.onError
      headers:
        'Accept': ShareCoffee.REST.applicationType
        'Content-Type': ShareCoffee.REST.applicationType
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : options.eTag
      body: if typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)

    if @method is 'GET'
      delete result.headers['X-RequestDigest']
      delete result.headers['Content-Type']

    delete result.headers['X-HTTP-Method'] unless @method is 'POST' and options.eTag?
    delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and options.eTag?)
    delete result.success unless options.onSuccess?
    delete result.error unless options.onError?
    delete result.body unless @method is 'POST'
    result
# ##ShareCoffee.CrossDomain
# The CrossDomain namespace offers functionality which will be used when you're building Cloud-Hosted Apps (AutoHosted-and ProviderHosted-Apps).
root.ShareCoffee.CrossDomain = class
  # ##crossDomainLibrariesLoaded
  # flag which determines if CrossDomain libraries are loaded or not.
  @crossDomainLibrariesLoaded = false

  # ##loadCSOMCrossDomainLibraries
  # This method will load all required libraries from SharePoint/Office365 that are required when you'd like to use CSOM(JSOM) from your Cloud-Hosted-App
  #
  # ### Parameter
  #   * [function] onSuccess - Success callback, which will be invoked as soon as all required libraries are loaded
  #   * [function] onError - Error callback, which will be invoked when an error is raised
  @loadCSOMCrossDomainLibraries = (onSuccess, onError) ->
    onAnyError = () =>
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false
      onError() if onError
    runtimeScriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.Runtime.js"
    spScriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.js"
    requestExecutorScriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.RequestExecutor.js"

    ShareCoffee.Core.loadScript runtimeScriptUrl, ()=>
      ShareCoffee.Core.loadScript spScriptUrl, ()=>
        ShareCoffee.Core.loadScript requestExecutorScriptUrl, ()=>
          ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
          onSuccess() if onSuccess
        , onAnyError
      , onAnyError
    , onAnyError

  # ##loadCrossDomainLibrary
  # The loadCrossDomainLibrary should be used when you'd like to use SharePoint's REST interface. The method will load SP.RequestExecutor.js from the associated SharePoint/SharePoint-Online
  #
  # ### Parameters
  #   * [function] onSuccess - Success callback, which will be invoked as soon as all required libraries are loaded
  #   * [function] onError - Error callback, which will be invoked when an error is raised
  @loadCrossDomainLibrary = (onSuccess, onError) ->
    onAnyError = () =>
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false
      onError() if onError
    requestExecutorScriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.RequestExecutor.js"
    ShareCoffee.Core.loadScript requestExecutorScriptUrl, ()=>
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      onSuccess() if onSuccess
    , onAnyError

  # ##build
  # build is the entry point for CRUD operations using the REST interface it supports create, read, update, delete
  @build =
    create:
      for: new ShareCoffee.CrossDomainRESTFactory 'POST'
    read:
      for: new ShareCoffee.CrossDomainRESTFactory 'GET'
    update:
      for: new ShareCoffee.CrossDomainRESTFactory('POST', true)
    delete:
      for: new ShareCoffee.CrossDomainRESTFactory 'DELETE'

  # ##getClientContext
  # It checks if all required cross domain libraries are loaded for using CSOM from a Cloud-Hosted App, if so, it will return the preconfigured SP.ClientContext instance
  #
  # ### ReturnValue
  # Returns an instance of SP.ClientContext which is targeting the AppWeb as far as all required libraries are loeded
  @getClientContext = () ->
    throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext' if ShareCoffee.CrossDomain.crossDomainLibrariesLoaded is false
    appWebUrl = ShareCoffee.Commons.getAppWebUrl()
    ctx = new SP.ClientContext appWebUrl
    factory = new SP.ProxyWebRequestExecutorFactory appWebUrl
    ctx.set_webRequestExecutorFactory factory
    ctx

  # ##getHostWeb
  # The getHostWeb method will return an instance of SP.Web targeting the suggested Web
  #
  # ### Parameters
  #   * [Object] ctx - The preconfigured instance of SP.ClientContext
  #   * [String] hostWebUrl - The site's url you're looking for (defaults to the SPHostUrl)
  #
  # ### ReturnValue
  # returns an instance of SP.Web targeting the suggested SharePoint Web
  @getHostWeb = (ctx, hostWebUrl = ShareCoffee.Commons.getHostWebUrl()) ->
    throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext' if ShareCoffee.CrossDomain.crossDomainLibrariesLoaded is false
    throw 'ClientContext cant be null, call ShareCoffee.CrossDomain.getClientContext() first' if not ctx?
    appContextSite = new SP.AppContextSite ctx, hostWebUrl
    appContextSite.get_web()

# Node.JS doesn't offer window...
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.RESTFactory
# Internal class which is responsible for translating your RequestOptions into the required format
root.ShareCoffee.RESTFactory = class
  constructor: (@method, @updateQuery = false) ->

  jQuery: (jQueryProperties) =>

    if jQueryProperties? and jQueryProperties.getRequestProperties?
      jQueryProperties = jQueryProperties.getRequestProperties()

    options = new ShareCoffee.REST.RequestProperties()
    options.extend jQueryProperties

    options.eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not options.eTag?)

    result =
      url: options.getUrl()
      type: @method
      contentType: ShareCoffee.REST.applicationType
      headers:
        'Accept' : ShareCoffee.REST.applicationType
        'X-RequestDigest' : ShareCoffee.Commons.getFormDigest()
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : options.eTag
      data: if typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)

    if @method is 'GET'
      delete result.contentType
      delete result.headers['X-RequestDigest']

    delete result.headers['X-HTTP-Method'] unless @method is 'POST' and options.eTag?
    delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and options.eTag?)
    delete result.data unless @method is 'POST'
    result

  angularJS: (angularProperties) =>

    if angularProperties? and angularProperties.getRequestProperties?
      angularProperties = angularProperties.getRequestProperties()

    options = new ShareCoffee.REST.RequestProperties()
    options.extend angularProperties
    options.eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not options.eTag?)

    result =
      url: options.getUrl()
      method: @method
      headers:
        'Accept' : ShareCoffee.REST.applicationType
        'Content-Type': ShareCoffee.REST.applicationType
        'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : options.eTag
      data: if typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)

    if @method is 'GET'
      delete result.headers['Content-Type']
      delete result.headers['X-RequestDigest']

    delete result.headers['X-HTTP-Method'] unless @method is 'POST' and options.eTag?
    delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and options.eTag?)
    delete result.data unless @method is 'POST'
    result

  reqwest: (reqwestProperties) =>

    if reqwestProperties? and reqwestProperties.getRequestProperties?
      reqwestProperties = reqwestProperties.getRequestProperties()

    options = new ShareCoffee.REST.RequestProperties()
    options.extend reqwestProperties
    options.eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not options.eTag?)
    result = null
    try
      result=
        url: options.getUrl()
        type: 'json'
        method: @method.toLowerCase()
        contentType: ShareCoffee.REST.applicationType
        headers:
          'Accept' : ShareCoffee.REST.applicationType
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
          'If-Match' : options.eTag
          'X-HTTP-Method' : 'MERGE'
        data: if options.payload? and typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)
        success: options.onSuccess
        error: options.onError


      if @method is 'GET'
        delete result.contentType
        delete result.headers['X-RequestDigest']

      delete result.headers['X-HTTP-Method'] unless @method is 'POST' and options.eTag?
      delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and options.eTag?)
      delete result.data unless @method is 'POST'
      delete result.success unless options.onSuccess?
      delete result.error unless options.onError?

    catch Error
      throw 'please provide either a json string or an object as payload'
    result

# ##ShareCoffee.REST
# This namespace is responsible for exposing REST functionality for SharePoint-Hosted Apps
root.ShareCoffee.REST = class

  @applicationType = "application/json;odata=verbose"
  # ##build
  # Build offers CRUD API for REST queries. Available methods are create, update, read, delete
  @build =
    create:
      for: new ShareCoffee.RESTFactory 'POST'
    read:
      for: new ShareCoffee.RESTFactory 'GET'
    update :
      for: new ShareCoffee.RESTFactory('POST', true)
    delete:
      for: new ShareCoffee.RESTFactory 'DELETE'
# ##ShareCoffee.REST.RequestProperties
# Use this class to configure your REST requests. If you prefer plain JSON objects, you can also provide the configuration as plain JSON object
#
# ### Parameters
#
#   * [String] url - the Request URL
#   * [Object|String] payload - The request payload
#   * [String] hostWebUrl - Optional the HostWebUrl
#   * [String] eTag - Optional pass eTag for POST, PUT or DELETE requests
#   * [Function] onSuccess - onSuccess callback
#   * [Function] onError - onError callback
root.ShareCoffee.REST.RequestProperties = class

  constructor: (@url, @payload, @hostWebUrl, @eTag, @onSuccess, @onError) ->
    @url = null unless @url?
    @payload = null unless @payload?
    @hostWebUrl = null unless @hostWebUrl?
    @eTag = null unless @eTag?
    @onSuccess = null unless @onSuccess?
    @onError = null unless @onError?

  getUrl: ()=>
    if @hostWebUrl?
      if @url.indexOf("?") is -1
        return "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppContextSite(@target)/#{@url}?@target='#{@hostWebUrl}'"
      else
        return "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppContextSite(@target)/#{@url}&@target='#{@hostWebUrl}'"
    else
      return "#{ShareCoffee.Commons.getApiRootUrl()}#{@url}"

  extend:  (objects...) =>
    for object in objects
      for key, value of object
        @[key] = value
    return

# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.SettingsLink
# Create a new instance of ShareCoffee.SettingsLink which can be placed inside of the App-ChromeBar
#
# ### Parameters
#   * [String] url - the target url for the settings link
#   * [String] title - visual representation for the settings link
#   * [bool] appendQueryStringToUrl - determines if the entire QueryString should be appended to the url
#
# ### ReturnValue
# Returns a configured instance of ShareCoffee.SettingsLink
root.ShareCoffee.SettingsLink = (url, title, appendQueryStringToUrl = false) ->
  linkUrl: if appendQueryStringToUrl then "#{url}?#{ShareCoffee.Commons.getQueryString()}" else url
  displayName: title 

# ##ShareCoffee.ChromeSettings
# An instance of ShareCoffee.ChromeSettings is used to configure the entire App-ChromeBar.
#
# ### Parameters
#   * [String] iconUrl - URL to the AppIcon
#   * [String] title - Title of your App
#   * [String] helpPageUrl - optinal URL which points to your App's help page
#   * [SettingsLinks] settingsLinkSplat - You can pass as many SettingsLink instances as you want to
root.ShareCoffee.ChromeSettings = (iconUrl, title,helpPageUrl, settingsLinkSplat...) ->
  appIconUrl: iconUrl
  appTitle: title
  appHelpPageUrl: helpPageUrl
  settingsLinks: settingsLinkSplat

# ##ShareCoffee.UI
# This class capsulates all SharePoint UI interactions
root.ShareCoffee.UI = class
  
  # ##showNotification
  # The showNotification method provides an wrapper for SharePoint's SP.UI.Notify API. On top of just calling SharePoint's API, 
  # showNotification checks if all required objects are available. If not, an error will be logged to the JS Console.
  #
  # ### Parameters
  #   * [String] message - The message you'd like to display
  #   * [bool] isSticky - Determines if the message should stuck on the page or if it should disappear after a few seconds
  #
  # ### ReturnValue
  # showNotification returns an NotificationId, which can be used to manually remove the notification later using the removeNotification function
  @showNotification = (message, isSticky = false) ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.addNotification?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.addNotification message, isSticky

  # ##removeNotification
  # The removeNotification function will remove a notification from the current page. If any of the required SharePoint libraries is not loaded, an error is displayed within the browser console
  #
  # ### Parameter
  #   * [int] notificationId - The notification's id that should be removed from the page
  @removeNotification = (notificationId) ->
    return unless notificationId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.removeNotification?

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.removeNotification notificationId

  # ##showStatus
  # The showStatus method is used to display a status message on the current page. If any of the required SharePoint scripts isn't loaded, an error will be logged to the browsers console
  #
  # ### Parameter
  #   * [String] title - The title of the status
  #   * [String] contentAsHtml - Content of the status (supports HTML)
  #   * [bool] showOnTp - determines if the status should appear on top (defaults to false)
  #   * [String] color - sets the color of the status message (defaults to blue)
  #
  # ### ReturnValue
  # Returns the status' Id
  @showStatus = (title, contentAsHtml, showOnTop = false, color = 'blue') ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.addStatus? and SP.UI.Status.setStatusPriColor?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    statusId = SP.UI.Status.addStatus title, contentAsHtml, showOnTop
    SP.UI.Status.setStatusPriColor statusId, color
    statusId

  # ##removeStatus
  # This method is used to remove an existing status from the current page
  #
  # ### Parameter
  #   * [int] statusId - Id of the status message which should be removed from the page
  @removeStatus = (statusId) ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeStatus? 
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeStatus statusId

  # ##removeAllStatus
  # This method is used to remove all status messages from the current page
  @removeAllStatus = () ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeAllStatus? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeAllStatus()

  # ##setStatusColor
  # The setStatusColor function is used to change the color of an existing status message.
  #
  # ### Parameter
  #  * [int] statusId - Id of the status message you want to colorize
  #  * [String] color - The new color value for the status message (defaults to blue)
  @setStatusColor = (statusId, color='blue') ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.setStatusPriColor? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.setStatusPriColor statusId, color


  @onChromeLoadedCallback = null
  
  # ##loadAppChrome
  # The loadAppChrome method will load all required scripts from SharePoint or Office365 and display the App-Chrome-Bar
  # If you're developing Cloud-Hosted Apps for SharePoint you should consider including the AppChromeBar. Users recognize that they are still in the context of SharePoint/Office365 and they can easily navigate back to their entry point.
  #
  # ### Parameters
  #   * [String] placeHolderId - The ChromeBar requires an DIV element where the Chrome will be displayed. Provide the id from the div here
  #   * [Object] chromeSettings - Either provide an instance of ShareCoffee.ChromeSettings or an JSON object which defines the options for the AppChromeBar
  #   * [function] onAppChromeLoaded - Provide a callback which will be executed as soon as the ChromeBar is loaded
  #
  # ### Throws
  # Throws an exception if the SP.UI.Controls.js file can't be loaded from SharePoint/Office365
  @loadAppChrome = (placeHolderId, chromeSettings, onAppChromeLoaded = undefined) ->
    if onAppChromeLoaded?
      ShareCoffee.UI.onChromeLoadedCallback = onAppChromeLoaded
      chromeSettings.onCssLoaded = "ShareCoffee.UI.onChromeLoadedCallback()"

    onScriptLoaded = () =>
      chrome = new SP.UI.Controls.Navigation placeHolderId, chromeSettings
      chrome.setVisible true

    scriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.UI.Controls.js"

    ShareCoffee.Core.loadScript scriptUrl, onScriptLoaded, ()->
      throw "Error loading SP.UI.Controls.js"
    

