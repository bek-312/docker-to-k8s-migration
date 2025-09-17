(bonus) Assignment #2: Complete Kubernetes deployment from Assignment#1 and add more features

Description


(bonus) Assignment #2: Complete Kubernetes deployment from Assignment#1 and add more features

TASK #1:

Deploy API based Quote application that you have created in Assignment #1: Build an API based Quotes App with docker-compose and migrate to Kubernetes with the yamls files you created there (You can skip Network Policy yamls). Make sure everything is working. You might need to adjust yaml files to make everything work

TASK #2:

Sensitive data should not be hardcoded. The connection string in the "back.py" file contains the login and password the application uses (Links to an external site.). In order to hide this data, we are going to read it from an environment variable called SQLALCHEMY_DATABASE_URI:


...
from random import randint
from flask import request
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ['SQLALCHEMY_DATABASE_URI']
app.config['SQLALCHEMY_ECHO'] = True
db = SQLAlchemy(app)
...


 

os.environ['SQLALCHEMY_DATABASE_URI'] - this is how python references an environment variable named SQLALCHEMY_DATABASE_URI

Above was the change you needed to make in the code of back service. After changing the code, you must build and push the image again, otherwise, docker image will not have updated code

Then, make sure that back service has this SQLALCHEMY_DATABASE_URI environment variable referenced from a Kubernetes secret (create it)

Also, data service has MySQL root password, user name, and database env variables configured in a deployment yaml file. This is not the best practice. Make sure that these env variables come from a Kubernetes secret

Same for the data-script service, it should also reference it's env variables from Kubernetes secret. To accomplish first, you would need to change this line in import.sh (Links to an external site.).  Make sure it's using environment variables like this:
mysql -h $MYSQL_DB_HOST -u $MYSQL_USER -p${MYSQL_USER_PASSWORD} mydatabase < /opt/mydatabase.sql

And of course, you would need to build and push an image whenever you make a code change that affects container image.

Make sure data-script kubernetes yaml is referencing above variables from a Kubernetes secret as well

TASK #3:

Our data-script service creates database schema and adds sample quotes into a database.

But what if a database is not running yet? This service will fail to update the database.

That's why we had added this sleep command (Links to an external site.), but even if you wait for 120 seconds, it's not guaranteed that the database is up. So we need to make sure that import.sh (Links to an external site.) script in data-script service runs only when the database (data service) is up and running.

How can we achieve this? We can use Init Container in the data-script pod/deployment (https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ )

Init Container is a container that runs before an app container runs in a Pod. So when you create a pod with one Init Container and one normal/app container: 
Init Container starts => Init Container completes => App container starts and runs

In this case, we will have an Init Container that checks whether the database is up, and this Init Container will complete only when the database is up.

Add an Init Container to data-script service that will keep checking until the database is up with the following command:


['sh', '-c', "until mysql -h ${MYSQL_DB_HOST} -u ${MYSQL_USER} -p${MYSQL_USER_PASSWORD} -e 'show databases;'; do echo waiting for mydb; sleep 2; done"]

 

You would need to add env variables to init container as well (MYSQL_DB_HOST,MYSQL_USER,MYSQL_USER_PASSWORD). Reference them from a kubernetes secret

TASK #4:

Our data service is currently not using any persistent storage, so if the data service pod restarts all the data will be gone. MySQL stores it's data in this folder - /var/lib/mysql

Make sure that data service is using Persistent Volume (backed by EBS) to store data on MySQL storage directory

Note: Save all the files created in this assignment somewhere as you will need them in the future assignments



# Minikube on EC2 and deploy

# install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# start a local cluster using Docker
minikube start --driver=docker

# create a namespace for the app
kubectl create namespace quotes

# apply resources in a good order
kubectl apply -n quotes -f k8s/data-deployment.yaml -f k8s/data-service.yaml
kubectl rollout status -n quotes deploy/data

kubectl apply -n quotes -f k8s/data-script-deployment.yaml   # seeder (we’ll convert to Job later)
# optional: watch logs to confirm it ran once
kubectl logs -n quotes deploy/data-script --tail=100 || true

kubectl apply -n quotes -f k8s/back-deployment.yaml -f k8s/back-service.yaml
kubectl rollout status -n quotes deploy/back

kubectl apply -n quotes -f k8s/api-service.yaml

kubectl apply -n quotes -f k8s/front-deployment.yaml -f k8s/front-service.yaml
kubectl rollout status -n quotes deploy/front