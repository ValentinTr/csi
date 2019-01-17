drop table if exists Categorie CASCADE;
drop table if exists compte    CASCADE;
drop table if exists filiere   CASCADE;
drop table if exists promotion CASCADE;
drop table if exists roles CASCADE;
drop table if exists commentaire CASCADE;
drop table if exists utilisateur   CASCADE;
drop table if exists notification  CASCADE;
drop table if exists annonce   CASCADE;
drop table if exists repondre  CASCADE;
drop table if exists archive_annonce   CASCADE;
drop table if exists archive_repondre  CASCADE;

drop type if exists lib;
drop type if exists promo;
drop type if exists enum_role;
drop type if exists repet;
drop type if exists etat;
drop type if exists statut;


-- creation des types enum
CREATE TYPE lib AS ENUM ('MIAGE', 'SC', 'TAL', 'MIASHS');
CREATE TYPE promo AS ENUM ('L1', 'L2', 'L3', 'M1', 'M2');
CREATE TYPE enum_role AS ENUM('Utilisateur' , 'Administrateur');
CREATE TYPE repet AS ENUM('Aucune' , 'Jour' , 'Semaine' , 'Mois');
CREATE TYPE etat AS ENUM('Annulée' , 'Terminée' , 'En cours');
CREATE TYPE statut AS ENUM('non traitée' , 'en attente' , 'acceptée' , 'refusée');


-- creation des tables
CREATE TABLE Categorie
(
    CAT_id SERIAL NOT NULL PRIMARY KEY,
    CAT_libelle VARCHAR(30)
);

CREATE TABLE Compte
(
    CPT_id SERIAL NOT NULL PRIMARY KEY NOT NULL,
    CPT_login VARCHAR(20) NOT NULL,
    CPT_motdepasse TEXT NOT NULL,
    api_token TEXT
);

CREATE TABLE Filiere
(
    FIL_id SERIAL NOT NULL PRIMARY KEY NOT NULL,
    FIL_libelle lib NOT NULL
);

CREATE TABLE Promotion
(
    PRO_id SERIAL NOT NULL PRIMARY KEY NOT NULL,
    PRO_libelle promo NOT NULL
);

CREATE TABLE roles(
    rol_id SERIAL NOT NULL PRIMARY KEY,
    rol_libelle enum_role
);

CREATE TABLE Utilisateur
(
    UTIL_id SERIAL NOT NULL PRIMARY KEY NOT NULL,
    UTIL_nom VARCHAR(40) NOT NULL,
    UTIL_prenom VARCHAR(30) NOT NULL,
    UTIL_mail VARCHAR(60) NOT NULL,
    UTIL_CPT_id integer,
    UTIL_ROL_id integer,
    UTIL_FIL_id integer,
    UTIL_PRO_id integer,
    CONSTRAINT CPTid FOREIGN KEY (UTIL_CPT_id) REFERENCES Compte(CPT_id),
    CONSTRAINT FILid FOREIGN KEY (UTIL_FIL_id) REFERENCES Filiere(FIL_id),
    CONSTRAINT PROid FOREIGN KEY (UTIL_PRO_id) REFERENCES Promotion(PRO_id),
    CONSTRAINT ROLid FOREIGN KEY (UTIL_ROL_id) REFERENCES roles(rol_id)
);

CREATE TABLE Notification
(
    NOT_id SERIAL NOT NULL,
    NOT_titre VARCHAR(140),
    NOT_message VARCHAR(450),
    NOT_UTIL_id integer,
    CONSTRAINT NOTpkey PRIMARY KEY(NOT_id),
    CONSTRAINT NOTUTILid FOREIGN KEY (NOT_UTIL_id) REFERENCES Utilisateur(UTIL_id)
);

