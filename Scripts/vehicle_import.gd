tool
extends EditorScenePostImport

func post_import(scene):
	for child in scene.get_children():
		if child.name == "wheel_front_left" or child.name == "wheel_front_right" or child.name == "wheel_rear_left" or child.name == "wheel_rear_right":
			var vehicle_wheel = VehicleWheel.new()
			scene.remove_child(child)
			vehicle_wheel.name = child.name
#			vehicle_wheel.rotation_degrees = child.rotation_degrees
#			vehicle_wheel.scale = child.scale
#			vehicle_wheel.transform = child.transform
			vehicle_wheel.translate(child.translation)
			child.translation = Vector3(0, 0, 0)
#			vehicle_wheel.global_scale(child.scale)
			scene.add_child(vehicle_wheel)
			vehicle_wheel.set_owner(scene)
			vehicle_wheel.add_child(child)
			child.set_owner(scene)
		if child.name == "hitch":
			var hitch_area = Area.new()
			hitch_area.name = child.name + "_area"
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
	return scene
