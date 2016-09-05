{$, View} = require 'space-pen'

module.exports =
  class GitGuiDiffView extends View
    @content: ->
      @div class: 'git-gui-diff-view', =>
        @button class: 'btn', click: 'close', 'Close'
        @div id: 'diff-text'

    initialize: ->

    serialize: ->

    destroy: ->

    close: ->
      $('#diff-text').empty()
      $('.git-gui').removeClass 'expanded'
      $('.git-gui-overlay').removeClass 'fade-and-blur'
      $('.git-gui-diff-view').removeClass 'open'
