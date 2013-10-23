root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.Commons or = {}
root.ShareCoffee.Commons.applicationType = "application/json;odata=verbose"

root.ShareCoffee.Commons.getQueryStringParameter = (parameterName) ->
  params = document.URL.split("?")[1].split("&")
  parameterValue = (p.split("=")[1] for p in params when p.split("=")[0] is parameterName)
  parameterValue[0] ? ''

root.ShareCoffee.Commons.getAppWebUrl = () ->
  if(_spPageContextInfo)
    _spPageContextInfo.webAbsoluteUrl
  else
    console.error "_spPageContextInfo is not defined" if console and console.error
    ""
root.ShareCoffee.Commons.getApiRootUrl = () ->
  "#{ShareCoffee.Commons.getAppWebUrl()}/_api/"

root.ShareCoffee.Commons.getFormDigest = () ->
  document.getElementById('__REQUESTDIGEST').value


root.ShareCoffee.Commons.buildGetRequest = (url) ->
  url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}", 
  type: "GET",
  headers:
    'Accepts' : ShareCoffee.Commons.applicationType

root.ShareCoffee.Commons.buildDeleteRequest = (url) ->
  url :"#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
  type: "DELETE",
  contentType: ShareCoffee.Commons.applicationType,
  headers:
    'Accept': ShareCoffee.Commons.applicationType,
    'If-Match': '*',
    'X-RequestDigest': ShareCoffee.Commons.getFormDigest()

root.ShareCoffee.Commons.buildUpdateRequest = (url, eTag, requestPayload) ->
  url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
  type: 'POST',
  contentType: ShareCoffee.Commons.applicationType,
  headers:
    'Accept' : ShareCoffee.Commons.applicationType,
    'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
    'X-HTTP-Method': 'MERGE',
    'If-Match': eTag
  data: requestPayload

root.ShareCoffee.Commons.buildCreateRequest = (url, requestPayload) ->
  url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}",
  type: 'POST',
  contentType: ShareCoffee.Commons.applicationType,
  headers:
    'Accept': ShareCoffee.Commons.applicationType,
    'X-RequestDigest' : ShareCoffee.Commons.getFormDigest()
  data: requestPayload
