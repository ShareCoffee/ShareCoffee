root = window ? global
root.ShareCoffee or = {}

root.ShareCoffee.RESTFactory = class
  constructor: (@method) ->
  SPCrossDomainLib: (url, onSuccess = null, onError = null, hostWebUrl = null, payload = null, eTag = null) =>
    hostWebUrl = ShareCoffee.Commons.getHostWebUrl() unless hostWebUrl?
    eTag = '*' if @method is 'DELETE'

    result = 
      url: "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppContextSite(@target)/#{url}?@target='#{hostWebUrl}'" 
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

  jQuery: (url, hostWebUrl = null, payload = null, eTag = null) =>
    eTag = '*' if @method is 'DELETE'

    result = 
      url: if hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{url}?@target='#{hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{url}"
      type: @method
      contentType: ShareCoffee.REST.applicationType
      headers: 
        'Accept' : ShareCoffee.REST.applicationType
        'X-RequestDigest' : ShareCoffee.Commons.getFormDigest()
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : eTag
      data: if typeof payload is 'string' then payload else JSON.stringify(payload)

    if @method is 'GET'
      delete result.contentType
      delete result.headers['X-RequestDigest']
    
    delete result.headers['X-HTTP-Method'] unless @method is 'POST' and eTag?
    delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and eTag?)
    delete result.data unless @method is 'POST'
    result

  angularJS: (url, hostWebUrl = null, payload = null, eTag = null) =>
    eTag = '*' if @method is 'DELETE'

    result = 
      url: if hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{url}?@target='#{hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{url}"
      method: @method
      headers:
        'Accept' : ShareCoffee.REST.applicationType
        'Content-Type': ShareCoffee.REST.applicationType
        'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
        'X-HTTP-Method' : 'MERGE'
        'If-Match' : eTag
      data: if typeof payload is 'string' then payload else JSON.stringify(payload)

    if @method is 'GET'    
      delete result.headers['Content-Type']
      delete result.headers['X-RequestDigest']
    
    delete result.headers['X-HTTP-Method'] unless @method is 'POST' and eTag?
    delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and eTag?)
    delete result.data unless @method is 'POST'
    result
  
  reqwest: (url, hostWebUrl = null, payload = null, eTag=  null)=>
    eTag = '*' if @method is 'DELETE'
    result = null
    try
      result=
        url: if hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{url}?@target='#{hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{url}"
        method: @method.toLowerCase()
        contentType: ShareCoffee.REST.applicationType
        headers: 
          'Accept' : ShareCoffee.REST.applicationType
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
          'If-Match' : eTag
          'X-HTTP-Method' : 'MERGE'
        data: if payload? and typeof payload is 'object' then payload else JSON.parse(payload)

      if @method is 'GET'
        delete result.contentType
        delete result.headers['X-RequestDigest']

      delete result.headers['X-HTTP-Method'] unless @method is 'POST' and eTag?
      delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and eTag?)
      delete result.data unless @method is 'POST'
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
      for: new ShareCoffee.RESTFactory 'POST'
    delete: 
      for: new ShareCoffee.RESTFactory 'DELETE'

  @buildGetRequest = (url) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}", 
    type: "GET",
    headers:
      'Accept' : ShareCoffee.REST.applicationType

  @buildDeleteRequest = (url) ->
    url :"#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
    type: "DELETE",
    contentType: ShareCoffee.REST.applicationType,
    headers:
      'Accept': ShareCoffee.REST.applicationType,
      'If-Match': '*',
      'X-RequestDigest': ShareCoffee.Commons.getFormDigest()

  @buildUpdateRequest = (url, eTag, requestPayload) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
    type: 'POST',
    contentType: ShareCoffee.REST.applicationType,
    headers:
      'Accept' : ShareCoffee.REST.applicationType,
      'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
      'X-HTTP-Method': 'MERGE',
      'If-Match': eTag
    data: requestPayload

  @buildCreateRequest = (url, requestPayload) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
    type: 'POST',
    contentType: ShareCoffee.REST.applicationType,
    headers:
      'Accept': ShareCoffee.REST.applicationType,
      'X-RequestDigest' : ShareCoffee.Commons.getFormDigest()
    data: requestPayload
