path = require 'path'
chokidar = require 'chokidar'
{CompositeDisposable} = require 'atom'
{$, View} = require 'space-pen'
GitGuiActionBarView = require './git-gui-action-bar-view'
GitGuiActionView = require './git-gui-action-view'
GitGuiStagingAreaView = require './git-gui-staging-area-view'
GitGuiDiffView = require './git-gui-diff-view'
GitGuiConfigView = require './git-gui-config-view'
Git = require 'nodegit'

class GitGuiView extends View
  gitGuiActionBarView: null
  gitGuiStagingAreaView: null
  gitGuiActionView: null
  gitGuiDiffView: null
  modalPanel: null

  @content: ->
    @div class: 'git-gui', =>
      @subview 'gitGuiDiffView', new GitGuiDiffView()
      @div class: 'git-gui-settings', id: 'settings', =>
        @div class: 'git-gui-settings-content', =>
          @subview 'gitGuiConfigView', new GitGuiConfigView()
      @div class: 'git-gui-overlay', =>
        @subview 'gitGuiActionBarView', new GitGuiActionBarView()
        @div =>
          @span class: 'icon icon-repo'
          @select class: 'input-select', id: 'git-gui-project-list'
          @span class: 'icon icon-git-branch'
          @select class: 'input-select', id: 'git-gui-branch-list'
        @subview 'gitGuiStagingAreaView', new GitGuiStagingAreaView()

  initialize: ->
    @gitGuiActionView = new GitGuiActionView()
    @gitGuiActionView.parentView = this
    @modalPanel = atom.workspace.addModalPanel
      item: @gitGuiActionView,
      visible: false

    @watcher = chokidar.watch(atom.project.getPaths()[0], {ignored: /\.git*/} )
    .on 'change', (path) =>
      @gitGuiStagingAreaView.updateStatus path

    $(document).ready () =>
      $('#git-gui-project-list').on 'change', () =>
        @watcher.close()
        @watcher = chokidar.watch($('#git-gui-project-list').val(), {ignored: /\.git*/} )
        .on 'change', (path) =>
          @gitGuiStagingAreaView.updateStatus path

        @updateAll()
        @selectedProject = $('#git-gui-project-list').val()

      localGroup = "<optgroup id='git-gui-branch-list-branch' label='Branch'></optgroup>"
      remoteGroup = "<optgroup id='git-gui-branch-list-remote' label='Remote'></optgroup>"
      $('#git-gui-branch-list').append $(localGroup)
      $('#git-gui-branch-list').append $(remoteGroup)

      $('#git-gui-branch-list').on 'change', () =>
        @checkout()

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.project.onDidChangePaths (projectPaths) =>
      @updateProjects(projectPaths)

    @subscriptions.add @gitGuiStagingAreaView.onDidUpdateStatus () =>
      @gitGuiActionBarView.update()

    @subscriptions.add @gitGuiActionView.onDidCommit () =>
      @updateAll()

    @subscriptions.add @gitGuiActionView.onDidPush () =>
      @updateAll()

  serialize: ->

  destroy: ->
    @gitGuiActionBarView.destroy()
    @gitGuiActionView.destroy()
    @gitGuiStagingAreaView.destroy()
    @gitGuiDiffView.destroy()
    @subscriptions.dispose()
    @watcher.close()

  # TODO: keep the currently selected option
  updateProjects: (projectPaths) ->
    $('#git-gui-project-list').find('option').remove().end()
    for projectPath in projectPaths
      option = "<option value=#{projectPath} data-repo='#{path.join projectPath, '.git'}'>#{path.basename projectPath}</option>"
      $('#git-gui-project-list').append option
    if @selectedProject and @selectedProject in atom.project.getPaths()
      $('#git-gui-project-list').val(@selectedProject)
    else
      $('#git-gui-project-list').prop('selectedIndex', 0)
      @selectedProject = $('#git-gui-project-list').val()

  # TODO: This is the only time that the repo and config views are updated,
  #       they need a more dynamic way of updating.
  updateAll: ->
    pathToRepo = path.join $('#git-gui-project-list').val(), '.git'
    @gitGuiStagingAreaView.updateStatuses()
    @updateBranches(pathToRepo)
    @gitGuiConfigView.updateConfig(pathToRepo)
    @gitGuiActionView.gitGuiPushView.updateRemotes(pathToRepo)

  open: ->
    if $('.git-gui').hasClass 'open'
      return
    @updateProjects atom.project.getPaths()
    @updateAll()
    $('.git-gui').addClass 'open'

  close: ->
    if ! $('.git-gui').hasClass 'open'
      return
    $('.git-gui').removeClass 'open'

  isOpen: ->
    if $('.git-gui').hasClass 'open'
      return true
    return false

  updateBranches: (pathToRepo) ->
    $(document).ready () ->
      # Clear the `select` menu
      $('#git-gui-branch-list-branch').find('option').remove().end()
      $('#git-gui-branch-list-remote').find('option').remove().end()
      Git.Repository.open pathToRepo
      .then (repo) ->
        # Use `TYPE.OID` so that whatever `HEAD` points to is not duplicated in the branch list
        repo.getReferences(Git.Reference.TYPE.OID)
        .then (refs) ->
          for ref in refs
            if ref.isTag()
              continue

            option = "<option value=#{ref.name()}>#{ref.shorthand()}</option>"

            if ref.isBranch()
              $('#git-gui-branch-list-branch').append $(option)
            else if ref.isRemote()
              name = path.basename ref.shorthand()
              Git.Branch.lookup repo, name, Git.Branch.BRANCH.LOCAL
              .catch () ->
                # Add the option to the remotes group if a local branch does not exist
                $('#git-gui-branch-list-remote').append $(option)

            if ref.isHead()
              @currentRef = ref.name()
              $('#git-gui-branch-list').val(@currentRef)
      .catch (error) ->
        console.log error

  checkout: ->
    pathToRepo = $('#git-gui-project-list').find(':selected').data('repo')
    Git.Repository.open pathToRepo
    .then (repo) =>
      repo.getReference $('#git-gui-branch-list').val()
      .then (ref) =>
        if ref.isBranch()
          @checkoutBranch repo, ref
        else if ref.isRemote()
          @checkoutRemote repo, ref
    .done () =>
      # Ensure any changes are reflected in the branch list
      @updateBranches pathToRepo

  checkoutBranch: (repo, ref) ->
    checkoutOptions = new Git.CheckoutOptions()
    repo.checkoutBranch ref, checkoutOptions
    .then () ->
      atom.notifications.addSuccess "Branch checkout successful:", {description: ref.shorthand() }
    .catch (error) ->
      console.log error
      atom.notifications.addError "Branch checkout unsuccessful:", {description: error.toString() }

  checkoutRemote: (repo, ref) ->
    Git.Commit.lookup repo, ref.target()
    .then (commit) ->
      name = path.basename ref.shorthand()
      Git.Branch.create repo, name, commit, false
      .then (branch) ->
        Git.Branch.setUpstream branch, ref.shorthand()
        .then () ->
          checkoutOptions = new Git.CheckoutOptions()
          repo.checkoutBranch branch, checkoutOptions
          .then () ->
            atom.notifications.addSuccess "Branch checkout successful:", {description: ref.shorthand() }
      .catch (error) ->
        console.log error
        atom.notifications.addError "Branch checkout unsuccessful:", {description: error.toString() }

module.exports = GitGuiView
