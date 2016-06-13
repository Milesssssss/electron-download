const electron = require('electron');
// Module to control application life.
const {app} = electron;
// Module to create native browser window.
const {BrowserWindow} = electron;

const objectid = require('objectid')

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win;

function createWindow() {
    // Create the browser window.
    win = new BrowserWindow({width: 1400, height: 800});

    // and load the index.html of the app.
    win.loadURL(`file://${__dirname}/index.html`);

    // Open the DevTools.
    win.webContents.openDevTools();

    // Emitted when the window is closed.
    win.on('closed', () => {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        win = null;
    });

    const path = require('path')

    win.webContents.session.on('will-download', (e, item) => {
        //获取文件的总大小
        const totalBytes = item.getTotalBytes();

        //设置文件的保存路径，此时默认弹出的 save dialog 将被覆盖
        const filePath = path.join(app.getPath('downloads'), item.getFilename());
        item.setSavePath(filePath);

        //electron.dialog.showMessageBox({type: 'info', buttons: ['确定'], title: '下载', message: '开始下载' + filePath})

        const id = objectid().toString()

        const data = {
            id: id,
            url: item.getURL(),
            name: item.getFilename(),
            size: totalBytes,
            path: filePath
        }
        win.webContents.send('start-download', data);

        //监听下载过程，计算并设置进度条进度
        let progress = 0
        item.on('updated', (e, arg) => {
            progress = item.getReceivedBytes() / totalBytes
            var args = {
                id: id,
                progress: progress
            }
            win.setProgressBar(progress);
            win.webContents.send('downloading', args);
        });

        //监听下载结束事件
        item.on('done', (e, state) => {
            data.progress = progress
            win.webContents.send('download-done', data);

            //如果窗口还在的话，去掉进度条
            if (win) win.setProgressBar(-1);

            //下载被取消或中断了
            if (state === 'interrupted') {
                win.webContents.send('download-fail', data);
                electron.dialog.showErrorBox('下载失败', `文件 ${item.getFilename()} 因为某些原因被中断下载`);
            }

            //下载完成，让 dock 上的下载目录Q弹一下下
            if (state === 'completed') {
                app.dock.bounce("critical");
            }
        });
    });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', () => {
    // On OS X it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    // On OS X it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (win === null) {
        createWindow();
    }
});