-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 16 déc. 2021 à 17:35
-- Version du serveur : 10.4.22-MariaDB
-- Version de PHP : 8.0.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `Gr3_SQL_016`
--
CREATE DATABASE IF NOT EXISTS `Gr3_SQL_016` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `Gr3_SQL_016`;

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `ALERTE_RETARD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ALERTE_RETARD` ()  SELECT livraison.ID_Livraison,  commande.ID_Commande, commande.Date_d_emission
FROM commande
inner join livraison on commande.ID_Commande = livraison.ID_Commande
where livraison.Statut = 'En cours'  and datediff(now(),commande.Date_d_emission) > 10$$

DROP PROCEDURE IF EXISTS `BILAN_STOCK_DEFAUT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BILAN_STOCK_DEFAUT` ()  SELECT produit.ID_Produit,produit.Nom,produit.Stock
FROM produit
where produit.Stock<produit.StockCritique$$

DROP PROCEDURE IF EXISTS `BILAN_VENTES_ANNUELLES`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BILAN_VENTES_ANNUELLES` (IN `an` YEAR)  SELECT year(commande.Date_d_emission) as Année, sum(produit.PrixCondi*contenir.Quantite) as CA, sum(produit.marge*contenir.Quantite) as Marge
FROM commande
INNER join contenir on commande.ID_Commande = contenir.ID_Commande
INNER join produit on contenir.ID_Produit = produit.ID_Produit
where year(commande.Date_d_emission) = an or year(commande.Date_d_emission) = an-1
group by year(commande.Date_d_emission)$$

DROP PROCEDURE IF EXISTS `BILAN_VENTES_CATEGORIE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BILAN_VENTES_CATEGORIE` ()  SELECT produit.Categorie, sum(lignefacture.Nb*lignefacture.PrixUnitaire) as MONTANT
FROM produit
InNeR jOiN lignefacture on produit.ID_Produit = lignefacture.ID_Produit
group by produit.Categorie$$

DROP PROCEDURE IF EXISTS `FICHE_CONSOMMATEUR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FICHE_CONSOMMATEUR` (IN `name` VARCHAR(10))  SELECT *, commande.ID_Commande, livraison.*
FROM consommateur
INNER JOIN commande on commande.ID_Consommateur = consommateur.ID_Consommateur
INNER JOIN livraison on livraison.ID_Commande = commande.ID_Commande
WHERE consommateur.Nom like concat(name,'%')$$

DROP PROCEDURE IF EXISTS `FICHE_FOURNISSEUR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FICHE_FOURNISSEUR` (IN `id` INT(10))  SELECT fournisseur.Nom, fournisseur.Ferme, fournisseur.CodePost, fournaison.ID_Produit, fournaison.Quantite, fournaison.DateFournaison
from fournisseur
INNER JOIN fournaison on fournaison.ID_Fournisseur = fournisseur.ID_Fournisseur
where fournisseur.ID_Fournisseur=id$$

DROP PROCEDURE IF EXISTS `FICHE_PRODUITS_CATEGORIE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FICHE_PRODUITS_CATEGORIE` (IN `cat` VARCHAR(30))  SELECT *, fournisseur.Nom
FROM produit
INNER JOIN  fournisseur on produit.ID_Fournisseur = fournisseur.ID_Fournisseur 
where produit.Categorie = cat$$

DROP PROCEDURE IF EXISTS `FIND_PRODUITS_FOURNISSEUR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FIND_PRODUITS_FOURNISSEUR` (IN `id_a_check` VARCHAR(10))  SELECT produit.ID_Produit, produit.Nom, produit.Stock FROM produit WHERE produit.ID_Fournisseur = id_a_check$$

DROP PROCEDURE IF EXISTS `FOURNISSEUR_ADD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FOURNISSEUR_ADD` (IN `nom` VARCHAR(10), IN `ferme` VARCHAR(30), IN `codepostal` INT(11))  INSERT INTO `fournisseur` (`Nom`, `Ferme`, `CodePost`) VALUES (nom, ferme, codepostal)$$

DROP PROCEDURE IF EXISTS `FOURNISSEUR_ERASE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FOURNISSEUR_ERASE` (IN `id_a_supr` INT(10))  DELETE FROM fournisseur WHERE fournisseur.ID_Fournisseur = id_a_supr$$

DROP PROCEDURE IF EXISTS `FOURNISSEUR_UPDATE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FOURNISSEUR_UPDATE` (IN `id` INT(11), IN `name` VARCHAR(30), IN `ferm` VARCHAR(30), IN `codepostal` INT(11))  Begin 

#Changement de la ferme du fournisseur
if ferm <> '' then
update `fournisseur`
SET `Ferme` = ferm
WHERE fournisseur.id_fournisseur = id;
END if;

#Changement du code postal du fournisseur
if codepostal <> 0 then
update `fournisseur`
SET `CodePost` = codepostal
WHERE fournisseur.id_fournisseur = id;
END if;

#Changement du nom du fournisseur
if name <> '' then
update `fournisseur`
SET `Nom` = name
WHERE fournisseur.id_fournisseur = id;
END if;

end$$

DROP PROCEDURE IF EXISTS `LISTE_COMMANDE_STATUTS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTE_COMMANDE_STATUTS` (IN `etat1` VARCHAR(10), IN `etat2` VARCHAR(10), IN `etat3` VARCHAR(10))  SELECT commande.ID_Commande, commande.Date_d_emission, consommateur.Nom
FROM commande
inner JOIN consommateur on commande.ID_Consommateur=consommateur.ID_Consommateur
where commande.Statut IN(etat1, etat2, etat3)$$

DROP PROCEDURE IF EXISTS `LIVRAISON_OFFERTE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LIVRAISON_OFFERTE` ()  SELECT livraison.Frais, consommateur.Nom, commande.ID_Commande, commande.Statut, commande.Date_d_emission 
FROM livraison
INNER join commande on livraison.ID_Commande = commande.ID_Commande
inner JOIN consommateur on commande.id_consommateur = consommateur.ID_Consommateur
where livraison.Frais = 0$$

DROP PROCEDURE IF EXISTS `PRIXMOYEN_PRODUIT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRIXMOYEN_PRODUIT` (IN `nomproduit` VARCHAR(30))  SELECT produit.Nom, AVG(produit.PrixKilo) FROM produit WHERE produit.Nom = nomproduit$$

DROP PROCEDURE IF EXISTS `PRODUITS_VENDUS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUITS_VENDUS` (IN `reg` INT(2))  SELECT sum(lignefacture.Nb) as Quantite, fournisseur.nom, fournisseur.CodePost
from fournisseur
INNER join produit on fournisseur.ID_Fournisseur = produit.ID_Fournisseur
inner JOIN lignefacture on produit.ID_Produit = lignefacture.ID_Produit
where fournisseur.CodePost LIKE concat(reg,'%') 
GROUP by fournisseur.ID_Fournisseur$$

DROP PROCEDURE IF EXISTS `PRODUIT_ADD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUIT_ADD` (IN `categorie` VARCHAR(30), IN `sous_categorie` VARCHAR(30), IN `nom` VARCHAR(30), IN `description` VARCHAR(100), IN `prixcondi` FLOAT, IN `prixkilo` FLOAT, IN `dateperemption` DATE, IN `quantite` INT(11), IN `idfourni` INT(11))  INSERT INTO `produit` (`ID_Produit`, `Categorie`, `Sous_Categorie`, `Nom`, `Description`, `PrixCondi`, `PrixKilo`, `DateFin`, `StockCritique`, `ID_Fournisseur`) VALUES (0, categorie, sous_categorie,nom,description,prixcondi,prixkilo, dateperemption, quantite, idfourni)$$

DROP PROCEDURE IF EXISTS `PRODUIT_ERASE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUIT_ERASE` (IN `id_a_supprimer` INT(10))  DELETE FROM `produit` WHERE produit.ID_Produit = id_a_supprimer$$

DROP PROCEDURE IF EXISTS `PRODUIT_SEUIL`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUIT_SEUIL` (IN `id` INT(11), IN `montant` INT)  update `produit`
SET `StockCritique` = montant
WHERE produit.ID_Produit = id$$

