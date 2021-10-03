/*
 Составить общее текстовое описание БД и решаемых ею задач;
 https://milano-group.ru/dimitrovgrad
 Воспроизведение подобия основ базы данных сайта пиццерии милано.
 SELECT VERSION()
 */

DROP DATABASE IF EXISTS pizzeria_milano;
CREATE DATABASE pizzeria_milano;
USE pizzeria_milano;

-- profiles
CREATE TABLE profiles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  gender ENUM('male', 'female') NOT NULL,
  birthday DATE NOT NULL,
  photo_id INT UNSIGNED DEFAULT NULL,
  email VARCHAR(255) NOT NULL,
  phone CHAR(10) NOT NULL,
  password_hash CHAR(65) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE INDEX email_unique_idx (email),
  UNIQUE INDEX phone_unique_idx (phone),
  UNIQUE INDEX index_profiles_id (id)
) ENGINE=InnoDB COMMENT = 'Покупатели';

-- Триггер проверки корректности даты рождения
DROP TRIGGER IF EXISTS check_birthday_before_insert;
DROP TRIGGER IF EXISTS check_birthday_before_update;

DELIMITER //

CREATE TRIGGER check_birthday_before_insert BEFORE INSERT ON profiles
FOR EACH ROW
    BEGIN
        IF NEW.birthday >= CURRENT_DATE() THEN
            SIGNAL SQLSTATE '42210' SET MESSAGE_TEXT = 'Вставка отменена. День рождения должен быть в прошлом!';
        END IF;
END//

CREATE TRIGGER check_birthday_before_update BEFORE UPDATE ON profiles
FOR EACH ROW
    BEGIN
        IF NEW.birthday >= CURRENT_DATE() THEN
            SIGNAL SQLSTATE '42211' SET MESSAGE_TEXT = 'Обновление отменено. День рождения должен быть в прошлом!';
        END IF;
END//

DELIMITER ;
-- Заполнение таблицы profiles данными
INSERT profiles (first_name, last_name, gender, birthday, email, phone, password_hash) VALUES
    ('Леонид', 'Агутин', 'male', '1988-11-02', 'agutin@gmail.com', '9212223334', '-5040614928146711972'),
    ('Владимир', 'Путин', 'male', '1952-10-07', 'putin@gmail.com', '9004577888', '-1862718006077222736'),
    ('Валера', 'Чистяков', 'male', '1993-10-15', 'valera93@gmail.com', '9067066721', '-6401788670187638380'),
    ('Ирина', 'Владимировна', 'female', '1995-03-27', 'irisha95@gmail.com', '9047834538', '-5079876707756535076'),
    ('Максим', 'Петров', 'male', '1985-07-09', 'petrov8511@gmail.com', '9266735689', '-5937775057595984779'),
    ('Светлана', 'Юрьевна', 'female', '1994-09-21', 'svetkanaf4@gmail.com', '9014583478', '-7953843347713124911'),
    ('Рома', 'Попов', 'male', '1986-06-04', 'sdgfdg@mail.ru', '9064594321', '4074509406830680038'),
    ('Иван', 'Кувалдин', 'male', '1989-10-12', 'speedivan89@yandex.ru', '9969883339', '6774888379812783261'),
    ('Екатерина', 'Толстолобова', 'female', '1990-11-23', 'omuhajall-8457@gmail.com', '9027742202', '-9173652187872399425'),
    ('Дима', 'Сухарев', 'male', '1979-03-17', 'emility7946@gmail.com', '9370685229', '8014127907929121917'),
    ('Кристина', 'Богомолова', 'female', '1995-05-16', 'ronnerafe94@yandex.ru', '9695383610', '775100208209804549'),
    ('Татьяна', 'Игоревна', 'female', '1996-08-06', 'ycuvep96puf@gmail.com', '9206025494', '3750086720365832664'),
    ('Богдан', 'Романчук', 'male', '1981-02-14', '81movasocette@mail.ru', '9180071532', '4512768734478280099'),
    ('Алексей', 'Резников', 'male', '1987-04-05', 'ellufirrotto@yandex.ru', '9189223642', '5114471505986331064');
-- SELECT * FROM profiles;
-- Добавление пользователя через процедуру и транзакцию
DROP PROCEDURE IF EXISTS sp_add_profile;
DELIMITER //
    CREATE PROCEDURE sp_add_profile (
    first_name VARCHAR(255), last_name VARCHAR(255),
    gender ENUM('male', 'female'), birthday DATE,
    email VARCHAR(255),
    phone CHAR(10), password_hash CHAR(65),
    OUT tran_result VARCHAR(255))
