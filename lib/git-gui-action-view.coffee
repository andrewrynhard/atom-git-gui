{Emitter} = require 'atom'
{$, View} = require 'space-pen'
GitGuiCommitView = require './git-gui-commit-view'
GitGuiPushView = require './git-gui-push-view'

module.exports =
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
        $('#action-view').removeClass 'open'

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
    @gitGuiPushView.hide()
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
        @emitter.emit 'did-commit', oid
        @gitGuiCommitView.hide()
        atom.notifications.addSuccess "Commit successful: #{oid.tostrS()}"
      .catch (error) ->
        atom.notifications.addError "Commit unsuccessful: #{error}"

  openPushAction: (force) ->
    @gitGuiCommitView.hide()
    @gitGuiPushView.show()
    $('#action-view-action-button').text 'Push'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      $('#action-progress-indicator').css 'visibility', 'visible'
      @gitGuiPushView.push(force)
      .then () =>
        $('#action-view-close-button').click()
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        $('#push-action').removeClass 'available'
        @emitter.emit 'did-push'
        @gitGuiPushView.hide()
        $('#action-progress-indicator').css 'visibility', 'hidden'
        atom.notifications.addSuccess("Push successful")
      .catch (error) ->
        $('#action-progress-indicator').css 'visibility', 'hidden'
        atom.notifications.addError "Push unsuccessful: #{error}"
