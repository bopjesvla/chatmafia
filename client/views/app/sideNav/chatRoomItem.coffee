Template.chatRoomItem.helpers

	alert: ->
		if FlowRouter.getParam('_id') isnt this.rid or not document.hasFocus()
			return this.alert

	unread: ->
		if (FlowRouter.getParam('_id') isnt this.rid or not document.hasFocus()) and this.unread > 0
			return this.unread

	isDirectRoom: ->
		return this.t is 'd'

	userStatus: ->
		return 'status-' + (Session.get('user_' + this.name + '_status') or 'offline') if this.t is 'd'
		return ''

	name: ->
		return this.name

	roomIcon: ->
		switch this.t
			when 'd' then return 'icon-at'
			when 'c' then return 'icon-hash'
			when 'p' then return 'icon-lock'
			when 'g' then return 'icon-gamepad'

	active: ->
		if Session.get('openedRoom')? and Session.get('openedRoom') is this.rid
			return 'active'

	canLeave: ->
		return !!ChatSubscription.find({rid: this.rid, t: {$ne: 'd'}}).count()

	route: ->
		return switch this.t
			when 'd'
				FlowRouter.path('direct', {username: this.name})
			when 'p'
				FlowRouter.path('group', {name: this.name})
			when 'c'
				FlowRouter.path('channel', {name: this.name})
			when 'g'
				FlowRouter.path('game', {name: this.name.split(" ").join("_")})

Template.chatRoomItem.rendered = ->
	if not (FlowRouter.getParam('_id')? and FlowRouter.getParam('_id') is this.data.rid) and not this.data.ls
		KonchatNotification.newRoom(this.data.rid)

Template.chatRoomItem.events

	'click .open-room': (e) ->
		menu.close()

	'click .hide-room': (e) ->
		e.stopPropagation()
		e.preventDefault()

		if FlowRouter.getRouteName() in ['channel', 'group', 'direct', 'game'] and Session.get('openedRoom') is this.rid
			FlowRouter.go 'home'

		Meteor.call 'hideRoom', this.rid

	'click .leave-room': (e) ->
		e.stopPropagation()
		e.preventDefault()

		if FlowRouter.getRouteName() in ['channel', 'group', 'direct', 'game'] and Session.get('openedRoom') is this.rid
			FlowRouter.go 'home'

		RoomManager.close this.t + this.name
		
		Meteor.call 'leaveRoom', this.rid || this._id
