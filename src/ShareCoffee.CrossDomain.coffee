root = window ? global
root.ShareCoffee or = {}

root.ShareCoffee.CrossDomainRESTFactory = class
  constructor: (@method) ->

  SPCrossDomainLib: (url, hostWebUrl = null, onSuccess = null, onError = null, payload = null, eTag = null) =>
    throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the CrossDomain REST libraries' if ShareCoffee.CrossDomain.crossDomainLibrariesLoaded is false
    eTag = '*' if @method is 'DELETE'

    result = 
      url: if hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppContextSite(@target)/#{url}?@target='#{hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{url}"
      method: @method
      success: onSuccess
      error: onError
      headers: 
        'Accept': ShareCoffee.REST.applicationType
        'X-RequestDigest' : ShareCoffee.Commons.getFormDigest()
        'Content-Type': ShareCoffee.REST.applicationType
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : eTag
      body: if typeof payload is 'string' then payload else JSON.stringify(payload)

    if @method is 'GET'
      delete result.headers['X-RequestDigest']
      delete result.headers['Content-Type']
    
    delete result.headers['X-HTTP-Method'] unless @method is 'POST' and eTag?
    delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and eTag?)
    delete result.success unless onSuccess?
    delete result.error unless onError?
    delete result.body unless @method is 'POST'
    result

root.ShareCoffee.CrossDomain = class 
  @crossDomainLibrariesLoaded = false

  @loadCrossDomainLibrary = (onSuccess, onError) ->
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

  @build = 
    create:
      for: new ShareCoffee.CrossDomainRESTFactory 'POST'
    read:
      for: new ShareCoffee.CrossDomainRESTFactory 'GET'
    update:
      for: new ShareCoffee.CrossDomainRESTFactory 'POST'
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

