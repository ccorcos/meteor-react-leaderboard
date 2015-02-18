# Coffeescript looks a lot nice when you can pass as an array
# although we could just use an object with specified keys...
r = (type, props, children...) ->
  childrenArray = _.flatten children
  args = [].concat([type], [props], childrenArray)
  React.createElement.apply React, args


Player = React.createClass
  displayName: 'Player'
  propTypes: 
    player: React.PropTypes.object
    selected: React.PropTypes.bool
  getDefaultProps: ->
    selected: false
    player:
      _id: 0
      name: ''
      score: 0
  render: ->
    classes = React.addons.classSet
      'player': true
      'selected': @props.selected
    return r 'div', {className:classes, onClick: => Session.set('selectedPlayerId', @props.player._id)}, [
      r 'span', {className:"name"}, @props.player.name
      r 'span', {className:"score"}, @props.player.score
    ]


Leaderboard = React.createClass
  displayName: 'Leaderboard'
  propTypes: 
    players: React.PropTypes.array
    # selectedPlayerId: React.PropTypes.string
  getDefaultProps: ->
    players: []
    selectedPlayerId: ''
  render: ->
    players = @props.players.map (player) => r(Player, {player: player, selected: (@props.selectedPlayerId is player._id)})
    board = r('div', {className: "leaderboard"}, players)
    selectedPlayer = Players.findOne(@props.selectedPlayerId)
    if selectedPlayer
      incScore = r 'div', {className: "details"}, [
        r 'span', {className: "name"}, selectedPlayer.name
        r 'button', {className: "inc", onClick: => Players.update(selectedPlayer._id, {$inc: {score: 5}})}, 'Add 5 points'
      ]
      return r 'div', {}, [board, incScore]
    else
      return r 'div', {}, [board, r('div', {className:"message"}, 'Click a player to select')]

appState = ->
  players = Players.find({}, { sort: { score: -1, name: 1 } }).fetch()
  selectedPlayerId = Session.get('selectedPlayerId')
  return {players, selectedPlayerId}

Meteor.startup ->
  Tracker.autorun ->
    app = r 'div', {className:"outer"}, [
      r 'div', {className: "logo"}
      r 'h1', {className: "title"}, 'Leaderboard'
      r 'div', {className: "subtitle"}, 'Select a scientist to give them points'
      r(Leaderboard, appState())
    ]
    React.render(app, document.body)

