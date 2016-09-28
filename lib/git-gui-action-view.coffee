path = require 'path'
Git = require 'nodegit'
{Emitter} = require 'atom'
{$, View} = require 'space-pen'
GitGuiCommitView = require './git-gui-commit-view'
GitGuiPushView = require './git-gui-push-view'

class GitGuiActionView extends View
  @content: ->
    @div id: 'action-view', =>
      @subview 'gitGuiCommitView', new GitGuiCommitView()
      @subview 'gitGuiPushView', new GitGuiPushView()
      @div class: 'btn-toolbar', id: 'action-view-btn-group', =>
        @div class: 'btn-group', =>
          @button class: 'btn', id: 'action-view-close-button', 'Close'
          @button class: 'btn', id: 'action-view-action-button'

  initialize: ->
    @emitter = new Emitter
    @gitGuiCommitView.hide()
    @gitGuiPushView.hide()
    $(document).ready () ->
      $('body').on 'click', '#action-view-close-button', () ->
        $('atom-workspace-axis.horizontal').toggleClass 'blur'
        $('#action-view').parent().hide()

  serialize: ->

  destroy: ->
    @gitGuiCommitView.destroy()
    @gitGuiPushView.destroy()
    @emitter.dispose()

  onDidCommit: (callback) ->
    @emitter.on 'did-commit', callback

  onDidPush: (callback) ->
    @emitter.on 'did-push', callback

  openCommitAction: ->
    @gitGuiCommitView.show()
    $('#action-view-action-button').text 'Commit'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @gitGuiCommitView.commit()
      .then (oid) =>
        $('#action-view-close-button').click()
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        $('#commit-action').removeClass 'available'
        @gitGuiCommitView.hide()
        @emitter.emit 'did-commit', oid
        atom.notifications.addSuccess "Commit successful:", {description: oid.tostrS() }
      .catch (error) ->
        atom.notifications.addError "Commit unsuccessful:", {description: error}

  openPushAction: (force) ->
    pathToRepo = path.join $('#git-gui-project-list').val(), '.git'
    Git.Repository.open pathToRepo
    .then (repo) =>
      repo.getCurrentBranch()
      .then (ref) =>
        if force
          refSpec = '+' + refSpec
        refSpec = "refs/heads/#{ref.shorthand()}:refs/heads/#{ref.shorthand()}"

        Git.Remote.lookup repo, $('#git-gui-remotes-list').val()
        .then (remote) =>
          url = remote.url()
          if (url.indexOf("https") == - 1)
            @openSSHPush remote, refSpec, ref.shorthand()
          else
            $('#action-view-action-button').text 'Push'
            $('#action-view-action-button').off 'click'
            $('atom-workspace-axis.horizontal').toggleClass 'blur'
            $('#action-view').parent().show()
            $('#action-view').addClass 'open'
            @gitGuiPushView.show()
            @openPlaintextPush remote, refSpec, ref.shorthand()

  openSSHPush: (remote, refSpec, refShorthand) ->
    $('.git-gui-staging-area').toggleClass('fade-and-blur')
    $('#action-progress-indicator').css 'visibility', 'visible'
    @gitGuiPushView.pushSSH remote, refSpec
    .then () =>
      @showPushSuccess(remote.url(), refShorthand)
    .catch (error) =>
      @showPushError error
    .then () ->
      $('.git-gui-staging-area').toggleClass('fade-and-blur')

  openPlaintextPush: (remote, refSpec, refShorthand) ->
    $('#push-plaintext-options').css 'display', 'block'
    $('#action-view-action-button').on 'click', () =>
      $('atom-workspace-axis.horizontal').removeClass 'blur'
      $('#action-view').parent().hide()
      $('#action-view').removeClass 'open'
      $('#action-view-action-button').text ''
      $('#action-view-action-button').off 'click'
      @gitGuiPushView.hide()
      $('.git-gui-staging-area').addClass('fade-and-blur')
      $('#action-progress-indicator').css 'visibility', 'visible'
      @gitGuiPushView.pushPlainText remote, refSpec
      .then () =>
        @showPushSuccess(remote.url(), refShorthand)
      .catch (error) =>
        @showPushError error
      .then () ->
        $('.git-gui-staging-area').toggleClass('fade-and-blur')

  showPushError: (error) ->
    $('#action-progress-indicator').css 'visibility', 'hidden'
    atom.notifications.addError "Push unsuccessful:", {description: error.toString() }

  showPushSuccess: (url, refShorthand) ->
    $('#action-view-close-button').click()
    $('#action-view-action-button').empty()
    $('#action-view-action-button').off 'click'
    $('#push-action').removeClass 'available'
    $('#action-progress-indicator').css 'visibility', 'hidden'
    @emitter.emit 'did-push'
    atom.notifications.addSuccess("Push successful:", {detail: "To #{url}\n\t#{refShorthand} -> #{refShorthand}" } )

module.exports = GitGuiActionView
