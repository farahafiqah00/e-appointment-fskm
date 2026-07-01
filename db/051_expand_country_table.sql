-- 051: Expand country table to align with nationality lookup

INSERT INTO country (name, iso_code) VALUES
-- SE Asia
('Malaysia',        'MY'),
('Brunei',          'BN'),
('Singapore',       'SG'),
('Indonesia',       'ID'),
('Thailand',        'TH'),
('Philippines',     'PH'),
('Vietnam',         'VN'),
('Cambodia',        'KH'),
('Myanmar',         'MM'),
('Laos',            'LA'),
-- East Asia
('China',           'CN'),
('Japan',           'JP'),
('South Korea',     'KR'),
-- South Asia
('India',           'IN'),
('Pakistan',        'PK'),
('Bangladesh',      'BD'),
('Sri Lanka',       'LK'),
('Nepal',           'NP'),
-- Middle East
('Yemen',           'YE'),
('Saudi Arabia',    'SA'),
('Iraq',            'IQ'),
('Jordan',          'JO'),
('Libya',           'LY'),
('Egypt',           'EG'),
('Oman',            'OM'),
('Kuwait',          'KW'),
('Bahrain',         'BH'),
-- Africa
('Nigeria',         'NG'),
('Ghana',           'GH'),
('Kenya',           'KE'),
('Tanzania',        'TZ'),
('Sudan',           'SD'),
('Somalia',         'SO'),
('Zimbabwe',        'ZW'),
('South Africa',    'ZA'),
-- Western
('United Kingdom',  'GB'),
('United States',   'US'),
('Australia',       'AU'),
('Canada',          'CA'),
('Germany',         'DE'),
('France',          'FR'),
('Netherlands',     'NL'),
('Sweden',          'SE'),
('Norway',          'NO'),
('New Zealand',     'NZ')
ON DUPLICATE KEY UPDATE iso_code = VALUES(iso_code);
