extends Node2D
## Star Catcher: catch the falling stars before they reach the ground.
## Move with the arrow keys, the mouse or a finger. Everything is drawn in code, so this one
## file is the whole game.

const PADDLE_SIZE := Vector2(160.0, 26.0)
const PADDLE_SPEED := 900.0
const PADDLE_MARGIN := 70.0
const STAR_RADIUS := 24.0
const LIVES := 5

const SKY := Color("14182b")
const GROUND := Color("232a45")
const PADDLE := Color("f2b233")
const STAR := Color("ffe9a8")
const INK := Color("eceef0")

var _paddle_x := 0.0
var _pointer_x := -1.0
var _stars: Array[Dictionary] = []
var _spawn_in := 0.5
var _score := 0
var _lives := LIVES
var _best := 0


func _ready() -> void:
	_paddle_x = get_viewport_rect().size.x / 2.0


func _process(delta: float) -> void:
	var size := get_viewport_rect().size
	var paddle_y := size.y - PADDLE_MARGIN

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		_pointer_x = -1.0
		_paddle_x += direction * PADDLE_SPEED * delta
	elif _pointer_x >= 0.0:
		_paddle_x = move_toward(_paddle_x, _pointer_x, PADDLE_SPEED * 2.0 * delta)
	_paddle_x = clampf(_paddle_x, PADDLE_SIZE.x / 2.0, size.x - PADDLE_SIZE.x / 2.0)

	if _lives > 0:
		_spawn_in -= delta
		if _spawn_in <= 0.0:
			_spawn_in = maxf(0.3, 0.9 - _score * 0.01)
			_stars.append({
				"position": Vector2(randf_range(STAR_RADIUS, size.x - STAR_RADIUS), -STAR_RADIUS),
				"speed": randf_range(240.0, 380.0) + _score * 4.0,
				"spin": randf_range(-3.0, 3.0),
				"angle": 0.0,
			})

	for index in range(_stars.size() - 1, -1, -1):
		var star := _stars[index]
		star.position.y += star.speed * delta
		star.angle += star.spin * delta
		var caught: bool = (
			absf(star.position.x - _paddle_x) < PADDLE_SIZE.x / 2.0 + STAR_RADIUS * 0.5
			and absf(star.position.y - paddle_y) < PADDLE_SIZE.y / 2.0 + STAR_RADIUS * 0.6
		)
		if caught:
			_score += 1
			_best = maxi(_best, _score)
			_stars.remove_at(index)
		elif star.position.y > size.y + STAR_RADIUS:
			_lives = maxi(_lives - 1, 0)
			_stars.remove_at(index)

	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_pointer_x = event.position.x
	elif event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_pointer_x = event.position.x
			if _lives == 0:
				_restart()
	elif event.is_action_pressed("ui_accept") and _lives == 0:
		_restart()


func _restart() -> void:
	_stars.clear()
	_score = 0
	_lives = LIVES
	_spawn_in = 0.5


func _draw() -> void:
	var size := get_viewport_rect().size
	var paddle_y := size.y - PADDLE_MARGIN
	var font := ThemeDB.fallback_font

	draw_rect(Rect2(Vector2.ZERO, size), SKY)
	draw_rect(Rect2(0.0, size.y - 30.0, size.x, 30.0), GROUND)

	for star in _stars:
		draw_colored_polygon(_star_points(star.position, star.angle), STAR)

	draw_rect(Rect2(Vector2(_paddle_x, paddle_y) - PADDLE_SIZE / 2.0, PADDLE_SIZE), PADDLE)

	draw_string(font, Vector2(28.0, 54.0), "Stars %d" % _score, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 36, INK)
	draw_string(font, Vector2(0.0, 54.0), "Lives %d   " % _lives, HORIZONTAL_ALIGNMENT_RIGHT, size.x, 36, INK)

	if _lives == 0:
		draw_string(font, Vector2(0.0, size.y / 2.0 - 20.0), "Out of lives", HORIZONTAL_ALIGNMENT_CENTER, size.x, 64, INK)
		draw_string(
			font, Vector2(0.0, size.y / 2.0 + 40.0),
			"Best %d. Tap or press Enter to play again." % _best,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 28, STAR
		)


func _star_points(center: Vector2, angle: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in 10:
		var radius := STAR_RADIUS if index % 2 == 0 else STAR_RADIUS * 0.45
		points.append(center + Vector2.UP.rotated(angle + index * PI / 5.0) * radius)
	return points
