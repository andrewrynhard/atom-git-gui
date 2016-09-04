path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
  class GitGuiPushView extends View
    @content: ->
      @div =>
        @div
        @h2 "Username"
        @subview 'userName', new TextEditorView(mini: true)
        @h2 "Password"
        @subview 'userPassword', new TextEditorView(mini: true)
        @h2 "Remote"
        @div =>
          @select class: 'input-select', id: 'git-gui-remotes-list'

    initialize: ->
      $(document).ready () ->
        pathToRepo = path.join atom.project.getPaths()[0], '.git'
        Git.Repository.open pathToRepo
        .then (repo) ->
          repo.getRemotes()
          .then (remotes) ->
            for remote in remotes
              option = "<option value=#{remote}>#{remote}</option>"
              $('#git-gui-remotes-list').append $(option)

    destroy: ->

    push: () ->
      username = @userName.getText()
      password = @userPassword.getText()
      promise = new Promise (resolve, reject) ->
        $(document).ready ->
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) ->
            repo.getCurrentBranch()
            .then (ref) ->
              Git.Remote.lookup repo, $('#git-gui-remotes-list').val()
              .then (remote) ->
                remote.push ["refs/heads/#{ref.shorthand()}:refs/heads/#{ref.shorthand()}"],
                    callbacks:
                      credentials: () ->
                        return Git.Cred.userpassPlaintextNew username, password
                      transferProgress: (stats) ->
                        console.log stats
                        console.log("transfer progress")
                .then () ->
                  return resolve()
          .catch (error) ->
            return reject error

      return promise
