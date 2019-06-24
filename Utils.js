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
            pList.currentIndex = pModel.count-1;
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
    var k;

    k = "file:"+path.toString(); //qml use url and will add qrc: if no scheme
    k = k.replace(/\\/g, "/");

    if (k.endsWith(".srt") || k.endsWith(".ass") || k.endsWith(".ssa") || k.endsWith(".sub")
            || k.endsWith(".idx") || k.endsWith(".mpl2") || k.endsWith(".smi") || k.endsWith(".sami")
            || k.endsWith(".sup") || k.endsWith(".txt")) {
        subtitle.fuzzyMatch = true;
        subtitle.autoLoad = true;
    }
    else {
        if(!(fileName(k).length <= 6)) {
            pModel.append({ fTitle: fileName(k), fLink: k});
            pList.currentIndex = pModel.count - 1;
            subtitle.file = ""
        }
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


var dummy = {
    "movieHash": 89732,
    "movieName": "Amargedeon what come at all",
    "apiVersion": 0.1,

    "data": [
        {
            "position": 7466,
            "username": "ladfas",
            "comment": "sdfja fllksdfas I realy do not understand why they like each other at all"
        },
        {
            "position": 26724,
            "username": "adfdsa",
            "comment": "dfasd fldfkasf I realy do not understand why they like each other at all"
        },
        {
            "position": 13295,
            "username": "89adasd",
            "comment": "I realy do not understand why they like each other at all"
        },
        {
            "position": 17685,
            "username": "jasfsdfe",
            "comment": "I realy do not understand why they like each other at all"
        },
        {
            "position": 52864,
            "username": "adfawe",
            "comment": "yeaw da sdfasf I realy do not understand why they like each other at all"
        },
        {
            "position": 49562,
            "username": "kkdakaae",
            "comment": " ;;;d kkad a;;doad I realy do not understand why they like each other at all"
        },
        {
            "position": 45824,
            "username": "mdudadr",
            "comment": "d asf  ;sdfasfsaf I realy do not understand why they like each other at all"
        },
        {
            "position": 31397,
            "username": "unguad",
            "comment": "fasd djslfjasdf I realy do not understand why they like each other at all fasdfafa;f asdfas f asdfas fasdf asfas fasfklj lljhfa fsdjkhsfljfqwerui fafdifasd faf ksdfa lasf asfhas fasdfashflasd f"
        },
        {
            "position": 70533,
            "username": "jdafsdfad",
            "comment": "I realy do not understand why they like each other at all"
        }
    ]
}

