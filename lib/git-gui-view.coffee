{View} = require 'space-pen'
GitGuiActionBarView = require './git-gui-action-bar-view'
GitGuiActionView = require './git-gui-action-view'
GitGuiStagingAreaView = require './git-gui-staging-area-view'
GitGuiDiffView = require './git-gui-diff-view'
GitGuiSettingsView = require './git-gui-settings-view'

module.exports =
  class GitGuiView extends View
    @content: ->
      @div class: 'git-gui', =>
        @subview 'gitGuiDiffView', new GitGuiDiffView()
        @div class: 'git-gui-overlay', =>
          @subview 'gitGuiActionBarView', new GitGuiActionBarView()
          @subview 'gitGuiStatusView', new GitGuiStagingAreaView()
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
