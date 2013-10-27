root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.CrossDomain = class 
  
  @loadCrossDomainLibrary = (onSuccess, onError) ->
    scriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.RequestExecutor.js"
    ShareCoffee.Core.loadScript scriptUrl, onSuccess, onError
