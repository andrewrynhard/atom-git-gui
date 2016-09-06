path = require 'path'
chokidar = require 'chokidar'
{$, View} = require 'space-pen'
Git = require 'nodegit'
{Emitter} = require 'atom'

module.exports =
  class GitGuiStagingAreaView extends View
    @content: ->
      @div class: 'git-gui-staging-area', =>
        @ol class: 'list-group', id: 'status-list'

    initialize: ->
      @emitter = new Emitter
      @watcher = chokidar.watch(atom.project.getPaths()[0], {ignored: /\.git*/} )
      .on 'change', (path) =>
        @updateStatus path

      $(document).ready () =>
        $('#git-gui-project-list').on 'change', () =>
          @watcher.close()
          @watcher = chokidar.watch($('#git-gui-project-list').val(), {ignored: /\.git*/} )
          .on 'change', (path) =>
            @updateStatus path
          @updateStatuses()

        $('#status-list').on 'click', '#staging-area-file', (e) =>
          filename = $(e.target).data 'file'
          pathToRepo = $('#git-gui-project-list').find(':selected').data('repo')
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.refreshIndex()
            .then (index) =>
              # Reset the file if staged
              if $(e.target).data 'staged'
                repo.getHeadCommit()
                .then (commit) =>
                  Git.Reset.default repo, commit, filename
                  .then () =>
                    index.write()
                    @updateStatus filename
              # Add the file to the index
              else
                index.addByPath filename
                .then () =>
                  index.write()
                  @updateStatus filename
          .catch (error) ->
            console.log error

        $('#status-list').on 'click', '#staging-area-file-diff', (e) =>
          $('.git-gui-overlay').addClass 'fade-and-blur'
          $('.git-gui.open').toggleClass 'expanded'
          $('.git-gui-diff-view').toggleClass 'open'
          filename = $(e.target).data("file")
          pathToRepo = $('#git-gui-project-list').find(':selected').data('repo')
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.getHeadCommit()
            .then (commit) =>
              repo.getTree(commit.treeId())
              .then (tree) =>
                repo.refreshIndex()
                .then (index) =>
                  if $(e.target).data("staged")
                    Git.Diff.treeToIndex(repo, tree, index, null)
                    .then (diff) =>
                      @parentView.gitGuiDiffView.setDiffText filename, diff
                  else
                    Git.Diff.treeToWorkdir(repo, tree, index, null)
                    .then (diff) =>
                      @parentView.gitGuiDiffView.setDiffText filename, diff
          .catch (error) ->
            console.log error

        $('#status-list').on 'click', '#staging-area-file-remove', (e) =>
          filename = $(e.target).data("file")
          atom.confirm
            message: "Remove changes?"
            detailedMessage: "This will remove the changes made to:\n\t #{filename}"
            buttons:
              Ok: =>
                filename = $(e.target).data("file")
                pathToRepo = $('#git-gui-project-list').find(':selected').data('repo')
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
      @emitter.dispose()
      @watcher.close()

    onDidUpdateStatus: (callback) ->
      @emitter.on 'did-update-status', callback

    updateStatus: (filePath) ->
      pathToRepo = $('#git-gui-project-list').find(':selected').data('repo')
      file = atom.project.relativizePath(filePath)[1]
      Git.Repository.open pathToRepo
      .then (repo) =>
        status = Git.Status.file repo, file
        li = @makeStatusListItem file, status
        if $("[id='#{file}']").length
          if li
            $("[id='#{file}']").html $(li).children()
          else
            $("[id='#{file}']").remove()
        else
          $('#status-list').append li
        @emitter.emit 'did-update-status'
      .catch (error) ->
        console.log error

    updateStatuses: ->
      $('#status-list').empty()
      pathToRepo = path.join $('#git-gui-project-list').val(), '.git'
      Git.Repository.open pathToRepo
      .then (repo) =>
        repo.getStatus()
        .then (statuses) =>
          if statuses.length > 0
            for file in statuses
              status = Git.Status.file repo, file.path()
              li = @makeStatusListItem file.path(), status
              if li
                $('#status-list').append li
          @emitter.emit 'did-update-status'
      .catch (error) ->
        console.log error

    makeStatusListItem: (filePath, status) ->
      li = $("<li class='list-item git-gui-status-list-item' id='#{filePath}'></li")
      statusSpan = $("<span class='status icon'></span>")
      indexSpan = $("<span class='status status-added icon icon-check'></span>")
      fileSpan = $("<span id='staging-area-file' data-file='#{filePath}' data-staged='false'>#{filePath}</span>")
      removeSpan = $("<span class='icon icon-remove-close' id='staging-area-file-remove' data-file='#{filePath}'></span>")
      diffSpan = $("<span class='icon icon-diff' id='staging-area-file-diff' data-file='#{filePath}' data-staged='false'></span>")

      li.append statusSpan
      li.append indexSpan
      li.append fileSpan

      indexSpan.css 'opacity', 0
      switch status
        when Git.Status.STATUS.INDEX_NEW
          $(fileSpan).data 'staged', true
          $(diffSpan).data 'staged', true
          statusSpan.addClass 'status-added icon-diff-added'
          indexSpan.css 'opacity', 1
        when Git.Status.STATUS.WT_NEW
          statusSpan.addClass 'status-added icon-diff-added'
        when Git.Status.STATUS.INDEX_MODIFIED
          li.append diffSpan
          li.append removeSpan
          $(fileSpan).data 'staged', true
          $(diffSpan).data 'staged', true
          statusSpan.addClass 'status-modified icon-diff-modified'
          indexSpan.css 'opacity', 1
        when Git.Status.STATUS.WT_MODIFIED
          li.append diffSpan
          li.append removeSpan
          statusSpan.addClass 'status-modified icon-diff-modified'
        when Git.Status.STATUS.INDEX_MODIFIED + Git.Status.STATUS.WT_MODIFIED
          li.append diffSpan
          li.append removeSpan
          $(fileSpan).data 'staged', true
          $(diffSpan).data 'staged', true
          statusSpan.addClass 'status-modified icon-diff-modified'
          indexSpan.removeClass 'icon-check'
          indexSpan.removeClass 'status-added'
          indexSpan.addClass 'status-modified icon-alert'
          indexSpan.css 'opacity', 1
        when Git.Status.STATUS.INDEX_DELETED
          $(fileSpan).data 'staged', true
          $(diffSpan).data 'staged', true
          statusSpan.addClass 'status-removed icon-diff-removed'
          indexSpan.css 'opacity', 1
        when Git.Status.STATUS.WT_DELETED
          statusSpan.addClass 'status-removed icon-diff-removed'
        when Git.Status.STATUS.INDEX_RENAMED
          $(fileSpan).data 'staged', true
          $(diffSpan).data 'staged', true
          statusSpan.addClass 'status-renamed icon-diff-renamed'
          indexSpan.css 'opacity', 1
        when Git.Status.STATUS.WT_RENAMED
          statusSpan.addClass 'status-renamed icon-diff-renamed'
        when Git.Status.STATUS.IGNORED
          statusSpan.addClass 'status-ignored icon-diff-ignored'
        when Git.Status.STATUS.CURRENT
          return null
        else
          console.log "Unmatched status #{status}"
      return li