BEGIN
   DECLARE tran_rollback BOOL DEFAULT 0;
   DECLARE code varchar(255);
   DECLARE error_string varchar(255);
   DECLARE last_user_id int;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
BEGIN
    SET tran_rollback = 1;
        GET stacked DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    SET tran_result := CONCAT(code, ': ', error_string);
    END;

   START TRANSACTION;
   INSERT profiles (first_name, last_name, gender, birthday, email, phone, password_hash) VALUES
   (first_name, last_name, gender, birthday, email, phone, password_hash);

   IF tran_rollback THEN
       ROLLBACK;
   ELSE
       SET tran_result := 'luck';
       COMMIT;
       END IF;
   END //
DELIMITER ;

CALL sp_add_profile('Петр', 'Иванович', 'male', '1955-10-17', 'petr_ivanovich55@yandex.ru', '9160061532', '-9173652187872399425', @tran_result);
CALL sp_add_profile('Дмитрий', 'Анатольевич', 'male', '1965-09-14', 'bear_rf@mail.ru', '9997777777', '4512768734478280099', @tran_result);
-- SELECT @tran_result;

-- addresses
DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    profile_id BIGINT UNSIGNED NOT NULL,
    district VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    house_number INT NOT NULL,
    private_house ENUM('True', 'False') NOT NULL,
    apartment_number INT NOT NULL,
    CONSTRAINT fk_addresses_profile FOREIGN KEY (profile_id) REFERENCES profiles (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    INDEX index_addresses_profile_id (profile_id),
    UNIQUE INDEX index_addresses_id (id)
) ENGINE=InnoDB COMMENT = 'Адреса пользователей';

INSERT addresses (profile_id, district, street, house_number, private_house, apartment_number) VALUES
    ('1', 'Соцгород', 'Ленина', '22', 'True', '0'),
    ('2', 'Порт', 'Автостроителей', '37', 'False', '88'),
    ('3', 'Порт', 'Автостроителей', '39', 'False', '27'),
    ('4', 'Старый город', 'Гагарина', '50', 'True', '0'),
    ('5', 'Химмаш', 'Куйбышева', '250', 'False', '12'),
    ('6', 'Соцгород', 'Ленина', '20', 'True', '0'),
    ('7', 'Автозаводской', 'Московская', '68', 'False', '8'),
    ('8', 'Березовая роща', 'Суворова', '32', 'True', '0'),
    ('9', 'Первомайский', 'Победы', '28', 'False', '34'),
    ('10', 'Порт', 'Автостроителей', '27', 'False', '64'),
    ('11', 'Олимп', 'Алтайская', '126', 'True', '0'),
    ('12', 'Соцгород', 'Ленина', '9', 'False', '45'),
    ('13', 'Зайцев поселок', 'Тимрязева', '42', 'False', '62'),
    ('14', 'Осиновая роща', '9-я линия', '18', 'False', '46'),
    ('2', 'Порт', 'Победы', '53', 'True', '0'),
    ('15', 'Автозаводской', 'Московская', '69', 'False', '7'),
    ('16', 'Тверской', 'Вознесенский пер.', '18', 'True', '0');
-- SELECT * FROM addresses;


-- catalogs
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(65) UNIQUE COMMENT 'Название раздела',
    description TEXT DEFAULT NULL COMMENT 'Краткое описание товаров, которые можно найти в данной рубрике'
) ENGINE=InnoDB COMMENT = 'Разделы пиццерии';

INSERT catalogs (name, description) VALUES
    ('pizza_circle', 'Пицца целая'), -- 1
    ('drink', 'Напитки лимонад, чай, кофе, коктейль, горячий шоколад'), -- 2
    ('other', 'Все что угодно'), -- 3
    ('soup', 'Различные супы'), -- 4
    ('salad', 'Салаты'), -- 5
    ('spaghetti', 'Спагетти'), -- 6
    ('pie', 'Пироги'), -- 7
    ('pizza_portion', 'Порция пиццы'); -- 8
-- SELECT * FROM catalogs;


-- photos
CREATE TABLE photos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    catalog_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    file_name VARCHAR(255) DEFAULT 'name_photo',
    file_size BIGINT UNSIGNED DEFAULT 100,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_photos_catalogs FOREIGN KEY (catalog_id) REFERENCES catalogs (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_photos_id (id)
) ENGINE=InnoDB COMMENT = 'Изображение продукта, только фото' ;
-- SELECT * FROM photos;


