#!/bin/bash

# build single file page and copy to dist
cd webpage
npm install
webpack
cd ..

