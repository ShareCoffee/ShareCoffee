/*
ShareCoffee (c) 2013 Thorsten Hans 
| dotnet-rocks.com | https://github.com/ThorstenHans/ShareCoffee/ | under MIT License |
*/


(function() {
  var root,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
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

    _Class.checkConditions = function(errorMessage, condition) {
      if (condition() === false) {
        if (console && console.error) {
          console.error(errorMessage);
        }
        throw errorMessage;
      }
    };

    _Class.loadScript = function(scriptUrl, onLoaded, onError) {
      var head, s;
      s = document.createElement('script');
      head = document.getElementsByTagName('head').item(0);
      s.type = 'text/javascript';
      s.async = true;
      s.src = scriptUrl;
      s.onload = onLoaded;
      s.onerror = onError;
      return head.appendChild(s);
    };

    return _Class;

  })();

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.CrossDomainRESTFactory = (function() {
    function _Class(method) {
      this.method = method;
      this.SPCrossDomainLib = __bind(this.SPCrossDomainLib, this);
    }

    _Class.prototype.SPCrossDomainLib = function(url, hostWebUrl, onSuccess, onError, payload, eTag) {
      var result;
      if (hostWebUrl == null) {
        hostWebUrl = null;
      }
      if (onSuccess == null) {
        onSuccess = null;
      }
      if (onError == null) {
        onError = null;
      }
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (ShareCoffee.CrossDomain.crossDomainLibrariesLoaded === false) {
        throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the CrossDomain REST libraries';
      }
      if (this.method === 'DELETE') {
        eTag = '*';
      }
      result = {
        url: hostWebUrl != null ? "" + (ShareCoffee.Commons.getApiRootUrl()) + "SP.AppContextSite(@target)/" + url + "?@target='" + hostWebUrl + "'" : "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        method: this.method,
        success: onSuccess,
        error: onError,
        headers: {
          'Accept': ShareCoffee.REST.applicationType,
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
          'Content-Type': ShareCoffee.REST.applicationType,
          'X-HTTP-Method': 'MERGE',
          'If-Match': eTag
        },
        body: typeof payload === 'string' ? payload : JSON.stringify(payload)
      };
      if (this.method === 'GET') {
        delete result.headers['X-RequestDigest'];
        delete result.headers['Content-Type'];
      }
      if (!(this.method === 'POST' && (eTag != null))) {
        delete result.headers['X-HTTP-Method'];
      }
      if (!(this.method === 'DELETE' || (this.method === 'POST' && (eTag != null)))) {
        delete result.headers['If-Match'];
      }
      if (onSuccess == null) {
        delete result.success;
      }
      if (onError == null) {
        delete result.error;
      }
      if (this.method !== 'POST') {
        delete result.body;
      }
      return result;
    };

    return _Class;

  })();

  root.ShareCoffee.CrossDomain = (function() {
    function _Class() {}

    _Class.crossDomainLibrariesLoaded = false;

    _Class.loadCrossDomainLibrary = function(onSuccess, onError) {
      var onAnyError, requestExecutorScriptUrl, runtimeScriptUrl, spScriptUrl,
        _this = this;
      onAnyError = function() {
        ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false;
        if (onError) {
          return onError();
        }
      };
      runtimeScriptUrl = "" + (ShareCoffee.Commons.getHostWebUrl()) + "/_layouts/15/SP.Runtime.js";
      spScriptUrl = "" + (ShareCoffee.Commons.getHostWebUrl()) + "/_layouts/15/SP.js";
      requestExecutorScriptUrl = "" + (ShareCoffee.Commons.getHostWebUrl()) + "/_layouts/15/SP.RequestExecutor.js";
      return ShareCoffee.Core.loadScript(runtimeScriptUrl, function() {
        return ShareCoffee.Core.loadScript(spScriptUrl, function() {
          return ShareCoffee.Core.loadScript(requestExecutorScriptUrl, function() {
            ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true;
            if (onSuccess) {
              return onSuccess();
            }
          }, onAnyError);
        }, onAnyError);
      }, onAnyError);
    };

    _Class.build = {
      create: {
        "for": new ShareCoffee.CrossDomainRESTFactory('POST')
      },
      read: {
        "for": new ShareCoffee.CrossDomainRESTFactory('GET')
      },
      update: {
        "for": new ShareCoffee.CrossDomainRESTFactory('POST')
      },
      "delete": {
        "for": new ShareCoffee.CrossDomainRESTFactory('DELETE')
      }
    };

    _Class.getClientContext = function() {
      var appWebUrl, ctx, factory;
      if (ShareCoffee.CrossDomain.crossDomainLibrariesLoaded === false) {
        throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext';
      }
      appWebUrl = ShareCoffee.Commons.getAppWebUrl();
      ctx = new SP.ClientContext(appWebUrl);
      factory = new SP.ProxyWebRequestExecutorFactory(appWebUrl);
      ctx.set_webRequestExecutorFactory(factory);
      return ctx;
    };

    _Class.getHostWeb = function(ctx, hostWebUrl) {
      var appContextSite;
      if (hostWebUrl == null) {
        hostWebUrl = ShareCoffee.Commons.getHostWebUrl();
      }
      if (ShareCoffee.CrossDomain.crossDomainLibrariesLoaded === false) {
        throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext';
      }
      if (ctx == null) {
        throw 'ClientContext cant be null, call ShareCoffee.CrossDomain.getClientContext() first';
      }
      appContextSite = new SP.AppContextSite(ctx, hostWebUrl);
      return appContextSite.get_web();
    };

    return _Class;

  })();

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.RESTFactory = (function() {
    function _Class(method, updateQuery) {
      this.method = method;
      this.updateQuery = updateQuery != null ? updateQuery : false;
      this.reqwest = __bind(this.reqwest, this);
      this.angularJS = __bind(this.angularJS, this);
      this.jQuery = __bind(this.jQuery, this);
    }

    _Class.prototype.jQuery = function(url, hostWebUrl, payload, eTag) {
      var result;
      if (hostWebUrl == null) {
        hostWebUrl = null;
      }
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (this.method === 'DELETE' || (this.updateQuery === true && (eTag == null))) {
        eTag = '*';
      }
      result = {
        url: hostWebUrl != null ? "" + (ShareCoffee.Commons.getApiRootUrl()) + "SP.AppSiteContext(@target)/" + url + "?@target='" + hostWebUrl + "'" : "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        type: this.method,
        contentType: ShareCoffee.REST.applicationType,
        headers: {
          'Accept': ShareCoffee.REST.applicationType,
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
          'X-HTTP-Method': 'MERGE',
          'If-Match': eTag
        },
        data: typeof payload === 'string' ? payload : JSON.stringify(payload)
      };
      if (this.method === 'GET') {
        delete result.contentType;
        delete result.headers['X-RequestDigest'];
      }
      if (!(this.method === 'POST' && (eTag != null))) {
        delete result.headers['X-HTTP-Method'];
      }
      if (!(this.method === 'DELETE' || (this.method === 'POST' && (eTag != null)))) {
        delete result.headers['If-Match'];
      }
      if (this.method !== 'POST') {
        delete result.data;
      }
      return result;
    };

    _Class.prototype.angularJS = function(url, hostWebUrl, payload, eTag) {
      var result;
      if (hostWebUrl == null) {
        hostWebUrl = null;
      }
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (this.method === 'DELETE' || (this.updateQuery === true && (eTag == null))) {
        eTag = '*';
      }
      result = {
        url: hostWebUrl != null ? "" + (ShareCoffee.Commons.getApiRootUrl()) + "SP.AppSiteContext(@target)/" + url + "?@target='" + hostWebUrl + "'" : "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
        method: this.method,
        headers: {
          'Accept': ShareCoffee.REST.applicationType,
          'Content-Type': ShareCoffee.REST.applicationType,
          'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
          'X-HTTP-Method': 'MERGE',
          'If-Match': eTag
        },
        data: typeof payload === 'string' ? payload : JSON.stringify(payload)
      };
      if (this.method === 'GET') {
        delete result.headers['Content-Type'];
        delete result.headers['X-RequestDigest'];
      }
      if (!(this.method === 'POST' && (eTag != null))) {
        delete result.headers['X-HTTP-Method'];
      }
      if (!(this.method === 'DELETE' || (this.method === 'POST' && (eTag != null)))) {
        delete result.headers['If-Match'];
      }
      if (this.method !== 'POST') {
        delete result.data;
      }
      return result;
    };

    _Class.prototype.reqwest = function(url, onSuccess, onError, hostWebUrl, payload, eTag) {
      var Error, result;
      if (onSuccess == null) {
        onSuccess = null;
      }
      if (onError == null) {
        onError = null;
      }
      if (hostWebUrl == null) {
        hostWebUrl = null;
      }
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (this.method === 'DELETE' || (this.updateQuery === true && (eTag == null))) {
        eTag = '*';
      }
      result = null;
      try {
        result = {
          url: hostWebUrl != null ? "" + (ShareCoffee.Commons.getApiRootUrl()) + "SP.AppSiteContext(@target)/" + url + "?@target='" + hostWebUrl + "'" : "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
          type: 'json',
          method: this.method.toLowerCase(),
          contentType: ShareCoffee.REST.applicationType,
          headers: {
            'Accept': ShareCoffee.REST.applicationType,
            'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
            'If-Match': eTag,
            'X-HTTP-Method': 'MERGE'
          },
          data: (payload != null) && typeof payload === 'string' ? payload : JSON.stringify(payload),
          success: onSuccess,
          error: onError
        };
        if (this.method === 'GET') {
          delete result.contentType;
          delete result.headers['X-RequestDigest'];
        }
        if (!(this.method === 'POST' && (eTag != null))) {
          delete result.headers['X-HTTP-Method'];
        }
        if (!(this.method === 'DELETE' || (this.method === 'POST' && (eTag != null)))) {
          delete result.headers['If-Match'];
        }
        if (this.method !== 'POST') {
          delete result.data;
        }
        if (onSuccess == null) {
          delete result.success;
        }
        if (onError == null) {
          delete result.error;
        }
      } catch (_error) {
        Error = _error;
        throw 'please provide either a json string or an object as payload';
      }
      return result;
    };

    return _Class;

  })();

  root.ShareCoffee.REST = (function() {
    function _Class() {}

    _Class.applicationType = "application/json;odata=verbose";

    _Class.build = {
      create: {
        "for": new ShareCoffee.RESTFactory('POST')
      },
      read: {
        "for": new ShareCoffee.RESTFactory('GET')
      },
      update: {
        "for": new ShareCoffee.RESTFactory('POST', true)
      },
      "delete": {
        "for": new ShareCoffee.RESTFactory('DELETE')
      }
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
    var helpPageUrl, iconUrl, settingsLinkSplat, title;
    iconUrl = arguments[0], title = arguments[1], helpPageUrl = arguments[2], settingsLinkSplat = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
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
      var condition;
      if (isSticky == null) {
        isSticky = false;
      }
      condition = function() {
        return (typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Notify != null) && (SP.UI.Notify.addNotification != null);
      };
      ShareCoffee.Core.checkConditions("SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition);
      return SP.UI.Notify.addNotification(message, isSticky);
    };

    _Class.removeNotification = function(notificationId) {
      var condition;
      if (notificationId == null) {
        return;
      }
      condition = function() {
        return (typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Notify != null) && (SP.UI.Notify.removeNotification != null);
      };
      ShareCoffee.Core.checkConditions("SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)", condition);
      return SP.UI.Notify.removeNotification(notificationId);
    };

    _Class.showStatus = function(title, contentAsHtml, showOnTop, color) {
      var condition, statusId;
      if (showOnTop == null) {
        showOnTop = false;
      }
      if (color == null) {
        color = 'blue';
      }
      condition = function() {
        return (typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.addStatus != null) && (SP.UI.Status.setStatusPriColor != null);
      };
      ShareCoffee.Core.checkConditions("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition);
      statusId = SP.UI.Status.addStatus(title, contentAsHtml, showOnTop);
      SP.UI.Status.setStatusPriColor(statusId, color);
      return statusId;
    };

    _Class.removeStatus = function(statusId) {
      var condition;
      if (statusId == null) {
        return;
      }
      condition = function() {
        return (typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.removeStatus != null);
      };
      ShareCoffee.Core.checkConditions("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition);
      return SP.UI.Status.removeStatus(statusId);
    };

    _Class.removeAllStatus = function() {
      var condition;
      condition = function() {
        return (typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.removeAllStatus != null);
      };
      ShareCoffee.Core.checkConditions("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition);
      return SP.UI.Status.removeAllStatus();
    };

    _Class.setStatusColor = function(statusId, color) {
      var condition;
      if (color == null) {
        color = 'blue';
      }
      if (statusId == null) {
        return;
      }
      condition = function() {
        return (typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Status != null) && (SP.UI.Status.setStatusPriColor != null);
      };
      ShareCoffee.Core.checkConditions("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)", condition);
      return SP.UI.Status.setStatusPriColor(statusId, color);
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