CREATE TABLE `user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `access` CHAR(21) UNIQUE NOT NULL,
  `email` TEXT NOT NULL,
  `pw` TEXT NOT NULL,
  `salt` TEXT NOT NULL,
  `name` TEXT NOT NULL,
  `image` TEXT,
  CONSTRAINT `user_pk` PRIMARY KEY (`id`)
);

CREATE TABLE `post` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `access` CHAR(21) UNIQUE NOT NULL,
  `user` INT NOT NULL,
  `text` TEXT NOT NULL,
  `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `post_pk` PRIMARY KEY (`id`),
  CONSTRAINT `post_user_fk` FOREIGN KEY (`user`) REFERENCES user (`id`) ON DELETE CASCADE
);

CREATE TABLE `post_image` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `post` INT NOT NULL,
  `image` TEXT NOT NULL,
  CONSTRAINT `post_image_pk` PRIMARY KEY (`id`),
  CONSTRAINT `post_image_post_fk` FOREIGN KEY (`post`) REFERENCES post (`id`) ON DELETE CASCADE
);

CREATE TABLE `post_like` (
  `post` INT NOT NULL,
  `user` INT NOT NULL,
  CONSTRAINT `post_like_pk` PRIMARY KEY (`post`, `user`),
  CONSTRAINT `post_like_post_fk` FOREIGN KEY (`post`) REFERENCES post (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_like_user_fk` FOREIGN KEY (`user`) REFERENCES user (`id`) ON DELETE CASCADE
);

CREATE TABLE `post_comment` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `post` INT NOT NULL,
  `user` INT NOT NULL,
  `comment` TEXT NOT NULL,
  `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `post_comment_pk` PRIMARY KEY (`id`),
  CONSTRAINT `post_comment_post_fk` FOREIGN KEY (`post`) REFERENCES post (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_user_fk` FOREIGN KEY (`user`) REFERENCES user (`id`) ON DELETE CASCADE
);

CREATE TABLE `follow` (
  `follower` INT NOT NULL,
  `following` INT NOT NULL,
  CONSTRAINT `follow_pk` PRIMARY KEY (`follower`, `following`),
  CONSTRAINT `follow_follower_fk` FOREIGN KEY (`follower`) REFERENCES user (`id`) ON DELETE CASCADE,
  CONSTRAINT `follow_following_fk` FOREIGN KEY (`following`) REFERENCES user (`id`) ON DELETE CASCADE
);

CREATE VIEW `feed` AS (
  SELECT `user`.`id` AS `user`, `follow`.`following` AS `author`, `post`.`id` AS `post`, `post`.`access` AS `access`
  FROM `follow`, `user`, `post`
  WHERE `follow`.`follower` = `user`.`id` AND `follow`.`following` = `post`.`user`
  ORDER BY `post`.`time` DESC, `post`.`id` DESC
);
