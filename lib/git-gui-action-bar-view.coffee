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
            @a class: 'icon', id: 'settings-action'

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
          if $('#push-action').hasClass('force')
            atom.confirm
              message: "Force push?"
              detailedMessage: "This will overwrite changes to the remote."
              buttons:
                Ok: =>
                  $('atom-workspace-axis.horizontal').toggleClass 'blur'
                  $('#action-view').addClass 'open'
                  @parentView.gitGuiActionView.openPushAction(true)
                Cancel: ->
                  return
          else
            $('atom-workspace-axis.horizontal').toggleClass 'blur'
            $('#action-view').addClass 'open'
            @parentView.gitGuiActionView.openPushAction(false)

        $('body').on 'click', '#pull-action', () ->
          $('atom-workspace-axis.horizontal').toggleClass 'blur'
          $('#action-view').addClass 'open'
          # @parentView.gitGuiActionView.openPullAction()

        $('body').on 'click', '#settings-action', () ->
          $('#settings').toggleClass('open')
          $('.git-gui-staging-area').toggleClass('fade-and-blur')
          $('.git-gui-settings-menu-list li.selected').removeClass('selected')
          $('.git-gui-settings-subview.active').removeClass('active')

    serialize: ->

    destroy: ->

    updateActionBar: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) ->
        repo.getCurrentBranch()
        .then (ref) ->
          Git.Reference.nameToId repo, "refs/heads/#{ref.shorthand()}"
          .then (local) ->
            # TODO: Consider the case when a user wants to get the ahead/behind
            #       count from a remote other than origin.
            Git.Reference.nameToId repo, "refs/remotes/origin/#{ref.shorthand()}"
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
        # TODO: Add the ability to set remote refs.
        atom.notifications.addError "#{error}"
        console.log error
