# AISocket

[![Version](https://img.shields.io/cocoapods/v/AISocket.svg?style=flat)](http://cocoapods.org/pods/AISocket)
[![License](https://img.shields.io/cocoapods/l/AISocket.svg?style=flat)](http://cocoapods.org/pods/AISocket)
[![Platform](https://img.shields.io/cocoapods/p/AISocket.svg?style=flat)](http://cocoapods.org/pods/AISocket)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AISocket is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:


```ruby
pod "AISocket"
```

##Example
```objective-c

@import AISocket;

[[AISocketManager sharedInstance] connectHost:@"http://192.168.1.10:5000" delegate:self];
[[AISocketManager sharedInstance] listenOnEvent:[AISocketChatData eventName] dataCallback:^AISocketData *(id datas) {
    //Whent data received, you can parse data to AISocketData, then it will be notify to all observers
    AISocketChatData *obj = [[AISocketChatData alloc]initWithString:datas error:nil];
    return obj;
}];

```

If you need to observer data on other controllers:

```objective-c

[[AISocketManager sharedInstance] addObserver:self onEvent:[AISocketChatData eventName]];

```
##Observer Delegate
```objective-c

- (void)dlgAISocketManager:(AISocketManager*)manager status:(AISocketManagerStatus)status;
- (void)dlgAISocketManager:(AISocketManager*)manager withData:(AISocketData*)data;
- (void)dlgAISocketManager:(AISocketManager*)manager withData:(AISocketData*)data ackData:(NSArray*)ackData;

```

##Example Socket.io server
```javascript

var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
io.on('connection', function(socket){
    console.log('new connection');
    socket.on('chatmessage', function(msg,fn){
        fn('ack');
        console.log(msg);
        io.emit('chatmessage', msg);
    });
});

http.listen(5000, function(){
console.log('listening on *: 5000');
});


```
## Author

An Nguyen, anngdev@gmail.com

## License

AISocket is available under the MIT license. See the LICENSE file for more info.
