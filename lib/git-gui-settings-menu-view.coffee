path = require 'path'
fs = require 'fs'
{$, View} = require 'space-pen'
GitConfigView = require './git-config-view'

module.exports =
  class GitGuiSettingsMenuView extends View
    @content: ->
      @div class: 'git-gui-settings-menu', =>
        @ul class: 'list-group git-gui-menu-ul', =>
          @li class: 'list-item', click: 'setActiveMenuItem', =>
            @a class: 'icon', id: 'repo', 'Repo'
          @li class: 'list-item', click: 'setActiveMenuItem', =>
            @a class: 'icon', id: 'config', 'Config'

    initialize: ->

    destroy: ->

    setActiveMenuItem: (event, element) ->
      $('.git-gui-menu-ul li.selected').removeClass('selected');
      $('.git-gui-subview.active').removeClass('active');
      $(element).addClass 'selected'
      selectedItem = element.children(":first").attr("id")
      switch selectedItem
        # when 'repo' then $('repo-view').addClass 'active'
        when 'config' then $('#config-view').addClass 'active'
