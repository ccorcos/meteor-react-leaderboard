
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
  mixins: [React.addons.PureRenderMixin]

  displayName: 'Player'

  propTypes:
    playerId: React.PropTypes.string

  selectPlayer: ->
    Session.set('selectedPlayerId', @props.playerId)
    console.log "new selected", Session.get('selectedPlayerId')

  componentWillMount: ->
    self = this
    Tracker.autorun ->
      self.setState 
        'player': Players.findOne(self.props.playerId)
    
    Tracker.autorun ->
      self.setState
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

  componentWillMount: ->
    self = this
    Tracker.autorun ->
      playerId = Session.get('selectedPlayerId')
      console.log "toolbar selected", playerId
      self.setState 
        'seletedPlayer': null#Players.findOne(playerId, {fields:{name:1}})

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
  mixins: [React.addons.PureRenderMixin]

  displayName: 'Leaderboard'

  propTypes:
    playerIds: React.PropTypes.array

  render: ->
    # players = {}
    # for playerId in @props.playerIds
    #   players[playerId] = (Player {playerId})

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
    RenderDom (div {className:"outer"}, [
                (div  {className: "logo"})
                (h1   {className: "title"},    'Leaderboard')
                (div  {className: "subtitle"}, 'Select a scientist to give them points')
                (Leaderboard appState())
              ])
