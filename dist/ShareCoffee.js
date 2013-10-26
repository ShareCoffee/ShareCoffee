(function() {
  var root,
    __slice = [].slice;

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.CSOM = (function() {
    function _Class() {}

    _Class.getHostWeb = function(appWebCtx, hostWebUrl) {
      var hostWebCtx;
      hostWebCtx = new SP.AppContextSite(appWebCtx, hostWebUrl);
      return hostWebCtx.get_web();
    };

    return _Class;

  })();

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.Commons = (function() {
    function _Class() {}

    _Class.getQueryString = function() {
      return document.URL.split("?")[1];
    };

    _Class.getQueryStringParameter = function(parameterName) {
      var p, parameterValue, params, _ref;
      params = document.URL.split("?")[1].split("&");
      parameterValue = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = params.length; _i < _len; _i++) {
          p = params[_i];
          if (p.split("=")[0] === parameterName) {
            _results.push(p.split("=")[1]);
          }
        }
        return _results;
      })();
      return (_ref = parameterValue[0]) != null ? _ref : '';
    };

    _Class.getAppWebUrl = function() {
      var appWebUrlFromQueryString;
      if (ShareCoffee.Commons.loadAppWebUrlFrom != null) {
        return ShareCoffee.Commons.loadAppWebUrlFrom();
      } else if ((typeof _spPageContextInfo !== "undefined" && _spPageContextInfo !== null) && (_spPageContextInfo.webAbsoluteUrl != null)) {
        return _spPageContextInfo.webAbsoluteUrl;
      }
      appWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter("SPAppWebUrl");
      if (appWebUrlFromQueryString) {
        return decodeURIComponent(appWebUrlFromQueryString);
      } else {
        if (console && console.error) {
          console.error("_spPageContextInfo is not defined");
        }
        return "";
      }
    };

    _Class.getHostWebUrl = function() {
      var hostWebUrlFromQueryString;
      hostWebUrlFromQueryString = ShareCoffee.Commons.getQueryStringParameter("SPHostUrl");
      if (ShareCoffee.Commons.loadHostWebUrlFrom != null) {
        return ShareCoffee.Commons.loadHostWebUrlFrom();
      }
      if (hostWebUrlFromQueryString) {
        return decodeURIComponent(hostWebUrlFromQueryString);
      } else {
        if (console && console.error) {
          console.error("SPHostUrl is not defined in the QueryString");
        }
        return "";
      }
    };

    _Class.getApiRootUrl = function() {
      return "" + (ShareCoffee.Commons.getAppWebUrl()) + "/_api/";
    };

    _Class.getFormDigest = function() {
      return document.getElementById('__REQUESTDIGEST').value;
    };

    return _Class;

  })();

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.Core = (function() {
    function _Class() {}

    _Class.getRequestInstance = function() {
      if (typeof XMLHttpRequest !== "undefined" && XMLHttpRequest !== null) {
        return new XMLHttpRequest();
      } else if (typeof ActiveXObject !== "undefined" && ActiveXObject !== null) {
        return new ActiveXObject('MsXml2.XmlHttp');
      }
    };

    _Class.loadScript = function(scriptUrl, onLoaded, onError) {
      var r,
        _this = this;
      r = ShareCoffee.Core.getRequestInstance();
      return r.onReadyStateChange = function() {
        var head, script;
        if (r.readyState === 4) {
          if (r.status === 200 || r.status === 304) {
            head = document.getElementsByTagName('head').item(0);
            script = document.createElement('script');
            script.language = 'javascript';
            script.type = 'text/javascript';
            script.defer = true;
            script.text = r.responseText;
            head.appendChild(script);
            if (onLoaded != null) {
              return onLoaded();
            }
          } else {
            if (onError != null) {
              return onError();
            }
          }
        }
      };
    };

    return _Class;

  })();

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.REST = (function() {
    function _Class() {}

    _Class.applicationType = "application/json;odata=verbose";

    _Class.buildGetRequest = function(url) {
      return {
        url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        type: "GET",
        headers: {
          'Accepts': ShareCoffee.REST.applicationType
        }
      };
    };

    _Class.buildDeleteRequest = function(url) {
      return {
        url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        type: "DELETE",
        contentType: ShareCoffee.REST.applicationType,
        headers: {
          'Accept': ShareCoffee.REST.applicationType,
          'If-Match': '*',
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
        }
      };
    };

    _Class.buildUpdateRequest = function(url, eTag, requestPayload) {
      return {
        url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        type: 'POST',
        contentType: ShareCoffee.REST.applicationType,
        headers: {
          'Accept': ShareCoffee.REST.applicationType,
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
          'X-HTTP-Method': 'MERGE',
          'If-Match': eTag
        },
        data: requestPayload
      };
    };

    _Class.buildCreateRequest = function(url, requestPayload) {
      return {
        url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        type: 'POST',
        contentType: ShareCoffee.REST.applicationType,
        headers: {
          'Accept': ShareCoffee.REST.applicationType,
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
        },
        data: requestPayload
      };
    };

    return _Class;

  })();

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.SettingsLink = function(url, title, appendQueryStringToUrl) {
    if (appendQueryStringToUrl == null) {
      appendQueryStringToUrl = false;
    }
    return {
      linkUrl: appendQueryStringToUrl ? "" + url + "?" + (ShareCoffee.Commons.getQueryString()) : url,
      displayName: title
    };
  };

  root.ShareCoffee.ChromeSettings = function() {
    var helpPageUrl, iconUrl, settingsLinkSplat, tite;
    iconUrl = arguments[0], tite = arguments[1], helpPageUrl = arguments[2], settingsLinkSplat = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
    return {
      appIconUrl: iconUrl,
      appTitle: title,
      appHelpPageUrl: helpPageUrl,
      settingsLinks: settingsLinkSplat
    };
  };

  root.ShareCoffee.UI = (function() {
    function _Class() {}

    _Class.showNotification = function(message, isSticky) {
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Notify == null)) {
        console.error("SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Notify != null) && (SP.UI.Notify.addNotification != null)) {
        return SP.UI.Notify.addNotification(message, isSticky);
      }
    };

    _Class.removeNotification = function(notificationId) {
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Notify == null)) {
        console.error("SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Notify != null) && (SP.UI.Notify.removeNotification != null) && (notificationId != null)) {
        return SP.UI.Notify.removeNotification(notificationId);
      }
    };

    _Class.showStatus = function(title, contentAsHtml, showOnTop, color) {
      var statusId;
      if (color == null) {
        color = 'blue';
      }
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Status == null)) {
        console.error("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.addStatus != null) && (SP.UI.Status.setStatusPriColor != null)) {
        statusId = SP.UI.Status.addStatus(title, contentAsHtml, showOnTop);
        SP.UI.Status.setStatusPriColor(statusId, color);
        return statusId;
      }
    };

    _Class.removeStatus = function(statusId) {
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Status == null)) {
        console.error("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.removeStatus != null) && (statusId != null)) {
        return SP.UI.Status.removeStatus(statusId);
      }
    };

    _Class.removeAllStatus = function() {
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Status == null)) {
        console.error("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.removeAllStatus != null)) {
        return SP.UI.Status.removeAllStatus();
      }
    };

    _Class.setColor = function(statusId, color) {
      if (color == null) {
        color = 'blue';
      }
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Status == null)) {
        console.error("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.setStatusPriColor != null) && (statusId != null)) {
        return SP.UI.Status.setStatusPriColor(statusId, color);
      }
    };

    _Class.onChromeLoadedCallback = null;

    _Class.loadAppChrome = function(placeHolderId, chromeSettings, onAppChromeLoaded) {
      var onScriptLoaded, scriptUrl,
        _this = this;
      if (onAppChromeLoaded == null) {
        onAppChromeLoaded = void 0;
      }
      if (onAppChromeLoaded != null) {
        ShareCoffee.UI.onChromeLoadedCallback = onAppChromeLoaded;
        chromeSettings.onCssLoaded = "ShareCoffee.UI.onChromeLoadedCallback()";
      }
      onScriptLoaded = function() {
        var chrome;
        chrome = new SP.UI.Controls.Navigation(placeHolderId, chromeSettings);
        return chrome.setVisible(true);
      };
      scriptUrl = "" + (ShareCoffee.Commons.getHostWebUrl()) + "/_layouts/15/SP.UI.Controls.js";
      return ShareCoffee.Core.loadScript(scriptUrl, onScriptLoaded, function() {
        throw "Error loading SP.UI.Controls.js";
      });
    };

    return _Class;

  })();

}).call(this);

/*
//@ sourceMappingURL=ShareCoffee.js.map
*/