CREATE TABLE Annonce
(
    ANN_id SERIAL NOT NULL PRIMARY KEY,
    ANN_titre TEXT,
    ANN_description TEXT,
    ANN_dateDebut Timestamp NOT NULL,
    ANN_dateFIn Timestamp NOT NULL,
    ANN_dateLimiteReponse Timestamp NOT NULL,
    ANN_nbrMaxPersonnes integer,
    ANN_nbrPlacesDisponibles integer,
    ANN_visiblePublic boolean NOT NULL,
    ANN_repetition repet NOT NULL,
    ANN_etat etat NOT NULL,
    ANN_UTIL_id integer,
    ANN_CAT_id integer,
    ANN_PRO_id integer,
    CONSTRAINT ANNUTIL_id FOREIGN KEY (ANN_UTIL_id) REFERENCES Utilisateur(UTIL_id),
    CONSTRAINT ANNCAT_id FOREIGN KEY (ANN_CAT_id) REFERENCES Categorie(CAT_id),
    CONSTRAINT ANNPRO_id FOREIGN KEY (ANN_PRO_id) REFERENCES Promotion(PRO_id)
);

CREATE TABLE Commentaire
(
    COM_id SERIAL NOT NULL PRIMARY KEY,
    COM_ANN_id integer,
    COM_util_id integer,
    COM_date date,
    COM_message TEXT NOT NULL,
    CONSTRAINT ANNid FOREIGN KEY (COM_ANN_id) REFERENCES Annonce(ANN_id),
    CONSTRAINT Utilid FOREIGN KEY (COM_util_id) REFERENCES Utilisateur(util_id)
);

CREATE TABLE Repondre
(
    REP_ANN_id integer,
    REP_UTIL_id integer,
    REP_date timestamp NOT NULL,
    REP_statut statut NOT NULL,
    REP_message text NOT NULL,
    REP_alerte boolean NOT NULL
);

CREATE TABLE Archive_annonce
(
    IDarchive SERIAL PRIMARY KEY NOT NULL,
    idAnnonce int not null,
    idPropriétaire int not null,
    description text,
    dateDebut date not null,
    dateFin date not null,
    nbrMaxPersonne int not null,
    nbrPlacesDisponibles int not null
);

CREATE TABLE Archive_Repondre
(
    IDarchive SERIAL PRIMARY KEY NOT NULL,
    idAnnonce int not null,
    idUtilisateur int not null,
    message text,
    dateReponse date
);


-- Insertion d'un jeu de donnée

Insert Into filiere (fil_libelle) Values 
('MIAGE'), 
('SC'), 
('TAL'), 
('MIASHS');

Insert Into promotion(PRO_libelle) Values
('L1'),
('L2'),
('L3'),
('M1'),
('M2');

Insert Into categorie(cat_libelle) Values
('Sport'),
('Evenement'),
('Culture'),
('Discussion');

Insert into roles(rol_libelle) Values
('Administrateur'),
('Utilisateur');

Insert into compte(cpt_login,cpt_motdepasse) Values
('azerty0','aze123'),
('vtrombini','trombibi'),
('alyonnet','ouialavie'),
('llegrand','biker');

Insert into utilisateur(util_nom,util_prenom,util_mail,util_cpt_id,util_rol_id,util_fil_id,util_pro_id) Values
('Quiche','Jean','Jean-Quiche@gmail.com',1,2,2,3),
('Trombini','Valentin','val54200@gmail.com',2,2,1,4),
('Lyonnet','Antoine','kaaris@gmail.com',3,2,1,5);

Insert into annonce(ann_titre, ann_description,ann_dateDebut,ann_dateFin,ann_datelimitereponse,ann_nbrmaxpersonnes,ann_nbrplacesdisponibles,ann_visiblepublic,ann_repetition, ann_etat,ann_util_id,ann_cat_id,ann_pro_id) Values
('Lan de tetris','Ont va tous jouer à tetris','18-01-2019','24-01-2019','22-01-2019',4,0,true,'Mois','En cours',1,2,4),
('Randonnée','Allons dans les vosges cool ! ','16-01-2019','24-01-2019','23-01-2019',8,0,true,'Mois','En cours',3,1,4);

Insert into repondre(rep_ann_id,rep_util_id,rep_date, REP_statut, REP_message,REP_alerte )   Values 
    (1,4,now(),'non traitée','Je suis passionné de tetris !',true),
    (2,2,now(),'non traitée','Trop content, ouais les vosges',true);

