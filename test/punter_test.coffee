request = require('supertest')
_ = require('underscore')
should = require('chai').should()

app = require('../src/app').app

describe 'punters API', -> 
  wellFormedPunter = 
    fullName: 'Full Name'
    emailAddress: 'jim@test'
    company: 'Company'

  
  describe  'POST /punters', ->

    beforeEach ->
      @req = request(app).post('/punters')

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
      beforeEach ->
        @req = @req.type('application/json')

      it 'should not accept a blank punter', (done) ->
        @req.send({})
        .expect(400, done)

      it 'should not accept empty content', (done) ->
        @req.expect(400, done)
      
      it 'should accept a well formed punter', (done) ->
        @req
        .send(wellFormedPunter)
        .expect('Location', /punters\/[a-f0-9]+$/)
        .expect(302, done)

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
        request(app)
        .post('/punters')
        .type('application/json')
        .send(wellFormedPunter)
        .end (err, res) =>
          @existingUrl = res.header.location
          done(err)
    
      it 'display the punter', (done) ->
        request(app)
        .get(@existingUrl)
        .expect(200)
        .end (err,res) ->
          _.pick(res.body, _.keys(wellFormedPunter)).should.deep.equal wellFormedPunter
          done(err)

