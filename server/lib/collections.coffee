@ChatMessage = new Meteor.Collection 'rocketchat_message'
@ChatRoom = new Meteor.Collection 'rocketchat_room'
@ChatSubscription = new Meteor.Collection 'rocketchat_subscription'
@MafiaSetup = new Meteor.Collection 'chatmafia_setups'
@MafiaRoles = new Meteor.Collection 'chatmafia_roles'
@MafiaGames = new Meteor.Collection 'chatmafia_games'
@MapReducedStatistics = new Mongo.Collection 'rocketchat_mr_statistics'
@ChatReports = new Meteor.Collection 'rocketchat_reports'
