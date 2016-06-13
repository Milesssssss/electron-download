W.currentView = null
W.viewTransiting = false

W.disposeCurrentView = (nextViewController)->
    if W.currentView?.dispose
        W.currentView.dispose({nextViewParent: nextViewController.parentViewClass})
    else
        Promise.resolve(true)

W.toView = (nextViewController, params...)->
    if W.viewTransiting
        console.log 'WARNING! View transitions conflict!'
    W.viewTransiting = true
    q = W.disposeCurrentView(nextViewController).then ->
        nextViewController.show(params...).then (view)->
            W.currentView = view
            W.currentController = nextViewController
    q.lastly ->
        W.viewTransiting = false

Path.root("#/index")



