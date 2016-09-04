GitGuiView = require './git-gui-view'
{CompositeDisposable} = require 'atom'

module.exports =
  gitGuiView: null
  modalPanel: null
  subscriptions: null

  # TODO: Update the watched repo when the active atom project changes.
  activate: (state) ->
    @gitGuiView = new GitGuiView(state.gitGuiViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @gitGuiView, visible: true)

    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-gui:toggle': =>
      @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @gitGuiView.destroy()
    @subscriptions.dispose()

  serialize: ->
    gitGuiViewState: @gitGuiView.serialize()

  toggle: ->
    if @gitGuiView.isOpen()
      @gitGuiView.close()
    else
      @gitGuiView.open()
