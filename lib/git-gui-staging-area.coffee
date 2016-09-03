path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'

module.exports =
  class GitGuiStatusView extends View
    @content: ->
      @div class: 'git-gui-staging-area', =>
        @ol class: 'list-group', id: 'status-list'

    initialize: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      $(document).ready () =>
        $('#status-list').on 'click', '#staging-area-file', (e) =>
          filename = $(e.target).data("file")
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.refreshIndex()
            .then (index) =>
              # Reset the file if staged
              if $(e.target).prev().hasClass 'icon-check'
                $(e.target).prev().removeClass 'icon-check'
                repo.getHeadCommit()
                .then (commit) ->
                  Git.Reset.default repo, commit, filename
                .then () =>
                  index.write()
                  @setStatuses()
              # Stage the file
              else
                $(e.target).addClass 'icon icon-check'
                index.addByPath filename
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
            li = $("<li class='list-item'></li")
            div = $("<div class='inline-block status icon'></div>")
            span = $("<span class='icon' id='status-for-#{file.path()}'></span>")
            a = $("<span id='staging-area-file' data-file='#{file.path()}'>#{file.path()}</span>")
            li.append div
            li.append span
            li.append a
            if file.inIndex()
              $('#commit-action').addClass 'available'
              span.addClass 'icon-check'
              span.addClass 'status status-added'
            if file.inWorkingTree()
              span.addClass 'status status-modified'
            if file.isNew()
              div.addClass 'status-added icon-diff-added'
              value = parseInt($('#added-badge').text(), 10) + 1
              $('#added-badge').text(value)
            if file.isModified()
              value = parseInt($('#modified-badge').text(), 10) + 1
              $('#modified-badge').text(value)
              div.addClass 'status-modified icon-diff-modified'
            if file.isDeleted()
              value = parseInt($('#removed-badge').text(), 10) + 1
              $('#removed-badge').text(value)
              div.addClass 'status-removed icon-diff-removed'
            if file.isRenamed()
              value = parseInt($('#renamed-badge').text(), 10) + 1
              $('#renamed-badge').text(value)
              div.addClass 'status-renamed icon-diff-renamed'
            if file.isIgnored()
              value = parseInt($('#ignored-badge').text(), 10) + 1
              $('#ignored-badge').text(value)
              div.addClass 'status-ignored icon-diff-ignored'
            $('#status-list').append li
      .catch (error) ->
        console.log error
