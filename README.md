# KTHTTPSocketDemos
自建长连接通道以及通讯协议

本文的起因是希望像[《美团点评移动网络优化实践》](http://baijiahao.baidu.com/s?id=1562304796942521&wfr=spider&for=pc)中的方案一样、建设一个可以将HTTP请求转化成二进制数据包、并且在自建的TCP长连接通道上传输。当然、直接TCP双向通讯也是没有问题的。
