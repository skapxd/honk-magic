class_name DollarRecognizer
extends RefCounted

# =============================================================================
# HONK MAGIC - Dollar Recognizer ($1 Gesture Recognizer)
# =============================================================================
# Implementacion del algoritmo $1 para reconocimiento de gestos/runas.
# Basado en: https://depts.washington.edu/acelab/proj/dollar/index.html

const NumPoints = 64
const SquareSize = 250.0
const Origin = Vector2(0, 0)
const Diagonal = 353.55  # sqrt(250*250 + 250*250)
const HalfDiagonal = 0.5 * Diagonal
const AngleRange = deg_to_rad(45.0)
const AnglePrecision = deg_to_rad(2.0)
const Phi = 0.5 * (-1.0 + sqrt(5.0))  # Golden Ratio


class Unistroke:
	var Name: String
	var Points: Array[Vector2]
	var Vector: Array[float]

	func _init(name: String, points: Array[Vector2]):
		self.Name = name
		self.Points = DollarRecognizer.resample(points, DollarRecognizer.NumPoints)
		var radians = DollarRecognizer.indicative_angle(self.Points)
		self.Points = DollarRecognizer.rotate_by(self.Points, -radians)
		self.Points = DollarRecognizer.scale_to(self.Points, DollarRecognizer.SquareSize)
		self.Points = DollarRecognizer.translate_to(self.Points, DollarRecognizer.Origin)
		self.Vector = DollarRecognizer.vectorize(self.Points)


class Result:
	var Name: String
	var Score: float
	var Ms: int

	func _init(name: String, score: float, ms: int):
		self.Name = name
		self.Score = score
		self.Ms = ms


var Unistrokes: Array[Unistroke] = []


func _init():
	_load_rune_gestures()


func _load_rune_gestures() -> void:
	# Runas elementales para Honk Magic
	# Triangulo hacia arriba = Fuego
	add_gesture("fuego", [Vector2(79,245),Vector2(79,242),Vector2(79,239),Vector2(80,237),Vector2(80,234),Vector2(81,232),Vector2(82,230),Vector2(84,224),Vector2(86,220),Vector2(86,218),Vector2(87,216),Vector2(88,213),Vector2(90,207),Vector2(91,202),Vector2(92,200),Vector2(93,194),Vector2(94,192),Vector2(96,189),Vector2(97,186),Vector2(100,179),Vector2(102,173),Vector2(105,165),Vector2(107,160),Vector2(109,158),Vector2(112,151),Vector2(115,144),Vector2(117,139),Vector2(119,136),Vector2(119,134),Vector2(120,132),Vector2(121,129),Vector2(122,127),Vector2(124,125),Vector2(126,124),Vector2(129,125),Vector2(131,127),Vector2(132,130),Vector2(136,139),Vector2(141,154),Vector2(145,166),Vector2(151,182),Vector2(156,193),Vector2(157,196),Vector2(161,209),Vector2(162,211),Vector2(167,223),Vector2(169,229),Vector2(170,231),Vector2(173,237),Vector2(176,242),Vector2(177,244),Vector2(179,250),Vector2(181,255),Vector2(182,257)])

	# S curva = Agua
	add_gesture("agua", [Vector2(180,80),Vector2(160,70),Vector2(140,65),Vector2(120,70),Vector2(100,80),Vector2(85,100),Vector2(90,125),Vector2(110,145),Vector2(135,160),Vector2(160,175),Vector2(180,195),Vector2(185,220),Vector2(170,240),Vector2(145,250),Vector2(120,250),Vector2(95,240),Vector2(80,220)])

	# Espiral abierta = Viento
	add_gesture("viento", [Vector2(195,215),Vector2(175,225),Vector2(155,230),Vector2(135,230),Vector2(115,225),Vector2(95,215),Vector2(80,200),Vector2(70,180),Vector2(70,150),Vector2(70,120),Vector2(80,100),Vector2(95,85),Vector2(115,75),Vector2(135,75),Vector2(155,80),Vector2(175,90),Vector2(195,105)])

	# Cuadrado/Rectangulo = Tierra
	add_gesture("tierra", [Vector2(80,80),Vector2(80,120),Vector2(80,160),Vector2(80,200),Vector2(80,220),Vector2(120,220),Vector2(160,220),Vector2(200,220),Vector2(220,220),Vector2(220,200),Vector2(220,160),Vector2(220,120),Vector2(220,80)])

	# Cruz con circulo = Luz
	add_gesture("luz", [Vector2(18.45856,-115.8),Vector2(18.45856,-105.893),Vector2(18.45856,-95.9862),Vector2(18.45856,-86.0794),Vector2(18.45856,-76.1725),Vector2(18.45856,-66.2656),Vector2(18.45856,-56.3588),Vector2(18.7202,-46.4677),Vector2(18.75543,-36.5615),Vector2(18.75543,-26.6546),Vector2(18.75543,-16.7477),Vector2(18.75543,-6.84085),Vector2(18.75543,3.06601),Vector2(19.12052,12.9539),Vector2(19.77496,22.8282),Vector2(20.05621,32.7135),Vector2(20.05621,42.6204),Vector2(20.05621,52.5272),Vector2(20.05621,62.4341),Vector2(20.26102,72.3298),Vector2(20.53505,82.2261),Vector2(20.73199,92.1233),Vector2(21.19684,101.976),Vector2(18.37039,97.6604),Vector2(13.46811,89.0683),Vector2(8.490125,80.5126),Vector2(3.431262,72.0201),Vector2(-1.031283,63.1815),Vector2(-6.879946,55.2323),Vector2(-13.2047,47.6079),Vector2(-19.8926,40.3266),Vector2(-27.27312,33.7476),Vector2(-34.63255,27.1212),Vector2(-42.518,21.128),Vector2(-50.8035,15.7192),Vector2(-59.08194,10.28),Vector2(-67.17523,4.56808),Vector2(-75.30846,-1.0869),Vector2(-83.24666,-6.98174),Vector2(-91.62888,-12.1738),Vector2(-100.391,-16.7914),Vector2(-99.71428,-18.468),Vector2(-90.17663,-16.175),Vector2(-80.35713,-14.9144),Vector2(-70.51252,-13.8264),Vector2(-60.63532,-13.1281),Vector2(-50.72845,-13.1281),Vector2(-40.82158,-13.1281),Vector2(-30.91471,-13.1281),Vector2(-21.00785,-13.1281),Vector2(-11.10098,-13.1281),Vector2(-1.220918,-13.5293),Vector2(8.628597,-14.5554),Vector2(18.42076,-16.0244),Vector2(28.14949,-17.8498),Vector2(37.74192,-20.2987),Vector2(47.44056,-22.3163),Vector2(57.16827,-24.1913),Vector2(66.91475,-25.9663),Vector2(76.63788,-27.8581),Vector2(86.18843,-30.4873),Vector2(95.71598,-33.1939),Vector2(105.254,-35.8646),Vector2(114.6851,-38.8234)])

	# Simbolo de interrogacion invertido = Oscuridad (Captura)
	add_gesture("oscuridad", [Vector2(125,230),Vector2(120,225),Vector2(115,230),Vector2(120,235),Vector2(125,230),Vector2(125,210),Vector2(125,190),Vector2(125,170),Vector2(135,150),Vector2(150,140),Vector2(175,145),Vector2(185,165),Vector2(175,185),Vector2(155,195)])


