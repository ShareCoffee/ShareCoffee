root = window ? global

root.ShareCoffee or = {}
root.ShareCoffee.Commons or = {}
root.ShareCoffee.Commons.UI or = {}

root.ShareCoffee.Commons.UI.showNotification = (message, isSticky) ->
  console.error "SP.UI or SP.UI.Notify is not loaded" if not SP? or not SP.UI? or not SP.UI.Notify? 
  if SP? and SP.UI? and SP.UI.Notify? and SP.UI.Notify.addNotification
    SP.UI.Notify.addNotification message, isSticky