-- creation des fonctions

-- FUNCTION: public.acceptation_reponse(integer, integer)

-- DROP FUNCTION public.acceptation_reponse(integer, integer);

CREATE OR REPLACE FUNCTION public.acceptation_reponse(
	v_user integer,
	v_annonce integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

DECLARE
	v_reponseRecord RECORD;
    v_annonceRecord RECORD;
	v_idUser integer;
	v_idAnnonce integer;
BEGIN

	-- test si le destinataire du message existe
	v_idUser := (SELECT util_id FROM utilisateur WHERE utilisateur.util_id = v_user);
    
    -- Si l'annonce existe
	v_idAnnonce := (Select ann_id from annonce where annonce.ann_id = v_annonce);
   	 
    IF (v_idUser IS NULL) OR (v_idAnnonce IS NULL) THEN
   	 return -1;
    END IF;
    
    -- On récupère la réponse
	SELECT INTO v_reponseRecord * FROM repondre WHERE rep_ann_id = v_annonce AND rep_util_id = v_user;
    
    IF v_reponseRecord.rep_ann_id IS NULL THEN
   	 return -2;
    END IF;
    
	-- On récupère l'annonce associée
    SELECT INTO v_annonceRecord * FROM annonce WHERE ann_id = v_annonce;
   	 
    IF v_annonceRecord.ann_nbrplacesdisponibles > 0 THEN
   	 UPDATE annonce ann SET ann_nbrplacesdisponibles = v_annonceRecord.ann_nbrplacesdisponibles - 1 WHERE ann.ann_id = v_annonceRecord.ann_id;
   	 UPDATE repondre rep SET rep_statut = 'acceptée' WHERE rep_ann_id = v_annonce AND rep_util_id = v_user;
    ELSE
   	 UPDATE repondre rep SET rep_statut = 'en attente' WHERE rep_ann_id = v_annonce AND rep_util_id = v_user;
    END IF;
    
    RETURN 0;
    
    END;

$BODY$;

ALTER FUNCTION public.acceptation_reponse(integer, integer)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.notifier_tout_inscrit(ann_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	inscrits record;
	v_titre text;
	v_contenu text;
    BEGIN
		FOR inscrits IN (Select * from repondre where repondre.rep_ann_id= ann_id)
	LOOP
		v_titre := 'Suppression de l’annonce ' || ANN_id ;
		v_contenu := ' L’annonce à été supprimé par le propriétaire ' ;
	
		INSERT INTO notification(not_id,not_titre,not_message)
		VALUES(inscrits.rep_util_id,v_titre,v_contenu);
		
		
		
		
	END LOOP;
	
	DELETE FROM repondre
	WHERE repondre.rep_ann_id = ann_id;
	
	DELETE FROM annonce
	WHERE annonce.ann_id = ann_id;
	
	DELETE FROM commentaire
	WHERE commentaire.com_ann_id = ann_id;
        	
    END;


$BODY$;

ALTER FUNCTION public.notifier_tout_inscrit(integer)
    OWNER TO postgres;



-- FUNCTION: public.bannir_personne(integer, integer)

-- DROP FUNCTION public.bannir_personne(integer, integer);

CREATE OR REPLACE FUNCTION public.bannir_personne(
	v_idproprio integer,
	v_idcible integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
		v_titre text;
		v_contenu text;
        inscription record;	
    BEGIN
        FOR inscription IN (Select * from repondre,annonce where repondre.rep_ann_id = annonce.ann_id 
							and annonce.ann_util_id = v_idproprio
							and repondre.rep_util_id = v_idcible)
		LOOP
			v_titre := 'Votre inscription est annulée';
			v_contenu := 'Vous avez été banni par le propriétaire de l''annonce : ' || inscription.ann_titre ;
			INSERT INTO notification(not_titre,not_message,not_util_id)
			VALUES(v_titre,v_contenu,v_idcible);
			DELETE FROM repondre
			Where rep_ann_id = inscription.ann_id
			And rep_util_id = v_idcible;
		END LOOP;
	Insert Into bannir(ban_util_id,ban_util_idbanni) values (v_idproprio,v_idcible);
    END;

$BODY$;

ALTER FUNCTION public.bannir_personne(integer, integer)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.create_commentaire(libelle character, userCom integer, annonceCom integer) RETURNS integer LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
	DECLARE
    	v_idUser integer;
   	 v_idAnnonce integer;
   	 v_participation integer;
   	 v_testCommentaire integer;
   	 v_idCom integer;
	BEGIN
   	 
    	-- test si le créateur du commentaire existe
    	v_idUser := (SELECT util_id FROM utilisateur WHERE utilisateur.util_id = annonceCom);

   	 -- test si l'annonce du commentaire existe
    	v_idAnnonce := (Select ann_id from annonce where annonce.ann_id = libelle);
   	 
   	 IF (v_idUser IS NULL) OR (v_idAnnonce IS NULL) THEN
   		 return -1;
   	 END IF;
   	 
   	 -- test si l'utilisateur a bien participé à l'annonce
   	 v_participation := (SELECT rep_ann_id FROM repondre WHERE rep_ann_id = annonceCom AND rep_util_id = userCom AND rep_statut = 'acceptée');
   	 
   	 IF (v_participation IS NULL) THEN
   		 return -2;
   	 END IF;
   	 
   	 -- test si l'utilisateur n'a pas encore commenté l'annonce
   	 v_testCommentaire := (SELECT com_id FROM commentaire WHERE com_ann_id = userCom AND com_util_id = annonceCom);
   	 IF (v_testCommentaire IS NULL) THEN
   		 return -3;
   	 END IF;
   	 
   	 Insert into commentaire (com_ann_id, com_util_id, com_date, com_message) values (annonceCom, userCom, clock_timestamp(), libelle);
   	 
   	 -- test si le commentaire a bien été ajouté dans la base
   	 v_idCom := (SELECT com_id FROM commentaire WHERE com_ann_id = userCom AND com_util_id = annonceCom);
   	 IF (v_idCom IS NULL) THEN
   		 return -4;
   	 END IF;
   	 
    	Return 0;
	END;

$BODY$;



CREATE OR REPLACE FUNCTION public.create_promotion(libelle character) RETURNS integer LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
	DECLARE
    	v_idProm integer;
	BEGIN
   	 
   	 IF libelle <> 'l1' AND libelle <> 'l2' AND libelle <> 'l3' AND libelle <> 'm1' AND libelle <> 'm2' THEN
   		 RETURN -1;
   	 END IF;
   	 
    	v_idProm := (Select pro_id from promotion where pro_libelle = libelle);
   	 
    	If ( v_idProm IS NULL) THEN
        	Insert into promotion (pro_libelle) values (libelle);
    	END IF;
   	 
    	v_idProm := (Select pro_id from promotion where pro_libelle = libelle);
    	Return v_idProm;
	END;

$BODY$;



CREATE OR REPLACE FUNCTION public.create_filiere(libelle character) RETURNS integer LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
	DECLARE
    	v_idfil integer;
	BEGIN
    	v_idfil := (Select fil_id from filiere where fil_libelle = libelle);
   	 
    	If ( v_idfil IS NULL) THEN
        	Insert into filiere (fil_libelle) values (libelle);
    	END IF;
   	 
    	v_idfil := (Select fil_id from filiere where fil_libelle = libelle);
    	Return v_idfil;
	END;

$BODY$;




CREATE OR REPLACE FUNCTION public.create_notif(titre character, libelle character, destinataire integer) RETURNS integer LANGUAGE 'plpgsql'
	VOLATILE
AS $BODY$
	DECLARE
    	v_idUser integer;
   	 v_idNotif integer;
	BEGIN
   	 -- test si le destinataire du message existe
   	 v_idUser := (SELECT util_id FROM utilisateur WHERE utilisateur.util_id = destinataire);
    	IF ( v_idUser IS NULL) THEN
        	RAISE EXCEPTION 'Le destinataire n''existe pas';
    	END IF;
   	 
   	 -- insertion de la notification dans la base
    	Insert into notification (not_titre, not_message, not_util_id) values (titre, libelle, destinataire);
   	 
    	v_idNotif := (Select not_id from notification where not_message = libelle);
    	Return v_idNotif;
	END;

$BODY$;


-- FUNCTION: public.connect_user(text, text)

-- DROP FUNCTION public.connect_user(text, text);

CREATE OR REPLACE FUNCTION public.connect_user(
	v_login text,
	v_motdepasse text)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
		
		v_idcpt integer;
		v_iduser integer;
    BEGIN
		v_idcpt := (Select cpt_id from compte where cpt_login = v_login and cpt_motdepasse = v_motdepasse );
		If (v_idcpt IS NULL) then
			RAISE EXCEPTION 'Mauvaise combinaison login/mot de passe' ;
		else
			v_iduser := (Select util_id from utilisateur where util_cpt_id = v_idcpt);
			If ( v_iduser IS NULL) then
				Raise Exception 'Utilisateur non existant';
			else 
				RETURN v_iduser;
			END IF;
		END IF;
		
    END;

$BODY$;

ALTER FUNCTION public.connect_user(text, text)
    OWNER TO postgres;



-- FUNCTION: public.create_user(character, character, character, character, character, integer, integer)

-- DROP FUNCTION public.create_user(character, character, character, character, character, integer, integer);

CREATE OR REPLACE FUNCTION public.create_user(
	v_login character,
	v_motdepasse character,
	v_nom character,
	v_prenom character,
	v_mail character,
	v_idpromo integer,
	v_idfiliere integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
		v_idcpt integer;
		v_iduser integer;
    BEGIN
		v_idcpt := (SELECT cpt_id FROM compte WHERE compte.cpt_login = v_login);
		IF ( v_idcpt IS NOT NULL) THEN
			RAISE EXCEPTION 'Compte déjà existant';
		END IF;
		Insert into compte (cpt_login, cpt_motdepasse) values (v_login,v_motdepasse);
		v_idcpt := (SELECT cpt_id FROM compte WHERE compte.cpt_login = v_login);
		
		Insert Into utilisateur (util_nom,util_prenom,util_mail,util_cpt_id,util_rol_id,util_fil_id,util_pro_id) values (v_nom,v_prenom,v_mail,v_idcpt,2,v_idfiliere,v_idpromo);
		v_iduser := (SELECT util_id FROM utilisateur WHERE utilisateur.util_cpt_id = v_idcpt);
		IF ( v_iduser IS NULL) THEN
			RAISE EXCEPTION 'Probleme enregistrement compte';
		END IF;
		
		
    END;

$BODY$;

ALTER FUNCTION public.create_user(character, character, character, character, character, integer, integer)
    OWNER TO postgres;






CREATE OR REPLACE FUNCTION public.create_categorie(libelle character)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
		v_idcat integer;
    BEGIN
		v_idcat := (Select cat_id from categorie where cat_libelle = libelle);
		
		If ( v_idcat IS NULL) THEN
			Insert into categorie (cat_libelle) values (libelle);
		END IF;
		
		v_idcat := (Select cat_id from categorie where cat_libelle = libelle);
		Return v_idcat;
	
	
    END;

$BODY$;












CREATE OR REPLACE FUNCTION public.create_categorie(libelle character)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
		v_idcat integer;
    BEGIN
		v_idcat := (Select cat_id from categorie where cat_libelle = libelle);
		
		If ( v_idcat IS NULL) THEN
			Insert into categorie (cat_libelle) values (libelle);
		END IF;
		
		v_idcat := (Select cat_id from categorie where cat_libelle = libelle);
		Return v_idcat;
	
	
    END;

$BODY$;




CREATE OR REPLACE FUNCTION public.fusionner_categorie(
	v_nomcategorie1 character,
	v_nomcategorie2 character,
	v_opt integer,
	v_autrenom character)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$
DECLARE

    v_idcategorie1 integer;
	v_idcategorie2 integer;
	v_idautrenom integer;
	
	-- opt = 0 => v_nomcategorie1 et v_nomcategorie2 = v_autrenom
	-- opt = 1 => v_nomcategorie2 = v_nomcategorie 1
	-- opt = 2 => v_nomcategorie1 = v_nomcategorie2---
BEGIN

	IF (v_opt = 0) THEN
		-- On verifie si il existe déjà une categorie identique à celle voulu par l'administrateur
		v_idautrenom := (SELECT categorie.cat_id from categorie where categorie.cat_libelle = v_autrenom) ;
		If (v_idautrenom IS NULL ) THEN
			Insert Into categorie(cat_libelle) Values (v_autrenom);
		END IF;
		v_idautrenom := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_autrenom);
		v_idcategorie1 := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_nomcategorie1);
		v_idcategorie2 := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_nomcategorie2);
		-- Mise à jour des categories dans les annonces et supression des catégories fusionnées
		Update annonce
		Set annonce.ann_cat_id = v_id_utrenom
		Where annonce.ann_cat_id = v_idcategorie1 or annonce.ann_cat_id = v_idcategorie2;
		
		Delete from categorie
		Where categorie.cat_id = v_idcategorie1 OR categorie.cat_id = v_idcategorie2;
		
	ELSIF (v_opt = 1)	THEN
		v_idcategorie1 := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_nomcategorie1);
		v_idcategorie2 := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_nomcategorie2);
		
 		Update annonce
		Set annonce.ann_cat_id = v_idcategorie1
		Where annonce.ann_cat_id = v_idcategorie2;
		
		Delete from categorie
		Where categorie.cat_id = v_idcategorie2;
		
   ELSE
   		v_idcategorie1 := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_nomcategorie1);
		v_idcategorie2 := (SELECT categorie.cat_id From categorie Where categorie.cat_libelle = v_nomcategorie2);
		
 		Update annonce
		Set annonce.ann_cat_id = v_idcategorie2
		Where annonce.ann_cat_id = v_idcategorie1;
		
		Delete from categorie
		Where categorie.cat_id = v_idcategorie1;
	END IF;

	END;

