apiRoot = jj.getApiRoot()

api = {}
W.api = api

AjaxOption = (type, data, settings) ->
    @type = type

    if type == "POST" || type == "PUT" || type == "DELETE"
        @data = data && JSON.stringify(data)
        @contentType = "application/json"
    else
        @data = data

    this.beforeSend = (request) ->
        # request.setRequestHeader("X-username", APP.user?.username)
        # request.setRequestHeader("X-token", APP.user?.token)

#    @cache = false; # !!!

    _.extend(this, settings) if settings?

api.get = (relativeUrl, data, settings) ->
    Promise.resolve $.ajax(apiRoot + relativeUrl, new AjaxOption("GET", data, settings))

api.getAbsolute = (absoluteUrl, data, settings) ->
    Promise.resolve $.ajax(absoluteUrl, new AjaxOption("GET", data, settings))

api.post = (relativeUrl, data, settings) ->
    Promise.resolve $.ajax(apiRoot + relativeUrl, new AjaxOption("POST", data, settings))

api.postAbsolute = (absoluteUrl, data, settings) ->
    Promise.resolve $.ajax(absoluteUrl, new AjaxOption("POST", data, settings))

api.put = (relativeUrl, data) ->
    Promise.resolve $.ajax(apiRoot + relativeUrl, new AjaxOption("PUT", data))

api.remove = (relativeUrl, data) ->
    Promise.resolve $.ajax(apiRoot + relativeUrl, new AjaxOption("DELETE", data))

