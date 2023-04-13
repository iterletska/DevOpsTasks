from flask import Flask, request, jsonify
import ctypes

app = Flask(__name__)

# Load the C library
lib = ctypes.cdll.LoadLibrary('/usr/local/glibc/lib/libc.so.6')

@app.route('/', methods=['GET'])
def index():
    ip_address = request.remote_addr
    message = "Hello! Your IP address is {}".format(ip_address)
    response = {
        'message': message,
        'ip_address': ip_address
    }
    return jsonify(response)

if __name__ == '__main__':
    context = ('server.crt', 'server.key')
    app.run(debug=True, ssl_context=context)