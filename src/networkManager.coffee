Promise = require 'bluebird'
DBus = require './dbus-promise'
_ = require 'lodash'

dbus = new DBus()

bus = dbus.getBus('system')

systemd = require './systemd'

SERVICE = 'org.freedesktop.NetworkManager'
WHITE_LIST = ['resin-vpn', 'eth0']

NM_STATE_CONNECTED_GLOBAL = 70
NM_DEVICE_TYPE_WIFI = 2
NM_CONNECTIVITY_FULL = 5

exports.start = ->
	systemd.start('NetworkManager.service')

exports.stop = ->
	systemd.stop('NetworkManager.service')

exports.isSetup = ->
	getConnections()
	.map(validateConnection)
	.then (results) ->
    	return false in results

exports.setCredentials = (ssid, passphrase) ->
	connection = {
		'802-11-wireless': {
			ssid: _.invokeMap(ssid, 'charCodeAt')
		},
		connection: {
			id: ssid,
			type: '802-11-wireless',
		},
		'802-11-wireless-security': {
			'auth-alg': 'open',
			'key-mgmt': 'wpa-psk',
			'psk': passphrase,
		}
	}

	console.log('Saving connection')
	console.log(connection)

	bus.getInterfaceAsync(SERVICE, '/org/freedesktop/NetworkManager/Settings', 'org.freedesktop.NetworkManager.Settings')
	.then (settings) ->
		settings.AddConnectionAsync(connection)

exports.clearCredentials = ->
	getConnections()
	.map(deleteConnection)

exports.connect  = (timeout) ->
	getDevices()
	.then (devices) ->
		buffer = []
		for device in devices
			buffer.push(validateDevice(device))
		Promise.all(buffer)
		.then (results) ->
			console.log(results)
			bus.getInterfaceAsync(SERVICE, '/org/freedesktop/NetworkManager', 'org.freedesktop.NetworkManager')
			.then (manager) ->
				console.log('yo')
				console.log(manager)
				manager.ActivateConnectionAsync('/', devices[results.indexOf(true)], '/')
				.catch (e) ->
					console.log('error')
					console.log(e)
				.then ->
					console.log('yo1')
					new Promise (resolve, reject) ->
						handler = (value) ->
							if value == NM_STATE_CONNECTED_GLOBAL
								manager.removeListener('StateChanged', handler)
								resolve()

						# Listen for 'Connected' signals
						manager.on('StateChanged', handler)

						# But try to read in case we registered the event handler
						# after is was already connected
						manager.CheckConnectivityAsync()
						.then (state) ->
							if state == NM_CONNECTIVITY_FULL
								manager.removeListener('StateChanged', handler)
								resolve()

						setTimeout ->
							manager.removeListener('StateChanged', handler)
							reject()
						, timeout

getConnections = ->
	bus.getInterfaceAsync(SERVICE, '/org/freedesktop/NetworkManager/Settings', 'org.freedesktop.NetworkManager.Settings')
	.call('ListConnectionsAsync')

getConnection = (connection) ->
	bus.getInterfaceAsync(SERVICE, connection, 'org.freedesktop.NetworkManager.Settings.Connection')

validateConnection = (connection) ->
	getConnection(connection)
	.call('GetSettingsAsync')
	.then (settings) ->
		return settings.connection.id in WHITE_LIST

deleteConnection = (connection) ->
	getConnection(connection)
	.then (connection) ->
		connection.GetSettingsAsync()
		.then (settings) ->
			if settings.connection.id not in WHITE_LIST
				connection.DeleteAsync()

getDevices = ->
	bus.getInterfaceAsync(SERVICE, '/org/freedesktop/NetworkManager', 'org.freedesktop.NetworkManager')
	.call('GetDevicesAsync')

getDevice = (device) ->
	bus.getInterfaceAsync(SERVICE, device, 'org.freedesktop.NetworkManager.Device')

validateDevice = (device) ->
	getDevice(device)
	.call('getPropertyAsync', 'DeviceType')	
	.then (property) ->
		return property == NM_DEVICE_TYPE_WIFI
