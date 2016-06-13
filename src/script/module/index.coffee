getDownloadTasks = ->
    downloadTasks = localStorage.downloadTasks || "[]"
    downloadTasks = JSON.parse(downloadTasks)
    return downloadTasks

class DownloadCenter

    constructor: (@id, @url, @name, @size, @dist) ->
        @$tasks = $('.download-tasks')

        @$menu = $('.download-menu')

        unless @$menu.length
            @$menu = $ '<a>',
                class: "download-menu btn active"
                html: "<i class='fa fa-arrow-right fa-2x'></i>"
            .appendTo $('body')
            .on 'click', =>
                if @$menu.hasClass('active')
                    @$menu.removeClass('active').find('i').attr 'class': 'fa fa-bars fa-2x'
                else
                    @$menu.addClass('active').find('i').attr 'class': 'fa fa-arrow-right fa-2x'
                if @$tasks.hasClass('hidden') then @$tasks.removeClass('hidden') else @$tasks.addClass('hidden')

        unless @$tasks.length
            @$tasks = $('<div>', class: "download-tasks").appendTo $('body')
            @$clean = $ '<a>',
                class: "download-clean btn"
                text: "清除"
            .appendTo @$tasks
            .on 'click', =>
                tasks = window.getTasks()
                moves = _.remove tasks, {progress: 1}
                moves.forEach (r)=>
                    $("a[data-id=#{r.id}]").remove()
                localStorage.downloadTasks = JSON.stringify(tasks)
        else
            @$clean = @$tasks.find('.download-clean')

        @_initTask(@name).bind(@)

    _initTask: (@name)->
        @$task = $ "<a>",
            class: "download-task"
            "data-id": @id

        @$progress = $ "<div>",
            class: "download-progress"
            text: "0"
        .appendTo @$task

        $name = $ "<div>",
            class: "download-name"
            text: @name
            title: @name
        .appendTo @$task

        @$task
        .insertAfter @$clean
        .on 'click', =>
            shell.showItemInFolder(@dist) if @dist

    update: (progress)->
        @$progress.html(progress)

window.DownloadCenter = DownloadCenter


electron = require('electron')
ipcRenderer = electron.ipcRenderer
shell = electron.shell

window.initDownloadCenter = ->
    dcs = new Map()

    downloadTasks = getDownloadTasks()
    if (downloadTasks.length)
        downloadTasks.forEach (p)->
            dc = new DownloadCenter(p.id, p.url, p.name, p.size, p.path)
            dcs.set(p.id, dc)
            dc.update((p.progress && (p.progress * 100).toFixed(1) + '%') || '--')

    ipcRenderer.on 'start-download', (e, p)->
        dc = new DownloadCenter(p.id, p.url, p.name, p.size, p.path)
        dcs.set(p.id, dc)
        downloadTasks = getDownloadTasks()
        downloadTasks.push(p)
        localStorage.downloadTasks = JSON.stringify(downloadTasks)

    ipcRenderer.on 'downloading', (e, p)->
        dc = dcs.get(p.id)
        dc.update((p.progress * 100).toFixed(1) + '%')

    ipcRenderer.on 'download-fail', (e, p)->
        downloadTasks = getDownloadTasks()
        downloadTasks.forEach (r) ->
            r.progress = p.progress if (r.id == p.id)

    ipcRenderer.on 'download-done', (e, p)->
        downloadTasks = getDownloadTasks()
        downloadTasks.forEach (r)->
            r.progress = p.progress if (r.id == p.id)
        localStorage.downloadTasks = JSON.stringify(downloadTasks)