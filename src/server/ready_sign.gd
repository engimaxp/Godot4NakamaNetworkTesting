extends HBoxContainer
@onready var name_label = $Name
@onready var ready_label = $Ready

var username:String:
	set(val):
		username = val
		if is_instance_valid(name_label):
			name_label.text = username

var is_ready:bool = false:
	set(val):
		is_ready = val
		if is_instance_valid(ready_label):
			ready_label.text = "Ready" if is_ready else "NotReady"

var id:String
# Called when the node enters the scene tree for the first time.
func _ready():
	self.username = username
	self.is_ready = is_ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
