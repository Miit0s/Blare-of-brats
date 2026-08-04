extends Node

var joueurs_actifs = {} # Dictionnaire des joueureuses
var mon_fichier: FileAccess
var numero_du_round: int = 1 
var temps_debut_round: float = 0.0
var chemin_fichier: String = ""
var game_timer: Timer # Déclaration de la variable
var item_actuel = {}
var health : float = 0.5
var sound_volume : float = 0.0
var scene = ""

func _ready() -> void:
	# On crée le Timer
	game_timer = Timer.new()
	add_child(game_timer)
	
	game_timer.wait_time = 0.2 # Capture toutes les 0.2s
	game_timer.one_shot = false
	game_timer.timeout.connect(_recolter_donnees)



func get_scene(scene_played):
	scene = str(scene_played).split(":")[0]
	print(scene)	
	
func enregistrer_joueur(id_joueur, noeud_joueur):
	joueurs_actifs[id_joueur] = noeud_joueur
	print("je suis joueur actif : ", joueurs_actifs, joueurs_actifs[0])
	# Pas de lancement automatique du timer  car c'est la GameScene qui pilote au début de game

func objet_utiliser(player_id, item_type) :
	item_actuel[player_id] = item_type

func get_health(health_global):
	health = health_global
	
	
func get_sound_bar_value(sound_volume_global):
	sound_volume = sound_volume_global
	
	

func preparer_fichier(num_round: int):
	var dossier = "user://Datas/"
	
	if not DirAccess.dir_exists_absolute(dossier):
		DirAccess.make_dir_absolute(dossier)
	
	# On calcule la date et l'heure une seule fois au début du round
	var horodatage = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var nom_fichier = "%s_round%d.csv" % [horodatage, num_round]
	
	chemin_fichier = dossier + nom_fichier
	
	# creation fichier + en-tete
	mon_fichier = FileAccess.open(chemin_fichier, FileAccess.WRITE)
	if mon_fichier:
		mon_fichier.store_line("temps,p1_x,p1_y,p1_health, p1_item, p2_x, p2_y,p2_health, p2_item, sound_bar_value, map = %s" % scene)
		mon_fichier.close() # On ferme pour libérer le fichier
		print("Fichier initialisé avec succès : ", chemin_fichier)



func _recolter_donnees():
	if not joueurs_actifs.has(0) or not joueurs_actifs.has(1):
		return
	#on fait ce calcul car sinon y a de l'imprecision dans les valeurs de temps
	var temps_actuel = Time.get_ticks_msec()
	var temps_ecoule = (temps_actuel - temps_debut_round) / 1000.0
	
	var j1 = joueurs_actifs[0]
	var j2 = joueurs_actifs[1]
	
	var j1_x = j1.global_position.x
	var j1_y = j1.global_position.y
	
	var j2_x = j2.global_position.x
	var j2_y = j2.global_position.y
	
	var j1_item = str(item_actuel[0]).split(":")[0]
	var j2_item = str(item_actuel[1]).split(":")[0]
	
	var j1_health = health
	var j2_health = 1 - health
	var sound = sound_volume
	var ligne = " %f, %f, %f, %f, %s, %f, %f, %f, %s, %f " % [temps_ecoule, j1_x, j1_y, j1_health, j1_item, j2_x, j2_y, j2_health, j2_item, sound]
	
	mon_fichier = FileAccess.open(chemin_fichier, FileAccess.READ_WRITE)
	if mon_fichier:
		mon_fichier.seek_end() # On va tout à la fin pour ne rien écraser
		mon_fichier.store_line(ligne) 
		mon_fichier.close()
		print(ligne)
		
