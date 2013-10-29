root = window ? global
root.ShareCoffee or = {}

root.ShareCoffee.RESTFactory = class
  constructor: (@method, @updateQuery = false) ->

  jQuery: (jQueryProperties) =>
    options = new ShareCoffee.REST.jQueryProperties()
    options.extend jQueryProperties
    
    options.eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not options.eTag?)

    result = 
      url: if options.hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{options.url}?@target='#{options.hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{options.url}"
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
      url: if options.hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{options.url}?@target='#{options.hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{options.url}"
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
        url: if options.hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{options.url}?@target='#{options.hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{options.url}"
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
