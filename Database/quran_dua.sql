-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 25, 2019 at 10:35 AM
-- Server version: 10.1.13-MariaDB
-- PHP Version: 7.0.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `quran_dua`
--

-- --------------------------------------------------------

--
-- Table structure for table `scoredata`
--

CREATE TABLE `scoredata` (
  `ID` int(11) NOT NULL,
  `Score` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `scoredata`
--

INSERT INTO `scoredata` (`ID`, `Score`) VALUES
(1, -600),
(2, 5800),
(3, -200),
(4, 800),
(5, -400),
(6, 1800),
(7, 800),
(8, -600),
(9, 1200),
(10, -600),
(11, 14700),
(12, 0),
(13, 2700),
(14, 0),
(15, 0),
(16, 0),
(17, 4200),
(18, 0),
(19, 0),
(20, 0),
(21, 6800),
(22, 800),
(23, 0),
(24, 800),
(25, 0),
(26, 7800),
(27, 0),
(28, 0),
(29, 0),
(30, 0),
(31, 0),
(32, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `scoredata`
--
ALTER TABLE `scoredata`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `scoredata`
--
ALTER TABLE `scoredata`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
