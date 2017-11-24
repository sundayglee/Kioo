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
   // var path = kioo.source;
    path=path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"");
    cleanPath = decodeURIComponent(path);
    console.log(cleanPath);
}

function fileName(path) {
    path = path.toString()
    return path.substring(path.lastIndexOf("/") + 1)
}

function getFile(path) {
    var k,subs

    for (var i = 1; i < path.length; ++i) {
        k = "file:"+path[i].toString(); //qml use url and will add qrc: if no scheme
        k = k.replace(/\\/g, "/");

        if (k.endsWith(".srt") || k.endsWith(".ass") || k.endsWith(".ssa") || k.endsWith(".sub")
                || k.endsWith(".idx") || k.endsWith(".mpl2") || k.endsWith(".smi") || k.endsWith(".sami")
                || k.endsWith(".sup") || k.endsWith(".txt"))
            subs = k
        else {
            pModel.append({ fTitle: Utils.fileName(k), fLink: k})
            if(i==1)
                changeSource(k)
        }
    }
    if (subs) {
        subtitle.autoLoad = true
        subtitle.file = subs
    } else {
        subtitle.file = ""
    }
}

function getSingleFile(path) {
    var k,subs

    k = "file:"+path.toString(); //qml use url and will add qrc: if no scheme
    k = k.replace(/\\/g, "/");

    if (k.endsWith(".srt") || k.endsWith(".ass") || k.endsWith(".ssa") || k.endsWith(".sub")
            || k.endsWith(".idx") || k.endsWith(".mpl2") || k.endsWith(".smi") || k.endsWith(".sami")
            || k.endsWith(".sup") || k.endsWith(".txt"))
        subs = k
    else {
        pModel.append({ fTitle: Utils.fileName(k), fLink: k})
        changeSource(k)
    }

    if (subs) {
        subtitle.autoLoad = true
        subtitle.file = subs
    } else {
        subtitle.file = ""
    }
}


function scale(x) {
    return x*screen.devicePixelRatio
}

function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                callback(myxhr);
            }
        })(xhr);
        xhr.open('GET', url, true);
        xhr.send('');
}

function checkUrl(val) {
    var resp = "";
    if(val.startsWith("http"))
        resp = val;
    else
        resp = rpc.get(subList.currentIndex).sublink2;
    return resp;
}
