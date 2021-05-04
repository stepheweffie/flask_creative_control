from gevent import monkey
monkey.patch_all()
from flask import Flask, render_template
from flask_sockets import Sockets
from websocket import create_connection


app = Flask(__name__)
sockets = Sockets(app)

ws = create_connection("wss://cc-simple-chat.herokuapp.com:8000")


@sockets.route('/')
def echo_socket(ws):
    while not ws.closed:
        message = ws.receive()
        ws.send(message)


@app.route('/', methods=["GET", "POST"])
def index():
    return render_template('index.html')


if __name__ == "__main__":
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler as Handler

    server = pywsgi.WSGIServer(('https://cc-simple-chat.herokuapp.com', 5000), app, handler_class=Handler)

    print(Handler.connection_upgraded)
    server.serve_forever()
