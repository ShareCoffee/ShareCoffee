root = global ? window

root.ShareCoffee or = {}

root.ShareCoffee.Core = class
  
  @checkConditions = (errorMessage, condition) ->
    if condition() is false
      console.error errorMessage if console and console.error
      throw errorMessage

  @getRequestInstance = () ->
    if XMLHttpRequest?
      new XMLHttpRequest()
    else if ActiveXObject?
      new ActiveXObject('MsXml2.XmlHttp')

  @loadScript = (scriptUrl, onLoaded, onError) ->
    r = ShareCoffee.Core.getRequestInstance()
    r.onReadyStateChange = () =>
      if r.readyState is 4
        if r.status is 200 || r.status is 304
          head = document.getElementsByTagName('head').item(0)
          script = document.createElement 'script'
          script.language = 'javascript'
          script.type = 'text/javascript'
          script.defer = true
          script.text = r.responseText
          head.appendChild script
          onLoaded() if onLoaded?
        else
          onError() if onError?
    r.open 'GET', scriptUrl, true
    r.send()
