path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'
GitGuiActionBarView = require './git-gui-action-bar-view'
GitGuiStatusView = require './git-gui-status-view'
GitGuiSettingsView = require './git-gui-settings-view'

module.exports =
  class GitGuiView extends View
    @content: ->
      @div class: 'git-gui', id: 'container', =>
        @subview 'gitGuiActionBar', new GitGuiActionBarView()
        @subview 'gitGuiStatus', new GitGuiStatusView()
        @subview 'gitGuiSettingsMenu', new GitGuiSettingsView()

    initialize: ->

    serialize: ->

    destroy: ->
      @gitGuiActionBar.destroy()
      @gitGuiStatus.destroy()
      @gitGuiSettingsMenu.destroy()

    setStatuses: ->
      @gitGuiStatus.setStatuses()
