class Controller
    bindEvents: ->
        return unless @events and @events.length
        for event in @events
            do (event) =>
                @$view.on event[0], event[1], (e)=>
                    W.action(e) # 触摸时间 手柄事件 切换
                    @[event[2]](e)

    back: (e)->
        W.preventDefault e
        jj.backOrExit()

W.Controller = Controller

W.preventDefault = (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    e.stopPropagation()
    e

W.parseJSON = (string)->
    return null unless string
    return JSON.parse(string) if _.isString(string)
    string