-- pizza_circle
DROP TABLE IF EXISTS pizza_circle;
CREATE TABLE pizza_circle (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE COMMENT 'Название блюда',
    description TEXT DEFAULT NULL COMMENT 'Описание',
    gram_weight INT UNSIGNED NOT NULL,
    price DECIMAL COMMENT 'Цена',
    catalog_id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pizza_circle_catalogs FOREIGN KEY (catalog_id) REFERENCES catalogs (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE INDEX index_pizza_circle_id (id)
) ENGINE=InnoDB COMMENT = 'Позиции блюда, целая пицца (круг)' ;

-- Триггер для таблицы photos
DROP TRIGGER IF EXISTS filling_in_the_photo_table_pizza_circle;
DELIMITER //

CREATE TRIGGER filling_in_the_photo_table_pizza_circle AFTER INSERT ON pizza_circle
    FOR EACH ROW
    BEGIN
        INSERT photos (catalog_id, product_id, file_name)
        VALUES (NEW.catalog_id, NEW.id, NEW.name);
    end //
DELIMITER ;


INSERT pizza_circle (name, description, gram_weight, price, catalog_id) VALUES
    ('Адриатика', 'Филе лосося, помидора свежая, маслины, сыр, соус Маджорио', '1275', '760', '1'),
    ('Асоломио', 'Карбонад, грибы шампиньоны (конс.), перец болгарский, сыр, соус Маджорио, соус Милано', '1380', '560', '1'),
    ('Балканская', 'Грудинка копченая, грибы шампиньоны (конс.), сыр, соус Маджорио, соус Милано', '1285', '560', '1'),
    ('Венеция', 'Филе куриной грудки, грибы шампиньоны (конс.), сыр, соус Маджорио, соус Милано', '1310', '560', '1'),
    ('Виктория', 'Филе куриной грудки, бекон, перец болгарский, лук жареный, сыр, соус Маджорио, соус Милано', '1360', '672', '1'),
    ('Гавайская', 'Филе куриной грудки, ананасы (конс.), перец болгарский, сыр, соус Маджорио, соус Милано', '1370', '560', '1'),
    ('Диана', 'Карбонад, охотничьи колбаски, помидора свежая, грибы шампиньоны (конс.), сыр, соус Маджорио, соус Милано, базилик', '1403', '600', '1'),
    ('Европейская', 'Сервелат, карбонад, филе куриной грудки, ветчина, перец болгарский, сыр, соус Маджорио, соус Милано', '1330', '600', '1'),
    ('Загадка', 'Креветки тигровые, ананасы (конс.), сыр, соус Маджорио, соус Милано', '1250', '800', '1'),
    ('Королевская', 'Карбонад, сервелат, шампиньоны (конс.), помидора свежая, перец болгарский, маслины, сыр, соус Маджорио', '1455', '640', '1'),
    ('Марио', 'Сервелат, ветчина, сыр, соус Маджорио, соус Милано', '1280', '560', '1'),
    ('Маргарита+', 'Помидора свежая, шампиньоны (конс.), сыр, соус Маджорио, соус Милано', '1310', '488', '1'),
    ('Мексика', 'Фарш жареный, фасоль (конс.), шампиньоны (конс.), перец болгарский, помидора свежая, огурцы (конс.), сыр, соус Маджорио, соус Милано, перец чили', '1510', '560', '1'),
    ('Милано', 'Сервелат, ветчина, шампиньоны (конс.), помидора свежая, сыр, соус Маджорио', '1370', '600', '1'),
    ('Морская', 'Филе лосося, креветки, кальмары, крабовые палочки, помидора свежая, маслины, сыр, соус Маджорио, соус Милано', '1300', '720', '1'),
    ('Мужская', 'Сервелат, ветчина, карбонад, охотничьи колбаски, филе куриной грудки, маслины, сыр, соус Маджорио, соус Милано', '1285', '624', '1'),
    ('Оригинальная', 'Филе куриной грудки, помидора свежая, баклажан, сыр, соус Маджорио, соус Милано, зелень, чеснок', '1335', '544', '1'),
    ('Пивная', 'Охотничьи колбаски, огурцы (конс.), лук репчатый, сыр, соус Маджорио, соус Милано, горчица', '1300', '560', '1'),
    ('Пикантная', 'Сервелат, помидора свежая, сыр, соус Маджорио, соус Милано, зелень, чеснок', '1215', '544', '1'),
    ('Цезарь', 'Филе куриной грудки, помидора свежая, капуста пекинская, сыр, соус Маджорио, соус Цезарь, орегано', '1388', '560', '1'),
    ('Римская', 'Охотничьи колбаски, грудинка копченая, помидора свежая, капуста пекинская, сыр, соус Маджорио, горчица, мед', '1295', '560', '1'),
    ('Пирог «Флоренция»', 'Картофель, опята (конс.), лук репчатый, сыр, майонез', '1404', '420', '7');
-- SELECT * FROM pizza_circle;


-- pizza_portion
DROP TABLE IF EXISTS pizza_portion;
CREATE TABLE pizza_portion (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_in_pizza_circle INT UNSIGNED NOT NULL,
    gram_weight INT UNSIGNED NOT NULL,
    price DECIMAL COMMENT 'Цена',
    catalog_id INT UNSIGNED NOT NULL DEFAULT 8,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_id_is_pizza_circle FOREIGN KEY (id_in_pizza_circle) REFERENCES pizza_circle (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pizza_portion_catalogs FOREIGN KEY (catalog_id) REFERENCES catalogs (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_pizza_portion_id (id)
) ENGINE=InnoDB COMMENT = 'Позиции блюда, порция пиццы (кусочек)' ;


-- Триггер для таблицы photos
DROP TRIGGER IF EXISTS filling_in_the_photo_table_pizza_portion;
DELIMITER //

CREATE TRIGGER filling_in_the_photo_table_pizza_portion AFTER INSERT ON pizza_portion
    FOR EACH ROW
    BEGIN
        INSERT photos (catalog_id, product_id)
        VALUES (NEW.catalog_id, NEW.id);
    end //
DELIMITER ;


INSERT pizza_portion (id_in_pizza_circle, gram_weight, price) VALUES
    ('1' ,'159', '95'),
    ('2', '173', '70'),
    ('3', '161', '70'),
    ('4', '164', '70'),
    ('5', '170', '84'),
    ('6', '171', '70'),
    ('7', '175', '75'),
    ('8', '166', '75'),
    ('9', '156', '100'),
    ('10', '182', '80'),
    ('11', '160', '70'),
    ('12', '164', '61'),
    ('13', '189', '70'),
    ('14', '171', '75'),
    ('15', '163', '90'),
    ('16', '161', '78'),
    ('17', '169', '68'),
    ('18', '163', '70'),
    ('19', '153', '68'),
    ('20', '174', '70'),
    ('21', '162', '70'),
    ('22', '234', '70');
-- SELECT * FROM pizza_portion;

# SELECT pizza_portion.id, pizza_circle.name, pizza_circle.description, pizza_portion.gram_weight, pizza_portion.price
# FROM pizza_portion
# INNER JOIN
#     pizza_circle ON pizza_portion.id_in_pizza_circle = pizza_circle.id;

-- beverages (напитки)
DROP TABLE IF EXISTS beverages;
CREATE TABLE beverages (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    volume_milliliters INT UNSIGNED NOT NULL,
    price DECIMAL NOT NULL,
    catalog_id INT UNSIGNED NOT NULL DEFAULT 2,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_beverages_catalogs FOREIGN KEY (catalog_id) REFERENCES catalogs (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_beverages_id (id)
) ENGINE=InnoDB COMMENT = 'Позиции напитков' ;


-- Триггер для таблицы photos
DROP TRIGGER IF EXISTS filling_in_the_photo_table_beverages;
DELIMITER //

CREATE TRIGGER filling_in_the_photo_table_beverages AFTER INSERT ON beverages
    FOR EACH ROW
    BEGIN
        INSERT photos (catalog_id, product_id, file_name)
        VALUES (NEW.catalog_id, NEW.id, NEW.name);
    end //
DELIMITER ;


INSERT beverages (name, description, volume_milliliters, price) VALUES
    ('Пепси в ассорт. (розлив)', '_', '500', '85'),
    ('Коктейль «Милано»', 'Коктейль для взбивания, сливки, сироп , мороженое', '210', '85'),
    ('Молочный коктейль с шоколадной крошкой', 'Молоко, мороженое, шоколадная крошка', '210', '70'),
    ('Молочный Коктейль', 'Молоко, мороженое', '200', '70'),
    ('Чай «Гринфилд» с сахаром', '_', '250', '20'),
    ('Чай «Гринфилд» с сахаром, лимоном', '_', '250', '23'),
    ('Кофе Эспрессо', 'Кофе зерновой, сахар', '75', '70'),
    ('Кофе Американо', 'Кофе зерновой, сахар', '150', '70'),
    ('Кофе Капучино', 'Кофе зерновой, сливки, сахар', '150', '70'),
    ('Горячий шоколад', 'Шоколад', '150', '70');
-- SELECT * FROM beverages;

-- salads_and_hot_dishes (салаты и горячие блюда)
DROP TABLE IF EXISTS salads_and_hot_dishes;
CREATE TABLE salads_and_hot_dishes (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    gram_weight INT UNSIGNED NOT NULL,
    price DECIMAL NOT NULL,
    catalog_id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_salads_and_hot_dishes_catalogs FOREIGN KEY (catalog_id) REFERENCES catalogs (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_salads_and_hot_dishes_id (id)
) ENGINE=InnoDB COMMENT = 'Позиции салатов' ;


-- Триггер для таблицы photos
DROP TRIGGER IF EXISTS filling_in_the_photo_table_salads_and_hot_dishes;
DELIMITER //

CREATE TRIGGER filling_in_the_photo_table_salads_and_hot_dishes AFTER INSERT ON salads_and_hot_dishes
    FOR EACH ROW
    BEGIN
        INSERT photos (catalog_id, product_id, file_name)
        VALUES (NEW.catalog_id, NEW.id, NEW.name);
    end //
DELIMITER ;


INSERT salads_and_hot_dishes (name, description, gram_weight, price, catalog_id) VALUES
    ('«Айсберг»', 'Огурец свежий, яйцо куриное отварное, кальмар отварной, зеленый горошек, зелень, майонез', '172', '125', '5'),
    ('«Английский»', 'Филе куриной грудки, яйцо отварное, шампиньоны (конс.), огурцы (конс.), майонез, зелень', '192', '110', '5'),
    ('«Винегрет»', 'Картофель отварной, свекла, морковь, огурцы (конс.), зеленый горошек, зелень, масло растительное', '150', '55', '5'),
    ('«Греческий»', 'Помидора свежая, перец болгарский, огурец свежий, сыр, маслины, масло растительное, зелень', '124', '75', '5'),
    ('«Идеал»', 'Ветчина, сыр, свежий огурец, кукуруза (конс.), маслины, майонез, зелень', '154', '90', '5'),
    ('«Идиллия»', 'Ветчина, фасоль (конс.), огурцы (конс.), яйцо отварное, сухарики, майонез, зелень', '158', '95', '5'),
    ('«Морской»', 'Крабовые палочки, креветки, яйцо отварное, кукуруза (конс.), огурец свежий, майонез, зелень', '152', '85', '5'),
    ('«Мужская мечта»', 'Ветчина, филе куриной грудки, опята (конс.), яйцо отварное, лук репчатый, майонез, зелень.', '177', '120', '5'),
    ('«Оливье»', 'Ветчина, картофель отварной, морковь отварная, яйцо отварное, огурцы (конс.), зеленый горошек (конс.), майонез, зелень', '150', '65', '5'),
    ('«Цезарь»', 'Капуста пекинская, помидора свежая, сухарики, сыр пармезан, соус Цезарь', '185', '125', '5'),
    ('С грибным соусом', 'Спагетти, шампиньоны (конс.), лук репчатый, майонез, сыр, зелень', '300', '95', '6'),
    ('С охотничьими колбасками', 'Спагетти, охотничьи колбаски, лук репчатый, помидоры, перец болгарский, чеснок', '285', '110', '6'),
    ('С фаршем', 'Спагетти, фарш мясной жареный, лук репчатый, сыр, соус Милано', '320', '120', '6'),
    ('В хмельном соусе', 'Спагетти, филе куриной грудки, шампиньоны (конс.), сыр, соус Маджорио', '295', '110', '6'),
    ('С чесночным соусом', 'Спагетти, филе куриной грудки, шампиньоны (конс.), сыр, майонез, чеснок', '290', '110', '6'),
    ('Борщ', 'Филе куриной грудки, капуста белокачанная, свекла, картофель, морковь, перец болгарский, лук репчатый, масло растительное, томатная паста, зелень', '350', '80', '4'),
    ('Лапша куриная', 'Филе куриной грудки, картофель, морковь, лук репчатый, лапша, масло растительное, зелень', '350', '70', '4'),
    ('Солянка сборная мясная', 'Ветчина, карбонад, сервелат, картофель, огурцы маринованные, маслины, лук репчатый, масло растительное, томатная паста', '350', '110', '4'),
    ('Суп легкий', 'Филе куриной грудки, морковь, яйцо отварное, сухарики чесночные, зелень', '350', '65', '4'),
    ('Тигровые креветки в темпуре', 'Креветки тигровые, кляр, соус терияки, спайс соус', '250', '300', '3');
-- SELECT * FROM salads_and_hot_dishes;


-- discounts (скидки)
DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  profile_id BIGINT UNSIGNED,
  promo_code VARCHAR(255) DEFAULT 'DatBoy',
  discount FLOAT UNSIGNED DEFAULT '10' COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_discounts_profiles FOREIGN KEY (profile_id) REFERENCES profiles (id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE INDEX index_discounts_id (id)
) ENGINE=InnoDB COMMENT = 'Скидки';
-- SELECT * FROM discounts;


-- orders (заказы)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    profile_id BIGINT UNSIGNED NOT NULL,
    status_order ENUM('queue', 'executed', 'canceled', 'saved') NOT NULL COMMENT 'в очереди, исполнен, отменен, сохранен на будущее',
    wish TEXT DEFAULT NULL COMMENT 'Пожелание (комментарий) к заказу',
    payment_method ENUM('non-cash', 'cash') NOT NULL,
    order_price DECIMAL UNSIGNED,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_profiles FOREIGN KEY (profile_id) REFERENCES profiles (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_orders_order_id (id)
) ENGINE=InnoDB COMMENT = 'Заказы' ;


-- Триггер для таблицы discounts
DROP TRIGGER IF EXISTS filling_in_the_discount_table;
DELIMITER //

CREATE TRIGGER filling_in_the_discount_table AFTER INSERT ON orders
    FOR EACH ROW
    BEGIN
        INSERT discounts (profile_id, started_at)
        VALUES (NEW.profile_id, NEW.created_at);
    end //
DELIMITER ;


INSERT orders (profile_id, payment_method, status_order) VALUES
    ('1', 'non-cash', 'queue'), ('2', 'non-cash', 'queue'), ('3', 'non-cash', 'executed'), ('4', 'cash', 'executed'), ('5', 'cash', 'canceled'),
    ('6', 'cash', 'executed'), ('7', 'non-cash', 'queue'), ('8', 'cash', 'saved'), ('9', 'cash', 'canceled'), ('10', 'non-cash', 'canceled'),
    ('11', 'cash', 'executed'), ('12', 'non-cash', 'saved'), ('14', 'non-cash', 'queue');
INSERT orders (profile_id, status_order, wish, payment_method) VALUES
    ('4', 'queue', 'Побыстрее, в прошлый раз ждал полдня', 'non-cash'), ('9', 'queue', 'побольше паприки, получше разогрейте', 'cash'),
    ('12', 'executed', 'жду', 'non-cash'), ('3', 'saved', 'получше упакуйте', 'non-cash'), ('11', 'canceled', 'только не разлейте солянку', 'non-cash');
-- SELECT * FROM orders;


-- orders_products (состав заказов)
DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    catalog_id INT UNSIGNED NOT NULL,
    total INT UNSIGNED DEFAULT 1 NOT NULL COMMENT 'Количество заказанных товарных позиций',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_products_orders FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orders_products_catalogs FOREIGN KEY (catalog_id) REFERENCES catalogs (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_orders_products_id (id),
    INDEX index_orders_order_id (order_id)
) ENGINE=InnoDB COMMENT = 'Состав заказа' ;

INSERT orders_products (order_id, product_id, catalog_id) VALUES
    ('1', '1', '6'), ('2', '2', '4'), ('3', '22', '7'), ('4', '18', '4'), ('5', '13', '1'), ('6', '14', '1'), ('7', '17', '1'),
     ('8', '18', '1'), ('9', '2', '4'), ('10', '5', '4'), ('11', '1', '6'), ('12', '2', '6'), ('13', '19', '1'), ('14', '3', '4'),
     ('15', '2', '1'), ('16', '14', '1'), ('17', '1', '4'), ('18', '1', '1'), ('2', '2', '4'), ('7', '17', '1'), ('2', '1', '2'),
    ('12', '3', '2'), ('18', '7', '8');
-- SELECT * FROM orders_products;


-- reviews
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    profile_id BIGINT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    catalog_id INT UNSIGNED NOT NULL,
    review TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_profiles FOREIGN KEY (profile_id) REFERENCES profiles (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX index_reviews_id (id),
    INDEX index_reviews_profile_id (profile_id)
) ENGINE=InnoDB COMMENT = 'Отзыв покупателя о продукте' ;

INSERT reviews (profile_id, product_id, catalog_id, review) VALUES
    ('1', '1', '6', 'Ну очень вкусно!'), ('8', '14', '1', 'Наверное, пиццу пробовали все. Ведь это очень вкусное блюдо. Много вариантов, вкусно, сытно.'),
    ('14', '1', '1', 'При большом употреблении можно растолстеть. Люблю вкусно покушать.'), ('9', '2', '4', 'Топовый супчик'), ('12', '2', '1', 'Сытно, широта фантазии в начинке.'),
    ('2', '1', '1', 'Потрясающая еда!!!'), ('1', '3', '1', 'Великолепно!'), ('16', '1', '1', 'Со мной поделились. Очень вкусно...');
-- SELECT * FROM reviews;

-- Процедура снижения цены
DROP PROCEDURE IF EXISTS drop_the_price;
DELIMITER //
CREATE PROCEDURE drop_the_price (IN percent INT UNSIGNED)
BEGIN
UPDATE pizza_circle SET pizza_circle.price = pizza_circle.price - (pizza_circle.price * (percent / 100));
end //
DELIMITER ;

# CALL drop_the_price(50);

-- функция Plus
DROP FUNCTION IF EXISTS plus;
DELIMITER //
CREATE FUNCTION plus(a int, b int) RETURNS int
DETERMINISTIC
    BEGIN
        DECLARE result INT;
        SET result = a+b;
        RETURN (result);
    end //
DELIMITER ;

# SELECT plus(
#     (SELECT COUNT(id) FROM profiles WHERE gender = 'male'),
#     (SELECT COUNT(id) FROM profiles WHERE gender = 'female')
#            ) AS number_of_users;


-- Представления (скрипты характерных выборок)

-- Вывести всех пользователей и их адреса
# CREATE VIEW user_addresses AS
# SELECT profiles.id, profiles.first_name, profiles.last_name, profiles.phone, addresses.district, addresses.street, addresses.house_number, addresses.private_house, addresses.apartment_number
# FROM profiles
# INNER JOIN addresses ON profiles.id = addresses.profile_id;

-- Вывести таблицу кусочки пиццы с описанием
# CREATE VIEW slices_of_pizza_with_description AS
# SELECT pizza_portion.id, pizza_circle.name, pizza_circle.description, pizza_portion.gram_weight, pizza_portion.price
# FROM pizza_portion
# JOIN pizza_circle ON pizza_portion.id_in_pizza_circle = pizza_circle.id;

-- У каких пользователей не было ни одного заказа
# SELECT id, first_name, last_name
# FROM profiles
# WHERE NOT EXISTS (
# SELECT profiles.id
# FROM orders
# WHERE profiles.id = orders.profile_id);

-- Какая целая пицца стоит дешевле средней цены
# SELECT pizza_circle.name, pizza_circle.description, pizza_circle.gram_weight, pizza_circle.price
# FROM pizza_circle
# WHERE price < (SELECT AVG(price) FROM pizza_circle);

-- Какой кусочек пиццы стоит дороже средней цены напитка
# SELECT pizza_portion.id, pizza_circle.name, pizza_circle.description, pizza_portion.gram_weight, pizza_portion.price
# FROM pizza_portion
# JOIN pizza_circle ON pizza_portion.id_in_pizza_circle = pizza_circle.id
# WHERE pizza_portion.price < (SELECT AVG(beverages.price) FROM beverages);

-- Какие пользователи оставили комментарии и где они живут
# CREATE VIEW what AS
# SELECT profiles.first_name, profiles.last_name, reviews.review, addresses.district, addresses.street
# FROM profiles
# JOIN reviews ON profiles.id = reviews.profile_id
# JOIN addresses ON profiles.id = addresses.profile_id;

-- Средний возраст пользователей
# SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, profiles.birthday, NOW()))) AS average_age FROM profiles;

-- Вывести все товары из таблицы salads_and_hot_dishes (даже если у них нет catalog_id) и их каталог (LEFT JOIN)
# SELECT salads_and_hot_dishes.name, catalogs.name
# FROM salads_and_hot_dishes
# LEFT JOIN catalogs ON salads_and_hot_dishes.catalog_id = catalogs.id;

-- Вывести все товары из таблицы beverages (даже если у них нет catalog_id) и их каталог (RIGHT JOIN)
# SELECT beverages.name, catalogs.name
# FROM catalogs
# RIGHT JOIN beverages ON catalogs.id = beverages.catalog_id;

-- Какую целую пиццу заказывали больше 1 раза
# SELECT pizza_circle.name, sum(orders_products.total) AS sum
# FROM pizza_circle
# JOIN orders_products ON pizza_circle.id = orders_products.product_id
# AND pizza_circle.catalog_id = orders_products.catalog_id
#  GROUP BY pizza_circle.name HAVING sum > 1;

-- Целая и кусочек пиццы через UNION
# SELECT pizza_circle.id, pizza_circle.name, pizza_circle.gram_weight, pizza_circle.price
# FROM pizza_circle
# UNION
# SELECT pizza_portion.id, pizza_circle.name, pizza_portion.gram_weight, pizza_portion.price
# FROM pizza_portion
# JOIN pizza_circle ON pizza_portion.id_in_pizza_circle = pizza_circle.id;

-- Что заказывали пользователи
-- Целая пицца
# SELECT profiles.id, profiles.first_name, profiles.last_name, catalogs.name, pizza_circle.name, pizza_circle.name, pizza_circle.price, pizza_circle.gram_weight
# FROM profiles
# JOIN orders ON profiles.id = orders.profile_id
# JOIN orders_products ON orders.id = orders_products.order_id
# JOIN catalogs ON orders_products.catalog_id = catalogs.id
# JOIN pizza_circle ON orders_products.product_id = pizza_circle.id AND orders_products.catalog_id = pizza_circle.catalog_id
# ORDER BY profiles.id;
-- Напитки
# SELECT profiles.id, profiles.first_name, profiles.last_name, catalogs.name, beverages.name, beverages.name, beverages.price, beverages.volume_milliliters
# FROM profiles
# JOIN orders ON profiles.id = orders.profile_id
# JOIN orders_products ON orders.id = orders_products.order_id
# JOIN catalogs ON orders_products.catalog_id = catalogs.id
# JOIN beverages ON orders_products.product_id = beverages.id AND orders_products.catalog_id = beverages.catalog_id
# ORDER BY profiles.id;
-- Кусочек пиццы
# SELECT profiles.id, profiles.first_name, profiles.last_name, catalogs.name, pizza_circle.name, pizza_portion.price, pizza_portion.gram_weight
# FROM profiles
# JOIN orders ON profiles.id = orders.profile_id
# JOIN orders_products ON orders.id = orders_products.order_id
# JOIN catalogs ON orders_products.catalog_id = catalogs.id
# JOIN pizza_portion ON orders_products.product_id = pizza_portion.id AND orders_products.catalog_id = pizza_portion.catalog_id
# JOIN pizza_circle ON pizza_circle.id = pizza_portion.id
# ORDER BY profiles.id;
-- салаты и горячие блюда
# SELECT profiles.id, profiles.first_name, profiles.last_name, catalogs.name, salads_and_hot_dishes.name, salads_and_hot_dishes.name, salads_and_hot_dishes.price, salads_and_hot_dishes.gram_weight
# FROM profiles
# JOIN orders ON profiles.id = orders.profile_id
# JOIN orders_products ON orders.id = orders_products.order_id
# JOIN catalogs ON orders_products.catalog_id = catalogs.id
# JOIN salads_and_hot_dishes ON orders_products.product_id = salads_and_hot_dishes.id AND orders_products.catalog_id = salads_and_hot_dishes.catalog_id
# ORDER BY profiles.id;

-- Найти отзывы пользователей в которых есть слова великолепно, потрясающе, вкусно, сытно
# SELECT profiles.first_name, profiles.last_name, reviews.review
# FROM profiles
# JOIN reviews on profiles.id = reviews .profile_id
# WHERE reviews.review LIKE '%великолепно%' OR reviews.review LIKE '%потряс%' OR reviews.review LIKE '%вкусно%' OR reviews.review LIKE '%сытно%';

-- Сколько заказов совершили мужчины и женщины
# SELECT (SELECT COUNT(profiles.gender)
# FROM profiles
# JOIN orders ON profiles.id = orders.profile_id
# WHERE profiles.gender = 'male') AS Man, COUNT(profiles.gender) AS Woman
# FROM profiles
# JOIN orders ON profiles.id = orders.profile_id
# WHERE profiles.gender = 'female';

-- Пользователи которые зарегестрировались не позже 14 дней
# SELECT profiles.id, profiles.first_name, profiles.last_name
# FROM profiles
# WHERE TO_DAYS(NOW()) - TO_DAYS(profiles.created_at) <= 14
# ORDER BY profiles.created_at DESC;
