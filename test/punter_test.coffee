request = require('supertest')
_ = require('underscore')
should = require('chai').should()


before ->
  @db = require('mongoose').connect "mongodb://localhost//yow_game"
  @app = require('../src/app').server
    db: @db

after ->
  @db.disconnect()

describe 'punters API', -> 
  wellFormedPunter = 
    fullName: 'Full Name'
    emailAddress: 'jim@test'
    company: 'Company'
  
  punterWithMissingRequiredField = 
    fullName: 'fred'

  punterWithBlankRequiredField = 
    fullName: ''
    emailAddress: ''
    company: ''


  describe  'POST /punters', ->

    beforeEach ->
      @req = request(@app).post('/punters')

    describe 'as a form', -> 
      beforeEach ->
        @req = @req.type('form')

      it 'rejects the request', (done) ->
        @req
        .send({ wibble:true })
        .expect(400, done)

      it 'accepts a well formed punter', (done) ->
        @req
        .send(wellFormedPunter)
        .expect('Location', /punters\/[a-f0-9]+$/)
        .expect(302, done)

    describe 'with json', ->
      it_rejects  = (description, content) ->
        it "rejects #{description}", (done)->
          @req.send(content)
          .expect(400, done)

      beforeEach ->
        @req = @req.type('application/json')

      it 'should not accept empty content', (done) ->
        @req.expect(400, done)
      
      it 'should accept a well formed punter', (done) ->
        @req
        .send(wellFormedPunter)
        .expect('Location', /punters\/[a-f0-9]+$/)
        .expect(302, done)

      it_rejects 'a blank punter', {}

      it_rejects 'a punter with missing required fields', punterWithMissingRequiredField

      it_rejects 'a punter with blank fields', punterWithBlankRequiredField

      describe 'that has unsafe fields', ->
        it 'should not allow id information', (done) ->
          unsafePunter = _.extend {}, wellFormedPunter, 
            _id: 1
          
          @req
          .send(unsafePunter)
          .expect(400, done)

        it 'should not allow version information', (done) ->
          unsafePunter = _.extend {}, wellFormedPunter, 
            __v:10
          
          @req
          .send(unsafePunter)
          .expect(400, done)

  describe 'GET /punters/:id', -> 
    describe 'with an existing punter', ->
      beforeEach (done) ->
        request(@app)
        .post('/punters')
        .type('application/json')
        .send(wellFormedPunter)
        .end (err, res) =>
          @existingUrl = res.header.location
          done(err)
    
      it 'display the punter', (done) ->
        request(@app)
        .get(@existingUrl)
        .expect(200)
        .end (err,res) ->
          _.pick(res.body, _.keys(wellFormedPunter)).should.deep.equal wellFormedPunter
          done(err)

