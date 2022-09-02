FROM node:alpine
# Set the working directory
WORKDIR /usr/src/app

# The way a docker file works is it goes line by line, and if the image
# has been built before, it will use a cache to quickly build the image *unless*
# changes have been made. Once the dockerfile encounters a line where changes have been made,
# the caching stops, and the dockerfile runs the rest of the lines as if it 
# had never seen them before. Therefore, as this file (package.json) is unlikely to change, 
# this means it will be cached and so it won't take as much time to get all of the dependencies. 
# This is why this line is placed at the top - because otherwise if changes are made, and then 
# this line appears, docker won't use caching - and it will take a while to install the dependencies. 
COPY ./package.json ./
# We are able to run these npm commands (npm is a package manager)
# as "node:alpine" comes with npm installed.
RUN npm install -g npm@latest
RUN npm install express
# Copy everything from the current working directory over to the 
# container's current working directory. It is very likely that there will be changes here,
# and thus this is why "COPY ./package.json ./" appeared above separately.
COPY ./ ./ 
# Allow port 300
EXPOSE 3000
# Start the app
CMD ["node", "app.js"]
