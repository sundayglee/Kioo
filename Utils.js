function milliSecToString(msec) {
    msec = Math.floor(msec/1000)
    var ss = msec%60
    msec = (msec-ss)/60
    var mm = msec%60
    var hh = (msec-mm)/60
    if (ss < 10)
        ss = "0" + ss
    if (mm < 10)
        mm = "0" + mm
    if (hh < 10)
        hh = "0" + hh
    return hh + ":" + mm +":" + ss
}

function clean() {
    var path = kioo.source;
    path=path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"");
    cleanPath = decodeURIComponent(path);
    console.log(cleanPath);
}

function fileName(path) {
    return path.substring(path.lastIndexOf("/") + 1)
}
