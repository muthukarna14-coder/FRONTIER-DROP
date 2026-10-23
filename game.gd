extends Node3D

const ARENA_SIZE := 180.0
const BOT_COUNT := 10
var player: CharacterBody3D
var camera_pivot: Node3D
var camera: Camera3D
var hud: Label
var status_label: Label
var fire_button: Button
var move_vector := Vector2.ZERO
var look_touch_id := -1
var last_look := Vector2.ZERO
var health := 100
var ammo := 30
var reserve_ammo := 120
var kills := 0
var match_time := 0.0
var fire_cooldown := 0.0
var zone_radius := 82.0
var bots: Array[CharacterBody3D] = []
var rng := RandomNumberGenerator.new()
var mobile := false

func _ready() -> void:
 rng.randomize()
 mobile = OS.has_feature("mobile")
 _build_world()
 _build_player()
 _build_bots()
 _build_ui()
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not mobile else Input.MOUSE_MODE_VISIBLE

func _build_world() -> void:
 var env := WorldEnvironment.new()
 var e := Environment.new()
 e.background_mode = Environment.BG_SKY
 e.sky = Sky.new()
 e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 e.ambient_light_color = Color(0.62, 0.70, 0.78)
 e.ambient_light_energy = 0.75
 e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
 env.environment = e
 add_child(env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-48, -28, 0)
 sun.light_energy = 1.25
 sun.shadow_enabled = true
 add_child(sun)
 _box("Island", Vector3(0, -1.2, 0), Vector3(ARENA_SIZE, 2.0, ARENA_SIZE), Color(0.20, 0.35, 0.20))
 # Sand perimeter and simple road strips.
 _box("North beach", Vector3(0, -0.12, -86), Vector3(180, 0.25, 8), Color(0.72, 0.63, 0.42))
 _box("South beach", Vector3(0, -0.12, 86), Vector3(180, 0.25, 8), Color(0.72, 0.63, 0.42))
 _box("East beach", Vector3(86, -0.12, 0), Vector3(8, 0.25, 180), Color(0.72, 0.63, 0.42))
 _box("West beach", Vector3(-86, -0.12, 0), Vector3(8, 0.25, 180), Color(0.72, 0.63, 0.42))
 _box("Main road", Vector3(0, 0.02, 0), Vector3(8, 0.08, 170), Color(0.22, 0.23, 0.22))
 _box("Cross road", Vector3(0, 0.03, 10), Vector3(165, 0.08, 6), Color(0.22, 0.23, 0.22))
 for i in range(36):
  var p := Vector3(rng.randf_range(-78,78), 0, rng.randf_range(-78,78))
  if abs(p.x) < 10 or abs(p.z) < 8: continue
  if rng.randf() < 0.55:
   _make_tree(p, rng.randf_range(0.8,1.45))
  else:
   var sx := rng.randf_range(4,9)
   var sz := rng.randf_range(4,9)
   _box("Abandoned building", Vector3(p.x, 1.3, p.z), Vector3(sx, 2.6, sz), Color(0.37,0.39,0.37))
   _box("Roof", Vector3(p.x, 2.68, p.z), Vector3(sx+0.4,0.18,sz+0.4), Color(0.19,0.22,0.23))
 # Cover blocks around arena
 for i in range(22):
  var p := Vector3(rng.randf_range(-72,72),0,rng.randf_range(-72,72))
  _box("Concrete cover", Vector3(p.x,0.8,p.z), Vector3(rng.randf_range(1.5,3.5),1.6,rng.randf_range(1.5,3.5)), Color(0.36,0.39,0.39))

func _make_tree(p: Vector3, s: float) -> void:
 var trunk := _box("Tree trunk", p + Vector3(0,1.1*s,0), Vector3(0.55*s,2.2*s,0.55*s), Color(0.27,0.17,0.10))
 var crown := MeshInstance3D.new()
 var mesh := SphereMesh.new()
 mesh.radius = 1.65*s
 mesh.height = 3.1*s
 crown.mesh = mesh
 crown.position = p + Vector3(0,3.1*s,0)
 var mat := StandardMaterial3D.new()
 mat.albedo_color = Color(0.12+rng.randf()*0.06,0.28+rng.randf()*0.1,0.15)
 crown.material_override = mat
 add_child(crown)

func _box(n: String, p: Vector3, size: Vector3, color: Color) -> StaticBody3D:
 var body := StaticBody3D.new()
 body.name = n
 body.position = p
 var mesh := BoxMesh.new()
 mesh.size = size
 var mi := MeshInstance3D.new()
 mi.mesh = mesh
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.roughness = 0.92
 mi.material_override = mat
 body.add_child(mi)
 var shape := CollisionShape3D.new()
 var box := BoxShape3D.new()
 box.size = size
 shape.shape = box
 body.add_child(shape)
 add_child(body)
 return body

