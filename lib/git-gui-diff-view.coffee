{$, View} = require 'space-pen'
Git = require 'nodegit'

class GitGuiDiffView extends View
  selectedLines: []

  @content: ->
    @div class: 'git-gui-diff-view', =>
      @button class: 'btn', click: 'close', 'Close'
      @div id: 'diff-text'

  initialize: ->
    $(document).ready () =>
      $('body').on 'click', '.git-gui-diff-view-hunk-line.status-added, .git-gui-diff-view-hunk-line.status-removed', (e) =>
        $(e.target).addClass('staged')
        line = $(e.target).data 'line'
        @selectedLines.push line

  serialize: ->

  destroy: ->

  close: ->
    $('#diff-text').empty()
    $('.git-gui').removeClass 'expanded'
    $('.git-gui-overlay').removeClass 'fade-and-blur'
    $('.git-gui-diff-view').removeClass 'open'
    if @selectedLines.length > 0
      pathToRepo = $('#git-gui-project-list').find(':selected').data('repo')
      Git.Repository.open pathToRepo
      .then (repo) =>
        repo.stageLines(@filename, @selectedLines, false)
        .then () =>
          atom.notifications.addInfo("Staged #{@selectedLines.length} hunks")
          @selectedLines.length = 0
        .catch (error) ->
          console.log error


  setDiffText: (filename, diff) ->
    @filename = filename
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
            $(hunkLine).data 'line', line
          if String.fromCharCode(line.origin()) == '-'
            $(hunkLine).addClass 'status status-removed'
            $(hunkLine).data 'line', line
          $(hunkDiv).append hunkLine
      .catch (error) ->
        return reject error
      .done () ->
        return resolve hunkDiv
    return promise

  stageLine: () ->

module.exports = GitGuiDiffView
