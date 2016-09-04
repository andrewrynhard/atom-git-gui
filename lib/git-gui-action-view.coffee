{Emitter} = require 'atom'
{$, View} = require 'space-pen'
GitGuiCommitView = require './git-gui-commit-view'
GitGuiPushView = require './git-gui-push-view'

module.exports =
class GitGuiActionView extends View
  @content: ->
    @div id: 'action-view', =>
      @subview 'commitView', new GitGuiCommitView()
      @subview 'pushView', new GitGuiPushView()
      @div class: 'btn-toolbar', id: 'action-view-btn-group', =>
        @div class: 'btn-group', =>
          @button class: 'btn', id: 'action-view-close-button', 'Close'
          @button class: 'btn', id: 'action-view-action-button'

  initialize: ->
    @emitter = new Emitter
    @commitView.hide()
    @pushView.hide()
    $(document).ready () ->
      $('body').on 'click', '#action-view-close-button', () ->
        $('atom-workspace-axis.horizontal').toggleClass 'blur'
        $('#action-view').removeClass 'open'

  serialize: ->

  destroy: ->
    @commitView.destroy()
    @pushView.destroy()
    @gitGuiSettingsView.destroy()

  onDidCommit: (callback) ->
    @emitter.on 'did-commit', callback

  onDidPush: (callback) ->
    @emitter.on 'did-push', callback

  openCommitAction: ->
    @pushView.hide()
    @commitView.show()
    $('#action-view-action-button').text 'Commit'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @commitView.commit()
      .then (oid) =>
        $('#action-view-close-button').click()
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        @emitter.emit 'did-commit', oid
        @commitView.hide()
        atom.notifications.addSuccess "Commit successful: #{oid.tostrS()}"
      .catch (error) ->
        atom.notifications.addError "Commit unsuccessful: #{error}"

  openPushAction: ->
    @commitView.hide()
    @pushView.show()
    $('#action-view-action-button').text 'Push'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @pushView.push()
      .then () =>
        $('#action-view-close-button').click()
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        @pushView.hide()
        @emitter.emit 'did-push'
        atom.notifications.addSuccess("Push successful")
      .catch (error) ->
        atom.notifications.addError "Push unsuccessful: #{error}"

  openSettingsAction: ->
    @commitView.hide()
    @pushView.show()
    $('#action-view-action-button').text 'Save'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @pushView.push()
      .then () =>
        $('#action-view-close-button').click()
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        @pushView.hide()
        @emitter.emit 'did-push'
        atom.notifications.addSuccess("Push successful")
      .catch (error) ->
        atom.notifications.addError "Push unsuccessful: #{error}"
