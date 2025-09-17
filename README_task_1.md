# docker-to-k8s-migration
Build an API based Quotes App with docker-compose and migrate to Kubernetes

Note: this assignment could be used in your interviews as well - as it’s a full-scale migration of an app to containers.

This assignment is designed to educate you about deploying and managing the services with both docker-compose and Kubernetes. To achieve this,  you will develop a mini API (Application Programming Interface) application. The app creates an API to read and store quotes in a MySQL database. This is a typical project repository that you will see in many companies. We are using API service that works with quotes, in a real company the API service will probably do something more meaningful and important, but it will be exactly like this except for the code of the application. Try to understand how everything works and do not follow the steps blindly.

Note: You must be logged in to your GitHub account, which has access to 312 BC GitHub Organization

Prior to start:

Create an EC2 instance (t2.micro) with public IP and SSH into it.

Create an app folder on your instance.  Inside the app folder, create a file tree like shown in the following diagram:

What does each service do:

back: an API server container. This a backend, so all API requests will reach this service in the end, whether you reach it through front service or call it directly

data-script: a service which creates database schema and adds sample quotes into a database

data: a database containing the quotes

front: a frontend Web UI (User Interface) for the project. Note that it's also possible to execute API calls without this frontend service, you can do it by executing API calls with curl or any other HTTP client against back service directly

 

Now let's create these services.

 

Back service:

Content of the “back.py” file can be found in this repository. 

Explanation of what back.py does:
“back.py” is a python based code for an application that will serve as an API service with 2 routes/paths and will listen on port 3000: /api/v1/get-quote" and "/api/v1/set-quote"."/api/v1/get-quote" will return a random quote from a database when using a GET request "/api/v1/set-quote" will add a quote to a database when using a  POST request. The database definition is defined under the “app.config” directive in the back.py file (line 11) (it has been already set so no need to change it).


You need to write a Dockerfile for back service yourself:
Base image should be python:3.6.
Container should listen to port 3000 (use EXPOSE instruction).
The working directory must be set to /app (use WORKDIR).

Content of the “requirements.txt” file you can find in this repo.
Explanation: requirements.txt contains a list python package that must be installed inside a container image

Add the requirements.txt to image and install packages inside the image using these instructions: COPY requirements.txt /appRUN pip install -r requirements.txt

The final step is to initialize the API code as the container launches.
COPY back.py /appCMD python back.py

Data service:

Now, the data service is to be configured. Write Dockerfile for data service:
Data service should run based on mysql:5.7 image and should listen to 3306 port.


Data-script service:

Moving on to the data-script service.
mydatabase.sql is a SQL script that creates a database schema(table) and adds sample quotes into database table .
You can find this SQL script in the same repo

import.sh is a shell script that will inject above SQL script into a database using mysql command
You can find this script in the same repo 

Write a Dockerfile that will:Have alpine as a base image.Update all current packages with apk
Install mysql-client package with apk
Copy both import.sh and mydatabase.sql to /opt and make /opt a working directory.
import.sh should run when a container starts

Front service:

Next, is the front service. Same as before, all the files except for the Dockerfile can be found in the same repo . 

requirements.txt serves the same purpose as in back service - to install packages.

front.py is a python based code for an application that will serve as a Web UI service with 1 route/path (Links to an external site.) and will listen on port 3001 (Links to an external site.). When you go to http://front_service_ip:3001/hello/marsel (Links to an external site.) (you can put your name instead of marsel) in your browser, it will greet you and get a random quote for you by calling an API call to back service (Links to an external site.)

In the templates folder, you can find index.html and layout.html files that build the Web interface.
front.py uses index.html. And index.html references layout.html

Write a Dockerfile that will build front service image:Front service image must be based on python:3.6 image and listen to 3001 port.
Copy all the files in the front service folder (/app/front/) to /app folder inside a container image Working directory must be specified as /appPackages in the requirements.txt must be installed.
After that, front.py must start with python when a container starts. 

Create docker-compose to deploy everything:

We had already created a ready docker-compose yaml for you (link ). You just need to review the contents of it and try to understand what each directive does and means.

Once you understand what this docker-compose yaml does, copy the docker-compose.yml and build all the images with:docker-compose build

Then run all the containers:docker-compose up -d

Test the API service(back) using Curl:

In order to test our API is responding use curl command

curl -X GET -i  http://localhost:3000/api/v1/get-quote

