CREATE TABLE `question` (
  `id` int PRIMARY KEY,
  `text` varchar(255) NOT NULL,
  `type` ENUM ('single', 'multiple') NOT NULL,
  `topic_id` int NOT NULL,
  `image` image
);

CREATE TABLE `answer` (
  `id` int PRIMARY KEY,
  `question_id` int NOT NULL,
  `text` varchar(255) NOT NULL,
  `is_correct` boolean NOT NULL
);

CREATE TABLE `user` (
  `id` int PRIMARY KEY,
  `token` text,
  `name` text NOT NULL,
  `surname` text,
  `email` email NOT NULL,
  `type` ENUM ('student', 'professor', 'researcher', 'staff') NOT NULL,
  `affiliation_id` int NOT NULL,
  `level` int,
  `points` double
);

CREATE TABLE `affiliation` (
  `id` int PRIMARY KEY,
  `name` text NOT NULL,
  `level` ENUM ('bsc', 'msc', 'phd')
);

CREATE TABLE `quiz_answer` (
  `quiz_question_id` int,
  `answer_id` int,
  PRIMARY KEY (`quiz_question_id`, `answer_id`)
);

CREATE TABLE `topic` (
  `id` int PRIMARY KEY,
  `qr_code_link` text NOT NULL,
  `description` text
);

CREATE TABLE `content` (
  `id` int PRIMARY KEY,
  `description` text,
  `link` text,
  `date` date,
  `type` ENUM ('image', 'video', 'web_page', 'social_media', 'doc', 'music'),
  `event_id` int
);

CREATE TABLE `topic_event` (
  `topic_id` int,
  `event_id` int,
  PRIMARY KEY (`topic_id`, `event_id`)
);

CREATE TABLE `event` (
  `id` int PRIMARY KEY,
  `title` text,
  `date` date,
  `scope` ENUM ('iscte', 'nacional', 'internacional')
);

CREATE TABLE `topic_access` (
  `user_id` int,
  `topic_id` int,
  `when` timestamp NOT NULL,
  `is_scan` boolean NOT NULL,
  PRIMARY KEY (`user_id`, `topic_id`)
);

CREATE TABLE `quiz` (
  `id` int PRIMARY KEY,
  `level` int,
  `user_id` int
);

CREATE TABLE `quiz_question` (
  `id` int PRIMARY KEY,
  `question_id` int NOT NULL,
  `quiz_id` int NOT NULL
);

CREATE TABLE `level` (
  `id` int PRIMARY KEY,
  `level` int NOT NULL,
  `percent_correct` double NOT NULL,
  `topics_required` int NOT NULL,
  `trials_allowed` int NOT NULL,
  `max_points_quiz` int NOT NULL,
  `max_time_per_question` int NOT NULL,
  `num_single_questions` int NOT NULL,
  `num_multiple_questions` int NOT NULL
);

CREATE TABLE `quiz_question_trial` (
  `quiz_question_id` int,
  `trial` int,
  `start` timestamp NOT NULL,
  `finish` timestamp NOT NULL,
  PRIMARY KEY (`quiz_question_id`, `trial`)
);

ALTER TABLE `answer` ADD FOREIGN KEY (`question_id`) REFERENCES `question` (`id`);

ALTER TABLE `quiz_answer` ADD FOREIGN KEY (`answer_id`) REFERENCES `answer` (`id`);

ALTER TABLE `user` ADD FOREIGN KEY (`affiliation_id`) REFERENCES `affiliation` (`id`);

ALTER TABLE `question` ADD FOREIGN KEY (`topic_id`) REFERENCES `topic` (`id`);

ALTER TABLE `topic_access` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `topic_access` ADD FOREIGN KEY (`topic_id`) REFERENCES `topic` (`id`);

ALTER TABLE `quiz` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `quiz_question` ADD FOREIGN KEY (`quiz_id`) REFERENCES `quiz` (`id`);

ALTER TABLE `quiz_question` ADD FOREIGN KEY (`question_id`) REFERENCES `question` (`id`);

ALTER TABLE `quiz_answer` ADD FOREIGN KEY (`quiz_question_id`) REFERENCES `quiz_question` (`id`);

ALTER TABLE `quiz` ADD FOREIGN KEY (`level`) REFERENCES `level` (`id`);

ALTER TABLE `user` ADD FOREIGN KEY (`level`) REFERENCES `level` (`id`);

ALTER TABLE `quiz_question_trial` ADD FOREIGN KEY (`quiz_question_id`) REFERENCES `quiz_question` (`id`);

ALTER TABLE `topic_event` ADD FOREIGN KEY (`topic_id`) REFERENCES `topic` (`id`);

ALTER TABLE `topic_event` ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `content` ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

CREATE UNIQUE INDEX `quiz_question_index_0` ON `quiz_question` (`question_id`, `quiz_id`);

CREATE UNIQUE INDEX `quiz_question_trial_index_1` ON `quiz_question_trial` (`quiz_question_id`, `trial`);