$BODY$;

ALTER FUNCTION public.fusionner_categorie(character, character,integer,character)
    OWNER TO postgres;


 CREATE OR REPLACE FUNCTION getDispo(idUser integer, idAnnonce integer) RETURNS integer as $$
DECLARE
    resAnnonce RECORD;
    resInscription RECORD;
    dateDeb DATE;
    dateFin DATE;
BEGIN
    SELECT INTO dateDeb ann_datedebut FROM annonce WHERE ann_id=idAnnonce;
    SELECT INTO dateFin ann_datefin FROM annonce WHERE ann_id=idAnnonce;
    
    SELECT INTO resAnnonce *
    FROM annonce ann
    WHERE ann_id!=idAnnonce AND ann_util_id=idUser AND
    (ann_datefin BETWEEN dateDeb AND dateFin OR ann_datedebut BETWEEN dateDeb AND dateFin);
    
    IF resAnnonce.ann_id IS NOT NULL THEN
   	 RETURN 1;
    END IF;
    
    SELECT INTO resInscription *
    FROM annonce, repondre
    WHERE rep_ann_id=ann_id AND rep_util_id=idUSER AND rep_ann_id=idAnnonce AND rep_statut='acceptée'
    AND (ann_datefin BETWEEN dateDeb AND dateFin OR ann_datedebut BETWEEN dateDeb AND dateFin);
    
    IF resInscription.rep_ann_id IS NOT NULL THEN
   	 RETURN 2;
    END IF;
    
    RETURN 0;
