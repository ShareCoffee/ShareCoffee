root = window ? global

root.ShareCoffee or = {}
root.ShareCoffee.SettingsLink = (url, title, appendQueryStringToUrl = false) ->
  linkUrl: if appendQueryStringToUrl then "#{url}?#{ShareCoffee.Commons.getQueryString()}" else url
  displayName: title 
root.ShareCoffee.ChromeSettings = (iconUrl, tite,helpPageUrl, settingsLinkSplat...) ->
  appIconUrl: iconUrl
  appTitle: title
  appHelpPageUrl: helpPageUrl
  settingsLinks: settingsLinkSplat
root.ShareCoffee.UI = class
  
  @showNotification = (message, isSticky) ->
    console.error "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Notify? 
    if SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.addNotification?
      SP.UI.Notify.addNotification message, isSticky

  @removeNotification = (notificationId) ->
    console.error "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Notify? 
    if SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.removeNotification? and notificationId?
      SP.UI.Notify.removeNotification notificationId

  @showStatus = (title, contentAsHtml, showOnTop, color = 'blue') ->
    console.error "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Status?
    if SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.addStatus? and SP.UI.Status.setStatusPriColor?
      statusId = SP.UI.Status.addStatus title, contentAsHtml, showOnTop
      SP.UI.Status.setStatusPriColor statusId, color
      statusId

  @removeStatus = (statusId) ->
    console.error "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Status?
    if SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeStatus? and statusId?
      SP.UI.Status.removeStatus statusId

  @removeAllStatus = () ->
    console.error "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Status?
    if SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeAllStatus?
      SP.UI.Status.removeAllStatus()

  @setColor = (statusId, color='blue') ->
    console.error "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Status?
    if SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.setStatusPriColor? and statusId?
      SP.UI.Status.setStatusPriColor statusId, color

  @onChromeLoadedCallback = null

  @loadAppChrome = (placeHolderId, chromeSettings, onAppChromeLoaded = undefined) ->
    if onAppChromeLoaded?
      ShareCoffee.UI.onChromeLoadedCallback = onAppChromeLoaded
      chromeSettings.onCssLoaded = "ShareCoffee.UI.onChromeLoadedCallback()"

    onScriptLoaded = () =>
      chrome = new SP.UI.Controls.Navigation placeHolderId, chromeSettings
      chrome.setVisible true

    scriptUrl = "#{ShareCoffee.Commons.getHostWebUrl()}/_layouts/15/SP.UI.Controls.js"

    ShareCoffee.Core.loadScript scriptUrl, onScriptLoaded, ()->
      throw "Error loading SP.UI.Controls.js"
    

