#= require trix/views/object_view
#= require trix/views/block_view

{defer} = Trix.Helpers

class Trix.DocumentView extends Trix.ObjectView
  constructor: ->
    super
    @document = @object
    {@element} = @options

  render: ->
    @childViews = []

    @element.removeChild(@element.lastChild) while @element.lastChild

    unless @document.isEmpty()
      for object in @groupObjects(@document.getBlocks())
        view = @findOrCreateCachedChildView(Trix.BlockView, object)
        @element.appendChild(view.getElement())

    @didRender()

  didRender: ->
    defer => @garbageCollectCachedViews()

  focus: ->
    @element.focus()
