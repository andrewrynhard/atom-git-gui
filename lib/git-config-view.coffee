path = require 'path'
fs = require 'fs'
openpgp = require 'openpgp'
Git = require 'nodegit'
{$, View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
  class GitConfigView extends View
    @content: ->
        @div class: 'git-gui-subview', id: 'config-view', =>
          @h1 id: 'user', 'User'
          @label 'Name'
          @subview 'userName', new TextEditorView(mini: true)
          @label 'Email'
          @subview 'userEmail', new TextEditorView(mini: true)
          @label 'Signing Key'
          @div =>
            @select class: 'input-select', id: 'userSigningKey', =>

    initialize: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      pathToConfig = path.join pathToRepo, 'config'
      @addConfig()
      fs.watch pathToRepo, (event, filename) =>
        if filename == 'config'
          @addConfig()

      @subscriptions = new CompositeDisposable

      @subscriptions.add @userName.model.onDidStopChanging () =>
        @saveUserName()

      @subscriptions.add @userEmail.model.onDidStopChanging () =>
        @saveUserEmail()

      $(document).ready () =>
        $('#userSigningKey').on 'change', () =>
          @saveUserSigningKey()

    destroy: ->
        @subscriptions.dispose()

    # TODO: Get the global config settings as a default.
    addConfig: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) =>
        repo.config()
        .then (config) =>
          # Get the user name
          config.getStringBuf 'user.name'
          .then (buf) =>
            @addUserName buf
          .catch (error) ->
            @addUserName 'N/A'

          # Get the user email
          config.getStringBuf 'user.email'
          .then (buf) =>
            @addUserEmail buf
          .catch (error) ->
            @addUserEmail 'N/A'

          # Get the user signingkey
          config.getStringBuf 'user.signingkey'
          .then (buf) =>
              @addUserSigningKey buf
          .catch (error) ->
            @addUserSigningKey 'N/A'
        .catch (error) ->
          console.log error
      .catch (error) ->
        console.log error

    addUserName: (name) ->
        @userName.setText name

    saveUserName: ->
        pathToRepo = path.join atom.project.getPaths()[0], '.git'
        Git.Repository.open pathToRepo
        .then (repo) =>
          repo.config()
          .then (config) =>
            # Set the user name
            config.setString 'user.name', @userName.getText()
            .catch (error) ->
              console.log error
        .catch (error) ->
          console.log error

    addUserEmail: (email) ->
        @userEmail.setText email

    saveUserEmail: ->
        pathToRepo = path.join atom.project.getPaths()[0], '.git'
        Git.Repository.open pathToRepo
        .then (repo) =>
          repo.config()
          .then (config) =>
            # Set the user email
            config.setString 'user.email', @userEmail.getText()
            .catch (error) ->
              console.log error
        .catch (error) ->
          console.log error

    # TODO: Avoid having to export keys to 'secring.asc'
    # TODO: List only the keys that are associated with the active `user.email`
    addUserSigningKey: (signingkey) ->
      $(document).ready () =>
        # Clear the `select` menu
        $('#userSigningKey').find('option').remove().end()
        home = process.env.HOME
        pubring = path.join(home, '.gnupg', 'secring.asc')
        fs.readFile pubring, 'utf-8', (err, data) =>
          if (err)
            throw err
          keys = openpgp.key.readArmored(data).keys
          for key in keys
            userid = key.getPrimaryUser().user.userId.userid
            userid = userid.replace(/</g, '&lt');
            userid = userid.replace(/>/g, '&gt');
            keyid = key.primaryKey.getKeyId().toHex()
            $('#userSigningKey').append $("<option value=#{keyid}>#{keyid} #{userid}</option>")
            if keyid == signingkey
              $('#userSigningKey').val(keyid)

    saveUserSigningKey: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) =>
        repo.config()
        .then (config) =>
          # Set the user signingkey
          config.setString 'user.signingkey', $('#userSigningKey').val()
          .then (result) =>
            if result != 0
              console.log 'Error setting user.signingkey'
            # Ensure that commits are signed
            config.setString 'commit.gpgsign', 'true'
            .then (result) =>
              if result != 0
                console.log 'Error setting commit.gpgsign'

      .catch (error) ->
        console.log error
