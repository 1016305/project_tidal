extends Camera3D

const effects = preload("res://scripts/animation/woozy_head_camera_attrib.tres")

func exposure():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self.effects, "exposure_multiplier", 4, 1.5)
	tween.tween_property(self.effects, "exposure_multiplier", 0.5, 2)
	tween.tween_property(self.effects, "exposure_multiplier", 3, 2)
	tween.tween_property(self.effects, "exposure_multiplier", 1, 2.3)
	#7.8s
	
func blur():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	effects.set_dof_blur_near_enabled(true)
	effects.set_dof_blur_near_distance(100)
	effects.set_dof_blur_amount(0)
	tween.tween_property(self.effects, "dof_blur_amount", 0.7, 1.6)
	tween.tween_property(self.effects, "dof_blur_amount", 0.05, 2.4)
	tween.tween_property(self.effects, "dof_blur_amount", 0.31, 2.1)
	tween.tween_property(self.effects, "dof_blur_amount", 0, 1.7)

	await tween.finished
	print("tween_finished")
	effects.set_dof_blur_near_enabled(false)
	#7.8

func intro_blur_and_exposure():
	exposure()
	blur()
