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

    commit: ->
      $(document).ready =>
        message = @subjectEditor.getText() + '\n\n' + @bodyEditor.getText()
        pathToRepo = path.join atom.project.getPaths()[0], '.git'
        Git.Repository.open pathToRepo
        .then (repo) =>
          repo.refreshIndex()
          .then (index) =>
            index.writeTree()
            .then (oid) =>
              Git.Reference.nameToId repo, "HEAD"
              .then (head) =>
                repo.getCommit head
                .then (parent) =>
                  signature = Git.Signature.default repo
                  repo.createCommit "HEAD", signature, signature, message, oid, [parent]
                  .then (commitId) =>
                    console.log commitId
        .catch (error) ->
          console.log error
