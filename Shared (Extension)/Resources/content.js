browser.runtime.sendMessage(JSON.stringify({"requestType": "newPage", "url": window.location.href, "user": "testUser"})).then((response) => {
    console.log("Received response from background: ", response);
})

//browser.runtime.sendMessage({ greeting: "hello" }).then((response) => {
//    console.log("Received response: ", response);
//});


//browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//    console.log("Received request: ", request);
//});


