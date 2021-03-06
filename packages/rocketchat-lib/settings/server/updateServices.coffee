timer = undefined
updateServices = ->
	Meteor.clearTimeout timer if timer?

	timer = Meteor.setTimeout ->
		services = Settings.find({_id: /^(Accounts_OAuth_|Accounts_OAuth_Custom_)[a-z]+$/i}).fetch()

		for service in services
			console.log "Updating login service #{service._id}".blue

			serviceName = service._id.replace('Accounts_OAuth_', '')

			if serviceName is 'Meteor'
				serviceName = 'meteor-developer'

			if /Accounts_OAuth_Custom_/.test service._id
				serviceName = service._id.replace('Accounts_OAuth_Custom_', '')

			if service.value is true
				data =
					clientId: Settings.findOne({_id: "#{service._id}_id"})?.value
					secret: Settings.findOne({_id: "#{service._id}_secret"})?.value

				if /Accounts_OAuth_Custom_/.test service._id
					data.custom = true
					data.serverURL = Settings.findOne({_id: "#{service._id}_url"})?.value
					data.tokenPath = Settings.findOne({_id: "#{service._id}_token_path"})?.value
					data.identityPath = Settings.findOne({_id: "#{service._id}_identity_path"})?.value
					data.authorizePath = Settings.findOne({_id: "#{service._id}_authorize_path"})?.value
					data.buttonLabelText = Settings.findOne({_id: "#{service._id}_button_label_text"})?.value
					data.buttonLabelColor = Settings.findOne({_id: "#{service._id}_button_label_color"})?.value
					data.buttonColor = Settings.findOne({_id: "#{service._id}_button_color"})?.value
					new CustomOAuth serviceName.toLowerCase(),
						serverURL: data.serverURL
						tokenPath: data.tokenPath
						identityPath: data.identityPath
						authorizePath: data.authorizePath

				if serviceName is 'Facebook'
					data.appId = data.clientId
					delete data.clientId

				if serviceName is 'Twitter'
					data.consumerKey = data.clientId
					delete data.clientId

				ServiceConfiguration.configurations.upsert {service: serviceName.toLowerCase()}, $set: data
			else
				ServiceConfiguration.configurations.remove {service: serviceName.toLowerCase()}
	, 2000

Settings.find().observe
	added: (record) ->
		if /^Accounts_OAuth_.+/.test record._id
			updateServices()

	changed: (record) ->
		if /^Accounts_OAuth_.+/.test record._id
			updateServices()

	removed: (record) ->
		if /^Accounts_OAuth_.+/.test record._id
			updateServices()
