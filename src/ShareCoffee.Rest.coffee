root = window ? global
root.ShareCoffee or = {}

root.ShareCoffee.RESTFactory = class
  constructor: (@method, @updateQuery = false) ->

  jQuery: (url, hostWebUrl = null, payload = null, eTag = null) =>
    eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not eTag?)
    

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
    eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not eTag?)

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
  
  reqwest: (url, onSuccess = null, onError = null, hostWebUrl = null, payload = null, eTag=  null)=>
    eTag = '*' if @method is 'DELETE' or (@updateQuery is on and not eTag?)
    result = null
    try
      result=
        url: if hostWebUrl? then "#{ShareCoffee.Commons.getApiRootUrl()}SP.AppSiteContext(@target)/#{url}?@target='#{hostWebUrl}'" else "#{ShareCoffee.Commons.getApiRootUrl()}#{url}"
        type: 'json'
        method: @method.toLowerCase()
        contentType: ShareCoffee.REST.applicationType
        headers: 
          'Accept' : ShareCoffee.REST.applicationType
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
          'If-Match' : eTag
          'X-HTTP-Method' : 'MERGE'
        data: if payload? and typeof payload is 'object' then payload else JSON.parse(payload)
        success: onSuccess
        error: onError


      if @method is 'GET'
        delete result.contentType
        delete result.headers['X-RequestDigest']

      delete result.headers['X-HTTP-Method'] unless @method is 'POST' and eTag?
      delete result.headers['If-Match'] unless @method is 'DELETE' or (@method is 'POST' and eTag?)
      delete result.data unless @method is 'POST'
      delete result.success unless onSuccess?
      delete result.error unless onError?

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
