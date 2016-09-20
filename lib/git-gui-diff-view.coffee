{$, View} = require 'space-pen'

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
    .then (patches) =>
      pathPatch = patches.filter (patch) ->
        return patch.newFile().path() == filename
      for patch in pathPatch
        patch.hunks()
        .then (hunks) =>
          for hunk in hunks
            @makeHunkDiv patch, hunk
            .then (hunkDiv) ->
              $('#diff-text').append hunkDiv
    .catch (error) ->
      console.log error

  makeHunkDiv: (patch, hunk) ->
    promise = new Promise (resolve, reject) ->
      hunkDiv = $("<div class='git-gui-diff-view-hunk'></div>")
      hunk.lines()
      .then (lines) ->
        hunkDivText = 'diff ' + patch.oldFile().path() + ' ' + patch.newFile().path() + '\n'
        hunkDivText += hunk.header()
        $(hunkDiv).text hunkDivText
        for line in lines
          hunkLine = $("<div class='git-gui-diff-view-hunk-line'></div>")
          hunkLineText = String.fromCharCode(line.origin()) + line.content()
          $(hunkLine).text hunkLineText
          if String.fromCharCode(line.origin()) == '+'
            $(hunkLine).addClass 'status status-added'
          if String.fromCharCode(line.origin()) == '-'
            $(hunkLine).addClass 'status status-removed'
          $(hunkDiv).append hunkLine
      .catch (error) ->
        return reject error
      .done () ->
        return resolve hunkDiv
    return promise

module.exports = GitGuiDiffView
