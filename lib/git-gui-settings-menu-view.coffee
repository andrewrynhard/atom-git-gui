{$, View} = require 'space-pen'

# TODO: Improve setting the active menu item.
module.exports =
  class GitGuiSettingsMenuView extends View
    @content: ->
      @div class: 'git-gui-settings-menu', =>
        @ul class: 'list-group git-gui-settings-menu-list', =>
          @li class: 'list-item', click: 'setActiveMenuItem', =>
            @a class: 'icon', id: 'repo', 'Repo'
          @li class: 'list-item', click: 'setActiveMenuItem', =>
            @a class: 'icon', id: 'config', 'Config'

    initialize: ->

    destroy: ->

    setActiveMenuItem: (event, element) ->
      $('.git-gui-settings-menu-list li.selected').removeClass('selected')
      $('.git-gui-settings-subview.active').removeClass('active')
      $(element).addClass 'selected'
      selectedItem = element.children(":first").attr("id")
      switch selectedItem
        # when 'repo' then $('repo-view').addClass 'active'
        when 'config' then $('#config-view').addClass 'active'
