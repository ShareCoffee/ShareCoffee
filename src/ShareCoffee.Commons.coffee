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
