root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.REST = class 

  @applicationType = "application/json;odata=verbose"

  @loadCrossDomainLibrary = (onSuccess, onError) ->
    scriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.RequestExecutor.js"
    ShareCoffee.Core.loadScript scriptUrl, onSuccess, onError

  @buildGetRequest = (url) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}", 
    type: "GET",
    headers:
      'Accepts' : ShareCoffee.REST.applicationType

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
