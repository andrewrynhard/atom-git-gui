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
              if $("[id='status-for-#{path.basename filename}']").hasClass 'staged'
                $("[id='status-for-#{path.basename filename}']").removeClass 'staged'
                repo.getHeadCommit()
                .then (commit) =>
                  Git.Reset.default repo, commit, filename
                  .then () =>
                    index.write()
                    @updateStatuses()
              # Stage the file
              else
                if $(e.target).prev().prev().hasClass 'status-removed'
                  index.removeByPath filename
                  .then () =>
                    index.write()
                    @updateStatuses()
                else
                  index.addByPath filename
                  .then () =>
                    index.write()
                    @updateStatuses()
          .catch (error) ->
            console.log error

        $('#status-list').on 'click', '#staging-area-file-diff', (e) =>
          $('.git-gui-overlay').addClass 'fade-and-blur'
          $('.git-gui.open').toggleClass 'expanded'
          $('.git-gui-diff-view').toggleClass 'open'
          filename = $(e.target).data("file")
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.getHeadCommit()
            .then (commit) =>
              repo.getTree(commit.treeId())
              .then (tree) =>
                repo.refreshIndex()
                .then (index) =>
                  if $(e.target).data("in-working-tree")
                    Git.Diff.treeToWorkdir(repo, tree, index, null)
                    .then (diff) =>
                      @parentView.gitGuiDiffView.setDiffText filename, diff
                  else
                    Git.Diff.treeToIndex(repo, tree, index, null)
                    .then (diff) =>
                      @parentView.gitGuiDiffView.setDiffText filename, diff
          .catch (error) ->
            console.log error

        $('#status-list').on 'click', '#remove-staging-area-file', (e) =>
          filename = $(e.target).data("file")
          atom.confirm
            message: "Remove changes?"
            detailedMessage: "This will remove the changes made to:\n\t #{filename}"
            buttons:
              Ok: =>
                filename = $(e.target).data("file")
                pathToRepo = path.join atom.project.getPaths()[0], '.git'
                Git.Repository.open pathToRepo
                .then (repo) =>
                  repo.getHeadCommit()
                  .then (commit) =>
                    checkoutOptions = new Git.CheckoutOptions()
                    checkoutOptions.paths = [filename]
                    Git.Reset.reset(repo, commit, Git.Reset.TYPE.HARD, checkoutOptions)
                    .then () =>
                      @updateStatuses()
                .catch (error) ->
                  console.log error
              Cancel: ->

    serialize: ->

    destroy: ->

    updateStatuses: ->
      $('#status-list').empty()
      $('#commit-action').removeClass 'available'

      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) ->
        repo.getStatus()
        .then (statuses) ->
          for file in statuses
            li = $("<li class='list-item git-gui-status-list-item'></li")
            statusSpan = $("<span class='status icon'></span>")
            stageSpan = $("<span class='icon icon-check' id='status-for-#{path.basename file.path()}'></span>")
            fileSpan = $("<span id='staging-area-file' data-file='#{file.path()}'>#{file.path()}</span>")
            removeSpan = $("<span class='icon icon-remove-close' id='remove-staging-area-file' data-file='#{file.path()}'></span>")
            diffSpan = $("<span class='icon icon-diff' id='staging-area-file-diff' data-file='#{file.path()}' data-in-working-tree='false'></span>")
            li.append statusSpan
            li.append stageSpan
            li.append fileSpan
            if file.inIndex()
              $('#commit-action').addClass 'available'
              stageSpan.addClass 'staged'
              stageSpan.addClass 'status status-added'
            if file.inWorkingTree()
              stageSpan.addClass 'status status-modified'
              $(diffSpan).data('in-working-tree', 'true')
            if file.isNew()
              statusSpan.addClass 'status-added icon-diff-added'
            if file.isModified()
              li.append diffSpan
              li.append removeSpan
              statusSpan.addClass 'status-modified icon-diff-modified'
            if file.isDeleted()
              statusSpan.addClass 'status-removed icon-diff-removed'
            if file.isRenamed()
              statusSpan.addClass 'status-renamed icon-diff-renamed'
            if file.isIgnored()
              statusSpan.addClass 'status-ignored icon-diff-ignored'
            $('#status-list').append li
      .catch (error) ->
        console.log error
