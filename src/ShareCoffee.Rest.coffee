# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.RESTFactory
# Internal class which is responsible for translating your RequestOptions into the required format
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

# ##ShareCoffee.REST.angularProperties
# This class is used to configure REST requests and expose them for AngularJS
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

# ##ShareCoffee.REST.jQueryProperties
# This class is used to configure REST requests and expose them for jQuery
root.ShareCoffee.REST.jQueryProperties = class extends root.ShareCoffee.REST.angularProperties

# ##ShareCoffee.REST.reqwestProperties
# This class is used to configure REST requests and expose them for reqwest
root.ShareCoffee.REST.reqwestProperties = class extends root.ShareCoffee.REST.angularProperties
  constructor: (@url, @payload, @hostWebUrl, @eTag, @onSuccess, @onError) ->
    super @url, @payload, @hostWebUrl, @eTag
    @onSuccess = null unless @onSuccess?
    @onError = null unless @onError?
