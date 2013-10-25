root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.Commons = class 

  @getQueryStringParameter = (parameterName) ->
    params = document.URL.split("?")[1].split("&")
    parameterValue = (p.split("=")[1] for p in params when p.split("=")[0] is parameterName)
    parameterValue[0] ? ''

  @getAppWebUrl = () ->
    if ShareCoffee.Commons.loadAppWebUrlFrom?
      return ShareCoffee.Commons.loadAppWebUrlFrom()
    else if _spPageContextInfo? && _spPageContextInfo.webAbsoluteUrl?
      return _spPageContextInfo.webAbsoluteUrl

    appWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter "SPAppWebUrl"
    if appWebUrlFromQueryString
      return decodeURIComponent appWebUrlFromQueryString
    else
      console.error "_spPageContextInfo is not defined" if console and console.error
      return ""

  @getHostWebUrl = () ->
    hostWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter "SPHostUrl"
    if ShareCoffee.Commons.loadHostWebUrlFrom?
      return ShareCoffee.Commons.loadHostWebUrlFrom()
    if hostWebUrlFromQueryString
      return decodeURIComponent hostWebUrlFromQueryString
    else
      console.error "SPHostUrl is not defined in the QueryString" if console and console.error
      return ""

  @getApiRootUrl = () ->
    "#{ShareCoffee.Commons.getAppWebUrl()}/_api/"

  @getFormDigest = () ->
    document.getElementById('__REQUESTDIGEST').value
