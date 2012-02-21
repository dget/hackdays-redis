redis = (require 'redis').createClient()

redis.on "error", (err) ->
    console.log "Error #{err}"

express = require 'express'
app = express.createServer()

app.use(express.cookieParser())
app.use(express.session({ secret: "keyboard cat" }))
app.use(express.bodyParser())

app.get '/', (req, res) ->
	redis.zrevrangebyscore 'leaderboard', '+inf', '-inf', 'withscores', (err, leaders) ->

		leaderboard = 
			for i in [0...leaders.length/2]
				{name: leaders[i*2] 
				score: leaders[i*2+1]}


		leaderboard_html = ("<li>#{leader.score} - #{leader.name}</li>" for leader in leaderboard)

		console.log leaderboard_html

		leaderboard_html = leaderboard_html.join('')
		res.send('<html><head><title>DUMB TEST APP</title></head>' + 
				 "<body><h1>Hey #{req.session.name}</h1>"  + "<a href='5pts' class='button1'>5 points</a><br /><a href='10pts' class='button2'>10 points</a>" +
				 "<ul>" + leaderboard_html + "</ul>" + 
				 '</body></html>')

app.get '/set_name', (req, res) ->
	res.send('<html><head><title>DUMB TEST APP</title></head>' + 
			 "<body><form method='post' action='/set_name'><input type='text' name='name'><button type='submit'>Submit</submit>" +
			 '</body></html>')

app.post '/set_name', (req, res) ->
	req.session.name = req.body.name
	res.redirect '/'

app.get '/5pts', (req, res) ->
	redis.zincrby 'leaderboard', 5, req.session.name
	res.redirect '/'

app.get '/10pts', (req, res) ->
	redis.zincrby 'leaderboard', 10, req.session.name
	res.redirect '/'
	

app.listen 3000