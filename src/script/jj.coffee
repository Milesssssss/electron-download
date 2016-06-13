events = {}

fakeJJ =
    fake: true
    getApiRoot: -> '/api/'
    getResourceRoot: -> '/r/'
    backOrExit: ->
        history.back()
    isLandscape: -> true

window.jj = fakeJJ unless jj?
