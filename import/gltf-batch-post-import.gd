@tool
extends EditorScenePostImport

func _post_import(scene):
	var path = get_source_file()
	print("Running post import script on file '{file}'".format({'file': path}))
	
	path = path.substr(0, path.rfind('/'));
	path += "/models/";
	
	# Get valid mesh objects
	for object in scene.get_children():
		if !(object is MeshInstance3D):
			continue
		
		set_owner_on_node_descendents(object, object)
		
		object.transform.origin = Vector3(0,0,0)
		var nameType = object.name.get_slice("-",0)
		
		var finalpath = path + nameType + "/"
		var dir = DirAccess.open(path)
		if not dir.dir_exists(finalpath):
			dir.make_dir(finalpath)
		# Save each object to a file based on its object name		
		var packed = PackedScene.new()
		packed.pack(object)
		var scene_path = "{path}/{name}.scn".format({'path': finalpath, 'name': object.name})
		print(object.name, " -> ", scene_path)
		ResourceSaver.save(packed, scene_path)
	
	return scene

func set_owner_on_node_descendents(node : Node, owner : Node):
	for child in node.get_children():
		child.owner = owner
		set_owner_on_node_descendents(child, owner)
