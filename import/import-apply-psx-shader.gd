@tool
extends EditorScenePostImport

func _post_import(scene):
	replace_shader(scene)
	return scene

func replace_shader(node: Node):
	if node == null:
		return
	
	for child in node.get_children():
		if child is MeshInstance3D:
			child.position = Vector3.ZERO
			print("Swapping material on: %s" % [child.name])
			for mat_idx in range(0, child.mesh.get_surface_count()):
				var mat = child.mesh.surface_get_material(mat_idx)
				var new_mat = ShaderMaterial.new()
				var albedo_texture = mat.albedo_texture
				if albedo_texture != null:
					new_mat.shader = load("res://shaders/ps1-model.gdshader")
					new_mat.set_shader_parameter("albedo", mat.albedo_texture)
				else:
					new_mat.shader = load("res://shaders/ps1-model-flat.gdshader")
				new_mat.set_shader_parameter("albedo_color", mat.albedo_color)
				child.mesh.surface_set_material(mat_idx, new_mat)
		
		# Recursive call to get deeper Meshes (due to Armatures, etc.)
		replace_shader(child)
