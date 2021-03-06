Meteor.methods
	createGame: (setup) ->
		unless Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createGame -> Invalid user"
		
		user = Meteor.user()
		{username} = user
		
		if user.g?
			throw new Meteor.Error 'already-in-game', "You're already in a game."
		
		unless typeof setup?.name is "string" and /^[\p{L} ]{3,22}$/i.test setup.name
			throw new Meteor.Error 'setup-name-invalid'
		
		{name} = setup
		
		now = new Date()
		u =
			_id: Meteor.userId()
			username: username
		
		if setup.roles?
			s = []
			size = 0
			i = 0
			for r, count of setup.roles
				[role,alignment] = r.split("/")
				p = {}
				
				if alignment
					unless TeamConfig[alignment]?
						throw new Meteor.Error 'invalid-setup', "Alignment #{alignment} not found"
					
					p.a = alignment
				
				if role
					parts = role.split("+")
					for part in parts
						unless role and MafiaRoles.findOne({n:role, team: {$in: [alignment,undefined] }})
							throw new Meteor.Error 'invalid-setup', "Role not found"
					
					p.r = parts
				
				if typeof count is "number" and count > 1
					p.c = count
				
				s[i++] = p
				size += count or 1
				throw new Meteor.Error 'enormous-setup' if size > 25
			
			throw new Meteor.Error 'empty-setup' unless size > 1
			
			ms =
				n: name
				# s: s.sort((a, b) -> return (a.a or 't').localeCompare(b.a or 't') or (a.r or '').localeCompare(b.r or ''))
				s: s
				size: size
				ts: now
				u: u
				plays: 0
				runs: 1
			try
				ms._id = MafiaSetups.insert(ms)
			catch e
				throw new Meteor.Error 'duplicate-key'

		ms ?= MafiaSetups.findAndModify(
			query: n: name
			update: $inc: runs: 1
		)
		
		throw new Meteor.Error 'setup-not-found', "Setup not found" unless ms?
		throw new Meteor.Error 'invalid-setup', "Setup banned" if ms.banned
		
		console.log '[methods] createGame -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		# name = s.slugify name

		room =
			usernames: [username]
			ts: now
			t: 'g'
			name: "#{name} #{ms.runs+1}"
			msgs: 0
			u: u
			gs: "signups"
			sid: ms._id
			size: ms.size

		RocketChat.callbacks.run 'beforeCreateChannel', user, room

		# create new room
		rid = ChatRoom.insert room
		
		sub =
			rid: rid
			ts: now
			name: "#{name} #{ms.runs+1}"
			t: 'g'
			unread: 0
			u: u

		sub.ls = now
		sub.open = true

		ChatSubscription.insert sub
		
		Meteor.users.update Meteor.userId(), {$set: g: rid}

		Meteor.defer ->

			RocketChat.callbacks.run 'afterCreateChannel', user, room

		return {
			rid: rid
		}
