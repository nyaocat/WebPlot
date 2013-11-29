#!/bin/sh
npm install
make
coffee -bc public/js/
forever stop app.coffee
forever start -c coffee app.coffee