func recognize(points: Array[Vector2], use_protractor: bool = false) -> Result:
	var t0 = Time.get_ticks_msec()

	if points.size() < 10:
		return Result.new("none", 0.0, 0)

	var candidate = Unistroke.new("", points)
	var u = -1
	var b = INF

	for i in range(Unistrokes.size()):
		var d: float
		if use_protractor:
			d = optimal_cosine_distance(Unistrokes[i].Vector, candidate.Vector)
		else:
			d = distance_at_best_angle(candidate.Points, Unistrokes[i], -AngleRange, AngleRange, AnglePrecision)

		if d < b:
			b = d
			u = i

	var t1 = Time.get_ticks_msec()

	if u == -1:
		return Result.new("none", 0.0, t1 - t0)

	var score: float
	if use_protractor:
		score = 1.0 - b
	else:
		score = 1.0 - (b / HalfDiagonal)

	return Result.new(Unistrokes[u].Name, score, t1 - t0)


func add_gesture(name: String, points: Array[Vector2]) -> int:
	Unistrokes.append(Unistroke.new(name, points))
	var num = 0
	for u in Unistrokes:
		if u.Name == name:
			num += 1
	return num


func get_rune_names() -> Array[String]:
	var names: Array[String] = []
	for u in Unistrokes:
		if not names.has(u.Name):
			names.append(u.Name)
	return names


# =============================================================================
# Funciones estaticas del algoritmo $1
# =============================================================================

static func resample(points: Array[Vector2], n: int) -> Array[Vector2]:
	var I = path_length(points) / (n - 1)
	var D = 0.0
	var newpoints: Array[Vector2] = [points[0]]
	var src_pts = points.duplicate()
	var i = 1

	while i < src_pts.size():
		var d = src_pts[i - 1].distance_to(src_pts[i])
		if (D + d) >= I:
			var qx = src_pts[i - 1].x + ((I - D) / d) * (src_pts[i].x - src_pts[i - 1].x)
			var qy = src_pts[i - 1].y + ((I - D) / d) * (src_pts[i].y - src_pts[i - 1].y)
			var q = Vector2(qx, qy)
			newpoints.append(q)
			src_pts.insert(i, q)
			D = 0.0
		else:
			D += d
		i += 1

	if newpoints.size() == n - 1:
		newpoints.append(src_pts.back())

	return newpoints


