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
