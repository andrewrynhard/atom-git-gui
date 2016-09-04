{View} = require 'space-pen'
GitGuiMenuView = require './git-gui-settings-menu-view'
GitConfigView = require './git-config-view'

module.exports =
  class GitGuiSettingsView extends View
    @content: ->
      @div class: 'git-gui-settings', id: 'settings', =>
        @div class: 'git-gui-settings-content', =>
          @subview 'gitGuiSettingsMenu', new GitGuiMenuView()
          @subview 'gitConfig', new GitConfigView()

    initialize: ->

    destroy: ->
