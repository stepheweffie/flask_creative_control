$(document).ready(function(){
    if ("WebSocket in window") {
        const client = new ReconnectingWebSocket('wss://cc-simple-chat.herokuapp.com:443/submit');
        const server = new ReconnectingWebSocket('wss://cc-simple-chat.herokuapp.com:443/recieve');
        client.onopen = function(){
        // Send a small message to the console once the connection is established */
        console.log('Connection open!');
};
    client.onclose = function(){
        console.log('Connection closed');
};
    client.onmessage = function(message) {
        const message_data = JSON.parse(message.data);
        $('#chat-message').append('<div>'+message_data.text+'</div>');
        $("#chat-message").stop().animate({
    scrollTop: $('#chat-text')[0].scrollHeight
  }, 800);};

const handle = $("#handle")[0].value;
const text = $("#chat-text")[0].value;
const message = (JSON.stringify({ handle: handle, text: text, type: message}));

$("button").click = function() {

    console.log('chatting...');
    $('.text-input')[0].value = "";
};

$("form").onsubmit = function(event) {
    event.preventDefault();
    server.send(message);};
