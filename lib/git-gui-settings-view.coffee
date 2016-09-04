{$, View} = require 'space-pen'
GitGuiMenuView = require './git-gui-settings-menu-view'
GitConfigView = require './git-config-view'

module.exports =
  class GitGuiSettingsView extends View
    @content: ->
      @div class: 'git-gui-settings closed', id: 'settings', =>
        @div class: 'git-gui-settings-header', id: 'settings-header', =>
          @span "Settings"
        @div class: 'git-gui-settings-content', =>
          @subview 'gitGuiSettingsMenu', new GitGuiMenuView()
          @subview 'gitConfig', new GitConfigView()

    initialize: ->
      $(document).ready () ->
        $('body').on 'click', '#settings-header', () ->
          $('#settings').toggleClass('open')
          $('.git-gui-staging-area').toggleClass('fade-and-blur')
          $('.git-gui-settings-menu-list li.selected').removeClass('selected')
          $('.git-gui-settings-subview.active').removeClass('active')

    destroy: ->
