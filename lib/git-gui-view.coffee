path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'
GitGuiSettingsView = require './git-gui-settings-view'

module.exports =
  class GitGuiView extends View
    @content: ->
      @div class: 'git-gui', id: 'container', =>
        @div class: 'block', style: 'width: 100%', =>
          # @div class: 'git-gui-status', =>
          #   @span class: 'badge icon icon-diff-ignored', id: 'ignored-badge', 0
          #   @span class: 'badge icon icon-diff-added', id: 'added-badge', 0
          #   @span class: 'badge icon icon-diff-modified', id: 'modified-badge', 0
          #   @span class: 'badge icon icon-diff-removed', id: 'removed-badge', 0
          #   @span class: 'badge icon icon-diff-renamed', id: 'renamed-badge', 0
          @div class: 'select-list', =>
            @ol class: 'list-group', id: 'status-list', =>
          @subview 'gitGuiSettingsMenu', new GitGuiSettingsView()

    initialize: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      $(document).ready () =>
        $('#status-list').on 'click', '#unstaged-file', (e) =>
          fileName = $(e.target).data("file")
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.refreshIndex()
            .then (index) =>
                if $(e.target).hasClass 'icon icon-check'
                  $(e.target).removeClass 'icon icon-check'
                  repo.getHeadCommit()
                  .then (commit) =>
                    Git.Reset.default repo, commit, fileName
                  .then () =>
                    index.write()
                else
                  $(e.target).addClass 'icon icon-check'
                  index.addByPath fileName
                  .then () =>
                    index.write()
          .catch (error) ->
            console.log error

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      # @gitGuiSettingsMenu.destroy()
      # @gitConfig.destroy()

    setStatuses: ->
      $('#status-list').empty()
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) =>
        repo.getStatus()
        .then (statuses) =>
          for file in statuses
            a = ''
            if file.inIndex()
              a = "<a class='icon icon-check' id='unstaged-file' data-file='#{file.path()}'>#{file.path()}</a>"
            else
              a = "<a id='unstaged-file' data-file='#{file.path()}'>#{file.path()}</a>"
            if file.isNew()
              value = parseInt($('#added-badge').text(), 10) + 1;
              $('#added-badge').text(value);
              $('#status-list').append "<li class='list-item'><div class='inline-block status status-added icon icon-diff-added'></div>#{a}</li>"
            if file.isModified()
              value = parseInt($('#modified-badge').text(), 10) + 1;
              $('#modified-badge').text(value);
              $('#status-list').append "<li class='list-item'><div class='inline-block status status-modified icon icon-diff-modified'></div>#{a}</li>"
            if file.isDeleted()
              value = parseInt($('#removed-badge').text(), 10) + 1;
              $('#removed-badge').text(value);
              $('#status-list').append "<li class='list-item'><div class='inline-block status status-removed icon icon-diff-removed'></div>#{a}</li>"
            if file.isRenamed()
              value = parseInt($('#renamed-badge').text(), 10) + 1;
              $('#renamed-badge').text(value);
              $('#status-list').append "<li class='list-item'><div class='inline-block status status-renamed icon icon-diff-renamed'></div>#{a}</li>"
            if file.isIgnored()
              value = parseInt($('#ignored-badge').text(), 10) + 1;
              $('#ignored-badge').text(value);
              $('#status-list').append "<li class='list-item'><div class='inline-block status status-ignored icon icon-diff-ignored'></div>#{a}</li>"
      .catch (error) ->
        console.log error
