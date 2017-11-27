DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `user_id` varchar(32) NOT NULL,
  `wetchat_id` varchar(32) NOT NULL,
  `nickName` varchar(120),
  `avatarUrl` text,
  `gender` int(3) DEFAULT '0',
  `province` varchar(120),
  `city` varchar(120),
  `country` varchar(120),
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `user_location`;

CREATE TABLE `user_location` (
  `user_id` varchar(32) NOT NULL,
  `location_type` int(3) DEFAULT '0',
  `longitude` varchar(32),
  `latitude` varchar(32),
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`user_id`, `location_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `user_area`;

CREATE TABLE `user_area` (
  `user_id` varchar(32) NOT NULL,
  `location_date` date NOT NULL,
  `area` float DEFAULT '0',
  `line_color` varchar(32),
  `include_user` varchar(32),
  PRIMARY KEY (`user_id`, `location_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
