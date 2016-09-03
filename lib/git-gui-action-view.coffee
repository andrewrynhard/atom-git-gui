{$, View} = require 'space-pen'
GitGuiCommitView = require './git-gui-commit-view'

module.exports =
class GitGuiActionView extends View
  @content: ->
    @div id: 'action-view', =>
      @subview 'commitView', new GitGuiCommitView()
      @div class: 'btn-toolbar', =>
        @div class: 'btn-group', =>
          @button class: 'btn', id: 'action-close', 'Close'
          @button class: 'btn', id: 'action-button'

  initialize: ->
    $(document).ready () =>
      $('body').on 'click', '#action-close', () =>
        $('atom-workspace-axis.horizontal').toggleClass 'blur'
        $('#action-view').removeClass 'open'

  serialize: ->

  destroy: ->
