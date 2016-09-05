{View} = require 'space-pen'
GitGuiMenuView = require './git-gui-settings-menu-view'
GitGuiRepoView = require './git-gui-repo-view'
GitGuiConfigView = require './git-gui-config-view'

# TODO:
module.exports =
  class GitGuiSettingsView extends View
    @content: ->
      @div class: 'git-gui-settings', id: 'settings', =>
        @div class: 'git-gui-settings-content', =>
          @subview 'gitGuiSettingsMenu', new GitGuiMenuView()
          @subview 'gitGuiRepoView', new GitGuiRepoView()
          @subview 'gitGuiConfigView', new GitGuiConfigView()

    initialize: ->

    destroy: ->
      @gitGuiSettingsMenu.destroy()
      @gitGuiRepoView.destroy()
      @gitGuiConfigView.destroy()
