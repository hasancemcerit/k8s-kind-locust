import sys
import socket
import random

from flask import Flask

app = Flask(__name__)
app.url_map.strict_slashes = False

snake = "🐍"
counter = 0

@app.before_request
def before_request_func():
    global counter
    counter += 1

@app.route('/count', methods=['GET','POST'])
def count():
    global counter
    counter -= 1
    return f"{snake}: {socket.gethostname()} #{counter}"

@app.route('/', methods=['GET','POST'])
def world():
    return f"{snake}: Hello World!"

@app.route('/<string:name>', methods=['GET','POST'])
def name(name):
    return f"{snake}: Hello {name}!"

@app.route('/ping', methods=['GET','POST'])
def ping():
    return f"{snake}: pong from {socket.gethostname()}"

@app.route('/random', methods=['GET','POST'])
def rnd():
    return f"{snake}: {socket.gethostname()} generated random {random.randrange(sys.maxsize - 1)}"

@app.route('/ip', methods=['GET','POST'])
def ip():
    return f"{snake}: {socket.gethostbyname(socket.gethostname())}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, threaded = True)
