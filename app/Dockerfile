FROM node:alpine
# Set the working directory.
WORKDIR /usr/src/app

# The way a docker file works is it goes line by line, and if the image
# has been built before, it will use a cache to quickly build the image *unless*
# changes have been made. Once the dockerfile encounters a line where changes have been made,
# the caching stops, and the dockerfile runs the rest of the lines as if it 
# had never seen them before. Therefore, as this file (package.json) is unlikely to change, 
# this means this top part of the file will be cached - and so it won't take as much time to
# install all of the dependencies. 

# This simply copies the file over to the docker container's working directory (specificed above
# as /usr/src/app).
COPY ./package.json ./
# Installs the dependencies.
# We are able to run these npm commands (npm is a package manager)
# as "node:alpine" comes with npm installed.
RUN npm install -g npm@latest
RUN npm install express
# Copy everything from the current working directory (the directory with the Dockerfile) over to the 
# container's current working directory.
COPY ./ ./ 
# Allow port 3000.
EXPOSE 3000
# Start the app.
CMD ["node", "app.js"]
