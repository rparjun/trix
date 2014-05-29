#= require trix/lib/helpers

{defer} = Trix.Helpers

class Trix.MutationObserver
  options =
    attributes: true
    childList: true
    characterData: true
    subtree: true

  constructor: (@element) ->
    @observer = new window.MutationObserver @didMutate
    @start()

  start: ->
    @observer.observe(@element, options)

  stop: ->
    @observer.disconnect()

  didMutate: (mutations) =>
    significantMutations = @findSignificantMutations(mutations)
    if significantMutations.length
      defer => @delegate?.elementDidMutate?(significantMutations)

  # Private

  findSignificantMutations: (mutations) ->
    mutation for mutation in mutations when @mutationIsSignificant(mutation)

  mutationIsSignificant: (mutation) ->
    return true for node in @nodesModifiedByMutation(mutation) when @nodeIsEditable(node)
    false

  nodeIsEditable: (node) ->
    node?.nodeType is Node.ELEMENT_NODE and node.isContentEditable

  nodesModifiedByMutation: (mutation) ->
    nodes = []
    switch mutation.type
      when "attributes"
        # Ignore attribute changes made to the outermost element
        nodes.push(mutation.target) unless mutation.target is @element
      when "characterData"
        # Changes to text nodes should consider the parent element
        nodes.push(mutation.target.parentNode)
      when "childList"
        # Consider each added or removed node
        nodes.push(mutation.addedNodes...)
        nodes.push(mutation.removedNodes...)
    nodes