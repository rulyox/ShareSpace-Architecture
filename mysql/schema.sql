CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    access CHAR(21) UNIQUE NOT NULL,
    email TEXT NOT NULL,
    pw TEXT NOT NULL,
    salt TEXT NOT NULL,
    name TEXT NOT NULL,
    image TEXT,

    CONSTRAINT users_pk PRIMARY KEY (id)
);

CREATE TABLE post (
    id INT NOT NULL AUTO_INCREMENT,
    access CHAR(21) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    text TEXT NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT post_pk PRIMARY KEY (id),
    CONSTRAINT post_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE post_image (
    id INT NOT NULL AUTO_INCREMENT,
    post_id INT NOT NULL,
    image TEXT NOT NULL,

    CONSTRAINT post_image_pk PRIMARY KEY (id),
    CONSTRAINT post_image_post_fk FOREIGN KEY (post_id) REFERENCES post (id) ON DELETE CASCADE
);

CREATE TABLE post_like (
    post_id INT NOT NULL,
    user_id INT NOT NULL,

    CONSTRAINT post_like_pk PRIMARY KEY (post_id, user_id),
    CONSTRAINT post_like_post_fk FOREIGN KEY (post_id) REFERENCES post (id) ON DELETE CASCADE,
    CONSTRAINT post_like_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE post_comment (
    id INT NOT NULL AUTO_INCREMENT,
    access CHAR(21) UNIQUE NOT NULL,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT post_comment_pk PRIMARY KEY (id),
    CONSTRAINT post_comment_post_fk FOREIGN KEY (post_id) REFERENCES post (id) ON DELETE CASCADE,
    CONSTRAINT post_comment_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE follow (
    follower_id INT NOT NULL,
    following_id INT NOT NULL,

    CONSTRAINT follow_pk PRIMARY KEY (follower_id, following_id),
    CONSTRAINT follow_follower_fk FOREIGN KEY (follower_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT follow_following_fk FOREIGN KEY (following_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE VIEW feed AS (
    SELECT users.id AS user_id, follow.following_id AS author_id, post.id AS post_id, post.access AS access
    FROM users
        INNER JOIN follow ON follow.follower_id = users.id
        INNER JOIN post ON post.user_id = follow.following_id
    ORDER BY post.time DESC, post.id DESC
);
