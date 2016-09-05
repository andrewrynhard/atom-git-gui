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

    setDiffText: (filename, diff) ->
      $('#diff-text').empty()
      diff.patches()
      .then (patches) ->
        for patch in patches
          if patch.newFile().path() != filename
            continue
          patch.hunks()
          .then (hunks) ->
            for hunk in hunks
              hunk.lines()
              .then (lines) ->
                text = 'diff ' + patch.oldFile().path() + ' ' + patch.newFile().path() + '\n'
                text += hunk.header()
                for line in lines
                  if String.fromCharCode(line.origin()) == '+'
                    console.log '+'
                  if String.fromCharCode(line.origin()) == '-'
                    console.log '-'
                  text += String.fromCharCode(line.origin()) + line.content()
                $('#diff-text').append text
