# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.Commons
# This class offers different helper functions which makes your life as App-Dev easier
root.ShareCoffee.Commons = class 

  # ##getQueryString
  # getQueryString returns the entire QueryString from the current document's URL
  # 
  # ### ReturnValue
  # The entire QueryString
  @getQueryString = () ->
    document.URL.split("?")[1]

  # ##getQueryStringParameter
  # getQueryStringParameter returns a single parameter value from the current document's QueryString
  # 
  # ### Parameters
  #   * [String] parameterName - The name of the parameter
  # 
  # ### ReturnValue
  # Returns the value of the parameter, if no parameter is found by the name, an empty string is returned
  @getQueryStringParameter = (parameterName) ->
    params = document.URL.split("?")[1].split("&")
    parameterValue = (p.split("=")[1] for p in params when p.split("=")[0] is parameterName)
    parameterValue[0] ? ''

  # ##getAppWebUrl
  # getAppWebUrl will return the AppWebUrl. if a custom load method is associated to 
  # **ShareCoffee.Commons.loadAppWebUrlFrom** only this injected method will be executed
  # in all other cases getAppWebUrl will first try to get the AppWebUrl from **_spPageContextInfo** 
  # if this object isn't present the method looks inside of the **QueryString**
  #
  # ### ReturnValue
  # Returns the current AppWebUrl or returns an empty String if no method contains a value
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

  # ##getHostWebUrl
  # getHostWebUrl will return the HostWebURl. If a custom load method is associated to
  # **ShareCoffee.Commons.loadHostWebUrlFrom** only this injected method will be executed
  # in all other cases getHostWebUrl looks inside of the QueryString for SPHostUrl parameter
  #
  # ### ReturnValue
  # Returns the current HostWebUrl or returns an empty string if neither custom load method associated nor QueryString parameter is present
  @getHostWebUrl = () ->
    if ShareCoffee.Commons.loadHostWebUrlFrom?
      return ShareCoffee.Commons.loadHostWebUrlFrom()
    
    hostWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter "SPHostUrl"
    if hostWebUrlFromQueryString
      return decodeURIComponent hostWebUrlFromQueryString
    else
      console.error "SPHostUrl is not defined in the QueryString" if console and console.error
      return ""

  # ##getApiRootUrl
  # getApiRootUrl will return the the root path to SharePoint's REST endpoint {AppWebUrl}/_api/
  #
  # ### ReturnValue
  # REST API entrypoint {AppWebUrl}/_api/
  @getApiRootUrl = () ->
    "#{ShareCoffee.Commons.getAppWebUrl()}/_api/"

  # ##getFormDigest
  # getFormDigest returns the Form Digest Control value using plain old JavaScript instead of relying on jQuery
  #
  # ### ReturnValue
  # Form Digest's value
  @getFormDigest = () ->
    document.getElementById('__REQUESTDIGEST').value
