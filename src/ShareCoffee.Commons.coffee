root = window ? global

root.ShareCoffee or = {}
root.ShareCoffee.Commons or = {}

root.ShareCoffee.Commons.getAppWebUrl = () ->
  if(_spPageContextInfo)
    _spPageContextInfo.webAbsoluteUrl
  else
    console.error "_spPageContextInfo is not defined" if console and console.error
    ""
root.ShareCoffee.Commons.getApiRootUrl = () ->
  "#{ShareCoffee.Commons.getAppWebUrl()}/_api/"

root.ShareCoffee.Commons.buildGetRequest = (url) ->
  url: "#{ShareCoffee.Commons.getApiRootUrl()}#{url}", 
  type: "GET",
  headers:
    'Accepts' : 'application/json;odata=verbose'
