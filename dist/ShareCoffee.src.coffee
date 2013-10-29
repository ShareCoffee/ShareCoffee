###
ShareCoffee (c) 2013 Thorsten Hans 
| dotnet-rocks.com | https://github.com/ThorstenHans/ShareCoffee/ | under MIT License |
###

root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.CSOM = class

  @getHostWeb = (appWebCtx, hostWebUrl) ->
    hostWebCtx = new SP.AppContextSite appWebCtx, hostWebUrl
    hostWebCtx.get_web()


root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.Commons = class 

  @getQueryString = () ->
    document.URL.split("?")[1]

  @getQueryStringParameter = (parameterName) ->
    params = document.URL.split("?")[1].split("&")
    parameterValue = (p.split("=")[1] for p in params when p.split("=")[0] is parameterName)
    parameterValue[0] ? ''

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

  @getHostWebUrl = () ->
    hostWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter "SPHostUrl"
    if ShareCoffee.Commons.loadHostWebUrlFrom?
      return ShareCoffee.Commons.loadHostWebUrlFrom()
    if hostWebUrlFromQueryString
      return decodeURIComponent hostWebUrlFromQueryString
    else
      console.error "SPHostUrl is not defined in the QueryString" if console and console.error
      return ""

  @getApiRootUrl = () ->
    "#{ShareCoffee.Commons.getAppWebUrl()}/_api/"

  @getFormDigest = () ->
    document.getElementById('__REQUESTDIGEST').value

root = global ? window

root.ShareCoffee or = {}

root.ShareCoffee.Core = class
  
  @checkConditions = (errorMessage, condition) ->
    if condition() is false
      console.error errorMessage if console and console.error
      throw errorMessage

  @loadScript = (scriptUrl, onLoaded, onError) ->
    s = document.createElement 'script'
    head = document.getElementsByTagName('head').item(0)
    s.type = 'text/javascript'
    s.async = true
    s.src = scriptUrl
    s.onload = onLoaded
    s.onerror = onError
    head.appendChild(s)


root = window ? global
root.ShareCoffee or = {}

root.ShareCoffee.CrossDomainRESTFactory = class
  constructor: (@method, @updateQuery = false) ->

  SPCrossDomainLib: (sharePointRestProperties) =>
    options = new ShareCoffee.CrossDomain.SharePointRestProperties()
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

root.ShareCoffee.CrossDomain = class 
  @crossDomainLibrariesLoaded = false

  @loadCrossDomainLibrary = (onSuccess, onError) ->
    onAnyError = () =>
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false
      onError() if onError
    requestExecutorScriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.RequestExecutor.js"
    ShareCoffee.Core.loadScript requestExecutorScriptUrl, ()=>
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      onSuccess() if onSuccess
    , onAnyError

  @build = 
    create:
      for: new ShareCoffee.CrossDomainRESTFactory 'POST'
    read:
      for: new ShareCoffee.CrossDomainRESTFactory 'GET'
    update:
      for: new ShareCoffee.CrossDomainRESTFactory('POST', true)
    delete:
      for: new ShareCoffee.CrossDomainRESTFactory 'DELETE'
 
  @getClientContext = () ->
    throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext' if ShareCoffee.CrossDomain.crossDomainLibrariesLoaded is false
    appWebUrl = ShareCoffee.Commons.getAppWebUrl()
    ctx = new SP.ClientContext appWebUrl 
    factory = new SP.ProxyWebRequestExecutorFactory appWebUrl
    ctx.set_webRequestExecutorFactory factory
    ctx

  @getHostWeb = (ctx, hostWebUrl = ShareCoffee.Commons.getHostWebUrl()) ->
    throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext' if ShareCoffee.CrossDomain.crossDomainLibrariesLoaded is false
    throw 'ClientContext cant be null, call ShareCoffee.CrossDomain.getClientContext() first' if not ctx?
    appContextSite = new SP.AppContextSite ctx, hostWebUrl
    appContextSite.get_web()

root.ShareCoffee.CrossDomain.SharePointRestProperties = class
  constructor: (@url, @payload, @hostWebUrl, @eTag, @onSuccess, @onError) ->
    @url = null unless @url?
    @payload = null unless @payload?
    @hostWebUrl = null unless @hostWebUrl?
    @eTag = null unless @eTag?
    @onSuccess = null unless @onSuccess?
    @onError = null unless @onError?

  extend:  (objects...) =>
    for object in objects
      for key, value of object
        @[key] = value
    return 

root = window ? global
root.ShareCoffee or = {}

root.ShareCoffee.RESTFactory = class
  constructor: (@method, @updateQuery = false) ->

  jQuery: (jQueryProperties) =>
    options = new ShareCoffee.REST.jQueryProperties()
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
    options = new ShareCoffee.REST.angularProperties()
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
    options = new ShareCoffee.REST.reqwestProperties()
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

root.ShareCoffee.REST = class 

  @applicationType = "application/json;odata=verbose"

  @build = 
    create: 
      for: new ShareCoffee.RESTFactory 'POST'
    read: 
      for: new ShareCoffee.RESTFactory 'GET'
    update : 
      for: new ShareCoffee.RESTFactory('POST', true)
    delete: 
      for: new ShareCoffee.RESTFactory 'DELETE'

root.ShareCoffee.REST.angularProperties = class
  constructor: (@url, @payload, @hostWebUrl, @eTag) ->
    @url = null unless @url?
    @payload = null unless @payload?
    @hostWebUrl = null unless @hostWebUrl?
    @eTag = null unless @eTag?

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

root.ShareCoffee.REST.jQueryProperties = class extends root.ShareCoffee.REST.angularProperties

root.ShareCoffee.REST.reqwestProperties = class extends root.ShareCoffee.REST.angularProperties
  constructor: (@url, @payload, @hostWebUrl, @eTag, @onSuccess, @onError) ->
    super @url, @payload, @hostWebUrl, @eTag
    @onSuccess = null unless @onSuccess?
    @onError = null unless @onError?

root = window ? global

root.ShareCoffee or = {}

root.ShareCoffee.SettingsLink = (url, title, appendQueryStringToUrl = false) ->
  linkUrl: if appendQueryStringToUrl then "#{url}?#{ShareCoffee.Commons.getQueryString()}" else url
  displayName: title 

root.ShareCoffee.ChromeSettings = (iconUrl, title,helpPageUrl, settingsLinkSplat...) ->
  appIconUrl: iconUrl
  appTitle: title
  appHelpPageUrl: helpPageUrl
  settingsLinks: settingsLinkSplat

root.ShareCoffee.UI = class
  
  @showNotification = (message, isSticky = false) ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.addNotification?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.addNotification message, isSticky

  @removeNotification = (notificationId) ->
    return unless notificationId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.removeNotification?

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.removeNotification notificationId

  @showStatus = (title, contentAsHtml, showOnTop = false, color = 'blue') ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.addStatus? and SP.UI.Status.setStatusPriColor?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    statusId = SP.UI.Status.addStatus title, contentAsHtml, showOnTop
    SP.UI.Status.setStatusPriColor statusId, color
    statusId

  @removeStatus = (statusId) ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeStatus? 
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeStatus statusId

  @removeAllStatus = () ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeAllStatus? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeAllStatus()

  @setStatusColor = (statusId, color='blue') ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.setStatusPriColor? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.setStatusPriColor statusId, color

  @onChromeLoadedCallback = null

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
    

