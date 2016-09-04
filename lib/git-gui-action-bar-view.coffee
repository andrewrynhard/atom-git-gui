path = require 'path'
Git = require 'nodegit'
{$, View} = require 'space-pen'

module.exports =
  class GitGuiActionBarView extends View
    @content: ->
      @div class: 'git-gui-action-bar', =>
        @ul class: 'list-group git-gui-action-bar-list', =>
          @li class: 'list-item', =>
            @a class: 'icon', id: 'commit-action'
          @li class: 'list-item', =>
            @a class: 'icon', id: 'push-action'
          @li class: 'list-item', =>
            @a class: 'icon', id: 'pull-action'
          @li class: 'list-item', =>
            @a class: 'icon', id: 'branch-action'
        # @span class: 'badge icon icon-diff-ignored', id: 'ignored-badge', 0
        # @span class: 'badge icon icon-diff-added', id: 'added-badge', 0
        # @span class: 'badge icon icon-diff-modified', id: 'modified-badge', 0
        # @span class: 'badge icon icon-diff-removed', id: 'removed-badge', 0
        # @span class: 'badge icon icon-diff-renamed', id: 'renamed-badge', 0

    # TODO: Add an `amend` option for `commit`
    # TODO: Add an `merge` option for `pull`
    initialize: ->
      $(document).ready () =>
        $('body').on 'mouseenter', '#push-action', () ->
          $('body').on 'keydown', (e) ->
            if e.which == 16
              if ! $('#push-action').hasClass('force')
                $('#push-action').addClass 'force'

          $('body').on 'keyup', (e) ->
            if e.which == 16
              if $('#push-action').hasClass('force')
                $('#push-action').removeClass 'force'

        $('body').on 'mouseleave', '#push-action', () ->
          if $('#push-action').hasClass('force')
            $('#push-action').removeClass 'force'
          $('body').off 'keydown'
          $('body').off 'keyup'

        $('body').on 'click', '#commit-action', () =>
          $('atom-workspace-axis.horizontal').toggleClass 'blur'
          $('#action-view').addClass 'open'
          @parentView.gitGuiActionView.openCommitAction()

        $('body').on 'click', '#push-action', () =>
          $('atom-workspace-axis.horizontal').toggleClass 'blur'
          $('#action-view').addClass 'open'
          @parentView.gitGuiActionView.openPushAction()

        $('body').on 'click', '#pull-action', () ->
          $('atom-workspace-axis.horizontal').toggleClass 'blur'
          $('#action-view').addClass 'open'
          # @parentView.gitGuiActionView.openPullAction()

        $('body').on 'click', '#branch-action', () ->
          $('atom-workspace-axis.horizontal').toggleClass 'blur'
          $('#action-view').addClass 'open'
          # @parentView.gitGuiActionView.openBranchAction()

    serialize: ->

    destroy: ->

    updateActionBar: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) ->
        Git.Reference.nameToId repo, 'refs/heads/master'
        .then (local) ->
          Git.Reference.nameToId repo, 'refs/remotes/origin/master'
          .then (upstream) ->
            Git.Graph.aheadBehind(repo, local, upstream)
            .then (aheadbehind) ->
              if aheadbehind.ahead
                $('#push-action').addClass 'available'
              else
                $('#push-action').removeClass 'available'
              if aheadbehind.behind
                $('#pull-action').addClass 'available'
              else
                $('#pull-action').removeClass 'available'
      .catch (error) ->
        console.log error
