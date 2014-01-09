# Node.JS doesn't offer window... 
root = window ? global

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.CSOM
# The ShareCoffee.CSOM class is providing functionality which can be used when working with the SharePoint's CSOM
# **Important** These methods are designed to use in non CrossDomain scenarios
root.ShareCoffee.CSOM = class
  
  # ##getHostWeb
  # getHost web uses the SP.AppContextSite in order to receive the SPHostWeb requested by it's url
  #
  # ### Parameters
  #   * [Object] appWebCtx - The current AppWeb Context
  #   * [String] hostWebUrl - The HostWebUrl you're looking for
  #
  # ### Return Value
  # getHostWeb returns the suggested HostWeb Context
  @getHostWeb = (appWebCtx, hostWebUrl) ->
    hostWebCtx = new SP.AppContextSite appWebCtx, hostWebUrl
    hostWebCtx.get_web()