DROP PROCEDURE IF EXISTS `PRODUIT_UPDATE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUIT_UPDATE` (IN `idprod` INT(10), IN `idfourni` INT(10), IN `cat` VARCHAR(30), IN `sous_cat` VARCHAR(30), IN `nommage` VARCHAR(30), IN `descrip` VARCHAR(100), IN `prixcond` FLOAT, IN `prixk` FLOAT, IN `dateperemption` DATE, IN `quantite` INT(11))  Begin -- Début de la fonction d'update
#Changement de l'id du fournisseur du produit
if idfourni <> 0 then
update `produit`
SET `ID_Fournisseur` = idfourni
WHERE produit.ID_Produit = idprod;
END if;

#Changement de la catégorie du produit
if cat <> '' then
UPDATE `produit`
SET `Categorie` = cat
WHERE produit.ID_Produit = idprod;
END if;

#Changement de la sous-catégorie du produit
if sous_cat <> '' then
UPDATE `produit`
SET `Sous_categorie` = sous_cat
WHERE produit.ID_Produit = idprod;
END if;

#Changement du nom du produit
if nommage <> '' then
UPDATE `produit`
SET `Nom` = nommage
WHERE produit.ID_Produit = idprod;
END if;

#Changement de la description du produit
if descrip <> '' then
UPDATE `produit`
SET `Description` = descrip 
WHERE produit.ID_Produit = idprod;
END if;

#Changement du prix conditionnel du produit
if prixcond <> 0 then
UPDATE `produit`
SET `PrixCondi` = prixcond 
WHERE produit.ID_Produit = idprod;
END if;

#Changement du prix au kg du produit
if prixk <> 0 then
UPDATE `produit`
SET `PrixKilo` = prixk
WHERE produit.ID_Produit = idprod;
END if;

