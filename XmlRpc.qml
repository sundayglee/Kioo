import QtQuick 2.9
import QtQuick.XmlListModel 2.0

XmlListModel {
    id: xmlroot
    query: "/methodResponse/params/param/value/struct"
    property string baseurl: "http://api.opensubtitles.org:80/xml-rpc"
    property string path: ""
    property string url: baseurl + path
    property string user: ""
    property string passwd: ""
    property string lang: "en"
    property bool   authenticate: user != "" && passwd != ""

    function rpcRequest(request,handler) {
        var http = new XMLHttpRequest()

        http.open("POST",xmlroot.url,true)
        http.setRequestHeader("Content-type", "text/xml")
        http.setRequestHeader("Content-length", request.length)
        http.setRequestHeader("Connection","close")
        http.onreadystatechange = function() {
            if(http.readyState == 4 && http.status == 200) {
                //console.log("XmlRpc::rpcRequest.onreadystatechange()")
//                console.log("")
//                console.log("coming \n")
//                console.log(http.responseText)
                handler(http.responseText)

               // var token = http.responseXML.getElementByTagName("name")[0].childNodes[0].nodeValue;
               // var token = http.responseXML.documentElement;
               // var token = http.responseXML.documentElement.childNodes[0].childNodes[0].firstChild.childNodes[0].childNodes[0].childNodes[1].childNodes[0].childNodes[0].nodeValue;
               // console.log(token);

            }

        }
        http.send(request)
    }

    function callHandler(response) {
      //  console.log("XmlRpc::callHandler()" + response)
        xml = response
    }

    function logIn() {
        var request = "";
        request += "<methodCall>"
        request += "<methodName>LogIn</methodName>"
        request += "<params><param>"
        request += "<value><string></string></value>"
        request += "</param>"
        request += "<param>"
        request += "<value><string></string></value>"
        request += "</param>"
        request += "<param>"
        request += "<value><string>en</string></value>"
        request += "</param>"
        request += "<param>"
        request += "<value><string>Kioo Media v1.0</string></value>"
        request += "</param></params>"
        request += "</methodCall>";

        var http = new XMLHttpRequest()

        http.open("POST",url,false)
        http.setRequestHeader("Content-type", "text/xml")
        http.setRequestHeader("Content-length", request.length)
        http.setRequestHeader("Connection", "close")
        http.send(request);
      //  console.log(request);

        if (http.status === 200) {
         // console.log(http.responseText);
            return http.responseXML.documentElement.childNodes[0].childNodes[0].firstChild.childNodes[0].childNodes[0].childNodes[1].childNodes[0].childNodes[0].nodeValue;
        };
        return 0;
    }

    function call(params) {
        var request = "<methodCall>
                     <methodName>LogIn</methodName>
                     <params>
                      <param>
                       <value><string></string></value>
                      </param>
                      <param>
                       <value><string></string></value>
                      </param>
                      <param>
                       <value><string>en</string></value>
                      </param>
                      <param>
                       <value><string>Koo Media v1.0</string></value>
                      </param>
                     </params>
                    </methodCall>"

        rpcRequest(request,callHandler)
    }

    function search(params) {
        //console.log("XmlRpc.call(",cmd,params,")")

        var token = logIn();

        var request = ""
        var pName = ['sublanguageid','moviehash','moviebytesize']
        request += "<?xml version='1.0'?>"
        request += "<methodCall>"
        request += "<methodName>SearchSubtitles</methodName>"
        request += "<params>"
        request += "<param><value><string>"+token+"</string></value></param>"
        request += "<param><value><array><data><value><struct>"
        for (var i=0; i<params.length; i++) {
            if (typeof(params[i])=="string") {
                request += "<member><name>"+pName[i]+"</name>"
                request += "<value><string>"+params[i]+"</string></value></member>"
            }
            if (typeof(params[i])=="number") {
                request += "<member><name>"+pName[i]+"</name>"
                request += "<value><string>"+params[i]+"</string></value></member>"
            }
        }
        request += "</struct></value></data></array></value></param>"

        request += "</params>"
        request += "</methodCall>"

      //  console.log(request)
        rpcRequest(request,callHandler)
    }

    function hashCalc(file, callback) {
        var HASH_CHUNK_SIZE = 65536, //64 * 1024
            longs = [],
            temp = file.size;

        function read(start, end, callback) {
            var reader = new FileReader();
            reader.onload = function(e) {
                callback.call(reader, process(e.target.result));
            };

            if (end === undefined) {
                reader.readAsBinaryString(file.slice(start));
            } else {
                reader.readAsBinaryString(file.slice(start, end));
            }
        }

        function process(chunk) {
            for (var i = 0; i < chunk.length; i++) {
                longs[(i + 8) % 8] += chunk.charCodeAt(i);
            }
        }

        function binl2hex(a) {
            var b = 255,
                d = '0123456789abcdef',
                e = '',
                c = 7;

            a[1] += a[0] >> 8;
            a[0] = a[0] & b;
            a[2] += a[1] >> 8;
            a[1] = a[1] & b;
            a[3] += a[2] >> 8;
            a[2] = a[2] & b;
            a[4] += a[3] >> 8;
            a[3] = a[3] & b;
            a[5] += a[4] >> 8;
            a[4] = a[4] & b;
            a[6] += a[5] >> 8;
            a[5] = a[5] & b;
            a[7] += a[6] >> 8;
            a[6] = a[6] & b;
            a[7] = a[7] & b;
            for (d, e, c; c > -1; c--) {
                e += d.charAt(a[c] >> 4 & 15) + d.charAt(a[c] & 15);
            }
            return e;
        }


        for (var i = 0; i < 8; i++) {
            longs[i] = temp & 255;
            temp = temp >> 8;
        }

        read(0, HASH_CHUNK_SIZE, function() {
            read(file.size - HASH_CHUNK_SIZE, undefined, function() {
                callback.call(null, file, binl2hex(longs));
            });
        });
    }
}
