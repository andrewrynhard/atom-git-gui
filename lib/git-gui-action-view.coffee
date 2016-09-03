{$, View} = require 'space-pen'
GitGuiCommitView = require './git-gui-commit-view'

module.exports =
class GitGuiActionView extends View
  @content: ->
    @div id: 'action-view', =>
      @subview 'commitView', new GitGuiCommitView()
      @div class: 'btn-toolbar', =>
        @div class: 'btn-group', =>
          @button class: 'btn', id: 'action-view-close-button', 'Close'
          @button class: 'btn', id: 'action-view-action-button'

  initialize: ->
    $(document).ready () ->
      $('body').on 'click', '#action-view-close-button', () ->
        $('atom-workspace-axis.horizontal').toggleClass 'blur'
        $('#action-view').removeClass 'open'

  serialize: ->

  destroy: ->

  openCommitAction: ->
    $('#action-view-action-button').text 'Commit'
    $('#action-view-action-button').off 'click'
    $('#action-view-action-button').on 'click', () =>
      @commitView.commit()
      $('#action-view-close-button').click()
      @parentView.gitGuiStatusView.setStatuses()
