
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

ReactClass = (args...)->
  Element = React.createClass.apply(React, args)
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object' and not _.isArray(options[0])
    React.createElement.apply(React, [Element].concat(options))



# Destructure what we need
{div, span, button, h1} = DOM

Player = ReactClass

  displayName: 'Player'

  propTypes:
    playerId: React.PropTypes.string

  selectPlayer: ->
    Session.set('selectedPlayerId', @props.playerId)

  getInitialState: ->
    {player: {name: "", score: "", id: ""}}

  componentWillMount: ->
    self = this
    Tracker.autorun ->
      self.setState
        'player': Players.findOne(self.props.playerId),
        'isSelected': Session.equals('selectedPlayerId', self.props.playerId)

  render: ->
    classes = React.addons.classSet
      'player': true
      'selected': @state.isSelected

    (div {className:classes, onClick: @selectPlayer}, [
      (span {className: "name" }, @state.player.name )
      (span {className: "score"}, @state.player.score)
    ])

Toolbar = ReactClass

  getInitialState: ->
    {selectedPlayer: null}

  componentWillMount: ->
    self = this
    Tracker.autorun ->
      try
        playerId = Session.get('selectedPlayerId')
        if _.isString(playerId) and playerId.length > 0
          self.setState({selectedPlayer: Players.findOne({_id: playerId})})
      catch e
        console.log(e)

  incPlayerScore: ->
    Players.update(@state.selectedPlayer._id, {$inc: {score: 5}})

  render: ->
    if @state.selectedPlayer
      (div {className: "details"}, [
        (span   {className: "name"}, @state.selectedPlayer.name)
        (button {className: "inc", onClick: @incPlayerScore}, 'Add 5 points'     )
      ])
    else
      (div {className:"message"}, 'Click a player to select')

Leaderboard = ReactClass

  displayName: 'Leaderboard'

  propTypes:
    playerIds: React.PropTypes.array

  render: ->
    players = @props.playerIds.map (playerId) =>
      (Player {playerId: playerId, key: playerId})

    (div [
      (div {className: "leaderboard"}, players)
      (Toolbar())
    ])


appState = ->
  players = Players.find({}, { fields: { _id: 1 }, sort: { score: -1, name: 1 } }).fetch()
  playerIds = _.pluck players, '_id'
  {playerIds}

RenderDom = (component) -> React.render(component, document.body)


Meteor.startup ->
  Tracker.autorun ->
    state = appState()
    Tracker.nonreactive ->
      RenderDom (div {className:"outer"}, [
                  (div  {className: "logo"})
                  (h1   {className: "title"},    'Leaderboard')
                  (div  {className: "subtitle"}, 'Select a scientist to give them points')
                  (Leaderboard appState())
                ])
