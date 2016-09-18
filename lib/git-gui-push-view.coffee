path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'
{TextEditorView} = require 'atom-space-pen-views'

class GitGuiPushView extends View
  @content: ->
    @div class: 'action-view-content', =>
      @div
      @h2 "Username"
      @subview 'userName', new TextEditorView(mini: true)
      @h2 "Password"
      @subview 'userPassword', new TextEditorView(mini: true)
      @h2 "Remote"
      @div =>
        @select class: 'input-select', id: 'git-gui-remotes-list'

  initialize: ->
    pathToRepo = path.join atom.project.getPaths()[0], '.git'
    @updateRemotes(pathToRepo)

  destroy: ->

  updateRemotes: (pathToRepo) ->
    $(document).ready () ->
      Git.Repository.open pathToRepo
      .then (repo) ->
        repo.getRemotes()
        .then (remotes) ->
          for remote in remotes
            option = "<option value=#{remote}>#{remote}</option>"
            $('#git-gui-remotes-list').append $(option)

  push: (force) ->
    pathToRepo = path.join $('#git-gui-project-list').val(), '.git'
    promise = new Promise (resolve, reject) =>
      $(document).ready =>
        Git.Repository.open pathToRepo
        .then (repo) =>
          repo.getCurrentBranch()
          .then (ref) =>
            Git.Remote.lookup repo, $('#git-gui-remotes-list').val()
            .then (remote) =>
              refSpec = "refs/heads/#{ref.shorthand()}:refs/heads/#{ref.shorthand()}"
              if force
                refSpec = '+' + refSpec
              attempt = true
              remote.push [refSpec],
                  callbacks:
                    certificateCheck: () ->
                      return 1
                    credentials: (url, userName) =>
                      if attempt
                        attempt = false
                        if (url.indexOf("https") == - 1)
                          return Git.Cred.sshKeyFromAgent(userName)
                        else
                          return Git.Cred.userpassPlaintextNew @userName.getText(), @userPassword.getText()
                      else
                        return Git.Cred.defaultNew()
                    # transferProgress: (stats) ->
                    #   console.log stats
              .then () ->
                return resolve()
        .catch (error) ->
          return reject error

    return promise

module.exports = GitGuiPushView
