extends Node

var joueurs_actifs = {} # Dictionnaire des joueureuses
var mon_fichier: FileAccess
var numero_du_round: int = 1 
var temps_debut_round: float = 0.0
var chemin_fichier_actuel: String = ""
var game_timer: Timer # Déclaration de la variable

# =========================================================================
# 1. INITIALISATION DU TIMER (Dès que le manager apparaît en jeu)
# =========================================================================
func _ready() -> void:
	# On crée PHYSIQUEMENT le Timer dans la mémoire du PC
	game_timer = Timer.new()
	add_child(game_timer)
	
	game_timer.wait_time = 0.1 # Capture toutes les 0.1s
	game_timer.one_shot = false
	game_timer.timeout.connect(_recolter_donnees)
	print("Moteur de télémétrie initialisé et prêt.")

func enregistrer_joueur(id_du_joueur, noeud_du_joueur):
	joueurs_actifs[id_du_joueur] = noeud_du_joueur
	print("Le joueur ", id_du_joueur, " est bien enregistré dans la télémétrie !")
	# On a retiré le lancement automatique du timer ici, 
	# car c'est désormais le Match Manager (GameScene) qui pilote au moment du "GO!"

# =========================================================================
# 2. PRÉPARATION DU FICHIER DE ROUND (Appelé par le Match Manager)
# =========================================================================
func preparer_fichier(num_round: int):
	var dossier = "user://Datas/"
	
	if not DirAccess.dir_exists_absolute(dossier):
		DirAccess.make_dir_absolute(dossier)
		
	# On calcule la date et l'heure une seule fois au début du round
	var horodatage = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var nom_fichier = "%s_round%d.csv" % [horodatage, num_round]
	
	chemin_fichier_actuel = dossier + nom_fichier
	
	# On crée le fichier et on écrit l'en-tête (5 colonnes avec le temps)
	mon_fichier = FileAccess.open(chemin_fichier_actuel, FileAccess.WRITE)
	if mon_fichier:
		mon_fichier.store_line("temps,p1_x,p1_y,p2_x,p2_y")
		mon_fichier.close() # On ferme pour libérer le fichier
		print("Fichier initialisé avec succès : ", chemin_fichier_actuel)

# =========================================================================
# 3. RÉCOLTE DES DONNÉES (S'exécute 10 fois par seconde via le Timer)
# =========================================================================
func _recolter_donnees():
	if not joueurs_actifs.has(0) or not joueurs_actifs.has(1):
		return
		
	# CALCUL DU TEMPS ÉCOULÉ (Ta demande n°3 !)
	var temps_actuel = Time.get_ticks_msec()
	var temps_ecoule = (temps_actuel - temps_debut_round) / 1000.0
	
	var j1 = joueurs_actifs[0]
	var j2 = joueurs_actifs[1]
	
	var j1_x = j1.global_position.x
	var j1_y = j1.global_position.y
	var j2_x = j2.global_position.x
	var j2_y = j2.global_position.y
	
	# On assemble la ligne en mettant le temps écoulé en PREMIÈRE colonne
	var ligne = "%f,%f,%f,%f,%f" % [temps_ecoule, j1_x, j1_y, j2_x, j2_y]
	
	# RE-OUVERTURE DU FICHIER EN MODE SÉCURISÉ
	mon_fichier = FileAccess.open(chemin_fichier_actuel, FileAccess.READ_WRITE)
	if mon_fichier:
		mon_fichier.seek_end() # On va tout à la fin pour ne rien écraser
		mon_fichier.store_line(ligne) # On écrit les coordonnées et le temps
		mon_fichier.close() # On referme proprement immédiatement
		print("Données sauvegardées : ", ligne)
