from gevent import monkey
monkey.patch_all()
import gevent
import json
import os
import redis
# from flask_socketio import SocketIO
from flask import Flask, render_template, request
from flask_sockets import Sockets
REDIS_URL = os.environ.get('REDIS_URL')
REDIS_CHAN = 'simple-chat'
app = Flask(__name__)
sockets = Sockets(app)
r = redis.from_url(REDIS_URL, port=REDIS_URL.port, ssl=True, ssl_cert_reqs=None)


class ChatBackend(object):
    """Interface for registering and updating WebSocket clients."""

    def __init__(self):
        self.clients = list()
        self.pubsub = r.pubsub()
        self.pubsub.subscribe(REDIS_CHAN)

    def __iter_data(self):
        for message in self.pubsub.listen():
            data = message.get('data')
            if message['type'] == 'message':
                app.logger.info(u'Sending message: {}'.format(data))
                yield data

    def register(self, client):
        """Register a WebSocket connection for Redis updates."""
        self.clients.append(client)

    def send(self, client, data):
        """Send given data to the registered client.
        Automatically discards invalid connections."""
        try:
            client.send(data)
        except AttributeError:
            self.clients.remove(client)

    def run(self):
        """Listens for new messages in Redis, and sends them to clients."""
        for data in self.__iter_data():
            for client in self.clients:
                gevent.spawn(self.send, client, data)

    def start(self):
        """Maintains Redis subscription in the background."""
        gevent.spawn(self.run)


chats = ChatBackend()
chats.start()


@app.route('/', methods=["GET", "POST"])
def index():
    welcome_message = "WELCOME"
    username = "Savant"
    # TODO loop over previous chat messages or load them in html
    if request.method == 'POST':
        data = json.dumps(request.form)
        r.publish(REDIS_CHAN, data)
        return False
    return render_template('index.html', welcome_message=welcome_message, username=username)


@sockets.route('/submit')
def inbox(ws):
    """Receives incoming chat messages, inserts them into Redis."""
    while not ws.closed:
        # Sleep to prevent *constant* context-switches.
        gevent.sleep(0.1)
        message = ws.receive()

        if message:
            app.logger.info(u'Inserting message: {}'.format(message))
            r.publish(REDIS_CHAN, message)


@sockets.route('/receive')
def outbox(ws):
    """Sends outgoing chat messages, via `ChatBackend`."""
    chats.register(ws)
    while not ws.closed:
        # Context switch while `ChatBackend.start` is running in the background.
        gevent.sleep(0.1)


if __name__ == "__main__":
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler as Handler
    server = pywsgi.WSGIServer(('https://cc-simple-chat.herokuapp.com', 5000), app, handler_class=Handler)
    server.serve_forever()
