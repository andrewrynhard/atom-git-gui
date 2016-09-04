{$, View} = require 'space-pen'
GitGuiCommitView = require './git-gui-commit-view'
GitGuiPushView = require './git-gui-push-view'

module.exports =
class GitGuiActionView extends View
  @content: ->
    @div id: 'action-view', =>
      @subview 'commitView', new GitGuiCommitView()
      @subview 'pushView', new GitGuiPushView()
      @div class: 'btn-toolbar', =>
        @div class: 'btn-group', =>
          @button class: 'btn', id: 'action-view-close-button', 'Close'
          @button class: 'btn', id: 'action-view-action-button'

  initialize: ->
    @commitView.hide()
    @pushView.hide()
    $(document).ready () ->
      $('body').on 'click', '#action-view-close-button', () ->
        $('atom-workspace-axis.horizontal').toggleClass 'blur'
        $('#action-view').removeClass 'open'

  serialize: ->

  destroy: ->

  openCommitAction: ->
    @pushView.hide()
    @commitView.show()
    $('#action-view-action-button').text 'Commit'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @commitView.commit()
      .then (oid) =>
        @parentView.gitGuiStatusView.setStatuses()
        $('#action-view-close-button').click()
        atom.notifications.addSuccess "Commit successful: #{oid.tostrS()}"
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        @commitView.hide()

  openPushAction: ->
    @commitView.hide()
    @pushView.show()
    $('#action-view-action-button').text 'Push'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @pushView.push('andrewrynhard', '259558afd2967c5d38f5d111ed12bca73456a2ef')
      .then (status) =>
        console.log status
        @parentView.gitGuiStatusView.setStatuses()
        $('#action-view-close-button').click()
        atom.notifications.addSuccess("Push successful")
        $('#action-view-action-button').empty()
        $('#action-view-action-button').off 'click'
        @pushView.hide()
      .catch (error) ->
        atom.notifications.addError "Push unsuccessful: #{error}"
