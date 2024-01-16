browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received msg from content: ", request);
    browser.runtime.sendNativeMessage("application.id", request, function(response) {
            sendResponse(response);
    });
    return true;
});

//let port = browser.runtime.connectNative("application.id");

//port.onMessage.addListener(function(message) {
//    console.log("Received native port message:");
//    console.log(message);
//});

//port.postMessage("Hello from browser background");

//browser.runtime.sendNativeMessage("application.id", {message: "hello from the browser background!"}, function(response) {
//    console.log("response recieved: ", response)
//}