func _build_player() -> void:
 player = CharacterBody3D.new()
 player.name = "Player"
 player.position = Vector3(0, 1, 25)
 var capsule := CapsuleMesh.new()
 capsule.radius = 0.48
 capsule.height = 1.8
 var bodymesh := MeshInstance3D.new()
 bodymesh.mesh = capsule
 var mat := StandardMaterial3D.new()
 mat.albedo_color = Color(0.10,0.30,0.48)
 mat.metallic = 0.12
 bodymesh.material_override = mat
 bodymesh.position.y = 0.9
 player.add_child(bodymesh)
 var shape := CollisionShape3D.new()
 var cap := CapsuleShape3D.new()
 cap.radius = 0.48
 cap.height = 1.8
 shape.shape = cap
 shape.position.y = 0.9
 player.add_child(shape)
 camera_pivot = Node3D.new()
 camera_pivot.position.y = 1.55
 player.add_child(camera_pivot)
 camera = Camera3D.new()
 camera.position = Vector3(0,1.0,5.4)
 camera.rotation_degrees.x = -9
 camera.current = true
 camera_pivot.add_child(camera)
 add_child(player)

func _build_bots() -> void:
 for i in BOT_COUNT:
  var b := CharacterBody3D.new()
  b.name = "PracticeBot_%02d" % (i+1)
  b.position = Vector3(rng.randf_range(-65,65), 0.9, rng.randf_range(-65,65))
  var mesh := MeshInstance3D.new()
  var capsule := CapsuleMesh.new()
  capsule.radius = 0.45
  capsule.height = 1.75
  mesh.mesh = capsule
  var mat := StandardMaterial3D.new()
  mat.albedo_color = Color(0.56,0.18,0.12)
  mesh.material_override = mat
  mesh.position.y = 0.9
  b.add_child(mesh)
  var col := CollisionShape3D.new()
  var shape := CapsuleShape3D.new()
  shape.radius = 0.45
  shape.height = 1.75
  col.shape = shape
  col.position.y = 0.9
  b.add_child(col)
  b.set_meta("hp", 100)
  b.set_meta("dir_timer", rng.randf_range(0.5,3.0))
  b.set_meta("dir", Vector3(rng.randf_range(-1,1),0,rng.randf_range(-1,1)).normalized())
  add_child(b)
  bots.append(b)

func _build_ui() -> void:
 var layer := CanvasLayer.new()
 add_child(layer)
 var panel := PanelContainer.new()
 panel.position = Vector2(18,18)
 panel.size = Vector2(300,100)
 layer.add_child(panel)
 var vb := VBoxContainer.new()
 panel.add_child(vb)
 var title := Label.new()
 title.text = "FRONTIER DROP  /  FIELD TEST"
 title.add_theme_font_size_override("font_size",18)
 vb.add_child(title)
 hud = Label.new()
 hud.text = "HP 100  |  AMMO 30/120"
 vb.add_child(hud)
 status_label = Label.new()
 status_label.text = "ELIMINATIONS 0  |  PRACTICE BOTS %d" % BOT_COUNT
 vb.add_child(status_label)
 var hint := Label.new()
 hint.text = "WASD move • Mouse aim • Click fire • R reload • Esc mouse"
 hint.position = Vector2(18,126)
 layer.add_child(hint)
 var reticle := Label.new()
 reticle.text = "+"
 reticle.add_theme_font_size_override("font_size",30)
 reticle.position = Vector2(632,338)
 layer.add_child(reticle)
 var reload_button := Button.new()
 reload_button.text = "RELOAD"
 reload_button.position = Vector2(1080,590)
 reload_button.size = Vector2(150,60)
 reload_button.pressed.connect(_reload)
 layer.add_child(reload_button)
 fire_button = Button.new()
 fire_button.text = "FIRE"
 fire_button.position = Vector2(1080,500)
 fire_button.size = Vector2(150,75)
 fire_button.button_down.connect(_fire)
 layer.add_child(fire_button)
 var jump_button := Button.new()
 jump_button.text = "JUMP"
 jump_button.position = Vector2(910,590)
 jump_button.size = Vector2(130,60)
 jump_button.pressed.connect(_jump)
 layer.add_child(jump_button)
 var left := Button.new()
 left.text = "◀"
 left.position = Vector2(25,520)
 left.size = Vector2(80,80)
 left.button_down.connect(func(): move_vector.x = -1.0)
 left.button_up.connect(func(): move_vector.x = 0.0)
 layer.add_child(left)
 var right := Button.new()
 right.text = "▶"
 right.position = Vector2(195,520)
 right.size = Vector2(80,80)
 right.button_down.connect(func(): move_vector.x = 1.0)
 right.button_up.connect(func(): move_vector.x = 0.0)
 layer.add_child(right)
 var forward := Button.new()
 forward.text = "▲"
 forward.position = Vector2(110,475)
 forward.size = Vector2(80,70)
 forward.button_down.connect(func(): move_vector.y = -1.0)
 forward.button_up.connect(func(): move_vector.y = 0.0)
 layer.add_child(forward)
 var back := Button.new()
 back.text = "▼"
 back.position = Vector2(110,610)
 back.size = Vector2(80,65)
 back.button_down.connect(func(): move_vector.y = 1.0)
 back.button_up.connect(func(): move_vector.y = 0.0)
 layer.add_child(back)

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  player.rotate_y(-event.relative.x * 0.0025)
  camera_pivot.rotate_x(-event.relative.y * 0.0022)
  camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -0.8, 0.5)
 elif event is InputEventKey and event.pressed:
  if event.keycode == KEY_ESCAPE:
   Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  elif event.keycode == KEY_R:
   _reload()
  elif event.keycode == KEY_SPACE:
   _jump()
 elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  if not mobile: _fire()

