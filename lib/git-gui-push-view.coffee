path = require 'path'
{$, View} = require 'space-pen'
Git = require 'nodegit'

module.exports =
  class GitGuiPushView extends View
    @content: ->
      @div =>
        @h2 "Remote"
        @div

    initialize: ->

    destroy: ->

    push: (username, password) ->
      promise = new Promise (resolve, reject) ->
        $(document).ready ->
          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) ->
            Git.Remote.lookup repo, 'origin'
            .then (remote) ->
              remote.push(["refs/heads/master:refs/heads/master"],
                {
                  callbacks:
                    credentials: (url, userName) ->
                      console.log url, userName
                      return Git.Cred.userpassPlaintextNew username, password
                } )
              .then (status) ->
                return resolve status
          .catch (error) ->
            return reject error

      return promise
