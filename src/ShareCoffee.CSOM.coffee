root = window ? global
root.ShareCoffee or = {}
root.ShareCoffee.CSOM = class

  @getHostWeb = (appWebCtx, hostWebUrl) ->
    hostWebCtx = new SP.AppContextSite appWebCtx, hostWebUrl
    hostWebCtx.get_web()
