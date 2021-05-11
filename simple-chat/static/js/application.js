// Support TLS-specific URLs, when appropriate.
if (window.location.protocol == "https:") {
  var ws_scheme = "wss://";
} else {
  var ws_scheme = "ws://"
};
if ("WebSocket in window") {
    var inbox = new ReconnectingWebSocket(ws_scheme + document.domain + "/submit");
    var outbox = new ReconnectingWebSocket(ws_scheme + location.host + ":receive");
}
inbox.onmessage = function(message) {
  var data = JSON.parse(message.data);
  $("#log").append("<div class='panel panel-default'><div class='panel-heading'>" +
      $('<span/>').text(data.handle).html() + "</div><div class='panel-body'>" +
      $('<span/>').text(data.text).html() + "</div></div>");
  $("#log").stop().animate({
    scrollTop: $('#chat-text')[0].scrollHeight
  }, 800);
};

inbox.onclose = function(){
    console.log('inbox closed');
    this.inbox = new WebSocket(inbox.url);

};

outbox.onclose = function(){
    console.log('outbox closed');
    this.outbox = new WebSocket(outbox.url);
};

$("#chat").on("submit", function(event) {
  event.preventDefault();
  var handle = $("#handle")[0].value;
  var text   = $("#data")[0].value;
  outbox.send(JSON.stringify({ handle: handle, text: text }));
  $("#data")[0].value = "";
});
