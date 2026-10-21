class_name SpiderWeb
extends Node2D

# A sticky web with a cartoon spider waiting above it (Sky Climb level 2+).
# Anything that touches the web gets stuck; the spider then crawls down to it.
# The game drives the rules; this node only holds state and draws itself.

const RADIUS := 95.0
const SPIDER_SPEED := 85.0
const HOME := Vector2(0.0, -RADIUS - 46.0)

var victim: Node = null        # Jelly (the Block) or a bot Node2D
var spider_pos := HOME          # local position of the spider
var struggle := 0               # taps Jelly has made trying to escape
var _phase := randf_range(0.0, TAU)


func _process(delta: float) -> void:
	_phase += delta
	if victim == null and spider_pos != HOME:
		spider_pos = spider_pos.move_toward(HOME, SPIDER_SPEED * 1.5 * delta)
	queue_redraw()


func crawl_toward(local_target: Vector2, delta: float) -> bool:
	# Returns true once the spider reaches the target.
	spider_pos = spider_pos.move_toward(local_target, SPIDER_SPEED * delta)
	return spider_pos.distance_to(local_target) < 18.0


func _draw() -> void:
	var silk := Color(1.0, 1.0, 1.0, 0.85)
	var shade := Color(0.25, 0.3, 0.5, 0.35)  # soft outline so webs read on pale skies
	var spokes := 8
	# Radial spokes.
	for i in range(spokes):
		var angle := TAU * float(i) / float(spokes)
		draw_line(Vector2.ZERO, Vector2.from_angle(angle) * RADIUS, shade, 5.0, true)
		draw_line(Vector2.ZERO, Vector2.from_angle(angle) * RADIUS, silk, 3.0, true)
	# Rings, slightly sagging between spokes.
	for ring in range(1, 5):
		var r := RADIUS * float(ring) / 4.0
		var points := PackedVector2Array()
		for i in range(spokes + 1):
			var a := TAU * float(i) / float(spokes)
			points.append(Vector2.from_angle(a) * r)
			if i < spokes:
				var mid := a + TAU / float(spokes) * 0.5
				points.append(Vector2.from_angle(mid) * r * 0.9)
		draw_polyline(points, shade, 4.5, true)
		draw_polyline(points, silk, 2.5, true)
	# Thread the spider hangs from.
	var bob := sin(_phase * 2.2) * (5.0 if victim == null else 0.0)
	var body := spider_pos + Vector2(0.0, bob)
	draw_line(Vector2(0.0, -RADIUS - 120.0), body, Color(1.0, 1.0, 1.0, 0.6), 2.0, true)
	_draw_spider(body)


func _draw_spider(at: Vector2) -> void:
	var shell := Color("4a2e6b")
	var leg := Color("2f1d47")
	var wiggle := sin(_phase * 9.0) * 4.0
	for side in [-1.0, 1.0]:
		for i in range(4):
			var base := at + Vector2(side * 10.0, -6.0 + float(i) * 6.0)
			var knee := base + Vector2(side * 22.0, -14.0 + float(i) * 6.0 + (wiggle if i % 2 == 0 else -wiggle))
			var foot := knee + Vector2(side * 12.0, 18.0)
			draw_polyline(PackedVector2Array([base, knee, foot]), leg, 4.0, true)
	draw_circle(at + Vector2(0.0, 8.0), 20.0, shell)
	draw_circle(at + Vector2(0.0, -12.0), 14.0, shell)
	# Big friendly eyes.
	for side in [-1.0, 1.0]:
		var eye: Vector2 = at + Vector2(side * 6.0, -14.0)
		draw_circle(eye, 5.5, Color.WHITE)
		draw_circle(eye + Vector2(0.0, 1.5), 2.6, Color("1b1030"))
	draw_circle(at + Vector2(-8.0, 6.0), 4.0, Color(1.0, 0.6, 0.8, 0.5))
	draw_circle(at + Vector2(8.0, 6.0), 4.0, Color(1.0, 0.6, 0.8, 0.5))
