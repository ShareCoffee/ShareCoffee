(function() {
  var root, _base;

  root = typeof window !== "undefined" && window !== null ? window : global;

  root.ShareCoffee || (root.ShareCoffee = {});

  (_base = root.ShareCoffee).Commons || (_base.Commons = {});

  root.ShareCoffee.Commons.applicationType = "application/json;odata=verbose";

  root.ShareCoffee.Commons.getAppWebUrl = function() {
    if (_spPageContextInfo) {
      return _spPageContextInfo.webAbsoluteUrl;
    } else {
      if (console && console.error) {
        console.error("_spPageContextInfo is not defined");
      }
      return "";
    }
  };

  root.ShareCoffee.Commons.getApiRootUrl = function() {
    return "" + (ShareCoffee.Commons.getAppWebUrl()) + "/_api/";
  };

  root.ShareCoffee.Commons.getFormDigest = function() {
    return document.getElementById('__REQUESTDIGEST').value;
  };

  root.ShareCoffee.Commons.buildGetRequest = function(url) {
    return {
      url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
      type: "GET",
      headers: {
        'Accepts': ShareCoffee.Commons.applicationType
      }
    };
  };

  root.ShareCoffee.Commons.buildDeleteRequest = function(url) {
    return {
      url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
      type: "DELETE",
      contentType: ShareCoffee.Commons.applicationType,
      headers: {
        'Accept': ShareCoffee.Commons.applicationType,
        'If-Match': '*',
        'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
      }
    };
  };

  root.ShareCoffee.Commons.buildUpdateRequest = function(url, eTag, requestPayload) {
    return {
      url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
      type: 'POST',
      contentType: ShareCoffee.Commons.applicationType,
      headers: {
        'Accept': ShareCoffee.Commons.applicationType,
        'X-RequestDigest': ShareCoffee.Commons.getFormDigest(),
        'X-HTTP-Method': 'MERGE',
        'If-Match': eTag
      },
      data: requestPayload
    };
  };

  root.ShareCoffee.Commons.buildCreateRequest = function(url, requestPayload) {
    return {
      url: "" + (ShareCoffee.Commons.getApiRootUrl()) + url,
      type: 'POST',
      contentType: ShareCoffee.Commons.applicationType,
      headers: {
        'Accept': ShareCoffee.Commons.applicationType,
        'X-RequestDigest': ShareCoffee.Commons.getFormDigest()
      },
      data: requestPayload
    };
  };

}).call(this);

/*
//@ sourceMappingURL=ShareCoffee.js.map
*/