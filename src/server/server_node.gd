extends Node

var peer
func _enter_tree():
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	else:
		start_network(false)


func start_network(server):
	peer = ENetMultiplayerPeer.new()
	if server:
		multiplayer.peer_connected.connect(create_player)
		multiplayer.peer_disconnected.connect(destroy_player)
		peer.create_server(4242)
		print("server listening on localhost 4242")
	else:
		peer.create_client("localhost",4242)
	
	multiplayer.set_multiplayer_peer(peer)

func create_player(id):
	print("WordPirate%s joined" % id)
	
func destroy_player(id):
	print("WordPirate%s leaved" % id)

func _ready():
	print("aksjdklaskdj")
