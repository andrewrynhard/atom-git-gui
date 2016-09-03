path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'

module.exports =
  class GitGuiStatusView extends View
    @content: ->
      @div class: 'status-view', =>
        @ol class: 'list-group', id: 'status-list'

    initialize: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      $(document).ready () =>
        $('#status-list').on 'click', '#staging-area-file', (e) =>
          fileName = $(e.target).data("file")
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.refreshIndex()
            .then (index) =>
              # Reset the file if staged
              if $(e.target).hasClass 'icon icon-check'
                $(e.target).removeClass 'icon icon-check'
                repo.getHeadCommit()
                .then (commit) ->
                  Git.Reset.default repo, commit, fileName
                .then () =>
                  index.write()
                  @setStatuses()
              # Stage the file
              else
                $(e.target).addClass 'icon icon-check'
                index.addByPath fileName
                .then () =>
                  index.write()
                  @setStatuses()
          .catch (error) ->
            console.log error

    serialize: ->

    destroy: ->

    setStatuses: ->
      $('#status-list').empty()
      $('#commit-action').removeClass 'available'

      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) ->
        repo.getStatus()
        .then (statuses) ->
          for file in statuses
            a = $("<a id='staging-area-file' data-file='#{file.path()}'>#{file.path()}</a>")
            div = $("<div class='inline-block'></div>")
            li = $("<li class='list-item'></li>")
            li.append div
            li.append a
            if file.inIndex()
              $('#commit-action').addClass 'available'
              a.addClass 'icon icon-check'
            if file.isNew()
              div.addClass 'status status-added icon icon-diff-added'
              value = parseInt($('#added-badge').text(), 10) + 1
              $('#added-badge').text(value)
            if file.isModified()
              value = parseInt($('#modified-badge').text(), 10) + 1
              $('#modified-badge').text(value)
              div.addClass 'status status-modified icon icon-diff-modified'
            if file.isDeleted()
              value = parseInt($('#removed-badge').text(), 10) + 1
              $('#removed-badge').text(value)
              div.addClass 'status status-removed icon icon-diff-removed'
            if file.isRenamed()
              value = parseInt($('#renamed-badge').text(), 10) + 1
              $('#renamed-badge').text(value)
              div.addClass 'status status-renamed icon icon-diff-renamed'
            if file.isIgnored()
              value = parseInt($('#ignored-badge').text(), 10) + 1
              $('#ignored-badge').text(value)
              div.addClass 'status status-ignored icon icon-diff-ignored'
            $('#status-list').append li
      .catch (error) ->
        console.log error
