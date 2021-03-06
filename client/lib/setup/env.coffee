#
# Sets the app up for enviornment-specific configurations
#

path = require 'path'
sd = require('sharify').data
{ NODE_ENV } = process.env

module.exports = (app) ->

  # Compile assets on request in development
  if 'development' is NODE_ENV
    app.use require('stylus').middleware
      src: path.resolve(__dirname, '../../')
      dest: path.resolve(__dirname, '../../public')
    app.use require('browserify-dev-middleware')
      src: path.resolve(__dirname, '../../')
      globalTransforms: [
        require('envify')
      ]
      transforms: [
        require('babelify'),
        require('caching-coffeeify'),
        require('jadeify')
      ]
      debug: true
      detectGlobals: false
      noParse: [require.resolve('jquery')]

  # Mount antigravity in test
  if 'test' is NODE_ENV
    app.use '/__gravity', require('antigravity').server
