-- MySQL Script generated by MySQL Workbench
-- Sat May 18 20:36:22 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`GameHistory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`GameHistory` (
  `idGameHistory` INT NOT NULL AUTO_INCREMENT,
  `0row` VARCHAR(3) NOT NULL,
  `1row` VARCHAR(3) NOT NULL,
  `2row` VARCHAR(3) NOT NULL,
  `mode` VARCHAR(9) NOT NULL,
  `p1Sign` VARCHAR(1) NOT NULL,
  `p2Sign` VARCHAR(1) NOT NULL,
  `time` DATETIME NOT NULL,
  `winner` VARCHAR(9) NOT NULL,
  PRIMARY KEY (`idGameHistory`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
