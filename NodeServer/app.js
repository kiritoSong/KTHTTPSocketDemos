var net = require('net');
const https = require('https');

var HOST = '127.0.0.1';
var PORT = 8080;

// 创建一个TCP服务器实例，调用listen函数开始监听指定端口
// 传入net.createServer()的回调函数将作为”connection“事件的处理函数
// 在每一个“connection”事件中，该回调函数接收到的socket对象是唯一的


net.createServer(function(sock) {
    sock.setEncoding(`hex`);
    // 我们获得一个连接 - 该连接自动关联一个socket对象
    console.log('CONNECTED: ' +
        sock.remoteAddress + ':' + sock.remotePort);

    // 为这个socket实例添加一个"data"事件处理函数
    sock.on('data', function(data) {
        console.log('DATA ' + sock.remoteAddress + '16进制数据: ' + data);
        // 回发该数据，客户端将收到来自服务端的数据
        // sock.write('You said "' + data + '"');


        var type = getType(data);
        var requestIdentifier = getRequestIdentifier(data);
        var contengtLength = getContengtLength(data);

        var content = data.substr(24,parseInt(contengtLength,16)*2);
        var jsonStr = hexCharCodeToStr(content);
        console.log(`type:` + type);
        console.log(`requestIdentifier:` + requestIdentifier);
        console.log(`data:`+jsonStr);

        /*     demo工作区     */
        switch(parseInt(type))
        {
            case 1:
                //心跳包
                sock.write(data , `hex`);
                break;
            case 402:
                //接收到单纯的json字典
                var restr = jsonStr;
                var redata  = stringToHex(restr);
                var contentL = fn3(restr.length.toString(16),8);
                sock.write(type + requestIdentifier + contentL + redata , `hex`);
                break;
            case 403:

                var json = JSON.parse(jsonStr);
                //尝试get请求
                https.get(json.url, (resp) => {
                    let httpdata = '';

                    // A chunk of data has been recieved.
                    resp.on('data', (chunk) => {
                        httpdata += chunk;
                    });

                    // The whole response has been received. Print out the result.
                    resp.on('end', () => {
                        var restr = httpdata;
                        var redata  = stringToHex(restr);
                        var contentL = fn3(restr.length.toString(16),8);
                        sock.write(type + requestIdentifier + contentL + redata , `hex`);
                    });

                }).on("error", (err) => {
                    console.log("Error: " + err.message);
                });

                break;
            default:

        }




    });

    // 为这个socket实例添加一个"close"事件处理函数
    sock.on('close', function(data) {
        console.log('CLOSED: ' +
            sock.remoteAddress + ' ' + sock.remotePort);
    });

}).listen(PORT, HOST);

console.log('Server listening on ' + HOST +':'+ PORT);
function stringToHex(str){
    var val="";
    for(var i = 0; i < str.length; i++){
        if(val == "")
            val = str.charCodeAt(i).toString(16);
        else
            val += str.charCodeAt(i).toString(16);
    }
    return val;
}

//16进制转字符串
function hexCharCodeToStr(hexCharCodeStr) {
    var trimedStr = hexCharCodeStr.trim();
    var rawStr =
        trimedStr.substr(0,2).toLowerCase() === "0x"
            ?
            trimedStr.substr(2)
            :
            trimedStr;
    var len = rawStr.length;
    if(len % 2 !== 0) {
        alert("Illegal Format ASCII Code!");
        return "";
    }
    var curCharCode;
    var resultStr = [];
    for(var i = 0; i < len;i = i + 2) {
        curCharCode = parseInt(rawStr.substr(i, 2), 16); // ASCII Code Value
        resultStr.push(String.fromCharCode(curCharCode));
    }
    return resultStr.join("");
}

//二进制转数字
function binToAscii(num){
    var str1='';
    if(typeof num !='String'){
        var str=num.toString();
    }
    var Hlong=Math.ceil(str.length/8);
    for(var i=0;i<Hlong;i++){
        str1+=String.fromCharCode(parseInt(str.substring(i*8,(i+1)*8),2));
    }
    return str1;
}


//请求类型
function getType(data) {

    var type = data.substr(0,8);
    return type;
}


//请求序列号
function getRequestIdentifier(data) {

    var type = data.substr(8,8);
    return type;
}


//内容长度
function getContengtLength(data) {
    var type = data.substr(16,8);
    return type;
}

//补位
function fn3(num, length) {
    return (Array(length).join('0') + num).slice(-length);
}