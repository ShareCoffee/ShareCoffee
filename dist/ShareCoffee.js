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

  root.ShareCoffee.CrossDomain = (function() {
    function _Class() {}

    _Class.loadCrossDomainLibrary = function(onSuccess, onError) {
      var scriptUrl;
      scriptUrl = "" + (ShareCoffee.Commons.getHostWebUrl()) + "/_layouts/15/SP.RequestExecutor.js";
      return ShareCoffee.Core.loadScript(scriptUrl, onSuccess, onError);
    };

    return _Class;

  })();

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  root.ShareCoffee.RESTFactory = (function() {
    function _Class(method) {
      this.method = method;
      this.reqwest = __bind(this.reqwest, this);
      this.angularJS = __bind(this.angularJS, this);
      this.jQuery = __bind(this.jQuery, this);
    }

    _Class.prototype.jQuery = function(url, payload, eTag) {
      var result;
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (this.method === 'DELETE') {
        eTag = '*';
      }
      result = {
        url: url,
        type: this.method,
        contentType: ShareCoffee.REST.applicationType,
        headers: {
          'Accepts': ShareCoffee.REST.applicationType,
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

    _Class.prototype.angularJS = function(url, payload, eTag) {
      var result;
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (this.method === 'DELETE') {
        eTag = '*';
      }
      result = {
        url: url,
        method: this.method,
        headers: {
          'Accepts': ShareCoffee.REST.applicationType,
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

    _Class.prototype.reqwest = function(url, payload, eTag) {
      var Error, result;
      if (payload == null) {
        payload = null;
      }
      if (eTag == null) {
        eTag = null;
      }
      if (this.method === 'DELETE') {
        eTag = '*';
      }
      result = null;
      try {
        result = {
          url: url,
          method: this.method.toLowerCase(),
          contentType: ShareCoffee.REST.applicationType,
          headers: {
            'Accepts': ShareCoffee.REST.applicationType,
            'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
            'If-Match': eTag,
            'X-HTTP-Method': 'MERGE'
          },
          data: (payload != null) && typeof payload === 'object' ? payload : JSON.parse(payload)
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
        "for": new ShareCoffee.RESTFactory('POST')
      },
      "delete": {
        "for": new ShareCoffee.RESTFactory('DELETE')
      }
    };

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