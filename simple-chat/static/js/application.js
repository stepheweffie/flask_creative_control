
$(document).ready(function() {
    if ("WebSocket in window") {
        const wsuri = 'wss://'+'cc-simple-chat.herokuapp.com:5000';
        const client = new ReconnectingWebSocket(wsuri + '/submit');
        const server = new ReconnectingWebSocket(wsuri + '/recieve');
        client.onopen = function () {
            // Send a small message to the console once the connection is established */
            console.log('Connection open!');
        };
        client.onclose = function () {
            console.log('Connection closed');
        };
        client.onmessage = function (message) {
            const message_data = JSON.parse(message.data);
            console.log('Message sent');
            $('#chat-message').append('<div><p>' + message_data.handle + ': ' + message_data.text + '</p></div>');
            $("#chat-message").stop().animate({
                scrollTop: $('#chat-text')[0].scrollHeight
            }, 800);
        };

        const handle = $("#handle")[0].value;
        const text = $("#chat-text")[0].value;
        const message ={
          type: 'message',
          handle: handle,
          text: text,
          date: Date.now(),
        };

        $("#input-form").on("submit", function (event) {
            event.preventDefault();
            server.send(JSON.stringify(message));
            $("#text-input")[0].value = "";
        });
    }
});
