CREATE TABLE IF NOT EXISTS `rs_drugsell_xp` (
    `identifier`   VARCHAR(60)  NOT NULL,
    `xp`           INT(11)      NOT NULL DEFAULT 0,
    `level`        INT(11)      NOT NULL DEFAULT 1,
    `total_sales`  INT(11)      NOT NULL DEFAULT 0,
    `total_earned` BIGINT(20)   NOT NULL DEFAULT 0,
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
