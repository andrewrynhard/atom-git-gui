path = require 'path'
fs = require 'fs'
child_process = require 'child_process'
{$, View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
Git = require 'nodegit'

class GitGuiCommitView extends View
  @content: ->
    @div class: 'action-view-content', =>
      @h2 "Subject"
      @subview 'subjectEditor', new TextEditorView(mini: true)
      @h2 "Body"
      @subview 'bodyEditor', new TextEditorView()

  initialize: ->

  destroy: ->

  commit: () ->
    promise = new Promise (resolve, reject) =>
      pathToRepo = path.join $('#git-gui-project-list').val(), '.git'
      msg = @subjectEditor.getText() + '\n\n' + @bodyEditor.getText() + '\n'
      commitEditMsg = path.join pathToRepo, 'COMMIT_EDITMSG'
      fs.writeFile commitEditMsg , msg, (err) =>
        if err then return reject err
        @commitMsgHook(commitEditMsg)
        .then () ->
          Git.Repository.open pathToRepo
          .then (repo) ->
            repo.refreshIndex()
            .then (index) ->
              index.writeTree()
              .then (oid) ->
                if repo.isEmpty()
                  signature = Git.Signature.default repo
                  repo.createCommit 'HEAD', signature, signature, msg, oid, []
                else
                  Git.Reference.nameToId repo, 'HEAD'
                  .then (head) ->
                    repo.getCommit head
                    .then (parent) ->
                      signature = Git.Signature.default repo
                      repo.createCommit 'HEAD', signature, signature, msg, oid, [parent]
                      .then (oid) ->
                        return resolve oid
                      #   Git.Commit.createWithSignature repo, message, signature.toString(), "NULL"
                      #   .then (oid) ->
                      #     atom.notifications.addSuccess("Commit successful: #{oid.tostrS()}")
        .catch (error) ->
          return reject error

    return promise

  commitMsgHook: (commitEditMsg) ->
    promise = new Promise (resolve, reject) ->
      commitMsgHook = path.join $('#git-gui-project-list').val(), '.git', 'hooks', 'commit-msg'
      fs.exists commitMsgHook, (exists) ->
        if exists
          child_process.exec "#{commitMsgHook} #{commitEditMsg}", {env: process.env} , (error, stdout, stderr) ->
            if error then return reject stdout
            if stderr then return reject stdout
            return resolve()
        else
          return resolve()
    return promise

module.exports = GitGuiCommitView
