{View} = require 'space-pen'
GitGuiMenuView = require './git-gui-settings-menu-view'
GitGuiRepoView = require './git-gui-repo-view'
GitGuiConfigView = require './git-gui-config-view'

module.exports =
  class GitGuiSettingsView extends View
    @content: ->
      @div class: 'git-gui-settings', id: 'settings', =>
        @div class: 'git-gui-settings-content', =>
          @subview 'gitGuiSettingsMenu', new GitGuiMenuView()
          @subview 'gitRepoView', new GitGuiRepoView()
          @subview 'gitConfigView', new GitGuiConfigView()

    initialize: ->

    destroy: ->
