function show(platform, visitsCount, enabled, useSettingsInsteadOfPreferences) {
    document.getElementsByClassName('url-test')[0].innerText = visitsCount
    document.body.classList.add(`platform-${platform}`);

    if (useSettingsInsteadOfPreferences) {
        document.getElementsByClassName('platform-mac state-on')[0].innerText = "Digital Portraiture’s extension is currently on. You can turn it off in the Extensions section of Safari Settings.";
        document.getElementsByClassName('platform-mac state-off')[0].innerText = "Digital Portraiture’s extension is currently off. You can turn it on in the Extensions section of Safari Settings.";
        document.getElementsByClassName('platform-mac state-unknown')[0].innerText = "You can turn on Digital Portraiture’s extension in the Extensions section of Safari Settings.";
        document.getElementsByClassName('platform-mac open-preferences')[0].innerText = "Quit and Open Safari Settings…";
    }

    if (typeof enabled === "boolean") {
        document.body.classList.toggle(`state-on`, enabled);
        document.body.classList.toggle(`state-off`, !enabled);
    } else {
        document.body.classList.remove(`state-on`);
        document.body.classList.remove(`state-off`);
    }
    
//    urlList.forEach((url) => {
//        const node = document.createElement("li");
//        const textnode = document.createTextNode(url);
//        node.appendChild(textnode);
//        document.getElementsByClassName("url-list")[0].appendChild(node);
//    })
}

function openPreferences() {
    webkit.messageHandlers.controller.postMessage("open-preferences");
}

function sendMsgToBrowser() {
    webkit.messageHandlers.controller.postMessage("send-msg-to-browser");
}

document.querySelector("button.open-preferences").addEventListener("click", openPreferences);

document.querySelector("button.send-msg-to-browser").addEventListener("click", sendMsgToBrowser);
