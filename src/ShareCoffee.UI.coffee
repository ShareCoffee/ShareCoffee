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
  # The removeNotification function will remove a notification from the current page. If any of the required SharePoint libraries is not loaded, an error is displayed within the browser console
  #
  # ### Parameter
  #   * [int] notificationId - The notification's id that should be removed from the page
  @removeNotification = (notificationId) ->
    return unless notificationId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.removeNotification?

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition
    SP.UI.Notify.removeNotification notificationId

  # ##showStatus
  # The showStatus method is used to display a status message on the current page. If any of the required SharePoint scripts isn't loaded, an error will be logged to the browsers console
  #
  # ### Parameter
  #   * [String] title - The title of the status
  #   * [String] contentAsHtml - Content of the status (supports HTML)
  #   * [bool] showOnTp - determines if the status should appear on top (defaults to false)
  #   * [String] color - sets the color of the status message (defaults to blue)
  #
  # ### ReturnValue
  # Returns the status' Id
  @showStatus = (title, contentAsHtml, showOnTop = false, color = 'blue') ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.addStatus? and SP.UI.Status.setStatusPriColor?
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    statusId = SP.UI.Status.addStatus title, contentAsHtml, showOnTop
    SP.UI.Status.setStatusPriColor statusId, color
    statusId

  # ##removeStatus
  # This method is used to remove an existing status from the current page
  #
  # ### Parameter
  #   * [int] statusId - Id of the status message which should be removed from the page
  @removeStatus = (statusId) ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeStatus? 
    
    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeStatus statusId

  # ##removeAllStatus
  # This method is used to remove all status messages from the current page
  @removeAllStatus = () ->
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.removeAllStatus? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.removeAllStatus()

  # ##setStatusColor
  # The setStatusColor function is used to change the color of an existing status message.
  #
  # ### Parameter
  #  * [int] statusId - Id of the status message you want to colorize
  #  * [String] color - The new color value for the status message (defaults to blue)
  @setStatusColor = (statusId, color='blue') ->
    return unless statusId?
    condition = () ->
      SP? and SP.UI? and SP.UI.Status? and SP.UI.Status.setStatusPriColor? 

    ShareCoffee.Core.checkConditions "SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition
    SP.UI.Status.setStatusPriColor statusId, color


  @onChromeLoadedCallback = null
  
  # ##loadAppChrome
  # The loadAppChrome method will load all required scripts from SharePoint or Office365 and display the App-Chrome-Bar
  # If you're developing Cloud-Hosted Apps for SharePoint you should consider including the AppChromeBar. Users recognize that they are still in the context of SharePoint/Office365 and they can easily navigate back to their entry point.
  #
  # ### Parameters
  #   * [String] placeHolderId - The ChromeBar requires an DIV element where the Chrome will be displayed. Provide the id from the div here
  #   * [Object] chromeSettings - Either provide an instance of ShareCoffee.ChromeSettings or an JSON object which defines the options for the AppChromeBar
  #   * [function] onAppChromeLoaded - Provide a callback which will be executed as soon as the ChromeBar is loaded
  #
  # ### Throws
  # Throws an exception if the SP.UI.Controls.js file can't be loaded from SharePoint/Office365
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
    

