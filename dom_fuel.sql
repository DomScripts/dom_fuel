-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.24-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table esxlegacy_a9e0f4.dom_fuel
CREATE TABLE IF NOT EXISTS `dom_fuel` (
  `GasStation` varchar(50) DEFAULT NULL,
  `Owner` varchar(46) DEFAULT NULL,
  `id` varchar(50) DEFAULT NULL,
  `Gas` int(255) DEFAULT NULL,
  `Money` int(255) DEFAULT NULL,
  `Price` int(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table esxlegacy_a9e0f4.dom_fuel: ~27 rows (approximately)
INSERT INTO `dom_fuel` (`GasStation`, `Owner`, `id`, `Gas`, `Money`, `Price`) VALUES
	('Grove Street', NULL, NULL, 0, 0, 0),
	('Strawberry Ave', NULL, NULL, 0, 0, 0),
	('El Rancho Blvd', NULL, NULL, 0, 0, 0),
	('Mirror Park Blvd', NULL, NULL, 0, 0, 0),
	('Popular St', NULL, NULL, 0, 0, 0),
	('Clinton Ave', NULL, NULL, 0, 0, 0),
	('North Rockford Dr - 1', NULL, NULL, 0, 0, 0),
	('West Eclipse Blvd', NULL, NULL, 0, 0, 0),
	('North Rockford Dr - 2', NULL, NULL, 0, 0, 0),
	('Calais Ave', NULL, NULL, 0, 0, 0),
	('Palomino Freeway', NULL, NULL, 0, 0, 0),
	('Innocence Blvd', NULL, NULL, 0, 0, 0),
	('Macdonald St', NULL, NULL, 0, 0, 0),
	('Lindsay Circus', NULL, NULL, 0, 0, 0),
	('Route 68 - 1', NULL, NULL, 0, 0, 0),
	('Route 68 - 2', NULL, NULL, 0, 0, 0),
	('Route 68 - 3', NULL, NULL, 0, 0, 0),
	('Route 68 - 4', NULL, NULL, 0, 0, 0),
	('Route 68 - 5', NULL, NULL, 0, 0, 0),
	('Senora Way', NULL, NULL, 0, 0, 0),
	('Senora Freeway', NULL, NULL, 0, 0, 0),
	('Alhambra Dr', NULL, NULL, 0, 0, 0),
	('Grapseed Main St', NULL, NULL, 0, 0, 0),
	('Panorama Dr', NULL, NULL, 0, 0, 0),
	('Great Ocean Hwy - 1', NULL, NULL, 0, 0, 0),
	('Great Ocean Hwy - 2', NULL, NULL, 0, 0, 0),
	('Paleto Bvld', NULL, NULL, 0, 0, 0);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
