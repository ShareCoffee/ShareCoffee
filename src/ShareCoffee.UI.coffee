root = window ? global

root.ShareCoffee or = {}
root.ShareCoffee.UI = class
  
  @showNotification = (message, isSticky) ->
    console.error "SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)" if not SP? or not SP.UI? or not SP.UI.Notify? 
    if SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.addNotification?
      SP.UI.Notify.addNotification message, isSticky

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

    
