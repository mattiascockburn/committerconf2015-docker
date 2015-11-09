# Dieses Beispiel wurde adaptiert von
# http://blog.docker.com/2014/08/getting-started-with-orchestration-using-fig/ 
# und http://docs.docker.com/compose/extends/
from flask import Flask
from redis import Redis
import os
app = Flask(__name__)
redis = Redis(host=os.environ['REDIS_HOST'], port=6379)

@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hallo Committerconf!. Diese Seite wurde %s mal aufgerufen.\n' % redis.get('hits')

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