END;

$$ LANGUAGE plpgsql;

 CREATE OR REPLACE FUNCTION repeat_annonce(idAnnonce integer) RETURNS void as $$
DECLARE
	resAnnonce RECORD;
	nouvDateDebut TIMESTAMP;
	nouvDateFin TIMESTAMP;
	nouvDateLimRep TIMESTAMP;
    intervalDebutFin INTERVAL;
    intervalDebutLimiteRep INTERVAL;
    heureMinuteDebut TIME;
BEGIN
    
	SELECT INTO resAnnonce * FROM annonce ann WHERE ann_id=idAnnonce;
    
    -- calcul des intervals entre le début et la fin de l'annonce / le début et la date limite de réponse
    intervalDebutFin := resAnnonce.ann_datefin - resAnnonce.ann_datedebut;
    intervalDebutLimiteRep := resAnnonce.ann_datelimitereponse - resAnnonce.ann_datedebut;
    
    -- extraction des heures et minutes de la date de début de l'annonce pour éviter un décalage
    heureMinuteDebut := resAnnonce.ann_datedebut::timestamp::time;
    

    IF resAnnonce.ann_repetition='Jour' THEN
   	 -- on récupère la date de fin sans l'heure et la minute et on y ajoute un jour pour avoir la nouvelle date de début en mettant les heures et minute de début à 0
    	nouvDateDebut := date_trunc('day', resAnnonce.ann_datefin) + interval '1 day';
   	 -- on ajoute les heures et minutes de début de l'annonce précédente
   	 nouvDateDebut := nouvDateDebut + heureMinuteDebut;
   	 
    	nouvDateFin := nouvDateDebut + intervalDebutFin;
    	nouvDateLimRep := nouvDateDebut + intervalDebutLimiteRep;
	ELSIF resAnnonce.ann_repetition='Semaine' THEN
   	 -- on récupère la date de fin sans l'heure et la minute et on y ajoute un jour pour avoir la nouvelle date de début en mettant les heures et minute de début à 0
    	nouvDateDebut := date_trunc('day', resAnnonce.ann_datefin) + interval '1 week';
   	 -- on ajoute les heures et minutes de début de l'annonce précédente
   	 nouvDateDebut := nouvDateDebut + heureMinuteDebut;
   	 
    	nouvDateFin := nouvDateDebut + intervalDebutFin;
    	nouvDateLimRep := nouvDateDebut + intervalDebutLimiteRep;
   	 
	ELSIF resAnnonce.ann_repetition='Mois' THEN
   	 -- on récupère la date de fin sans l'heure et la minute et on y ajoute un jour pour avoir la nouvelle date de début en mettant les heures et minute de début à 0
    	nouvDateDebut := date_trunc('day', resAnnonce.ann_datefin) + interval '1 month';
   	 -- on ajoute les heures et minutes de début de l'annonce précédente
   	 nouvDateDebut := nouvDateDebut + heureMinuteDebut;
   	 
    	nouvDateFin := nouvDateDebut + intervalDebutFin;
    	nouvDateLimRep := nouvDateDebut + intervalDebutLimiteRep;
	END IF;


   INSERT INTO annonce (ann_description, ann_datedebut, ann_datefin, ann_datelimite, ann_nbrmaxpersonnes, ann_nbrplacesdisponibles, ann_visiblepublic, ann_repetition, ann_etat, ann_util_id, ann_cat_id, ann_pro_id)
	VALUES (resAnnonce.ann_description, nouvDateDebut, nouvDateFin, nouvDateLimRep, resAnnonce.ann_nbrmaxpersonnes, resAnnonce.ann_nbrplacesdisponibles, resAnnonce.ann_visiblepublic, resAnnonce.ann_repetition, resAnnonce.ann_etat, resAnnonce.ann_util_id, resAnnonce.ann_cat_id, resAnnonce.ann_pro_id);


END;

$$ LANGUAGE plpgsql;


 CREATE OR REPLACE FUNCTION inscription_annonce(idUser integer, idAnnonce integer, mess character, alerte boolean) RETURNS void as $$
DECLARE
    v_dispo integer;
	
BEGIN
 	v_dispo := (Select getDispo(idUser,idAnnonce)  ) ;
	If v_dispo != 0 then
		Insert into repondre (rep_ann_id,rep_util_id,rep_date_,rep_statut,rep_message,rep_alerte) values (idAnnonce, idUser,now(),'conflit',mess,alerte);
		RAISE EXCEPTION 'Temporel';
	End if;
	
	Insert into repondre (rep_ann_id,rep_util_id,rep_date_,rep_statut,rep_message,rep_alerte) values (idAnnonce, idUser,now(),'non traitée',mess,alerte);
END;

$$ LANGUAGE plpgsql;




























