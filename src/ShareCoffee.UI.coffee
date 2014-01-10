# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.SettingsLink
# Create a new instance of ShareCoffee.SettingsLink which can be placed inside of the App-ChromeBar
#
# ### Parameters
#   * [String] url - the target url for the settings link
#   * [String] title - visual representation for the settings link
#   * [bool] appendQueryStringToUrl - determines if the entire QueryString should be appended to the url
#
# ### ReturnValue
# Returns a configured instance of ShareCoffee.SettingsLink
root.ShareCoffee.SettingsLink = (url, title, appendQueryStringToUrl = false) ->
  linkUrl: if appendQueryStringToUrl then "#{url}?#{ShareCoffee.Commons.getQueryString()}" else url
  displayName: title 

# ##ShareCoffee.ChromeSettings
# An instance of ShareCoffee.ChromeSettings is used to configure the entire App-ChromeBar.
#
# ### Parameters
#   * [String] iconUrl - URL to the AppIcon
#   * [String] title - Title of your App
#   * [String] helpPageUrl - optinal URL which points to your App's help page
#   * [SettingsLinks] settingsLinkSplat - You can pass as many SettingsLink instances as you want to
root.ShareCoffee.ChromeSettings = (iconUrl, title,helpPageUrl, settingsLinkSplat...) ->
  appIconUrl: iconUrl
  appTitle: title
  appHelpPageUrl: helpPageUrl
  settingsLinks: settingsLinkSplat

# ##ShareCoffee.UI
# This class capsulates all SharePoint UI interactions
root.ShareCoffee.UI = class
  
  # ##showNotification
  # The showNotification method provides an wrapper for SharePoint's SP.UI.Notify API. On top of just calling SharePoint's API, 
  # showNotification checks if all required objects are available. If not, an error will be logged to the JS Console.
  #
  # ### Parameters
  #   * [String] message - The message you'd like to display
  #   * [bool] isSticky - Determines if the message should stuck on the page or if it should disappear after a few seconds
  #
  # ### ReturnValue
  # showNotification returns an NotificationId, which can be used to manually remove the notification later using the removeNotification function
  @showNotification = (message, isSticky = false) ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.addNotification?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.addNotification message, isSticky

  # ##removeNotification
  # The removeNotification will remove a notification from the current page. If any of the required SharePoint libraries is not loaded, an error is displayed within the browser console
  #
  # ### Parameter
  #   * [int] notificationId - The notification's id that should be removed from the page
  @removeNotification = (notificationId) ->
    return unless notificationId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.removeNotification?

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.removeNotification notificationId

  @showStatus = (title, contentAsHtml, showOnTop = false, color = 'blue') ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.addStatus? and SP.UI.Status.setStatusPriColor?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    statusId = SP.UI.Status.addStatus title, contentAsHtml, showOnTop
    SP.UI.Status.setStatusPriColor statusId, color
    statusId

  @removeStatus = (statusId) ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeStatus? 
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeStatus statusId

  @removeAllStatus = () ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeAllStatus? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeAllStatus()

  @setStatusColor = (statusId, color='blue') ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.setStatusPriColor? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
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
    

