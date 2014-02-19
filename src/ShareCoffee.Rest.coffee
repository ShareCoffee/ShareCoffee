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
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : options.eTag
      data: if typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)

    if @method is 'GET'
      delete result.contentType
    else
      result.headers['X-RequestDigest'] = ShareCoffee.Commons.getFormDigest()

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
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : options.eTag
      data: if typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)

    if @method is 'GET'
      delete result.headers['Content-Type']
    else
      result.headers['X-RequestDigest'] = ShareCoffee.Commons.getFormDigest()

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
          'If-Match' : options.eTag
          'X-HTTP-Method' : 'MERGE'
        data: if options.payload? and typeof options.payload is 'string' then options.payload else JSON.stringify(options.payload)
        success: options.onSuccess
        error: options.onError


      if @method is 'GET'
        delete result.contentType
      else
        result.headers['X-RequestDigest'] = ShareCoffee.Commons.getFormDigest()

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
