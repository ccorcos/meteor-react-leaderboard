
# Coffee Syntax Jazz
build_tag = (tag) ->
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object' and not _.isArray(options[0])
    React.DOM[tag].apply @, options

DOM = do ->
  object = {}
  for element in Object.keys(React.DOM)
      object[element] = build_tag element
  object

ReactClass = (args...) ->
  Element = React.createClass.apply React, args
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object' and not _.isArray(options[0])
    React.createElement.apply React, [Element].concat(options) 



# Destructure what we need
{div, span, button, h1} = DOM

Player = ReactClass
  mixins: [React.addons.PureRenderMixin]
  
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

  selectPlayer: ->
    Session.set 'selectedPlayerId', @props.player._id

  render: ->

    classes = React.addons.classSet
      'player': true
      'selected': @props.selected

    # coffeescript ignores newlines. human taste buds do not.
    div 
      className: classes
      , onClick: @selectPlayer
    , [ 
      span 
        className: "name"
      , @props.player.name
      span 
        className: "score"
      , @props.player.score
    ]


Leaderboard = ReactClass
  mixins: [React.addons.PureRenderMixin]
  displayName: 'Leaderboard'
  propTypes:
    players: React.PropTypes.array
    # selectedPlayerId: React.PropTypes.string
  getDefaultProps: ->
    players: []
    selectedPlayerId: ''
  incPlayerScore: ->
    Players.update @selectedPlayer._id
    , 
      $inc:
        score: 5
  render: ->

    players = @props.players.map (player) =>
      Player 
        player: player
      , 
        selected: @props.selectedPlayerId is player._id

    board = (div {className: "leaderboard"}, players)

    @selectedPlayer = Players.findOne @props.selectedPlayerId

    if @selectedPlayer
      div [
        board
        div 
          className: "details"
        , [
          span
            className: "name"
          , @selectedPlayer.name
          button 
            className: "inc", onClick: @incPlayerScore
          , 'Add 5 points'     
        ]
      ]
    else
      div [
        board
        div
          className: "message"
        , 'Click a player to select'
      ]

appState = ->
  players = Players.find {}
  , 
    sort:
      score: -1, name: 1
  .fetch()
  selectedPlayerId = Session.get 'selectedPlayerId'
  return {players, selectedPlayerId}

RenderDom = (component) -> React.render component, document.body


Meteor.startup ->
  Tracker.autorun ->
    RenderDom div 
      className:"outer"
    , [
        div  
          className: "logo"
        h1   
          className: "title"
        ,    'Leaderboard'
        div  
          className: "subtitle"
        , 'Select a scientist to give them points'
        Leaderboard appState()
      ]
