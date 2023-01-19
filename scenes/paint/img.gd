extends Sprite

var img_id: int = Globals.img_id
var path: String = "res://scenes/paint/assets/paint/images/"+ String(img_id) + ".png"
var img_resource : StreamTexture = load(path)
var img: Image = Image.new()
var selected_texture
var pattern_image : Image
var imageTexture : ImageTexture = ImageTexture.new()
var selected_color : Color
var thread : Thread
var main_color = Color8(212,212,212)
var previous_animation_player = null
var mode: int = 0
var brush = Globals.brush
var run = false
var activeLine

var stars = preload("res://scenes/paint/paricles.tscn")

func _ready():
	var lines_overlay_node = get_node("../lines_overlay")
	if Globals.painting_type == "drawing":
		lines_overlay_node.visible = false
		scale = Vector2(1,1)
	else:
		lines_overlay_node.texture = load("res://scenes/paint/assets/paint/images/overlays/"+ String(img_id) + ".png")
		img = img_resource.get_data()
		img.lock()
		thread = Thread.new()
		clean()
	
	texture = img_resource
	
func has_colored_everything():
	return true

func clean():
	var sizeX = img.get_size().x - 1
	var sizeY = img.get_size().y - 1
	
	for i in range(sizeX):
		for j in range(sizeY):
			if img.get_pixel(i,j).r < 0.9 and img.get_pixel(i,j).g < 0.9 and img.get_pixel(i,j).b < 0.9 or img.get_pixel(i,j).a < 0.9:
				img.set_pixel(i,j,Color(0,0,0,1))
			else:
				img.set_pixel(i,j,Color(1,1,1,1))
	
	imageTexture.create_from_image(img,16)
	texture = imageTexture


func color_pattern(position):
	var posX: int = int(position.x)
	var posY: int = int(position.y)
	var sizeX = img.get_size().x - 1
	var sizeY = img.get_size().y - 1
	var black_color: Color = Color.black
	if(img.get_pixel(posX,posY)).is_equal_approx(black_color):
		return

	var stack = [posX,posY]
	while stack.size() != 0 :
		var currentY = stack.pop_back()
		var currentX = stack.pop_back()
		var main_color_p = pattern_image.get_pixel(currentX,currentY)
		img.set_pixel(currentX,currentY,main_color_p)
		if currentX < sizeX and !img.get_pixel(currentX+1,currentY).is_equal_approx(black_color) and img.get_pixel(currentX+1,currentY) != pattern_image.get_pixel(currentX+1,currentY):
			stack.append(currentX+1)
			stack.append(currentY)
		if currentX > 0 and !img.get_pixel(currentX-1,currentY).is_equal_approx(black_color) and img.get_pixel(currentX-1,currentY) != pattern_image.get_pixel(currentX-1,currentY):
			stack.append(currentX-1)
			stack.append(currentY)
		if currentY < sizeY and !img.get_pixel(currentX,currentY+1).is_equal_approx(black_color) and img.get_pixel(currentX,currentY+1) != pattern_image.get_pixel(currentX,currentY+1):
			stack.append(currentX)
			stack.append(currentY+1)
		if currentY > 0 and !img.get_pixel(currentX,currentY-1).is_equal_approx(black_color) and img.get_pixel(currentX,currentY-1) != pattern_image.get_pixel(currentX,currentY-1):
			stack.append(currentX)
			stack.append(currentY-1)

	imageTexture.create_from_image(img,32)
	texture = imageTexture


func color(position):
	var posX = position.x
	var posY = position.y
	var sizeX = img.get_size().x - 1
	var sizeY = img.get_size().y - 1
	var stack: Array = [posX,posY]
	var black = Color.black
	if(img.get_pixel(posX,posY)).is_equal_approx(black):
		return
	while stack.size() != 0 :
		var currentY = stack.pop_back()
		var currentX = stack.pop_back()
		img.set_pixel(currentX,currentY,main_color)
		if currentX < sizeX and !img.get_pixel(currentX+1,currentY).is_equal_approx(black) and (img.get_pixel(currentX+1,currentY).r != main_color.r or img.get_pixel(currentX+1,currentY).g != main_color.g or img.get_pixel(currentX+1,currentY).b != main_color.b):
			stack.append(currentX+1)
			stack.append(currentY)
		if currentX > 0 and !img.get_pixel(currentX-1,currentY).is_equal_approx(black) and (img.get_pixel(currentX-1,currentY).r != main_color.r or img.get_pixel(currentX-1,currentY).g != main_color.g or img.get_pixel(currentX-1,currentY).b != main_color.b ):
			stack.append(currentX-1)
			stack.append(currentY)
		if currentY < sizeY and !img.get_pixel(currentX,currentY+1).is_equal_approx(black) and (img.get_pixel(currentX,currentY+1).r != main_color.r or img.get_pixel(currentX,currentY+1).g != main_color.g or img.get_pixel(currentX,currentY+1).b != main_color.b):
			stack.append(currentX)
			stack.append(currentY+1)
		if currentY > 0 and !img.get_pixel(currentX,currentY-1).is_equal_approx(black) and (img.get_pixel(currentX,currentY-1).r != main_color.r or img.get_pixel(currentX,currentY-1).g != main_color.g or img.get_pixel(currentX,currentY-1).b != main_color.b):
			stack.append(currentX)
			stack.append(currentY-1)
	imageTexture.create_from_image(img,32)
	texture = imageTexture

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if event.is_pressed():
			if thread.is_active():
				thread.wait_to_finish()
			if mode == 0:
				thread.start(self, "color", get_local_mouse_position())
			elif mode == 1:
				thread.start(self, "color_pattern", get_local_mouse_position())

