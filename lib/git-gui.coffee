GitGuiView = require './git-gui-view'
{CompositeDisposable, GitRepository} = require 'atom'
{$} = require 'space-pen'

module.exports = GitGui =
  gitGuiView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @gitGuiView = new GitGuiView(state.gitGuiViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @gitGuiView, visible: true)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-gui:toggle': => @toggle()

    repo = atom.project.getRepositories()[0]

    @subscriptions.add repo.onDidChangeStatus (event) =>
      console.log 'changed status'
      @gitGuiView.setStatuses()

    @subscriptions.add repo.onDidChangeStatuses () =>
      console.log 'changed statuses'
      @gitGuiView.setStatuses()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @gitGuiView.destroy()

  serialize: ->
    gitGuiViewState: @gitGuiView.serialize()

  toggle: ->
    @gitGuiView.setStatuses()
    $(document).ready () =>
      if $('#container').hasClass('open')
        $('#container').removeClass 'open'
        $('#container').addClass 'closed'
        $('.git-gui-menu-ul li.selected').removeClass('selected');
        $('.git-gui-subview.active').removeClass('active');
      else
        $('#container').removeClass 'closed'
        $('#container').addClass 'open'
