-- 049: nationality lookup table + add nationality column to candidate

CREATE TABLE IF NOT EXISTS nationality (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL UNIQUE,
  sort_order INT          NOT NULL DEFAULT 999
) ENGINE=InnoDB;

INSERT INTO nationality (name, sort_order) VALUES
-- Malaysia first
('Malaysian',      1),
-- ASEAN
('Bruneian',      10),
('Singaporean',   11),
('Indonesian',    12),
('Thai',          13),
('Filipino',      14),
('Vietnamese',    15),
('Cambodian',     16),
('Myanmar',       17),
('Laotian',       18),
-- South & East Asia
('Chinese',       20),
('Japanese',      21),
('Korean',        22),
('Indian',        23),
('Pakistani',     24),
('Bangladeshi',   25),
('Sri Lankan',    26),
('Nepalese',      27),
-- Middle East
('Yemeni',        30),
('Saudi Arabian', 31),
('Iraqi',         32),
('Jordanian',     33),
('Libyan',        34),
('Egyptian',      35),
('Omani',         36),
('Kuwaiti',       37),
('Bahraini',      38),
-- Africa
('Nigerian',      40),
('Ghanaian',      41),
('Kenyan',        42),
('Tanzanian',     43),
('Sudanese',      44),
('Somali',        45),
('Zimbabwean',    46),
('South African', 47),
-- Western
('British',       50),
('American',      51),
('Australian',    52),
('Canadian',      53),
('German',        54),
('French',        55),
('Dutch',         56),
('Swedish',       57),
('Norwegian',     58),
('New Zealander', 59),
('Other',         999)
ON DUPLICATE KEY UPDATE sort_order = VALUES(sort_order);

-- Add nationality column to candidate (fixes HTTP 500 on view/edit)
ALTER TABLE candidate
  ADD COLUMN IF NOT EXISTS nationality VARCHAR(100) NULL AFTER contact_email;
