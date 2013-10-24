root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.Rest = class 

  @applicationType = "application/json;odata=verbose"
  @buildGetRequest = (url) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}", 
    type: "GET",
    headers:
      'Accepts' : ShareCoffee.Rest.applicationType

  @buildDeleteRequest = (url) ->
    url :"#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
    type: "DELETE",
    contentType: ShareCoffee.Rest.applicationType,
    headers:
      'Accept': ShareCoffee.Rest.applicationType,
      'If-Match': '*',
      'X-RequestDigest': ShareCoffee.Commons.getFormDigest()

  @buildUpdateRequest = (url, eTag, requestPayload) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
    type: 'POST',
    contentType: ShareCoffee.Rest.applicationType,
    headers:
      'Accept' : ShareCoffee.Rest.applicationType,
      'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
      'X-HTTP-Method': 'MERGE',
      'If-Match': eTag
    data: requestPayload

  @buildCreateRequest = (url, requestPayload) ->
    url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
    type: 'POST',
    contentType: ShareCoffee.Rest.applicationType,
    headers:
      'Accept': ShareCoffee.Rest.applicationType,
      'X-RequestDigest' : ShareCoffee.Commons.getFormDigest()
    data: requestPayload
