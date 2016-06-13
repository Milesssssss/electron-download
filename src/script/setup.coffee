console.log 'ENTER UI'

# 建立全局命名空间
W =
    View: {}
    ENV_product: 'product'
    ENV_browser: 'browser'
    ENV_mock: 'mock'
    defaultAppScore: 90

W.ENV = window.jj? and W.ENV_product or W.ENV_browser
console.log 'UI ENV=' + W.ENV

window.W = W

# 当前屏幕宽度
W.isLandscape = jj.isLandscape()

# 解决界面非常小的BUG
if window.innerWidth < 300
    console.log '界面非常小，重新加载！' + window.innerWidth
# setTimeout (-> window.location.reload()), 300

class Logger
    constructor: (@tag) -> true
    debug: (messages)->
        console.log messages and messages.join(', ')
W.Logger = Logger

W.staticImg = (img)->
    if img
        jj.getResourceRoot() + img.path
    else
        ''

W.static = (path)-> jj.getResourceRoot() + path