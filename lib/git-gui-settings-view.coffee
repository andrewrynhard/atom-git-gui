path = require 'path'
fs = require 'fs'
{$, View} = require 'space-pen'
GitGuiMenuView = require './git-gui-settings-menu-view'
GitConfigView = require './git-config-view'

module.exports =
  class GitGuiSettingsView extends View
    @content: ->
      @div class: 'git-gui-settings closed', id: 'settings', =>
        @div class: 'git-gui-settings-header', id: 'settings-header', =>
          @span class: 'icon icon-settings', "Settings"
        @div class: 'git-gui-settings-content', =>
          @subview 'gitGuiSettingsMenu', new GitGuiMenuView()
          @subview 'gitConfig', new GitConfigView()

    initialize: ->
      $(document).ready () =>
        $('body').on 'click', '#settings-header', () =>
          if $('#settings').hasClass('open')
            $('#settings').removeClass 'open'
            $('#settings').addClass 'closed'
            $('.git-gui-menu-ul li.selected').removeClass('selected');
            $('.git-gui-subview.active').removeClass('active');
          else
            $('#settings').removeClass 'closed'
            $('#settings').addClass 'open'

    destroy: ->
