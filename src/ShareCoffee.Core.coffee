root = global ? window

root.ShareCoffee or = {}

root.ShareCoffee.Core = class
  
  @checkConditions = (errorMessage, condition) ->
    if condition() is false
      console.error errorMessage if console and console.error
      throw errorMessage

  @loadScript = (scriptUrl, onLoaded, onError) ->
    s = document.createElement 'script'
    head = document.getElementsByTagName('head').item(0)
    s.type = 'text/javascript'
    s.async = true
    s.src = scriptUrl
    s.onload = onLoaded
    s.onerror = onError
    head.appendChild(s)

