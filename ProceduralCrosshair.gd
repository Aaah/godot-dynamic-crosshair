extends Control

# configuration
export(float, 0.0, 100.0) var recoil_offset = 25.0
export(float, 0.0, 100.0) var recoil_max = 100.0
export(float, 0.0, 100.0) var recoil_min = 2.0
export(float, 0.0, 100.0) var recoil_release = 0.5
export(float, 0.0, 100.0) var xhair_maxlw = 5.0
export(float, 0.0, 100.0) var xhair_minlw = 1.0
export(Color, RGB) var xhair_color := Color(1.0, 1.0, 1.0)
export(bool) var debug_display = true

# context parameters
var current_recoil = recoil_min
var xhair_npoints_lod = 32
var xhair_lw = 1.0
var center = Vector2()
var shoot_coords = Vector2()

# 1. [done] Crosshair is a circle
# 2. [done] Its radius increases when shoot, cooldown to get back to normal size
# 3. [todo] Its radius is a function of the distance to the object aimed at
# 4. [done] simplify deg to rad, keep all in radians
# 5. [todo] recoil that pushes up the weapon the xhair

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _draw_dot(pos, color):
	draw_line(pos, pos + Vector2(1,1), color, 2.0)

func _draw_circle(center, radius, color, linewidth):

	var points_arc = PoolVector2Array()

	for i in range(xhair_npoints_lod + 1):
		var angle_point = i * 2.0 * PI / xhair_npoints_lod
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(xhair_npoints_lod):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, linewidth)

func _input(event):
	if Input.is_action_just_pressed("shoot"):
#		print("Mouse Click at: ", event.position)
		# get coordinates of the shot
		shoot_coords = _get_shoot_position(event)
		
		# update the recoil
		current_recoil = clamp(current_recoil + recoil_offset, recoil_min, recoil_max)
	
#		print("shoot : %d x %d" % [shoot_coords[0], shoot_coords[1]])
#		print("Shoot at Radius : %.3f pxl, Angle = %.3f rad" % [shoot_coords[0], shoot_coords[1]])
		
func _draw():
	_draw_circle(center, current_recoil, xhair_color, xhair_lw)
	if debug_display:
		_draw_dot(shoot_coords, Color(1.0,0.0,0.0))
	
func _process(delta):
	
	# permanent release of the recoil
	if current_recoil > recoil_min:
		current_recoil = lerp(current_recoil, 0.0, delta / recoil_release)
	
	# the crosshair follows the mouse
	center = get_viewport().get_mouse_position()
	xhair_color.a = 1.0 - current_recoil / recoil_max
	xhair_lw = xhair_minlw + (xhair_maxlw - xhair_minlw) * (current_recoil / recoil_max)
	
	update() # call the _draw function again

func _get_shoot_position(event):
	# random draw for the bullet
	var r = randf() * current_recoil
	var theta = randf() * 2 * PI
	var pos = event.position + r * Vector2(cos(theta), sin(theta))
	return pos
