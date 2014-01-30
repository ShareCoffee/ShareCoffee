# Node.JS doesn't offer window...
root = global ? window

# ensure the core namespace
root.ShareCoffee or = {}

# ##ShareCoffee.Core
# This class is used internally because these methods are used more frequently within the entire project
root.ShareCoffee.Core = class

  # ##checkConditions
  # checkConditions evaluates the method provided as 2nd parameter and throw's an error as far as the return value is false.
  #
  # ### Parameters
  #  * [String] errorMessage - the error message which will be logged and thrown
  #  * [function] condition - the condition which will be evaluated
  #
  @checkConditions = (errorMessage, condition) ->
    if condition() is false
      console.error errorMessage if console and console.error
      throw errorMessage

  # ##loadScript
  # loadScript loads JavaScript resources from any url and adds it to the current <head> tag.
  #
  # ### Parameters
  #   * [String] scriptUrl - The script's location
  #   * [function] onLoaded - Callback which will be executed as soon as the script is loaded
  #   * [function] onError - Callback which will be invoked as soon as the script loading failes
  #
  @loadScript = (scriptUrl, onLoaded, onError) ->
    s = document.createElement 'script'
    head = document.getElementsByTagName('head').item(0)
    s.type = 'text/javascript'
    s.async = true
    s.src = scriptUrl
    s.onload = onLoaded
    s.onerror = onError
    head.appendChild(s)

# shorthand for ShareCoffee
root.$s = root.ShareCoffee unless root.$s?
