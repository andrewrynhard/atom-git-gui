{View} = require 'space-pen'
GitGuiActionBarView = require './git-gui-action-bar-view'
GitGuiActionView = require './git-gui-action-view'
GitGuiStatusView = require './git-gui-staging-area'
GitGuiSettingsView = require './git-gui-settings-view'

module.exports =
  class GitGuiView extends View
    @content: ->
      @div class: 'git-gui', =>
        @subview 'gitGuiActionBarView', new GitGuiActionBarView()
        @subview 'gitGuiStatusView', new GitGuiStatusView()
        @subview 'gitGuiSettingsView', new GitGuiSettingsView()

    initialize: ->
      @gitGuiActionView = new GitGuiActionView()
      @modalPanel = atom.workspace.addModalPanel
        item: @gitGuiActionView,
        visible: true
      @gitGuiActionView.parentView = this

    serialize: ->

    destroy: ->
      @gitGuiActionBarView.destroy()
      @gitGuiActionView.destroy()
      @gitGuiStatusView.destroy()
      @gitGuiSettingsView.destroy()

    setStatuses: ->
      @gitGuiStatusView.setStatuses()
