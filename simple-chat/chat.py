from gevent import monkey
import json
monkey.patch_all()
import gevent
import os
import redis
from flask import Flask, render_template, request
from flask_sockets import Sockets
REDIS_URL = os.environ.get('REDIS_URL')
REDIS_CHAN = 'simple-chat'
# from websocket import create_connection


app = Flask(__name__)
sockets = Sockets(app)
r = redis.from_url(REDIS_URL)
# ws = create_connection("wss://cc-simple-chat.herokuapp.com:8000")


@sockets.route('/')
def echo_socket(ws):
    while not ws.closed:
        gevent.sleep(0.1)
        message = ws.receive()
        ws.send(message)
        if message:
            app.logger.info(f''.format(message))
            r.publish(REDIS_CHAN, message)


@app.route('/', methods=["GET", "POST"])
def index():
    data = request.data
    if request.method == 'POST':
        print(request.data)
        echo_socket(data)
        r.publish(REDIS_CHAN, "Incoming")
        r.broadcast(REDIS_CHAN)
    return render_template('index.html', data=json.dumps(data))


if __name__ == "__main__":
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler as Handler

    server = pywsgi.WSGIServer(('https://cc-simple-chat.herokuapp.com', 5000), app, handler_class=Handler)

    server.serve_forever()
