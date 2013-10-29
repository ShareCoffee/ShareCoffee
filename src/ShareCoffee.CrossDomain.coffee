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
