# Table creation script for DES database
# Last edit 8/28/2022
# Authors:
# Principal investigator: Dr. Katherine Nelson
# Student Research Assistant: Haley Booth
# Consultants: Prof. Josh Gross and Prof. John Goeltz

DROP DATABASE DES;
CREATE DATABASE IF NOT EXISTS DES;
USE DES;

CREATE TABLE IF NOT EXISTS publication (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pub_name VARCHAR(100) DEFAULT NULL,
    is_book BOOL DEFAULT NULL,
    is_journal BOOL DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS citation (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_author_surname VARCHAR(80) DEFAULT NULL,
    title VARCHAR(250) DEFAULT NULL,
    pub_year YEAR DEFAULT NULL,
    first_page VARCHAR(6) DEFAULT NULL,
    last_page VARCHAR(6) DEFAULT NULL,
    DOI VARCHAR(255) DEFAULT NULL,
    publication_id INT,
    FOREIGN KEY (publication_id)
        REFERENCES publication (id)
);

CREATE TABLE IF NOT EXISTS editor (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    editor_name VARCHAR(100) NOT NULL DEFAULT 'Needs editor name',
    is_also_reviewer BOOL
);

/* salt table is completed for each ionic constituent (is_salt = TRUE in constituent table)
*/
CREATE TABLE IF NOT EXISTS salt (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cation_name VARCHAR(200) DEFAULT NULL,
    cation_mass_amu FLOAT DEFAULT NULL,
    cation_formula VARCHAR(2500) DEFAULT NULL,
    cation_charge TINYINT DEFAULT NULL,
    anion_name VARCHAR(200) DEFAULT NULL,
    anion_mass_amu FLOAT DEFAULT NULL,
    anion_formula VARCHAR(2500) DEFAULT NULL,
    anion_charge TINYINT DEFAULT NULL,
    editor_id INT,
    FOREIGN KEY (editor_id)
        REFERENCES editor (id),
    reviewer_id INT,
    FOREIGN KEY (reviewer_id)
        REFERENCES editor (id)
);
describe salt;

CREATE TABLE IF NOT EXISTS hbd_groups (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    citation_id INT,
    FOREIGN KEY (citation_id)
        REFERENCES citation (id),
    editor_id INT,
    FOREIGN KEY (editor_id)
        REFERENCES editor (id),
    reviewer_id INT,
    FOREIGN KEY (reviewer_id)
        REFERENCES editor (id),
    alcohol_aliphatic TINYINT DEFAULT NULL,
    alcohol_aromatic TINYINT DEFAULT NULL,
    aromatic TINYINT DEFAULT NULL,
    carboxylic_acid TINYINT DEFAULT NULL,
    amide TINYINT DEFAULT NULL,
    amine_primary TINYINT DEFAULT NULL,
    amine_secondary TINYINT DEFAULT NULL,
    amine_tertiary TINYINT DEFAULT NULL,
    amine_quaternary TINYINT DEFAULT NULL,
    amine_aromatic TINYINT DEFAULT NULL,
    aldimine_primary TINYINT DEFAULT NULL,
    ketimine_primary TINYINT DEFAULT NULL,
    imide TINYINT DEFAULT NULL,
    oxime TINYINT DEFAULT NULL,
    phenol TINYINT DEFAULT NULL,
    phosphonium TINYINT DEFAULT NULL,
    other VARCHAR(200)
);
/* 
constituent table describes each chemical involved in a reported deep eutectic mixture.
Names and formulas longer than the specified sizes will have to be NULL until amino acids, 
nucleic acids, etc are incorporated into the database design. Common names will be relied on
where necessary.
Hydrogen bond donor is abbreviated HBD.
Cation and anion info is only included if is_salt is TRUE.
See data dictionary for further details.
*/
-- would have called this table component, but that is a MySQL keyword. 

CREATE TABLE IF NOT EXISTS constituent (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    common_name VARCHAR(200) DEFAULT NULL,
    other_name VARCHAR(200) DEFAULT NULL,
    preferred_iupac VARCHAR(5000) DEFAULT NULL,
    cas_number VARCHAR(12) DEFAULT NULL,
    formula VARCHAR(5000) DEFAULT NULL,
    melting_point_K FLOAT DEFAULT NULL,
    is_decomp BOOL,
    mass_amu FLOAT DEFAULT NULL,
    volume_A3 FLOAT DEFAULT NULL,
    num_conformations TINYINT DEFAULT NULL,
    net_dipole_Db FLOAT DEFAULT NULL,
    is_HBD BOOL DEFAULT NULL,
    hbd_groups_id INT DEFAULT NULL,
    FOREIGN KEY (hbd_groups_id)
        REFERENCES hbd_groups (id),
    is_salt BOOL,
    salt_id INT DEFAULT NULL,
    FOREIGN KEY (salt_id)
        REFERENCES salt (id),
    NFPA_health TINYINT DEFAULT NULL,
    NFPA_flammability TINYINT DEFAULT NULL,
    NFPA_instability TINYINT DEFAULT NULL,
    NFPA_special TINYINT DEFAULT NULL
);

/* RT stands for room temperature */

CREATE TABLE IF NOT EXISTS eutectic (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    constituent1_id INT,
    FOREIGN KEY (constituent1_id)
        REFERENCES constituent (id),
    constituent2_id INT,
    FOREIGN KEY (constituent2_id)
        REFERENCES constituent (id),
    editor_id INT,
    FOREIGN KEY (editor_id)
        REFERENCES editor (id),
    reviewer_id INT,
    FOREIGN KEY (reviewer_id)
        REFERENCES editor (id),
    mole_fraction_HBD FLOAT,
    mole_fraction_salt FLOAT,
    melting_point_K FLOAT,
    mp_method VARCHAR(100),
    viscosity_RT FLOAT,
    conductivity_RT_mScm FLOAT,
    density_RT_gmL FLOAT,
    density_method VARCHAR(100),
    Ea_viscosity_cP FLOAT,
    Ea_conductivity_kJmol FLOAT
);

/* to include non-eutectic mixtures for comparison */
CREATE TABLE IF NOT EXISTS non_eutectic (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    constituent1_id INT,
    FOREIGN KEY (constituent1_id)
        REFERENCES constituent (id),
    constituent2_id INT,
    FOREIGN KEY (constituent2_id)
        REFERENCES constituent (id),
    citation_id INT,
    FOREIGN KEY (citation_id)
        REFERENCES citation (id),
    editor_id INT,
    FOREIGN KEY (editor_id)
        REFERENCES editor (id),
    forms_solution BOOL DEFAULT NULL,
    depresses_Tf BOOL DEFAULT NULL,
    Tf_decrease_K FLOAT DEFAULT NULL
);