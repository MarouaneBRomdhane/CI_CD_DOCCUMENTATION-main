# create dockerfile 
fill it with this at first :

```
FROM node:20.5.1-alpine3.18 as dev
WORKDIR /app
COPY package*.json  .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm","start"] 
```
# run the Image

```
sudo docker build -t sardina 
```
# sardina refers to the image name and can be any name

# Now to optimize the images we go to this code

```FROM node:20.5.1-alpine3.18 as dev
WORKDIR /app
COPY package*.json  .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm","start"] 

FROM node:20.5.1 as build
WORKDIR /app
COPY package*.json  .
RUN npm install
COPY . .
RUN npm run build 


FROM nginx:stable-alpine as prod
WORKDIR /usr/share/nginx/html
COPY --from=build  /app/build  .
```

# For the command is the same as earlier however change the name ofc 

```
sudo docker build -t wrata
```

# show the existing container

please note that once running the previous command will automatically create its own container.

```
sudo docker ps
```

# remove the existing container 
in order to build again we need to remove the older conatiner

```
sudo docker container prune
```

# Running the image on web

to run the docker image inside the web we need to run it while giving it a port as well as mentioning the container port, the new name of the docker and then the name of the image

```
sudo docker run -p 8090:80 -d --name prod sardina
```

# add jenkins docker-compose 
we need to create a new file called "docker-compose.yml"
 # put this code that runs jenkins, sonarqube, sonarscanner, nexus
 ```
 # docker-compose.yaml
# docker-compose.yaml
version: '3.3'
services:
  jenkins:
    image: jenkins/jenkins:jdk11
    privileged: true
    user: root
    ports:
      - 8080:8080
      - 50000:50000
    container_name: jenkinsserver
    volumes:
      - jenkins-data:/var/jenkins_home
      - jenkins-home:/home
      - /var/run/docker.sock:/var/run/docker.sock
       
  nexus:
    image: sonatype/nexus3
    container_name: nexus
    privileged: true
    user: root
    ports:
      - 8081:8081
      - 8085:8085
    volumes:
      - /home/nexus:/nexus-data
    restart: always

  sonarqube:
    image: sonarqube
    restart: unless-stopped
    container_name: sonarqube
    environment:
      - SONARQUBE_JDBC_USERNAME=sonarqube
      - SONARQUBE_JDBC_PASSWORD=sonarpass
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonarqube
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9001:9000"
  db:
    image: postgres:13
    container_name: postgresql
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data

volumes:
  jenkins-data: {}
  jenkins-home: {}
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql:
  postgresql_data:
 ```

 # to install sonarscanner we need firstly 
```
 npm install --save-dev sonarqube-scanner
```
# then create a file sonar-scanner.properties
```
sonar.projectKey=my-project-key

sonar.projectName=My Project
sonar.projectVersion=1.0

sonar.sources=src

sonar.language=java

sonar.host.url=http://localhost:
sonar.login= (write your sonarQube token, open sonarQube > account > security > add token name > type User Token > no expiration > generate > copy and pase here )
```
# then go packages.json and add 
```

"scripts": {
  "sonar": "sonar-scanner"
}
```
# and then run this command 
```npm run sonar
```

 # to get the jenkins password we need to enter inside the docker bash using this commaand :

```
sudo docker exec -it container_name bash
# cat /var/jenkins_home/secrets/initialAdminPassword

```





