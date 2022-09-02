FROM node:alpine
# Set the working directory
WORKDIR /usr/src/app

# We first copy ./package.json alone because it is unlikely we will make changes
# to this file. This means docker will cache it so when we rebuild the docker image,
# it will not take as much time to get all of the dependencies. 
COPY ./package.json ./
# We are able to run these npm commands (npm is a package manager)
# as "node:alpine" comes with npm installed.
RUN npm install -g npm@latest
RUN npm install express
# Copy everything else from the current working directory over to the 
# container's current working directory. It is likely that there will be changes here,
# so caching is not important. 
COPY ./ ./ 
# Allow port 300
EXPOSE 3000
# Start the app
CMD ["node", "app.js"]
