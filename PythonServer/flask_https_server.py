from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    if request.environ.get('HTTP_X_FORWARDED_FOR') is None:
        ip_address=request.environ['REMOTE_ADDR']
    else:
        ip_address=request.environ['HTTP_X_FORWARDED_FOR']

    message = "Hello! Your IP address is {}".format(ip_address)
    response = {
        'message': message,
        'ip_address': ip_address
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True, ssl_context=('server.crt', 'server.key'))