extends Node
@onready var email = %Email
@onready var password = %Password
@onready var user_name = %UserName
@onready var regist = %Regist
@onready var login = %Login
@onready var finding_match = %FindingMatch
@onready var ready_screen = %ReadyScreen
@onready var matching = %Matching
@onready var find_match = %FindMatch
@onready var regist_login_panel = %RegistLoginPanel
@onready var ready_sign_panel = %ReadySignPanel
@onready var ready_sign_container = %ReadySignContainer
@onready var im_ready = %IMReady


func _ready():
	regist_login_panel.show()
	finding_match.hide()
	ready_screen.hide()
	ready_sign_panel.hide()
	find_match.pressed.connect(find_match_game)
	login.pressed.connect(login_user)
	regist.pressed.connect(regist_user)
	im_ready.pressed.connect(user_ready)
	OnlineMatch.matchmaker_matched.connect(on_match_found)

	OnlineMatch.player_joined.connect(PlayerJoined)
	OnlineMatch.player_left.connect(PlayerLeft)
	OnlineMatch.player_status_changed.connect(PlayerStatusChanged)
	OnlineMatch.match_ready.connect(MatchReady)
	OnlineMatch.match_not_ready.connect(MatchNotReady)

func PlayerJoined(player):
	pass
	
func PlayerLeft(player):
	pass
	
func PlayerStatusChanged(player, status):
	pass
	
func MatchReady(player):
	pass
	
func MatchNotReady(player):
	pass
	
func find_match_game():
	matching.show()
	find_match.hide()
	if not Online.is_nakama_socket_connected():
		await Online.connect_nakama_socket()
	print("looking for a match...")
	OnlineMatch.start_matchmaking(Online.nakama_socket,{"min_count":2})

func ready_screen_show():
	finding_match.hide()
	ready_screen.show()

func show_match_find():
	regist_login_panel.hide()
	finding_match.show()

func regist_user():
	print("regist_user start")
	var session = await Online.nakama_client.authenticate_device_async("d4b0fd15-78a5-46e8-8cad-306df0417c7e","aaaa1")
#	var session = await Online.nakama_client.authenticate_email_async(\
#		email.text,password.text,user_name.text,true)
	if session.is_exception():
		print(session.get_exception().message)
	Online.nakama_session = session
	print("regist_user end")
	show_match_find()

func login_user():
	print("login_user start")
	var session = await Online.nakama_client.authenticate_device_async("b2535e17-b7e3-4b84-a461-68ac62ccf0ce","bbbb1")
#	var session = await Online.nakama_client.authenticate_email_async(\
#		email.text,password.text,null,false)
	if session.is_exception():
		print(session.get_exception().message)
	Online.nakama_session = session
	print("login_user end")
	show_match_find()

func on_match_found(players):
	print(players)
	ready_screen_show()
	await get_tree().create_timer(1.0).timeout
	ready_sign_panel_show()
	for id in players:
		var userReady = READY_SIGN.instantiate()
		ready_sign_container.add_child(userReady)
		userReady.username = (players[id]["username"])
		userReady.id = id
		
const READY_SIGN = preload("res://src/server/ready_sign.tscn")

func ready_sign_panel_show():
	ready_screen.hide()
	ready_sign_panel.show()

func _get_custom_rpc_methods():
	return [
		"playerIsReady"
	]

func user_ready():
	OnlineMatch.custom_rpc_sync(self,"playerIsReady",[OnlineMatch.get_my_session_id()])

var ready_players = {}

func playerIsReady(sessionId):
	for c in ready_sign_container.get_children():
		if c.id == sessionId:
			c.is_ready = true
	if OnlineMatch.is_network_server():
		ready_players[sessionId] = true
		if ready_players.size() == OnlineMatch.players.size():
			OnlineMatch.start_playing()
