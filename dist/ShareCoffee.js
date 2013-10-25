(function() {
  var root;

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

    _Class.getApiRootUrl = function() {
      return "" + (ShareCoffee.Commons.getAppWebUrl()) + "/_api/";
    };

    _Class.getFormDigest = function() {
      return document.getElementById('__REQUESTDIGEST').value;
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

  root.ShareCoffee.UI = (function() {
    function _Class() {}

    _Class.showNotification = function(message, isSticky) {
      if ((typeof SP === "undefined" || SP === null) || (SP.UI == null) || (SP.UI.Notify == null)) {
        console.error("SP.UI or SP.UI.Notify is not loaded");
      }
      if ((typeof SP !== "undefined" && SP !== null) && (SP.UI != null) && (SP.UI.Notify != null) && SP.UI.Notify.addNotification) {
        return SP.UI.Notify.addNotification(message, isSticky);
      }
    };

    return _Class;

  })();

}).call(this);

/*
//@ sourceMappingURL=ShareCoffee.js.map
*/