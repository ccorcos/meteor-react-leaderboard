# Coffee Syntax Jazz
build_tag = (tag) ->
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object' and not _.isArray(options[0])
    React.DOM[tag].apply @, options

@DOM = do ->
  object = {}
  for element in Object.keys(React.DOM)
      object[element] = build_tag element
  object

@ReactClass = (args...)->
  Element = React.createClass.apply(React, args)
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object' and not _.isArray(options[0])
    React.createElement.apply(React, [Element].concat(options))