#Changement de la date de préremption du produit
if dateperemption <> 0 then
UPDATE `produit`
SET `DateFin` = dateperemption 
WHERE produit.ID_Produit = idprod;
END if;

#Changement de la quantite du produit
if quantite <> 0 then
UPDATE `produit`
SET `StockCritique` = quantite
WHERE produit.ID_Produit = idprod;
END if;
-- Fin de la fonction d'update
END$$

DROP PROCEDURE IF EXISTS `QUALITE_COMMANDE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `QUALITE_COMMANDE` ()  SELECT avg(commande.Qualite) from commande commande WHERE commande.Qualite$$

DROP PROCEDURE IF EXISTS `QUALITE_LIVRAISON`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `QUALITE_LIVRAISON` ()  SELECT avg(livraison.Qualite) from livraison WHERE livraison.Qualite$$

DROP PROCEDURE IF EXISTS `STATS_CAUSE_RETARDS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `STATS_CAUSE_RETARDS` ()  SELECT livraison.CauseRetard as Cause, count(livraison.CauseRetard) as NombreDeFois
FROM livraison
wHeRe livraison.CauseRetard is not NULL
GROUP By livraison.CauseRetard$$

DROP PROCEDURE IF EXISTS `STATS_SATISFACTION`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `STATS_SATISFACTION` ()  SELECT (avg(livraison.Qualite) + avg(commande.Qualite))/2 as NoteGlobaleDesUtilisateurs from livraison, commande
WHERE livraison.Qualite or commande.Qualite$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `bon_d_achat`
--

DROP TABLE IF EXISTS `bon_d_achat`;
CREATE TABLE `bon_d_achat` (
  `ID_Bon` int(11) NOT NULL,
  `Valeur` int(2) NOT NULL DEFAULT 5,
  `DateCreation` date NOT NULL,
  `DatePeremption` date NOT NULL,
  `ID_Consommateur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `bon_d_achat`
--

INSERT INTO `bon_d_achat` (`ID_Bon`, `Valeur`, `DateCreation`, `DatePeremption`, `ID_Consommateur`) VALUES
(1, 5, '2021-11-08', '2022-01-08', 1),
(2, 5, '2021-11-09', '2022-01-09', 3),
(3, 5, '2021-11-10', '2022-01-10', 4),
(4, 5, '2021-10-11', '2021-12-11', 9),
(5, 5, '2021-10-12', '2021-12-12', 8),
(6, 5, '2021-10-13', '2021-12-13', 12);

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE `commande` (
  `ID_Commande` int(11) NOT NULL,
  `Statut` varchar(10) NOT NULL,
  `Qualite` int(1) DEFAULT NULL,
  `Date_d_emission` date NOT NULL,
  `ID_Consommateur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`ID_Commande`, `Statut`, `Qualite`, `Date_d_emission`, `ID_Consommateur`) VALUES
(1, 'terminée', 5, '2021-01-01', 1),
(2, 'terminée', 4, '2021-02-01', 2),
(3, 'terminée', 3, '2021-04-01', 7),
(4, 'En prépara', NULL, '2021-10-25', 5),
(5, 'annulée', NULL, '2021-09-01', 2),
(6, 'terminée', 2, '2021-03-19', 1),
(7, 'terminée', 1, '2021-05-01', 8),
(8, 'annulée', NULL, '2020-04-28', 4),
(9, 'En prépara', NULL, '2020-11-28', 6),
(10, 'En prépara', NULL, '2021-11-28', 5),
(11, 'terminée', 4, '2021-12-14', 2),
(12, 'terminée', NULL, '2022-02-08', 8);

-- --------------------------------------------------------

--
-- Structure de la table `consommateur`
--

