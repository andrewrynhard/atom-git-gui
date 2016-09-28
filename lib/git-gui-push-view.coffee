{$, View} = require 'space-pen'
Git = require 'nodegit'
{TextEditorView} = require 'atom-space-pen-views'

class GitGuiPushView extends View
  @content: ->
    @div class: 'action-view-content', =>
      @div id: 'push-plaintext-options', =>
        @h2 "Username"
        @subview 'userName', new TextEditorView(mini: true)
        @h2 "Password"
        @subview 'userPassword', new TextEditorView(mini: true)
      @div =>
        @h2 "Remote"
        @select class: 'input-select', id: 'git-gui-remotes-list'

  initialize: ->

  destroy: ->

  updateRemotes: (pathToRepo) ->
    # Clear the `select` menu
    $('#git-gui-remotes-list').find('option').remove().end()
    Git.Repository.open pathToRepo
    .then (repo) ->
      Git.Remote.list repo
      .then (remotes) ->
        for remote in remotes
          option = "<option value=#{remote}>#{remote}</option>"
          $('#git-gui-remotes-list').append $(option)

  pushPlainText: (remote, refSpec) ->
    attempt = true
    remote.push [refSpec],
      callbacks:
        certificateCheck: () ->
          return 1
        credentials: () =>
          if attempt
            attempt = false
            return Git.Cred.userpassPlaintextNew @userName.getText(), @userPassword.getText()
          else
            return Git.Cred.defaultNew()
        # transferProgress: (stats) ->
        #   console.log stats

  pushSSH: (remote, refSpec) ->
    attempt = true
    remote.push [refSpec],
        callbacks:
          certificateCheck: () ->
            return 1
          credentials: (url, userName) ->
            if attempt
              attempt = false
              return Git.Cred.sshKeyFromAgent(userName)
            else
              return Git.Cred.defaultNew()
          # transferProgress: (stats) ->
          #   console.log stats

module.exports = GitGuiPushView