func _on_Purple_pressed():
	var animation_player = get_node("../SC/HC/VB/CCPurple/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(212,212,212))

func _on_Green_pressed():
	var animation_player = get_node("../SC/HC/VB/CCGreen/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(180,180,180))

func _on_Red_pressed():
	var animation_player = get_node("../SC/HC/VB/CCRed/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(144,144,144))

func _on_Yellow_pressed():
	var animation_player = get_node("../SC/HC/VB/CCYellow/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(98,98,98))

func _on_Blue_pressed():
	var animation_player = get_node("../SC/HC/VB/CCBlue/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(74,74,74))

func _on_Brown_pressed():
	var animation_player = get_node("../SC/HC/VB/CCBrown/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(50,50,50))

func _on_Skyblue_pressed():
	var animation_player = get_node("../SC/HC/VB/CCSkyBlue/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(20,20,20))

func _on_Pink_pressed():
	var animation_player = get_node("../SC/HC/VB/CCPink/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(10,10,10))
	
func _on_Darkgreen_pressed():
	var animation_player = get_node("../SC/HC/VB/CCDarkGreen/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_color(animation_player,Color8(1,1,1))
	
func play_forward_animation_change_pattern(animation_player,pattern_name):
	if previous_animation_player != animation_player:
		animation_player.play("crayon-move")
		var pattern_img_resource = load("res://scenes/paint/assets/paint/pattern/"+pattern_name+".jpg")
		selected_texture = pattern_img_resource
		if Globals.painting_type != "drawing":
			pattern_image = pattern_img_resource.get_data()
			pattern_image.lock()
		previous_animation_player = animation_player
		mode = 1
	else:
		previous_animation_player = null
		
func play_forward_animation_change_color(animation_player,color):
	if previous_animation_player != animation_player:
		animation_player.play("crayon-move")
		main_color = color
		previous_animation_player = animation_player
		mode = 0
	else:
		previous_animation_player = null

func play_reverse_animation(_animation_player):
	if previous_animation_player != null and previous_animation_player.current_animation_position !=0:
		previous_animation_player.play_backwards("crayon-move")

func _on_Ballon_pressed():
	var animation_player = get_node("../SC2/HC/VB/CCBallon/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_pattern(animation_player,"screentone_1")

func _on_BlueWhite_pressed():
	var animation_player = get_node("../SC2/HC/VB/CCBlueWhite/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_pattern(animation_player,"screentone_2")

func _on_PinkBlue_pressed():
	var animation_player = get_node("../SC2/HC/VB/CCPinkBlue/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_pattern(animation_player,"screentone_3")

func _on_StreetArt_pressed():
	var animation_player = get_node("../SC2/HC/VB/CCStreetArt/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_pattern(animation_player,"screentone_4")

func _on_YellowDonuts_pressed():
	var animation_player = get_node("../SC2/HC/VB/CCYellowDonuts/AnimationPlayer")
	play_reverse_animation(animation_player)
	play_forward_animation_change_pattern(animation_player,"screentone_5")

func _on_CrayonButton_pressed():
	var animation_player_switch = get_node("../ToolSwitcher")
	if animation_player_switch != null and animation_player_switch.current_animation_position != 0:
		animation_player_switch.play_backwards("switch_colors_and_patterns")

func _on_PatternButon_pressed():
	var animation_player_switch = get_node("../ToolSwitcher")
	if animation_player_switch.current_animation_position != 0.5:
		animation_player_switch.play("switch_colors_and_patterns")

func _input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if event.is_pressed():
			if thread.is_active():
				thread.wait_to_finish()
			if mode == 0:
				thread.start(self, "color", get_local_mouse_position())
			elif mode == 1:
				thread.start(self, "color_pattern", get_local_mouse_position())
			_show_stars(event)

func _show_stars(event):
	var stars_instance = stars.instance()
	stars_instance.position = event.position				
	stars_instance.emitting = true
	add_child(stars_instance)
