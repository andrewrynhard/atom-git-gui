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
      @div class: 'action-progress', id: 'action-progress-indicator', =>
        @span class: 'loading loading-spinner-small inline-block'
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
      .catch (error) ->
        atom.notifications.addError "Commit unsuccessful:", {description: error}
      .then (oid) =>
        $('#action-view-close-button').click()
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        $('#commit-action').removeClass 'available'
        @gitGuiCommitView.hide()
        @emitter.emit 'did-commit', oid
        atom.notifications.addSuccess "Commit successful:", {description: oid.tostrS() }

  openPushAction: (force) ->
    $('#action-view-action-button').text 'Push'
    $('#action-view-action-button').off 'click'
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
            @openSSHPush remote, refSpec
          else
            @openPlaintextPush remote, refSpec
          @gitGuiPushView.show()

  openSSHPush: (remote, refSpec) ->
    $('#push-plaintext-options').css 'display', 'none'
    $('#action-view-action-button').on 'click', () =>
      $('#action-progress-indicator').css 'visibility', 'visible'
      @gitGuiPushView.pushSSH remote, refSpec
      .catch (error) =>
        @showPushError error
      .then () =>
        @showPushSuccess()

  openPlaintextPush: (remote, refSpec) ->
    $('#push-plaintext-options').css 'display', 'block'
    $('#action-view-action-button').on 'click', () =>
      $('#action-progress-indicator').css 'visibility', 'visible'
      @gitGuiPushView.pushPlainText remote, refSpec
      .catch (error) =>
        @showPushError error
      .then () =>
        @showPushSuccess()

  showPushError: (error) ->
    $('#action-progress-indicator').css 'visibility', 'hidden'
    atom.notifications.addError "Push unsuccessful:", {description: error.toString() }
  showPushSuccess: () ->
    $('#action-view-close-button').click()
    $('#action-view-action-button').empty()
    $('#action-view-action-button').off 'click'
    $('#push-action').removeClass 'available'
    $('#action-progress-indicator').css 'visibility', 'hidden'
    @gitGuiPushView.hide()
    @emitter.emit 'did-push'
    atom.notifications.addSuccess("Push successful")

module.exports = GitGuiActionView
