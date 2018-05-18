extends Spatial


const ROT_SPEED = 0.15
var rot_x = 0
var rot_y = 0
var zoom = 0
const ZOOM_SPEED = 0.2
const ZOOM_MAX = 7
onready var initial_rotation = get_node(NodePath("camera")).get_rotation().y
var trailer
var is_hitch_close = false
var is_hitched = false
var cone_joint
var trailer_hitch
var tractor_hitch
var tractor
var trailer_info

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cone_joint = get_node("ConeTwistJoint")
	trailer_hitch = get_node("Trailer/Hitch")
	tractor_hitch = get_node("Tractor/hitch_area")
	tractor = tractor_hitch.get_parent()
	trailer_info = get_node("Control/trailer_info")
	tractor_hitch.connect("area_entered", self, "_on_Hitch_area_entered")
	tractor_hitch.connect("area_exited", self, "_on_Hitch_area_exited")

func _unhandled_input(ev):

	if (ev is InputEventMouseButton and ev.button_index == BUTTON_WHEEL_UP):
		if (zoom<ZOOM_MAX):
			zoom+=ZOOM_SPEED
			get_node("camera/base/rotation/camera").translation.z = -zoom

	if (ev is InputEventMouseButton and ev.button_index == BUTTON_WHEEL_DOWN):
		if (zoom>-ZOOM_MAX):
			zoom-=ZOOM_SPEED
			get_node("camera/base/rotation/camera").translation.z = -zoom

	if (ev is InputEventMouseButton and ev.button_mask == BUTTON_MASK_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if (ev is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		rot_y += ev.relative.x * ROT_SPEED
		rot_x += ev.relative.y * ROT_SPEED
#		rot_y = clamp(rot_y,-180,180)
		rot_x = clamp(rot_x,-35,65)
		var t = Transform()
		t = t.rotated(Vector3(0,0,1),rot_x * PI / 180.0)
		t = t.rotated(Vector3(0,1,0),-rot_y * PI / 180.0)


		get_node("camera/base").transform.basis = t.basis

	if (ev.is_action_pressed("key_escape")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if (ev.is_action_pressed("key_hitch")):
		if is_hitched:
			cone_joint.set_node_b(NodePath())
			cone_joint.set_node_a(NodePath())
			trailer_info.set_text("Press Q to hitch trailer")
			is_hitched = false
		elif is_hitch_close:
			cone_joint.set_node_b(NodePath())
			cone_joint.set_node_a(NodePath())
			var original_tractor_transform = tractor.global_transform
			cone_joint.global_transform = trailer_hitch.get_global_transform()
			trailer_hitch.get_parent().translate(Vector3(0, 0, -0.1))
			cone_joint.set_node_b(trailer_hitch.get_parent().get_path())
			tractor.global_transform = cone_joint.global_transform
			tractor.translate(Vector3(-tractor_hitch.translation.x, -tractor_hitch.translation.y, -tractor_hitch.translation.z))
			cone_joint.set_node_a(tractor.get_path())
			tractor.global_transform = original_tractor_transform
			trailer_info.set_text("Press Q to unhitch trailer")
			is_hitched = true

func _process(delta):
	get_node("camera").set_transform(get_node("Tractor").get_transform())
	get_node("camera").rotation = get_node("Tractor").rotation
	get_node("camera").rotate_y(initial_rotation)
	var velocity = get_node("Tractor").get_linear_velocity()
	var speed = abs(velocity.x) + abs(velocity.y) + abs(velocity.z)
	get_node("Control/Panel/Label").text = String(round(speed)) + " km/h\n Not accurate"


func _on_Hitch_area_entered(area):
	if area is Area:
		trailer_info.set_visible(true)
		trailer_info.set_text("Press Q to hitch trailer")
		is_hitch_close = true


func _on_Hitch_area_exited(area):
	if area is Area:
		trailer_info.set_visible(false)
		is_hitch_close = false
