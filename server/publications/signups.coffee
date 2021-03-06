Meteor.publish 'signups', () ->
	unless this.userId
		return this.ready()

	console.log '[publish] signups ->'.green

	# Change to validate access manualy
	# if not Meteor.call 'canAccessRoom', rid, this.userId
	# 	return this.ready()

	ChatRoom.find
		t: 'g'
		gs: $in: ['signups', 'filled']
	,
		fields:
			ts: 1
			name: 1
			t: 1
			cl: 1
			u: 1
			usernames: 1
			gs: 1
			size: 1
		limit: 20