func _physics_process(delta: float) -> void:
 match_time += delta
 fire_cooldown = maxf(0.0, fire_cooldown-delta)
 var input_vec := Vector2.ZERO
 if Input.is_key_pressed(KEY_W): input_vec.y -= 1
 if Input.is_key_pressed(KEY_S): input_vec.y += 1
 if Input.is_key_pressed(KEY_A): input_vec.x -= 1
 if Input.is_key_pressed(KEY_D): input_vec.x += 1
 input_vec += move_vector
 input_vec = input_vec.limit_length(1.0)
 var dir := (player.global_transform.basis * Vector3(input_vec.x,0,input_vec.y)).normalized()
 player.velocity.x = dir.x * 7.0
 player.velocity.z = dir.z * 7.0
 if not player.is_on_floor(): player.velocity.y -= 20.0*delta
 else: player.velocity.y = -0.2
 player.move_and_slide()
 player.position.x = clampf(player.position.x,-87,87)
 player.position.z = clampf(player.position.z,-87,87)
 _update_bots(delta)
 if Vector2(player.position.x,player.position.z).length() > zone_radius:
  health = maxi(0,health-int(5*delta))
  if health == 0: _respawn_player()
 if match_time > 35.0:
  zone_radius = maxf(22.0, 82.0 - (match_time-35.0)*0.35)
 hud.text = "HP %d  |  AMMO %d/%d  |  ZONE %dm" % [health,ammo,reserve_ammo,int(zone_radius)]
 status_label.text = "ELIMINATIONS %d  |  PRACTICE BOTS %d" % [kills,bots.size()]

func _update_bots(delta: float) -> void:
 for b in bots:
  if not is_instance_valid(b): continue
  var to_player := player.global_position - b.global_position
  var d := to_player.length()
  if d < 35.0 and d > 8.0:
   var ddir := to_player.normalized()
   b.velocity.x = ddir.x * 2.0
   b.velocity.z = ddir.z * 2.0
  else:
   var timer: float = b.get_meta("dir_timer") - delta
   if timer <= 0:
    b.set_meta("dir_timer",rng.randf_range(0.8,2.5))
    b.set_meta("dir",Vector3(rng.randf_range(-1,1),0,rng.randf_range(-1,1)).normalized())
   else: b.set_meta("dir_timer",timer)
   var wander: Vector3 = b.get_meta("dir")
   b.velocity.x = wander.x * 1.1
   b.velocity.z = wander.z * 1.1
  if not b.is_on_floor(): b.velocity.y -= 18*delta
  else: b.velocity.y = -0.1
  b.move_and_slide()
  if d < 18 and rng.randf() < 0.006:
   health = maxi(0,health-4)

func _fire() -> void:
 if fire_cooldown > 0 or ammo <= 0: return
 fire_cooldown = 0.18
 ammo -= 1
 var from := camera.global_position
 var to := from + (-camera.global_transform.basis.z * 110.0)
 var query := PhysicsRayQueryParameters3D.create(from,to)
 query.exclude = [player]
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 if hit:
  var obj: Object = hit.get("collider")
  if obj is CharacterBody3D and str(obj.name).begins_with("PracticeBot_"):
   var hp: int = int(obj.get_meta("hp")) - 34
   if hp <= 0:
    bots.erase(obj)
    obj.queue_free()
    kills += 1
   else:
    obj.set_meta("hp",hp)

func _reload() -> void:
 if ammo >= 30 or reserve_ammo <= 0: return
 var take := mini(30-ammo,reserve_ammo)
 ammo += take
 reserve_ammo -= take

func _jump() -> void:
 if player.is_on_floor(): player.velocity.y = 7.0

func _respawn_player() -> void:
 health = 100
 player.global_position = Vector3(0,1,25)
