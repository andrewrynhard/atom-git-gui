path = require 'path'
{$, View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
  class GitGuiCommitView extends View
    @content: ->
      @div =>
        @h2 "Subject"
        @subview 'subjectEditor', new TextEditorView(mini: true)
        @h2 "Body"
        @subview 'bodyEditor', new TextEditorView()

    initialize: ->

    destroy: ->
