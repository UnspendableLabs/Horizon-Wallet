chrome.runtime.onConnect.addListener((port) => {
  console.log("port.name is: " + port.name);

  if (port.name !== CONTENT_SCRIPT_PORT) return;

  port.onMessage.addListener((message, port) => {


    console.log ("message received in background script at port: " + port, message);

    if (!port.sender?.tab?.id) {
      console.error(
        "message reached background script :ithout a corresponding tab",
      );
      return;
    }

    // Chromium/Firefox discrepancy
    const originUrl = port.sender?.origin ?? port.sender?.url;

    if (!originUrl) {
      console.error("message reached background script without a valid origin");
      return;
    }

    console.log(
      "message received in background script at port: " + port,
      message,
    );
  });
});
