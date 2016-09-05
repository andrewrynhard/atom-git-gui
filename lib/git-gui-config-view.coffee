path = require 'path'
fs = require 'fs'
openpgp = require 'openpgp'
Git = require 'nodegit'
{$, View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
  class GitGuiConfigView extends View
    @content: ->
      @div class: 'git-gui-settings-subview', id: 'config-view', =>
        @h1 id: 'user', 'User'
        @label 'Name'
        @subview 'userName', new TextEditorView(mini: true)
        @label 'Email'
        @subview 'userEmail', new TextEditorView(mini: true)
        @label 'Signing Key'
        @div =>
          @select class: 'input-select', id: 'git-gui-user-signingkey-list'

    initialize: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      fs.watch pathToRepo, (event, filename) =>
        if filename == 'config'
          @updateConfig()

      @subscriptions = new CompositeDisposable

      @subscriptions.add @userName.model.onDidStopChanging () =>
        @saveUserName()

      @subscriptions.add @userEmail.model.onDidStopChanging () =>
        @saveUserEmail()

      $(document).ready () =>
        $('#git-gui-user-signingkey-list').on 'change', () =>
          @saveUserSigningKey()

    destroy: ->
      @subscriptions.dispose()

    # TODO: Get the global config settings as a default.
    # TODO: Avoid having to export keys to 'secring.asc'
    # TODO: List only the keys that are associated with the active `user.email`
    updateConfig: ->
      $(document).ready () =>
        # Clear the `select` menu
        $('#git-gui-user-signingkey-list').find('option').remove().end()
        home = process.env.HOME
        pubring = path.join(home, '.gnupg', 'secring.asc')
        fs.readFile pubring, 'utf-8', (err, data) =>
          if (err)
            throw err
          keys = openpgp.key.readArmored(data).keys
          for key in keys
            userid = key.getPrimaryUser().user.userId.userid
            userid = userid.replace(/</g, '&lt')
            userid = userid.replace(/>/g, '&gt')
            keyid = key.primaryKey.getKeyId().toHex()
            option = "<option value=#{keyid}>#{keyid} #{userid}</option>"
            $('#git-gui-user-signingkey-list').append $(option)

          pathToRepo = path.join atom.project.getPaths()[0], '.git'
          Git.Repository.open pathToRepo
          .then (repo) =>
            repo.config()
            .then (config) =>
              @setUserName config
              @setUserEmail config
              @setUserSigningKey config
          .catch (error) ->
            console.log error

    setUserName: (config) ->
      # Get the user name
      config.getStringBuf 'user.name'
      .then (buf) =>
        @userName.setText buf
      .catch (error) ->
        console.log error

    setUserEmail: (config) ->
      # Get the user email
      config.getStringBuf 'user.email'
      .then (buf) =>
        @userEmail.setText buf
      .catch (error) ->
        console.log error

    setUserSigningKey: (config) ->
      # Get the user signingkey
      config.getStringBuf 'user.signingkey'
      .then (buf) ->
        $('#git-gui-user-signingkey-list').val(buf)
      .catch () ->
        option = '<option disabled selected value> -- select a signing key -- </option>'
        $('#git-gui-user-signingkey-list').append $(option)

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

    saveUserSigningKey: ->
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) ->
        repo.config()
        .then (config) ->
          # Set the user signingkey
          config.setString 'user.signingkey', $('#git-gui-user-signingkey-list').val()
          .then () ->
            # Ensure that commits are signed
            config.setString 'commit.gpgsign', 'true'
      .catch (error) ->
        console.log error
