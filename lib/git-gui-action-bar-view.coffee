path = require 'path'
{$, View} = require 'space-pen'
GitGuiActionView = require './git-gui-action-view'
Git = require 'nodegit'

module.exports =
  class GitGuiActionBarView extends View
    @content: ->
        @div class: 'git-gui-action-bar', =>
          @ul class: 'list-group git-gui-action-bar-menu', =>
            @li class: 'list-item', =>
              @a class: 'icon', id: 'commit'
            @li class: 'list-item', =>
              @a class: 'icon', id: 'push'
            @li class: 'list-item', =>
              @a class: 'icon', id: 'pull'
            @li class: 'list-item', =>
              @a class: 'icon', id: 'branch'
          # @span class: 'badge icon icon-diff-ignored', id: 'ignored-badge', 0
          # @span class: 'badge icon icon-diff-added', id: 'added-badge', 0
          # @span class: 'badge icon icon-diff-modified', id: 'modified-badge', 0
          # @span class: 'badge icon icon-diff-removed', id: 'removed-badge', 0
          # @span class: 'badge icon icon-diff-renamed', id: 'renamed-badge', 0

    # TODO: Add an `amend` option for `commit`
    # TODO: Add an `merge` option for `pull`
    initialize: ->
      @actionView = new GitGuiActionView()
      @modalPanel = atom.workspace.addModalPanel(item: @actionView, visible: true)

      $(document).ready () =>
        $('body').on 'mouseenter', '#push', () =>
          $('body').on 'keydown', (e) =>
            if e.which == 16
              if !$('#push').hasClass('force')
                $('#push').addClass 'force'

          $('body').on 'keyup', (e) =>
            if e.which == 16
              if $('#push').hasClass('force')
                $('#push').removeClass 'force'

        $('body').on 'mouseleave', '#push', (e) =>
          if $('#push').hasClass('force')
            $('#push').removeClass 'force'
          $('body').off 'keydown'
          $('body').off 'keyup'

        $('body').on 'click', '#commit', (e) =>
          $('atom-workspace-axis.horizontal').toggleClass 'blur'
          $('#action-view').addClass 'open'
          $('#action-button').text 'Commit'
          $('#action-button').off 'click'
          $('#action-button').on 'click', () =>
            @commit()
            $('#action-close').click()

        $('body').on 'click', '#push', (e) =>
          console.log 'push'

        $('body').on 'click', '#pull', (e) =>
          console.log 'pull'

        $('body').on 'click', '#branch', (e) =>
          console.log 'branch'

    serialize: ->

    destroy: ->

    commit: ->
      # message = $()
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) =>
        repo.refreshIndex()
        .then (index) =>
          index.writeTree()
          .then (oid) =>
            Git.Reference.nameToId repo, "HEAD"
            .then (head) =>
              repo.getCommit head
              .then (parent) =>
                signature = Git.Signature.default repo
                repo.createCommit "HEAD", signature, signature, "message", oid, [parent]
                .then (commitId) =>
                  console.log commitId
      .catch (error) ->
        console.log error