DROP TABLE IF EXISTS `consommateur`;
CREATE TABLE `consommateur` (
  `ID_Consommateur` int(11) NOT NULL,
  `Prenom` varchar(25) NOT NULL,
  `Nom` varchar(25) NOT NULL,
  `Points` int(11) NOT NULL,
  `Fidelite` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `consommateur`
--

INSERT INTO `consommateur` (`ID_Consommateur`, `Prenom`, `Nom`, `Points`, `Fidelite`) VALUES
(1, 'Miou', 'Mi', 8, 0),
(2, 'Mia', 'Mo', 5, 0),
(3, 'Mu', 'Ma', 5, 0),
(4, 'NainCapable', 'Mitryl', 7, 0),
(5, 'Louis', 'XVI', 6, 0),
(6, 'Léon', 'Napo', 100, 0),
(7, 'Alek', 'Cendres', 2, 1),
(8, 'Peau', 'Lyne', 7, 1),
(9, 'Gua', 'Ssien', 10, 1),
(10, 'Victor', 'Ria', 20, 1),
(11, 'Mât', 'Tyss', 42, 1),
(12, 'Jul', 'Lien', 39, 1),
(13, 'Jman', 'Nuit', 70, 0),
(14, 'Paa', 'Didé', 69, 0),
(15, 'Jsoui', 'Fatgué', 22, 1),
(16, 'Jvoeu', 'Domir', 12, 0),
(17, 'XXX_Dark_Kevin_69_XXX', 'DemonDesPyramides', 35, 1),
(18, 'Emèrd', 'yaQatia', 9999, 0),
(19, 'Sparo', 'Spirou', 22, 0);

-- --------------------------------------------------------

--
-- Structure de la table `contenir`
--

DROP TABLE IF EXISTS `contenir`;
CREATE TABLE `contenir` (
  `ID_Produit` int(11) NOT NULL,
  `Quantite` int(3) NOT NULL,
  `ID_Commande` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `contenir`
--

INSERT INTO `contenir` (`ID_Produit`, `Quantite`, `ID_Commande`) VALUES
(1, 2, 1),
(2, 8, 1),
(3, 20, 1),
(7, 1, 2),
(8, 7, 2),
(9, 5, 3),
(2, 12, 4),
(1, 15, 4),
(9, 32, 5),
(2, 13, 6),
(2, 21, 6),
(11, 12, 7),
(2, 15, 8),
(3, 17, 9),
(20, 3, 9),
(13, 1, 9),
(9, 2, 9),
(16, 3, 10),
(5, 5, 10),
(2, 4, 10),
(18, 6, 10),
(8, 8, 10),
(7, 1, 10),
(15, 7, 10);

-- --------------------------------------------------------

--
-- Structure de la table `facture`
--

DROP TABLE IF EXISTS `facture`;
CREATE TABLE `facture` (
  `ID_Facture` int(11) NOT NULL,
  `Datum` date NOT NULL,
  `Total` float NOT NULL,
  `ID_Commande` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `facture`
--

INSERT INTO `facture` (`ID_Facture`, `Datum`, `Total`, `ID_Commande`) VALUES
(1, '2021-11-29', 0, 1),
(2, '2021-12-25', 0, 2),
(3, '2021-09-29', 0, 3),
(4, '2021-09-29', 0, 4),
(5, '2021-11-22', 0, 5);

-- --------------------------------------------------------

--
-- Structure de la table `fournaison`
--

DROP TABLE IF EXISTS `fournaison`;
CREATE TABLE `fournaison` (
  `ID_Produit` int(11) NOT NULL,
  `DateFournaison` date NOT NULL,
  `Quantite` int(3) NOT NULL,
  `ID_Fournisseur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `fournaison`
--

INSERT INTO `fournaison` (`ID_Produit`, `DateFournaison`, `Quantite`, `ID_Fournisseur`) VALUES
(1, '2021-11-28', 100, 1),
(2, '2021-11-27', 30, 2),
(3, '2021-11-25', 20, 4),
(4, '1020-08-28', 30, 5),
(5, '1921-11-25', 40, 4),
(6, '0821-11-18', 42, 5),
(7, '1911-01-01', 20, 3),
(8, '1919-11-25', 50, 7),
(9, '1865-07-12', 31, 8),
(10, '2021-11-12', 25, 2),
(10, '2021-08-15', 33, 3),
(12, '2021-08-07', 12, 4),
(13, '2021-03-08', 1, 7),
(14, '2015-07-04', 2, 2),
(15, '2015-05-07', 4, 9),
(16, '2019-12-25', 7, 10),
(17, '2001-03-18', 32, 7),
(18, '2008-04-17', 42, 6),
(19, '2009-05-28', 60, 3),
(27, '2021-01-12', 123, 7),
(13, '2021-12-07', 14, 3);

-- --------------------------------------------------------

--
-- Structure de la table `fournisseur`
--

DROP TABLE IF EXISTS `fournisseur`;
CREATE TABLE `fournisseur` (
  `ID_Fournisseur` int(11) NOT NULL,
  `Nom` varchar(30) DEFAULT NULL,
  `Ferme` varchar(30) NOT NULL,
  `CodePost` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `fournisseur`
--

INSERT INTO `fournisseur` (`ID_Fournisseur`, `Nom`, `Ferme`, `CodePost`) VALUES
(1, 'Bernard', 'Les trois fermes', 91400),
(2, 'Gatien', 'Les deux fermes', 91403),
(3, 'Bernard', 'La ferme dun hermite', 91000),
(4, 'Les 3 Fées', 'Hyrule', 20000),
(5, 'Sisi', 'Ltrou de souris', 3630),
(6, 'Bernabé', 'sa coquille', 91400),
(7, 'Esmeralda', 'Les trois fermes', 91400),
(8, 'PtitCon', 'TrouDculDmonde', 91400),
(9, 'Ingénieur', 'EPF', 92000),
(10, 'Ingénieure', 'EPF', 92000),
(11, 'Professeur', 'EPF', 92000),
(12, 'Kholeur', 'EPF', 92000),
(13, 'MrBonnesNotes', 'Pas EPF', 69000),
(14, 'Rattrapages', 'EPF', 92000),
(15, 'Yolastipoaaaaaek', 'yoland', 14322),
(18, 'Popo', 'Lala', 85555),
(19, 'eeeeeeh', 'stppppppppp', 69420);

-- --------------------------------------------------------

--
-- Structure de la table `lieulivraison`
--

DROP TABLE IF EXISTS `lieulivraison`;
CREATE TABLE `lieulivraison` (
  `ID_LieuLivraison` int(11) NOT NULL,
  `Adresse` varchar(30) NOT NULL,
  `Disponibilite` tinyint(1) NOT NULL,
  `PointRelais` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `lieulivraison`
--

INSERT INTO `lieulivraison` (`ID_LieuLivraison`, `Adresse`, `Disponibilite`, `PointRelais`) VALUES
(1, 'centre de la terre', 1, 1),
(2, 'EPF', 0, 1),
(3, 'Lauberge (chez Pauline)', 1, 1),
(4, 'Paris (le Pays)', 1, 0),
(5, 'Niort', 1, 0),
(6, 'MontSaintMichou', 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `lignefacture`
--

DROP TABLE IF EXISTS `lignefacture`;
CREATE TABLE `lignefacture` (
  `ID_LigneFacture` int(11) NOT NULL,
  `ID_Produit` int(11) NOT NULL,
  `Produit` varchar(30) NOT NULL,
  `Nb` int(11) NOT NULL,
  `PrixUnitaire` float NOT NULL,
  `ID_Facture` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `lignefacture`
--

INSERT INTO `lignefacture` (`ID_LigneFacture`, `ID_Produit`, `Produit`, `Nb`, `PrixUnitaire`, `ID_Facture`) VALUES
(1, 15, 'Topinambour', 3, 0.12, 1),
(2, 7, 'Carotte', 1, 0.14, 2),
(3, 8, 'Pintade', 8, 15, 3),
(4, 18, 'Courge spaghetti', 6, 3.95, 4),
(5, 2, 'Avoine', 4, 3, 5);

-- --------------------------------------------------------

--
-- Structure de la table `livraison`
--

DROP TABLE IF EXISTS `livraison`;
CREATE TABLE `livraison` (
  `ID_Livraison` int(11) NOT NULL,
  `Datum` date DEFAULT NULL,
  `Statut` varchar(25) NOT NULL,
  `Frais` int(11) NOT NULL,
  `Qualite` int(1) DEFAULT NULL,
  `CauseRetard` varchar(20) DEFAULT NULL,
  `ID_Commande` int(11) NOT NULL,
  `ID_LieuLivraison` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `livraison`
--

INSERT INTO `livraison` (`ID_Livraison`, `Datum`, `Statut`, `Frais`, `Qualite`, `CauseRetard`, `ID_Commande`, `ID_LieuLivraison`) VALUES
(1, '2021-11-19', 'Livraison effectuée', 1425, 5, NULL, 1, 1),
(2, NULL, 'En cours', 25, NULL, 'transport', 2, 3),
(3, NULL, 'En cours', 35, NULL, 'transport', 3, 4),
(4, NULL, 'En cours', 45, NULL, 'pénurie', 6, 5),
(5, NULL, 'annulée', 0, NULL, NULL, 7, 2),
(7, NULL, 'En cours', 0, NULL, NULL, 11, 3),
(8, NULL, 'En cours', 23, NULL, NULL, 12, 3);

-- --------------------------------------------------------

--
-- Structure de la table `marche`
--

DROP TABLE IF EXISTS `marche`;
CREATE TABLE `marche` (
  `ID_Marche` int(11) NOT NULL,
  `Nom` varchar(25) NOT NULL,
  `Lieu` varchar(30) NOT NULL,
  `Datum` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `marche`
--

INSERT INTO `marche` (`ID_Marche`, `Nom`, `Lieu`, `Datum`) VALUES
(1, 'O\'Puss', 'Pouilles', '2021-11-09'),
(2, 'Little Cat', 'Mondétour', '2021-12-09'),
(3, 'MarcheDeJavan', 'Pouilles', '2001-07-17'),
(4, 'VidePotagers', 'Marcoussis', '2021-11-09'),
(5, 'O\'Puss', 'Pouilles', '2021-10-09'),
(6, 'O\'Puss', 'Pouilles', '2021-09-08'),
(7, 'O\'Puss', 'Pouilles', '2021-08-05'),
(8, 'O\'Puss', 'Pouilles', '2021-07-10'),
(9, 'Yargart', 'Qèla', '2021-06-05'),
(10, 'O\'Puss', 'Pouilles', '2021-05-08'),
(11, 'O\'Puss', 'Pouilles', '2021-04-04'),
(12, 'O\'Puss', 'Pouilles', '2021-03-07'),
(13, 'O\'Puss', 'Pouilles', '2021-02-02'),
(14, 'luijyhtygl', 'lkhpiuhyhi', '2021-04-25');

-- --------------------------------------------------------

--
-- Structure de la table `participe`
--

DROP TABLE IF EXISTS `participe`;
CREATE TABLE `participe` (
  `ID_Marche` int(11) NOT NULL,
  `ID_Fournisseur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `participe`
--

INSERT INTO `participe` (`ID_Marche`, `ID_Fournisseur`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

DROP TABLE IF EXISTS `produit`;
CREATE TABLE `produit` (
  `ID_Produit` int(11) NOT NULL,
  `Categorie` varchar(30) NOT NULL,
  `Sous_Categorie` varchar(30) NOT NULL,
  `Nom` varchar(30) NOT NULL,
  `Description` varchar(100) NOT NULL,
  `PrixCondi` float NOT NULL,
  `PrixKilo` float NOT NULL,
  `marge` float NOT NULL,
  `DateFin` date NOT NULL,
  `Stock` int(11) NOT NULL,
  `StockCritique` int(3) NOT NULL DEFAULT 10,
  `ID_Fournisseur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`ID_Produit`, `Categorie`, `Sous_Categorie`, `Nom`, `Description`, `PrixCondi`, `PrixKilo`, `marge`, `DateFin`, `Stock`, `StockCritique`, `ID_Fournisseur`) VALUES
(1, 'Fruits & Légumes', 'Fruits de saison', 'Fraise', ' ', 2.5, 5.67, 0.5, '2021-12-31', 44, 10, 4),
(2, 'Fruits & Légumes', 'Fruits à coque', 'Noisette', ' ', 3, 20.6, 0.7, '2021-12-31', 420, 10, 1),
(3, 'Viande & Poisson', 'Poisson', 'Loup', ' ou Bar, ça dépend de la région', 22, 12, 1, '2021-12-31', 420, 10, 1),
(4, 'Epicerie sucrée', 'Céréales', 'Avoine', ' ', 3.12, 15.6, 1.1, '2021-12-31', 20, 15, 1),
(5, 'Epicerie sucrée', 'Miel', 'Miel d\'acacia', ' ', 2, 8, 1.2, '2021-12-31', 69, 22, 1),
(6, 'Fruits & Légumes', 'Courge', 'Courge spaghetti', ' ', 4, 1.68, 2, '2021-12-31', 420, 10, 5),
(7, 'Fruits & Légumes', 'Racine', 'Carotte', ' ', 0.14, 0.89, 0.03, '2021-12-31', 85, 10, 1),
(8, 'Viande & Poisson', 'Volaille', 'Pintade', ' ', 15, 9, 14.9, '2021-12-31', 420, 10, 1),
(9, 'Crèmerie', 'Oeuf', 'Oeuf de griffon', ' ', 12, 4, 10, '2021-12-31', 2, 5, 1),
(10, 'Epicerie salée', 'Huile & vinaigre', 'Vinaigre de Xérès', ' ', 3.5, 4, 2.7, '2021-12-31', 420, 10, 1),
(11, 'Epicerie sucrée', 'Compote', 'Compote pomme-rhubarbe', ' ', 4, 3, 1, '2021-12-31', 420, 10, 1),
(12, 'Viande & Poisson', 'Canard', 'Magret', ' ', 33, 50, 19, '2021-12-31', 420, 10, 1),
(13, 'Epicerie', 'Lait', 'Lait d\'amande', 'c\'est pas du lait de vache', 2, 1, 0.4, '2021-11-24', 434, 12, 1),
(14, 'Fruits & Légumes', 'Chou', 'Chou romanesco', ' ', 1.18, 13.98, 0.3, '2021-12-31', 420, 10, 1),
(15, 'Fruits & Légumes', 'Légumes oubliés', 'Topinambour', ' ', 0.12, 0.6, 0.09, '2021-12-31', 420, 10, 1),
(16, 'Fruits & Légumes', 'Herbe & salade', 'Aneth', ' ', 1.12, 3.6, 0.3, '2021-12-31', 420, 10, 1),
(17, 'Fruits & Légumes', 'Champignons', 'Trompette de la mort', ' ', 54, 2.6, 0.01, '2021-12-31', 420, 10, 1),
(18, 'Fruits & Légumes', 'Pommes de terre', 'Vitelotte', ' ', 3.95, 5.6, 0.8, '2021-12-31', 420, 10, 1),
(19, 'Fruits & Légumes', 'Ail, oignon, échalote', 'Echalote', ' ', 4.46, 13.67, 0.12, '2021-12-31', 3, 10, 1),
(20, 'Viande & Poisson', 'Porc', 'Pied de porc', 'Tout est bon dans le cochon', 15, 45, 5, '2202-12-12', 420, 23, 1),
(21, 'Viande & Poisson', 'Boeuf', 'Côte de boeuf', ' ', 17.48, 30.6, 5, '2021-12-31', 420, 10, 1),
(22, 'Viande & Poisson', 'Veau', 'Tête de veau', ' ', 32, 66.6, 19, '2021-12-31', 420, 10, 1),
(23, 'Viande & Poisson', 'Lapin', 'Patte de lapin', ' ', 6.44, 30.54, 2, '2021-12-31', 420, 10, 1),
(24, 'Viande & Poisson', 'Charcuterie', 'Kabanos', ' ', 15.8, 30.62, 7, '2021-12-31', 420, 10, 1),
(25, 'Crèmerie', 'Beurre & crème', 'Crème fraiche', ' ', 2.69, 2.69, 1, '2021-12-31', 420, 10, 1),
(26, 'Crèmerie', 'Fromage', 'Saint-Nectaire', ' ', 3.3, 6.6, 1.7, '2021-12-31', 420, 10, 1),
(27, 'Crèmerie', 'Yaourt', 'Yaourt de chèvre', ' ', 8.8, 10.45, 2.5, '2021-12-31', 543, 10, 1),
(28, 'Epicerie salée', 'Pâtes & riz', 'Nouilles de riz', ' ', 1.1, 2.6, 0.23, '2021-12-31', 420, 10, 1),
(29, 'Epicerie salée', 'Légumineuses & Céréales', 'Avoine', ' ', 2.2, 1.6, 0.34, '2021-12-31', 420, 10, 1),
(30, 'Epicerie sucrée', 'Fruits secs', 'Abricot sec', ' ', 6, 8, 0.94, '2021-12-31', 420, 10, 1),
(31, 'Epicerie sucrée', 'Farine', 'Farine azyme', ' ', 2.12, 3.4, 0.7, '2021-12-31', 420, 10, 1),
(32, 'Lovely spam', 'Wonderful spam', 'Spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 3.12, 15.6, 0.1, '2021-12-31', 420, 10, 1),
(33, 'Lovely spam', 'Wonderful spam', 'Egg & spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 4.23, 15.6, 1, '2021-12-31', 420, 10, 1),
(34, 'Lovely spam', 'Wonderful spam', 'Egg bacon & spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 5.34, 15.6, 0.3, '2021-12-31', 420, 10, 1),
(35, 'Lovely spam', 'Wonderful spam', 'Egg bacon sausage & spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 6.45, 15.6, 0.8, '2021-12-31', 420, 10, 1),
(36, 'Lovely spam', 'Wonderful spam', 'Spam bacon sausage & spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 7.56, 15.6, 2, '2021-12-31', 420, 10, 1),
(37, 'Lovely spam', 'Wonderful spam', 'Spam egg spam spam bacon &spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 8.67, 15.6, 1, '2021-12-31', 420, 10, 1),
(38, 'Lovely spam', 'Wonderful spam', 'Spam spam spam spam spam spam', 'Mélange de viande et graisse de porc en boîte, communément récolté dans les boîtes mail.', 9.78, 15.6, 2, '2021-12-31', 420, 10, 1),
(39, 'Crèmerie', 'Fromage', 'Raclette', 'Quand même moins bon que de la fondue', 12, 25, 11.5, '2022-07-12', 69, 124, 5);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `bon_d_achat`
--
ALTER TABLE `bon_d_achat`
  ADD PRIMARY KEY (`ID_Bon`),
  ADD KEY `FK_ID_Consommateur_2` (`ID_Consommateur`);

--
-- Index pour la table `commande`
--
ALTER TABLE `commande`
  ADD PRIMARY KEY (`ID_Commande`),
  ADD KEY `FK_ID_Consommateur_1` (`ID_Consommateur`);

--
-- Index pour la table `consommateur`
--
ALTER TABLE `consommateur`
  ADD PRIMARY KEY (`ID_Consommateur`);

--
-- Index pour la table `contenir`
--
ALTER TABLE `contenir`
  ADD KEY `FK_ID_Produit_1` (`ID_Produit`),
  ADD KEY `FK_ID_Commande_1` (`ID_Commande`);

--
-- Index pour la table `facture`
--
ALTER TABLE `facture`
  ADD PRIMARY KEY (`ID_Facture`),
  ADD KEY `FK_ID_Commande_2` (`ID_Commande`);

--
-- Index pour la table `fournaison`
--
ALTER TABLE `fournaison`
  ADD KEY `FK_ID_Produit_2` (`ID_Produit`),
  ADD KEY `FK_ID_Fournisseur_2` (`ID_Fournisseur`);

--
-- Index pour la table `fournisseur`
--
ALTER TABLE `fournisseur`
  ADD PRIMARY KEY (`ID_Fournisseur`),
  ADD KEY `ID_Fournisseur` (`ID_Fournisseur`);

--
-- Index pour la table `lieulivraison`
--
ALTER TABLE `lieulivraison`
  ADD PRIMARY KEY (`ID_LieuLivraison`);

--
-- Index pour la table `lignefacture`
--
ALTER TABLE `lignefacture`
  ADD PRIMARY KEY (`ID_LigneFacture`),
  ADD KEY `FK_ID_Facture` (`ID_Facture`),
  ADD KEY `FK_ID_Produit_3` (`ID_Produit`);

--
-- Index pour la table `livraison`
--
ALTER TABLE `livraison`
  ADD PRIMARY KEY (`ID_Livraison`),
  ADD KEY `FK_ID_Commande_3` (`ID_Commande`),
  ADD KEY `FK_ID_LieuLivraison` (`ID_LieuLivraison`);

--
-- Index pour la table `marche`
--
ALTER TABLE `marche`
  ADD PRIMARY KEY (`ID_Marche`);

--
-- Index pour la table `participe`
--
ALTER TABLE `participe`
  ADD KEY `FK_ID_Marche` (`ID_Marche`),
  ADD KEY `FK_ID_Fournisseur_1` (`ID_Fournisseur`);

--
-- Index pour la table `produit`
--
ALTER TABLE `produit`
  ADD PRIMARY KEY (`ID_Produit`),
  ADD KEY `FK_ID_Fournisseur_3` (`ID_Fournisseur`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `bon_d_achat`
--
ALTER TABLE `bon_d_achat`
  MODIFY `ID_Bon` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `commande`
--
ALTER TABLE `commande`
  MODIFY `ID_Commande` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `consommateur`
--
ALTER TABLE `consommateur`
  MODIFY `ID_Consommateur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `facture`
--
ALTER TABLE `facture`
  MODIFY `ID_Facture` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `fournisseur`
--
ALTER TABLE `fournisseur`
  MODIFY `ID_Fournisseur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `lieulivraison`
--
ALTER TABLE `lieulivraison`
  MODIFY `ID_LieuLivraison` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `lignefacture`
--
ALTER TABLE `lignefacture`
  MODIFY `ID_LigneFacture` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `livraison`
--
ALTER TABLE `livraison`
  MODIFY `ID_Livraison` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `marche`
--
ALTER TABLE `marche`
  MODIFY `ID_Marche` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `produit`
--
ALTER TABLE `produit`
  MODIFY `ID_Produit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=247;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `bon_d_achat`
--
ALTER TABLE `bon_d_achat`
  ADD CONSTRAINT `FK_ID_Consommateur_2` FOREIGN KEY (`ID_Consommateur`) REFERENCES `consommateur` (`ID_Consommateur`);

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `FK_ID_Consommateur_1` FOREIGN KEY (`ID_Consommateur`) REFERENCES `consommateur` (`ID_Consommateur`);

--
-- Contraintes pour la table `contenir`
--
ALTER TABLE `contenir`
  ADD CONSTRAINT `FK_ID_Commande_1` FOREIGN KEY (`ID_Commande`) REFERENCES `commande` (`ID_Commande`),
  ADD CONSTRAINT `FK_ID_Produit_1` FOREIGN KEY (`ID_Produit`) REFERENCES `produit` (`ID_Produit`);

--
-- Contraintes pour la table `facture`
--
ALTER TABLE `facture`
  ADD CONSTRAINT `FK_ID_Commande_2` FOREIGN KEY (`ID_Commande`) REFERENCES `commande` (`ID_Commande`);

--
-- Contraintes pour la table `fournaison`
--
ALTER TABLE `fournaison`
  ADD CONSTRAINT `FK_ID_Fournisseur_2` FOREIGN KEY (`ID_Fournisseur`) REFERENCES `fournisseur` (`ID_Fournisseur`),
  ADD CONSTRAINT `FK_ID_Produit_2` FOREIGN KEY (`ID_Produit`) REFERENCES `produit` (`ID_Produit`);

--
-- Contraintes pour la table `lignefacture`
--
ALTER TABLE `lignefacture`
  ADD CONSTRAINT `FK_ID_Facture` FOREIGN KEY (`ID_Facture`) REFERENCES `facture` (`ID_Facture`),
  ADD CONSTRAINT `FK_ID_Produit_3` FOREIGN KEY (`ID_Produit`) REFERENCES `produit` (`ID_Produit`);

--
-- Contraintes pour la table `livraison`
--
ALTER TABLE `livraison`
  ADD CONSTRAINT `FK_ID_Commande_3` FOREIGN KEY (`ID_Commande`) REFERENCES `commande` (`ID_Commande`),
  ADD CONSTRAINT `FK_ID_LieuLivraison` FOREIGN KEY (`ID_LieuLivraison`) REFERENCES `lieulivraison` (`ID_LieuLivraison`);

--
-- Contraintes pour la table `participe`
--
ALTER TABLE `participe`
  ADD CONSTRAINT `FK_ID_Fournisseur_1` FOREIGN KEY (`ID_Fournisseur`) REFERENCES `fournisseur` (`ID_Fournisseur`),
  ADD CONSTRAINT `FK_ID_Marche` FOREIGN KEY (`ID_Marche`) REFERENCES `marche` (`ID_Marche`);

--
-- Contraintes pour la table `produit`
--
ALTER TABLE `produit`
  ADD CONSTRAINT `FK_ID_Fournisseur_3` FOREIGN KEY (`ID_Fournisseur`) REFERENCES `fournisseur` (`ID_Fournisseur`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