static func indicative_angle(points: Array[Vector2]) -> float:
	var c = centroid(points)
	return atan2(c.y - points[0].y, c.x - points[0].x)


static func rotate_by(points: Array[Vector2], radians: float) -> Array[Vector2]:
	var c = centroid(points)
	var cos_val = cos(radians)
	var sin_val = sin(radians)
	var newpoints: Array[Vector2] = []
	for p in points:
		var qx = (p.x - c.x) * cos_val - (p.y - c.y) * sin_val + c.x
		var qy = (p.x - c.x) * sin_val + (p.y - c.y) * cos_val + c.y
		newpoints.append(Vector2(qx, qy))
	return newpoints


static func scale_to(points: Array[Vector2], size: float) -> Array[Vector2]:
	var B = bounding_box(points)
	var newpoints: Array[Vector2] = []
	for p in points:
		var qx = p.x * (size / B.size.x) if B.size.x > 0 else p.x
		var qy = p.y * (size / B.size.y) if B.size.y > 0 else p.y
		newpoints.append(Vector2(qx, qy))
	return newpoints


static func translate_to(points: Array[Vector2], pt: Vector2) -> Array[Vector2]:
	var c = centroid(points)
	var newpoints: Array[Vector2] = []
	for p in points:
		var qx = p.x + pt.x - c.x
		var qy = p.y + pt.y - c.y
		newpoints.append(Vector2(qx, qy))
	return newpoints


static func vectorize(points: Array[Vector2]) -> Array[float]:
	var sum = 0.0
	var vector: Array[float] = []
	for p in points:
		vector.append(p.x)
		vector.append(p.y)
		sum += p.x * p.x + p.y * p.y
	var magnitude = sqrt(sum)
	if magnitude > 0:
		for i in range(vector.size()):
			vector[i] /= magnitude
	return vector


static func optimal_cosine_distance(v1: Array[float], v2: Array[float]) -> float:
	var a = 0.0
	var b = 0.0
	var i = 0
	while i < v1.size():
		a += v1[i] * v2[i] + v1[i + 1] * v2[i + 1]
		b += v1[i] * v2[i + 1] - v1[i + 1] * v2[i]
		i += 2
	var angle = atan(b / a) if a != 0 else 0
	return acos(clampf(a * cos(angle) + b * sin(angle), -1.0, 1.0))


static func distance_at_best_angle(points: Array[Vector2], T: Unistroke, a: float, b: float, threshold: float) -> float:
	var x1 = Phi * a + (1.0 - Phi) * b
	var f1 = distance_at_angle(points, T, x1)
	var x2 = (1.0 - Phi) * a + Phi * b
	var f2 = distance_at_angle(points, T, x2)

	while abs(b - a) > threshold:
		if f1 < f2:
			b = x2
			x2 = x1
			f2 = f1
			x1 = Phi * a + (1.0 - Phi) * b
			f1 = distance_at_angle(points, T, x1)
		else:
			a = x1
			x1 = x2
			f1 = f2
			x2 = (1.0 - Phi) * a + Phi * b
			f2 = distance_at_angle(points, T, x2)

	return min(f1, f2)


static func distance_at_angle(points: Array[Vector2], T: Unistroke, radians: float) -> float:
	var newpoints = rotate_by(points, radians)
	return path_distance(newpoints, T.Points)


static func centroid(points: Array[Vector2]) -> Vector2:
	var x = 0.0
	var y = 0.0
	for p in points:
		x += p.x
		y += p.y
	return Vector2(x / points.size(), y / points.size())


static func bounding_box(points: Array[Vector2]) -> Rect2:
	var minX = INF
	var maxX = -INF
	var minY = INF
	var maxY = -INF
	for p in points:
		minX = min(minX, p.x)
		minY = min(minY, p.y)
		maxX = max(maxX, p.x)
		maxY = max(maxY, p.y)
	return Rect2(minX, minY, maxX - minX, maxY - minY)


static func path_distance(pts1: Array[Vector2], pts2: Array[Vector2]) -> float:
	var d = 0.0
	for i in range(pts1.size()):
		d += pts1[i].distance_to(pts2[i])
	return d / pts1.size()


static func path_length(points: Array[Vector2]) -> float:
	var d = 0.0
	for i in range(1, points.size()):
		d += points[i - 1].distance_to(points[i])
	return d
