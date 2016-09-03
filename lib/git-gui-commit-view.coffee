path = require 'path'
{$, View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
Git = require 'nodegit'

module.exports =
  class GitGuiCommitView extends View
    @content: ->
      @div =>
        @h2 "Subject"
        @subview 'subjectEditor', new TextEditorView(mini: true)
        @h2 "Body"
        @subview 'bodyEditor', new TextEditorView()

    initialize: ->

    destroy: ->

    commit: (callback) ->
      promise = new Promise (resolve, reject) =>
        message = @subjectEditor.getText() + '\n\n' + @bodyEditor.getText()
        $(document).ready ->
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) ->
            repo.refreshIndex()
            .then (index) ->
              index.writeTree()
              .then (oid) ->
                Git.Reference.nameToId repo, 'HEAD'
                .then (head) ->
                  repo.getCommit head
                  .then (parent) ->
                    signature = Git.Signature.default repo
                    repo.createCommit 'HEAD', signature, signature, message, oid, [parent]
                    .then (oid) ->
                      return resolve oid
                    #   Git.Commit.createWithSignature repo, message, signature.toString(), "NULL"
                    #   .then (oid) ->
                    #     atom.notifications.addSuccess("Commit successful: #{oid.tostrS()}")
          .catch (error) ->
            return reject error

      return promise
