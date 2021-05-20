$(document).ready(function(){
    if ("WebSocket in window") {
        const client = new ReconnectingWebSocket('wss://'+location.host+'/submit');
        const server = new ReconnectingWebSocket('wss://'+location.host+'/recieve');
        client.onopen = function(){
        // Send a small message to the console once the connection is established */
        console.log('Connection open!');
};
    client.onclose = function(){
        console.log('Connection closed');
};
    client.onmessage = function(message) {
        const message_data = JSON.parse(message.data);
        console.log('Message sent');
        $('#chat-message').append('<div><p>'+message_data.handle+': '+ message_data.text+'</p></div>');
        $("#chat-message").stop().animate({
    scrollTop: $('#chat-text')[0].scrollHeight
  }, 800);};

const handle = $("#handle")[0].value;
const text = $("#chat-text")[0].value;
const message = (JSON.stringify({ handle: handle, text: text, type: message}));

$("button").click = function() {
    console.log('chatting...');
};

$("#input-form").on("submit", function(event) {
  event.preventDefault();
  const handle = $("#handle")[0].value;
  const text   = $("#chat-text")[0].value;
  server.send(JSON.stringify({ handle: handle, text: text }));
  $("#text-input")[0].value = "";
});
