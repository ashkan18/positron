#
# Library of retrieval, persistance, validation, json view, and domain logic for the "authors" resource.
#

{ extend, omit } = require 'underscore'
db = require '../../lib/db'
async = require 'async'
Joi = require 'joi'
Joi.objectId = require('joi-objectid') Joi
{ ObjectId } = require 'mongojs'
{ API_MAX, API_PAGE_SIZE } = process.env

#
# Schemas
#
@schema = ( ->
  id: @objectId()
  name: @string().allow('')
  bio: @string().allow('')
  image_url: @string().allow('')
  twitter_handle: @string().allow('')
).call Joi

@querySchema = (->
  q: @string().allow('')
  limit: @number().max(Number API_MAX).default(Number API_PAGE_SIZE)
  offset: @number()
  count: @boolean().default(false)
).call Joi

#
# Retrieval
#
@find = (id, callback) ->
  query = if ObjectId.isValid(id) then { _id: ObjectId(id) } else { name: id }
  db.authors.findOne query, callback

@where = (input, callback) ->
  Joi.validate input, @querySchema, (err, input) =>
    return callback err if err
    cursor = db.authors
      .find({})
      .limit(input.limit)
      .sort($natural: -1)
      .skip(input.offset or 0)
    async.parallel [
      (cb) -> cursor.toArray cb
      (cb) ->
        return cb() unless input.count
        cursor.count cb
      (cb) ->
        return cb() unless input.count
        db.authors.count cb
    ], (err, [authors, authorCount, total]) =>
      callback err, {
        total: total if input.count
        count: authorCount if input.count
        results: authors.map(@present)
      }

#
# Persistence
#
@save = (input, callback) ->
  Joi.validate input, @schema, (err, input) =>
    return callback err if err
    data = extend omit(input, 'id'),
      _id: ObjectId(input.id)
    db.authors.save data, callback

@destroy = (id, callback) ->
  db.authors.remove { _id: ObjectId(id) }, callback

#
# JSON views
#
@present = (author) =>
  extend
    id: author?._id?.toString()
  , omit(author, '_id')