This should be your response with any random quote from the database

HTTP/1.0 200 OKContentType: application/jsonContent-Type: text/html; charset=utf-8Content-Length: 146Server: Werkzeug/0.14.1 Python/3.6.9Date: Thu, 26 Dec 2019 12:52:56 GMT

 {"random_quote": "Every great story on the planet happened when someone decide not to give up, but kept going no matter what. -- Spryte Loriano"}

Try to test the POST request and insert your own quote this way:

curl -i -H "Content-Type: application/json" -X POST  \
-d '{"quote":"To find a fault is easy; to do better may be difficult. -- Plutarch"}' http://localhost:3000/api/v1/set-quote

 

See the contents(quotes) in a database:

Check if the services are running with this command (it's expected that data-script has already exited since it completed it's job):
docker-compose ps

Go inside the database container:docker exec -it db sh

Enter MySQL prompt with this command (password):mysql -u root -p

List databases in MySQL with this command:
show databases;

Switch to mydatabase database with these command:
use mydatabase;

List tables inside this database with this command:
show tables;

List contents of the quotes table with this command:
select * from quotes;

These are the quotes you are getting when you execute /api/v1/get-quote API call to back service. And when you execute /api/v1/set-quote API call to back service, the quote gets added to this table.

Add a sample quote to a database using a POST request with /api/v1/set-quote API call to back service. Verify that the quote has been added by listing contents of quotes table

Test the API service(back) using Front service (use browser to access Front service):

Front service is listening on port 3001 (Links to an external site.) of localhost because we bound container port to localhost port. When you go to http://localhost:3001/hello/marsel (put your name or any word instead of marsel) in your browser, it will greet you and get a random quote for you by calling an API call to back service. And back service will retrieve a quote from the database.

Push our images to DockerHub:

Now log in to your DockerHub account with docker login.

Build and push 4 separate images for all 4 services like this (example for back service):cd backdocker build -t <username>/quotes-back:v1 .docker push <username>/quotes-back:v1

Now as we have our images on DockerHub, we no longer need build sections in our docker-compose file. Instead of build directive, add image directive for each service with images you created in previous steps (<username>/quotes-back:v1 for back service, <username>/quotes-front:v1 for front service, etc.). Image is specified in docker-compose like this:

Using Kompose to convert docker-compose to Kubernetes yaml files:

Now we migrate from local Docker Compose to Kubernetes with Kompose tool. kompose is a tool to help users familiar with docker-compose move to Kubernetes. It takes a Docker Compose file and translates it into Kubernetes resources.
To install kompose, follow these commands depending on your operating system:

#Linux:curl -L https://github.com/kubernetes/kompose/releases/download/v1.20.0/kompose-linux-amd64    -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose

#macOS:curl -L https://github.com/kubernetes/kompose/releases/download/v1.20.0/kompose-darwin-amd64    -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose


Now to convert the Compose file to Kubernetes resources files use:

kompose convert -f docker-compose.yml

As a result, you should get:

INFO Network myapp is detected at Source, shall be converted to equivalent NetworkPolicy at Destination
INFO Network myapp is detected at Source, shall be converted to equivalent NetworkPolicy at Destination
INFO Network myapp is detected at Source, shall be converted to equivalent NetworkPolicy at Destination
INFO Network myapp is detected at Source, shall be converted to equivalent NetworkPolicy at Destination
INFO Kubernetes file "back-service.yaml" created
INFO Kubernetes file "data-service.yaml" created
INFO Kubernetes file "front-service.yaml" created
INFO Kubernetes file "back-deployment.yaml" created
INFO Kubernetes file "myapp-networkpolicy.yaml" created
INFO Kubernetes file "data-deployment.yaml" created
INFO Kubernetes file "myapp-networkpolicy.yaml" created
INFO Kubernetes file "data-script-deployment.yaml" created
INFO Kubernetes file "myapp-networkpolicy.yaml" created
INFO Kubernetes file "front-deployment.yaml" created
INFO Kubernetes file "myapp-networkpolicy.yaml" created

Note that the above creates NetworkPolicies as well, it's an advanced routing/firewall feature and it's optional. It's okay if you are not familiar with NetworkPolicies yet.

Review all the Kubernetes yaml files created and compare to docker-compose. No need to deploy them into Kubernetes yet in this assignment because you would need to slightly adjust the yaml files.

 

Save the result files somewhere as you might need them in the future assignments





# minikube
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