tool
extends EditorScenePostImport

var front_wheel_radius = 0.45
var front_wheel_stiffness = 30
var front_wheel_travel = 5
var rear_wheel_radius = 0.77
var rear_wheel_stiffness = 50
var rear_wheel_travel = 0.2
var tractor_weight = 2949

func post_import(scene):
	for child in scene.get_children():
		if child.name == "wheel_front_left" or child.name == "wheel_front_right" or child.name == "wheel_rear_left" or child.name == "wheel_rear_right":
			var vehicle_wheel = VehicleWheel.new()
			scene.remove_child(child)
			vehicle_wheel.name = child.name
			vehicle_wheel.translate(child.translation)
			child.translation = Vector3(0, 0, 0)
			var regex = RegEx.new()
			regex.compile("(front_right|front_left)$")
			if regex.search(child.name):
				vehicle_wheel.set_radius(front_wheel_radius)
				vehicle_wheel.set_suspension_stiffness(front_wheel_stiffness)
				vehicle_wheel.set_suspension_travel(front_wheel_travel)
				vehicle_wheel.set_use_as_steering(true)
			else:
				vehicle_wheel.set_radius(rear_wheel_radius)
				vehicle_wheel.set_suspension_stiffness(rear_wheel_stiffness)
				vehicle_wheel.set_suspension_travel(rear_wheel_travel)
				vehicle_wheel.set_use_as_traction(true)
			scene.add_child(vehicle_wheel)
			vehicle_wheel.set_owner(scene)
			vehicle_wheel.add_child(child)
			child.set_owner(scene)
		if child.name == "hitch":
			var hitch_area = Area.new()
			hitch_area.name = child.name + "_area"
			hitch_area.set_collision_layer_bit(0, false)
			hitch_area.set_collision_mask_bit(0, false)
			hitch_area.set_collision_layer_bit(1, true)
			hitch_area.set_collision_mask_bit(1, true)
			scene.add_child(hitch_area)
			hitch_area.set_owner(scene)
			hitch_area.translation = child.translation
			hitch_area.set_scale(Vector3(0.18, 0.6, 0.18))
			var collision_shape = CollisionShape.new()
			collision_shape.set_shape(BoxShape.new())
			hitch_area.add_child(collision_shape)
			collision_shape.set_owner(scene)
	var collision_shape = CollisionShape.new()
	scene.add_child(collision_shape)
	collision_shape.set_owner(scene)
	var old_scene = scene
	scene = VehicleBody.new()
	scene.name = "Tractor"
	for child in old_scene.get_children():
		old_scene.remove_child(child)
		scene.add_child(child)
		child.set_owner(scene)
		for sub_child in child.get_children():
			sub_child.set_owner(scene)
	scene.set_weight(tractor_weight)
	return scene
