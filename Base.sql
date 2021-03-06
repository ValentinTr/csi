﻿drop table if exists Categorie CASCADE;
drop table if exists compte    CASCADE;
drop table if exists filiere   CASCADE;
drop table if exists promotion CASCADE;
drop table if exists roles CASCADE;
drop table if exists commentaire CASCADE;
drop table if exists utilisateur   CASCADE;
drop table if exists notification  CASCADE;
drop table if exists annonce   CASCADE;
drop table if exists repondre  CASCADE;
drop table if exists bannir  CASCADE;
drop table if exists archive_annonce   CASCADE;
drop table if exists archive_repondre  CASCADE;

drop type if exists lib CASCADE;
drop type if exists promo CASCADE;
drop type if exists enum_role CASCADE;
drop type if exists repet CASCADE;
drop type if exists etat CASCADE;
drop type if exists statut CASCADE;

drop role visiteur;
drop role utilisateur;
drop role administrateur;

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

-- Table: public.bannir

-- DROP TABLE public.bannir;

CREATE TABLE public.bannir
(
    ban_util_id integer NOT NULL,
    ban_util_idbanni integer NOT NULL,
    CONSTRAINT pdoubleid PRIMARY KEY (ban_util_id, ban_util_idbanni),
    CONSTRAINT fid FOREIGN KEY (ban_util_id)
        REFERENCES public.utilisateur (util_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fidban FOREIGN KEY (ban_util_idbanni)
        REFERENCES public.utilisateur (util_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.bannir
    OWNER to postgres;
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
    REP_alerte boolean NOT NULL,
    CONSTRAINT doubid PRIMARY KEY (REP_ANN_id,REP_UTIL_id),
    CONSTRAINT repann FOREIGN KEY (REP_ANN_id) references Annonce(ANN_id),
    CONSTRAINT reputil FOREIGN KEY (REP_UTIL_id) references Utilisateur(util_id)

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
    (1,3,now(),'non traitée','Je suis passionné de tetris !',true),
    (2,2,now(),'non traitée','Trop content, ouais les vosges',true);

-- creation des fonctions



--*********************************************************************
--******************************acceptation_reponse********************
--*********************************************************************
-- FUNCTION: public.acceptation_reponse(integer, integer)

-- DROP FUNCTION public.acceptation_reponse(integer, integer);

CREATE OR REPLACE FUNCTION public.acceptation_reponse(
  v_user_inscrit integer,
  v_annonce integer,
  v_user_proprietaire integer)
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
  v_iduserprop integer;
  v_titre text;
  v_description text;
BEGIN
  -- verifie si c'est bien le propriétaire de l'annonce
      v_iduserprop := (Select ann_util_id from annonce where annonce.ann_id = v_annonce);
      If v_user_proprietaire != v_iduserprop then
        RAISE Exception 'Seul le propriétaire de l''annonce peut accepter une inscription';
      End if;

  -- test si le destinataire du message existe
  v_idUser := (SELECT util_id FROM utilisateur WHERE utilisateur.util_id = v_user_inscrit);
    
    -- Si l'annonce existe
  v_idAnnonce := (Select ann_id from annonce where annonce.ann_id = v_annonce);
     
    IF (v_idUser IS NULL) OR (v_idAnnonce IS NULL) THEN
     RAISE Exception 'Annonce ou utilisateur introuvable';
    END IF;
  
  
    
    -- On récupère la réponse
  SELECT INTO v_reponseRecord * FROM repondre WHERE rep_ann_id = v_annonce AND rep_util_id = v_user_inscrit;
    
    IF v_reponseRecord.rep_ann_id IS NULL THEN
     RAISE Exception 'Inscription introuvable';
    END IF;
    
  -- On récupère l'annonce associée
    SELECT INTO v_annonceRecord * FROM annonce WHERE ann_id = v_annonce;
     
    IF v_annonceRecord.ann_nbrplacesdisponibles > 0 THEN
     UPDATE annonce ann SET ann_nbrplacesdisponibles = v_annonceRecord.ann_nbrplacesdisponibles - 1 WHERE ann.ann_id = v_annonceRecord.ann_id;
     UPDATE repondre rep SET rep_statut = 'acceptée' WHERE rep_ann_id = v_annonce AND rep_util_id = v_user_inscrit;
    ELSE
     UPDATE repondre rep SET rep_statut = 'en attente' WHERE rep_ann_id = v_annonce AND rep_util_id = v_user_inscrit;
    END IF;


    v_titre := 'Inscription acceptée';
    v_description := 'Votre inscription à l''annonce ' || v_annonceRecord.ann_titre || ' est acceptée.';
    INSERT INTO notification(not_util_id,not_titre,not_message)
    VALUES(v_user_inscrit,v_titre,v_description);
    
    RETURN 0;
    
    END;

$BODY$;







--*********************************************************************
--******************************notifier_tout_inscrit******************
--*********************************************************************

-- FUNCTION: public.notifier_tout_inscrit()

-- DROP FUNCTION public.notifier_tout_inscrit();

CREATE OR REPLACE FUNCTION public.notifier_tout_inscrit()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF 
AS $BODY$

    DECLARE
  inscrits record;
  v_titre text;
  v_contenu text;
  v_ann_id integer;
    BEGIN
    v_ann_id := NEW.ann_id;
    FOR inscrits IN (Select * from repondre where repondre.rep_ann_id= v_ann_id)
  LOOP
    v_titre := 'Suppression de l’annonce ' || v_ann_id ;
    v_contenu := ' L’annonce à été supprimé par le propriétaire ' ;
  
    INSERT INTO notification(not_util_id,not_titre,not_message)
    VALUES(inscrits.rep_util_id,v_titre,v_contenu);
    
    
    
    
  END LOOP;
  
  DELETE FROM repondre
  WHERE repondre.rep_ann_id = v_ann_id;
  
  DELETE FROM annonce
  WHERE annonce.ann_id = v_ann_id;
  
  DELETE FROM commentaire
  WHERE commentaire.com_ann_id = v_ann_id;
    
  Return null;
    END;

$BODY$;

ALTER FUNCTION public.notifier_tout_inscrit()
    OWNER TO postgres;






--*********************************************************************
--******************************bannir_personne********************
--*********************************************************************

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
    IF (v_idproprio = v_idcible)then
      RAISE EXCEPTION 'Tu ne peut pas te bannir ! ';
    ENd if;
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





--*********************************************************************
--******************************create_commentaire*********************
--*********************************************************************

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

--*********************************************************************
--******************************create_promotion***********************
--*********************************************************************

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

--*********************************************************************
--******************************create_filiere*************************
--*********************************************************************

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


--*********************************************************************
--******************************create_notif***************************
--*********************************************************************

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

--*********************************************************************
--******************************connect_user***************************
--*********************************************************************

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


--*********************************************************************
--******************************create_user****************************
--*********************************************************************

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



--*********************************************************************
--******************************create_categorie***********************
--*********************************************************************

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


--*********************************************************************
--******************************fusionner_categorie********************
--*********************************************************************

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
    
  ELSIF (v_opt = 1) THEN
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

--*********************************************************************
--******************************getDispo*******************************
--*********************************************************************

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
    WHERE rep_ann_id=ann_id AND rep_util_id=idUSER AND rep_ann_id=idAnnonce 
    AND (ann_datefin BETWEEN dateDeb AND dateFin OR ann_datedebut BETWEEN dateDeb AND dateFin);
    
    IF resInscription.rep_ann_id IS NOT NULL THEN
     RETURN 2;
    END IF;
    
    RETURN 0;
END;

$$ LANGUAGE plpgsql;



--*********************************************************************
--******************************repeat_annonce*************************
--*********************************************************************
-- FUNCTION: public.repeat_annonce()

-- DROP FUNCTION public.repeat_annonce();

CREATE OR REPLACE FUNCTION public.repeat_annonce()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF 
AS $BODY$

DECLARE
  idannonce integer;
  resAnnonce RECORD;
  nouvDateDebut TIMESTAMP;
  nouvDateFin TIMESTAMP;
  nouvDateLimRep TIMESTAMP;
    intervalDebutFin INTERVAL;
    intervalDebutLimiteRep INTERVAL;
    heureMinuteDebut TIME;
BEGIN
    idannonce := NEW.ann_id;
  SELECT INTO resAnnonce * FROM annonce  WHERE ann_id=idAnnonce;
    
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

   INSERT INTO annonce (ann_titre,ann_description, ann_datedebut, ann_datefin, ann_datelimitereponse, ann_nbrmaxpersonnes, ann_nbrplacesdisponibles, ann_visiblepublic, ann_repetition, ann_etat, ann_util_id, ann_cat_id, ann_pro_id)
  VALUES (resAnnonce.ann_titre,resAnnonce.ann_description, nouvDateDebut, nouvDateFin, nouvDateLimRep, resAnnonce.ann_nbrmaxpersonnes, resAnnonce.ann_nbrplacesdisponibles, resAnnonce.ann_visiblepublic, resAnnonce.ann_repetition, resAnnonce.ann_etat, resAnnonce.ann_util_id, resAnnonce.ann_cat_id, resAnnonce.ann_pro_id);
  Return null;
END;

$BODY$;

ALTER FUNCTION public.repeat_annonce()
    OWNER TO postgres;


-- FUNCTION: public.inscription_annonce(integer, integer, character, boolean)

-- DROP FUNCTION public.inscription_annonce(integer, integer, character, boolean);

CREATE OR REPLACE FUNCTION public.inscription_annonce(
  iduser integer,
  idannonce integer,
  mess character,
  alerte boolean)
    RETURNS integer[]
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

DECLARE
  v_resultCreation integer;
  v_result integer[];
  
BEGIN
  Insert into repondre (rep_ann_id,rep_util_id,rep_date,rep_statut,rep_message,rep_alerte) values (idAnnonce, idUser,now(),'non traitée',mess,alerte);
  
  
        v_resultCreation := (SELECT getdispo(iduser, idannonce));
        v_result[ 1 ] := idannonce;
        v_result[ 2 ] := v_resultCreation;

        Return v_result;
END;

$BODY$;

ALTER FUNCTION public.inscription_annonce(integer, integer, character, boolean)
    OWNER TO postgres;







--*********************************************************************
--******************************annuler_inscription********************
--*********************************************************************

-- FUNCTION: public.annuler_inscription(integer, integer)

-- DROP FUNCTION public.annuler_inscription(integer, integer);

CREATE OR REPLACE FUNCTION public.annuler_inscription(
  iduser integer,
  idannonce integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

DECLARE
    v_titre text;
  v_description text;
  annonce_cible record;
  v_nbplacedispo integer;
  v_statut_inscrit statut;
BEGIN
  IF ( (Select rep_ann_id from repondre where rep_ann_id = idannonce and rep_util_id = iduser) IS NULL )THEN
    Raise exception 'Inscription introuvable';
  End if;
  Select into annonce_cible * from annonce where annonce.ann_id = idannonce;
  v_titre := 'Annulation d''inscription a une annonce';
  v_description := 'Votre inscription à l''annonce ' || annonce_cible.ann_titre || ' est annulée.';
  INSERT INTO notification(not_util_id,not_titre,not_message)
    VALUES(iduser,v_titre,v_description);
 v_statut_inscrit := (Select rep_statut from repondre where rep_ann_id = idannonce and rep_util_id = iduser);
  DELETE FROM repondre
  where repondre.rep_util_id = iduser and repondre.rep_ann_id = idannonce; 
  
  
  
  If v_statut_inscrit = 'acceptée' then
    v_nbplacedispo := annonce_cible.ann_nbrplacesdisponibles+1;
    Update annonce
    SET ann_nbrplacesdisponibles = v_nbplacedispo
    WHERE ann_id = idannonce;

    perform inscription_acceptee_annulee(idannonce);
  End if;
END;

$BODY$;

ALTER FUNCTION public.annuler_inscription(integer, integer)
    OWNER TO postgres;



--*********************************************************************
--******************************Refuser_inscription********************
--*********************************************************************
CREATE OR REPLACE FUNCTION public.refuser_inscription(
  iduser integer,
  idannonce integer,
  id_proprio integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

DECLARE
  v_titre text;
  v_description text;
  annonce_cible record;
  v_idprop integer;
BEGIN
  -- verifie si c'est bien le propriétaire de l'annonce
  v_idprop:= (Select ann_util_id from annonce where annonce.ann_id = idannonce);
  If v_idprop != id_proprio then
    RAISE Exception 'Seul le propriétaire peut refuser une inscription';
  End if;
  IF ( (Select rep_ann_id from repondre where rep_ann_id = idannonce and rep_util_id = iduser) IS NULL )THEN
    RAISE Exception 'Inscription introuvable';
  End if;
  
  Select into annonce_cible * from annonce where annonce.ann_id = idannonce;
  v_titre := 'Inscription refusé';
  v_description := 'Votre inscription à l''annonce ' || annonce_cible.ann_titre || ' est refusée.';
  INSERT INTO notification(not_util_id,not_titre,not_message)
    VALUES(iduser,v_titre,v_description);
    
  DELETE FROM repondre
  where repondre.rep_util_id = iduser and repondre.rep_ann_id = idannonce; 
  
  return 0;
END;

$BODY$;

--*********************************************************************
--******************************create_annonce*********************
--*********************************************************************

 -- FUNCTION: public.create_annonce(character, character, timestamp without time zone, timestamp without time zone, timestamp without time zone, integer, boolean, repet, integer, character)

-- DROP FUNCTION public.create_annonce(character, character, timestamp without time zone, timestamp without time zone, timestamp without time zone, integer, boolean, repet, integer, character);

CREATE OR REPLACE FUNCTION public.create_annonce(
  v_titre character,
  v_description character,
  v_debut timestamp without time zone,
  v_fin timestamp without time zone,
  v_limiterep timestamp without time zone,
  v_nbrmaxpersonne integer,
  v_visible boolean,
  v_repetition repet,
  v_user integer,
  v_categorie character)
    RETURNS integer[]
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
        v_idCategorie integer;
        v_idCreateur integer;
        v_idAnnonce integer;
        v_resultCreation integer;
        v_result integer[];
    BEGIN
        -- test si le créateur de l'annonce existe
        v_idCreateur := (SELECT util_id FROM utilisateur WHERE utilisateur.util_id = v_user);
        IF ( v_idCreateur IS NULL) THEN
            RAISE EXCEPTION 'Le créateur n''existe pas';
        END IF;

        -- test si la catégorie de l'annonce existe
        v_idCategorie := (SELECT create_categorie(v_categorie));
        -- insertion de l'annonce dans la base
        Insert into annonce (ann_titre, ann_description, ann_datedebut, ann_datefin, ann_datelimitereponse, ann_nbrmaxpersonnes, ann_nbrplacesdisponibles, ann_visiblepublic, ann_repetition, ann_etat, ann_util_id, ann_cat_id)
        values (v_titre, v_description, v_debut, v_fin, v_limiteRep, v_nbrMaxPersonne, v_nbrMaxPersonne, v_visible, v_repetition, 'En cours', v_user, v_idCategorie);

        v_idAnnonce := (SELECT MAX(ann_id) FROM annonce WHERE ann_description = v_description AND ann_datedebut = v_debut AND ann_util_id = v_user);

        v_resultCreation := (SELECT getdispo(v_user, v_idAnnonce));

        v_result[ 1 ] := v_idAnnonce;
        v_result[ 2 ] := v_resultCreation;

        Return v_result;
    END;

$BODY$;

ALTER FUNCTION public.create_annonce(character, character, timestamp without time zone, timestamp without time zone, timestamp without time zone, integer, boolean, repet, integer, character)
    OWNER TO postgres;

--*********************************************************************
--******************************annuler_annonce************************
--*********************************************************************


CREATE OR REPLACE FUNCTION public.annuler_annonce(v_iduser integer, v_idAnnonce integer)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
    v_titre text;
    v_contenu text;
    v_titreAnnonce text;
    v_iduserprop integer;
    BEGIN
  
    v_titreAnnonce := (Select ann_titre from annonce where annonce.ann_id = v_idAnnonce);
    v_iduserprop := (Select ann_util_id from annonce where annonce.ann_id = v_idAnnonce);
  if v_iduser != v_iduserprop then
    return false;
  End if;
    v_titre := 'Annonce bien annulée ';
    v_contenu := ' Votre annonce :  ' || v_titreAnnonce || ' est bien annulée' ;
  
    INSERT INTO notification(not_titre,not_message,not_util_id)
    VALUES(v_titre,v_contenu,v_iduser);
  
    UPDATE annonce
    Set ann_etat = 'Annulée'
      Where ann_id = v_idAnnonce;  
    
   return true;
    END;
  
  
$BODY$;


--*********************************************************************
--******************************archivage******************************
--*********************************************************************


CREATE OR REPLACE FUNCTION public.archivage()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
    v_idAnnonce integer;
    inscrits record;
    v_titre text;
    v_contenu text;
    BEGIN
    v_idAnnonce := NEW.ann_id;
    FOR inscrits IN (Select * from repondre,annonce where repondre.rep_ann_id = annonce.ann_id and annonce.ann_id = v_idAnnonce)
  LOOP
  
    If (inscrits.rep_statut = 'acceptée') then
      v_titre := 'Annonce terminée ' ;
      v_contenu := ' L''annonce : ' || inscrits.ann_titre || ' est terminée' ;
      INSERT INTO notification(not_titre,not_message,not_util_id)
      VALUES(v_titre,v_contenu,inscrits.rep_util_id);
    
      insert into archive_repondre(idannonce,idutilisateur,message,datereponse)
      values(v_idAnnonce,inscrits.rep_util_id,inscrits.rep_message,inscrits.rep_date);
    End if; 
      DELETE FROM public.repondre
      WHERE repondre.rep_ann_id = v_idAnnonce;
    
  END LOOP;
  v_titre := 'Annonce terminée ' ;
  v_contenu := ' L''annonce : ' || NEW.ann_titre || ' est terminée' ;
  INSERT INTO notification(not_titre,not_message,not_util_id)
  VALUES(v_titre,v_contenu,NEW.ann_util_id);
  
  INSERT INTO public.archive_annonce(
  idannonce, idpropriétaire, description, datedebut, datefin, nbrmaxpersonne, nbrplacesdisponibles)
  VALUES (v_idAnnonce, NEW.ann_util_id, NEW.ann_description, NEW.ann_datedebut, NEW.ann_datefin , NEW.ann_nbrmaxpersonnes , NEW.ann_nbrplacesdisponibles);
  
  DELETE FROM public.annonce
  WHERE annonce.ann_id = v_idAnnonce;
  
  return null;
  END;
$BODY$;

--*********************************************************************
--******************************inscription_acceptee_annulee***********
--*********************************************************************


CREATE OR REPLACE FUNCTION public.inscription_acceptee_annulee(v_idAnnonce integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
  placedispo integer;
  nbenfile integer;
  premierattente integer;
    BEGIN

    placedispo := (Select ann_nbrplacesdisponibles from annonce where ann_id = v_idAnnonce );
    nbenfile := (Select count(rep_util_id) from repondre where rep_ann_id = v_idAnnonce and rep_statut = 'en attente');
  If placedispo = 1 then
    If nbenfile = 0 then
      Raise notice 'personne en file';
    else
      premierattente := (Select rep_util_id from repondre  where rep_ann_id = v_idAnnonce  and rep_statut = 'en attente' order by rep_date ASC LIMIT 1 );
      
      Update repondre
      set rep_statut = 'acceptée'
      Where rep_util_id = premierattente
      and rep_ann_id = v_idAnnonce;
      
      update annonce
      set ann_nbrplacesdisponibles = placedispo-1
      where ann_id = v_idAnnonce;
    END IF;
  END IF;
    END;

$BODY$;

ALTER FUNCTION public.create_categorie(character)
    OWNER TO postgres;






--*********************************************************************
--******************************inscription_expire*********************
--*********************************************************************


CREATE OR REPLACE FUNCTION public.inscription_expire() RETURNS void LANGUAGE 'plpgsql'
  COST 100
  VOLATILE
AS $BODY$
 Declare 
  non_traite record;
  v_titre text;
  v_contenu text;
  v_nomannonce text;
Begin
      For non_traite IN (Select * from repondre where rep_statut = 'non traitée')
  LOOP 
    raise notice 'Value: %', non_traite.rep_date + interval '2 day';
    if ( (non_traite.rep_date + interval '2 day') < clock_timestamp() ) then
      raise notice 'lol';
      v_nomannonce := (Select ann_titre from annonce where ann_id = non_traite.rep_ann_id);
      v_titre := 'Votre inscription est expiré';
      v_contenu := 'L''inscription à l''annonce : ' || v_titre || 'est expiré.';
      INSERT INTO notification(not_util_id,not_titre,not_message)
        VALUES(non_traite.rep_util_id,v_titre,v_contenu);
      
       DELETE FROM repondre
        WHERE repondre.rep_util_id = non_traite.rep_util_id
      and repondre.rep_ann_id = non_traite.rep_util_id;
    End if;
  END LOOP;
END;

$BODY$;


--*********************************************************************
--******************************getUserAvailableAnnonce****************
--********************************************************************* 
  
CREATE OR REPLACE FUNCTION public.getUserAvailableAnnonces(iduser integer)
    RETURNS setof annonce
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
  v_idpromo integer;
    BEGIN
      v_idpromo := (Select util_pro_id from utilisateur where util_id = iduser);
    
    return query (
      SELECT * FROM annonce WHERE ann_visiblepublic = true
        AND ann_util_id NOT IN (SELECT ban_util_id FROM bannir WHERE ban_util_idbanni = iduser)
      
      UNION
      
      SELECT annonce.* FROM annonce, utilisateur WHERE ann_visiblepublic = false
        AND annonce.ann_util_id = utilisateur.util_id AND v_idpromo = utilisateur.util_pro_id
        AND ann_util_id not in (select ban_util_id from bannir where ban_util_idbanni = iduser));
    END;

$BODY$;




--*******************
-- Ajout des triggers
--*******************
CREATE TRIGGER etat_annonce_annule
  AFTER UPDATE on annonce
  FOR EACH ROW
  When (new.ann_etat = 'Annulée')
  Execute procedure notifier_tout_inscrit();


  CREATE TRIGGER etat_annonce_termine
  AFTER UPDATE on annonce
  FOR EACH ROW
  When (new.ann_etat = 'Terminée')
  Execute procedure repeat_annonce();

 CREATE TRIGGER etat_annonce_termine_archivage
  AFTER UPDATE on annonce
  FOR EACH ROW
  When (new.ann_etat = 'Terminée')
  Execute procedure archivage();

-- Role
-- Visiteur
CREATE ROLE visiteur WITH
LOGIN PASSWORD 'visrol';
GRANT USAGE ON SCHEMA public TO visiteur;
GRANT select,insert,update on compte,utilisateur to visiteur;
GRANT select on filiere,promotion,roles to visiteur;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public
    TO visiteur;

--Utilisateur
CREATE ROLE utilisateur WITH
LOGIN PASSWORD 'utilrolpass';
Grant select,insert,update,delete on utilisateur,bannir,commentaire,annonce, repondre, notification to utilisateur;
Grant select,insert,update on compte to utilisateur;
Grant select,insert on categorie to utilisateur;
Grant select,insert on promotion,filiere,roles,archive_annonce,archive_repondre to utilisateur;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public
    TO utilisateur;

--Admin

CREATE ROLE administrateur WITH LOGIN PASSWORD 'adminrolpass' SUPERUSER ;
