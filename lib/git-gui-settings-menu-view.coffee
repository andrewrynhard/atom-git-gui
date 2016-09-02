path = require 'path'
fs = require 'fs'
{$, View} = require 'space-pen'
GitConfigView = require './git-config-view'

module.exports =
  class GitGuiSettingsMenuView extends View
    @content: ->
      @div class: 'git-gui-settings-menu', =>
        @ul class: 'list-group git-gui-menu-ul', =>
          # @li class: 'list-item', =>
          #   @a class: 'icon', id: 'commit', 'Commit'
          # @li class: 'list-item', =>
          #   @a class: 'icon', id: 'branch', 'Branch'
          # @li class: 'list-item', =>
          #   @a class: 'icon', id: 'push', 'Push'
          # @li class: 'list-item', =>
          #   @a class: 'icon', id: 'pull', 'Pull'
          @li class: 'list-item', click: 'setActiveMenuItem', =>
            @a class: 'icon', id: 'repo', 'Repo'
          @li class: 'list-item', click: 'setActiveMenuItem', =>
            @a class: 'icon', id: 'config', 'Config'

    initialize: ->
      # TODO: Add an `amend` option for `commit`
      # TODO: Add an `merge` option for `pull`
      # $( document ).ready () =>
      #   $('body').on 'mouseenter', '#push', () =>
      #     $('body').on 'keydown', (e) =>
      #       if e.which == 16
      #         if !$('#push').hasClass('force')
      #           $('#push').addClass 'force'
      #           $('#push').text 'Force Push'
      #     $('body').on 'keyup', (e) =>
      #       if e.which == 16
      #         if $('#push').hasClass('force')
      #           $('#push').removeClass 'force'
      #           $('#push').text 'Push'
      #   $('body').on 'mouseleave', '#push', (e) =>
      #     if $('#push').hasClass('force')
      #       $('#push').removeClass 'force'
      #       $('#push').text 'Push'
      #     $('body').off 'keydown'
      #     $('body').off 'keyup'

    destroy: ->

    setActiveMenuItem: (event, element) ->
      $('.git-gui-menu-ul li.selected').removeClass('selected');
      $('.git-gui-subview.active').removeClass('active');
      $(element).addClass 'selected'
      selectedItem = element.children(":first").attr("id")
      switch selectedItem
        # when 'repo' then $('repo-view').addClass 'active'
        when 'config' then $('#config-view').addClass 'active'
