
--Blake DeLong bhd343 Drop table script
BEGIN

  --Deletes all user created sequences
  FOR i IN (SELECT us.sequence_name FROM USER_SEQUENCES us) LOOP
    EXECUTE IMMEDIATE 'drop sequence '|| i.sequence_name ||'';
  END LOOP;

  --Deletes all user created tables
  FOR i IN (SELECT ut.table_name FROM USER_TABLES ut) LOOP
    EXECUTE IMMEDIATE 'drop table '|| i.table_name ||' CASCADE CONSTRAINTS ';
  END LOOP;

END;
/

--Blake DeLong bhd343 The sequences for the table primary keys are created here
CREATE SEQUENCE Bank_Account_ID_Seq
MINVALUE 1
MAXVALUE 9999999
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE Vehicle_ID_Seq
MINVALUE 1
MAXVALUE 9999999
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE Ride_ID_Seq
MINVALUE 1
MAXVALUE 9999999
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE Payment_ID_Seq
MINVALUE 1
MAXVALUE 9999999
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE Discount_ID_Seq
MINVALUE 1
MAXVALUE 9999999
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE Driver_ID_Seq
MINVALUE 100001
MAXVALUE 9999999
START WITH 100001
INCREMENT BY 1;

CREATE SEQUENCE Rider_ID_Seq
MINVALUE 3000001
MAXVALUE 9999999
START WITH 3000001
INCREMENT BY 1;

--Blake DeLong bhd3434 this Section is creating the tables
CREATE TABLE Driver (
    Driver_ID               NUMBER      DEFAULT Driver_ID_Seq.NEXTVAL    PRIMARY KEY,
    First_Name              VARCHAR(20) NOT NULL,
    Last_Name               VARCHAR(20) NOT NULL,
    Address                 VARCHAR(50) NOT NULL,
    City                    VARCHAR(20) NOT NULL,
    State                   CHAR(2)     NOT NULL,
    Zip                     CHAR(5)     NOT NULL,
    Phone                   CHAR(12)    NOT NULL,
    Email                   VARCHAR(30) NOT NULL    UNIQUE,
    DOB                     DATE        NOT NULL,
    Drivers_License_Num     NUMBER      NOT NULL    UNIQUE
);

CREATE TABLE Vehicle (
    Vehicle_ID                  NUMBER      DEFAULT Vehicle_ID_Seq.NEXTVAL    PRIMARY KEY,
    Year                        VARCHAR(4)  NOT NULL,
    Make                        VARCHAR(20) NOT NULL,
    Model                       VARCHAR(20) NOT NULL,
    Color                       VARCHAR(20) NOT NULL,
    VIN                         CHAR(17)    NOT NULL    UNIQUE,
    Plate_Number                VARCHAR(10) NOT NULL    UNIQUE,
    Insurance_Company           VARCHAR(30) NOT NULL,
    Insurance_Policy_Number     NUMBER      NOT NULL,
    Inspection_Exp_Date         DATE        NOT NULL
);

CREATE TABLE Rider (
    Rider_ID    NUMBER      DEFAULT Rider_ID_Seq.NEXTVAL    PRIMARY KEY,
    First_Name  VARCHAR(20) NOT NULL,
    Last_Name   VARCHAR(20) NOT NULL,
    Email       VARCHAR(30) NOT NULL    UNIQUE,
    Phone       CHAR(12)    NOT NULL,
    Address     VARCHAR(50) NOT NULL,
    City        VARCHAR(50) NOT NULL,
    Zip         CHAR(5)     NOT NULL,
    CONSTRAINT email_length_check
        CHECK (LENGTH(Email) >= 7)
);

CREATE TABLE Rider_Payment (
    Payment_ID              NUMBER      DEFAULT Payment_ID_Seq.NEXTVAL    PRIMARY KEY,
    Rider_ID                NUMBER      REFERENCES Rider (Rider_ID),
    Cardholder_First_Name   VARCHAR(20) NOT NULL,
    Cardholder_Mid_Name     VARCHAR(20),
    Cardholder_Last_Name    VARCHAR(20) NOT NULL,
    CardType                CHAR(4)     NOT NULL,
    CardNumber              CHAR(16)    NOT NULL,
    Expiration_Date         DATE        NOT NULL,
    CC_ID                   CHAR(3)     NOT NULL,
    Billing_Address         VARCHAR(20) NOT NULL,
    Billing_City            VARCHAR(20) NOT NULL,
    Billing_State           CHAR(2)     NOT NULL,
    Billing_Zip             CHAR(5)     NOT NULL,
    Primary_Card_Flag       CHAR(1)     NOT NULL,
    CONSTRAINT Primary_Card_Flag_Check
        CHECK (Primary_Card_Flag = 'Y' OR Primary_Card_Flag = 'N')
);

CREATE TABLE Discounts (
    Discount_ID         NUMBER      DEFAULT Discount_ID_Seq.NEXTVAL    PRIMARY KEY,
    Rider_ID            NUMBER      REFERENCES Rider (Rider_ID),
    Discount_Type       VARCHAR(10) NOT NULL,
    Dicount_Percent     NUMBER      NOT NULL,
    Used_Flag           CHAR(1)     DEFAULT 'N'             NOT NULL,
    Expriation_Date     DATE        DEFAULT (SYSDATE+30)    NOT NULL,
    CONSTRAINT Used_Flag_Check
        CHECK (Used_Flag = 'Y' OR Used_Flag = 'N')
);

CREATE TABLE Ride (
    Ride_ID             NUMBER      DEFAULT Ride_ID_Seq.NEXTVAL    PRIMARY KEY,
    Driver_ID           NUMBER      REFERENCES Driver (Driver_ID),
    Rider_ID            NUMBER      REFERENCES Rider (Rider_ID),
    Vehicle_ID          NUMBER      REFERENCES Vehicle (Vehicle_ID),
    Pickup_Address      VARCHAR(20) NOT NULL,
    Dropoff_Address     VARCHAR(20) NOT NULL,
    Request_Datetime    VARCHAR(30) DEFAULT SYSDATE,    --I interpreted the datetime columns to be distinctly different from date columns
    Start_Datetime      VARCHAR(30),                    --I am assuming that another system is recording the datetime in the correct format the placing it here
    End_Datetime        VARCHAR(30),                    --In my test data, i have entered datetime in the correct format
    Initial_Fare        NUMBER,
    Discount_Amount     NUMBER,
    Final_Fare          NUMBER,     
    Rating              NUMBER,
    CONSTRAINT Final_Fare_Check
        CHECK (Final_Fare = Initial_Fare - Discount_Amount)
);

CREATE TABLE Bank_Account (
    Bank_Account_ID     NUMBER      DEFAULT Bank_Account_ID_Seq.NEXTVAL    PRIMARY KEY,
    Driver_ID           NUMBER      REFERENCES Driver (Driver_ID)   UNIQUE,
    Routing_Number      CHAR(9)     NOT NULL,
    Account_Number      NUMBER      NOT NULL
);

CREATE TABLE Vehicle_Driver_Linking (
    Driver_ID               NUMBER  REFERENCES Driver (Driver_ID),
    Vehicle_ID              NUMBER  REFERENCES Vehicle (Vehicle_ID),
    Active_Vehicle_Flag     CHAR(1) NOT NULL,
    CONSTRAINT Active_Vehicle_Flag_Check
        CHECK (Active_Vehicle_Flag = 'Y' OR Active_Vehicle_Flag = 'N'),
    CONSTRAINT Vehicle_Driver_Linking_pk
        PRIMARY KEY (Driver_ID, Vehicle_ID)
);

--Blake DeLong bhd343 This section is creating the Indexes
CREATE INDEX Driver_ID_Ride_ix
    ON Ride (Driver_ID);

CREATE INDEX Rider_ID_Ride_ix
    ON Ride (Rider_ID);

CREATE INDEX Vehicle_ID_Ride_ix
    ON Ride (Vehicle_ID);

CREATE INDEX Rider_ID_Discounts_ix
    ON Discounts (Rider_ID);

CREATE INDEX Rider_ID_Rider_Payment_ix
    ON Rider_Payment (Rider_ID);

CREATE INDEX Last_Name_Driver_ix
    ON Driver (Last_Name);

CREATE INDEX Last_Name_Rider_ix
    ON Rider (Last_Name);

--Blake DeLong bhd343 This section is inserting the data
--Insert Riders
INSERT INTO rider (FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, ZIP)
VALUES ('Blake','DeLong','bhd343@utexas.edu','972-571-5519','123 Test Street','Austin','78751');

INSERT INTO rider (FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, ZIP)
VALUES ('Jake','DeShort','123abc@utexas.edu','972-571-9999','456 Rest Street','Dallas','75287');

INSERT INTO rider (FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, ZIP)
VALUES ('Drake','DeMedium','xyz987@utexas.edu','972-555-5555','789 SQL Drive','Houston','99999');

--Insert Rider Payments
INSERT INTO rider_payment (RIDER_ID, CARDHOLDER_FIRST_NAME, CARDHOLDER_MID_NAME, CARDHOLDER_LAST_NAME, CARDTYPE,
CARDNUMBER, EXPIRATION_DATE, CC_ID, BILLING_ADDRESS, BILLING_CITY, BILLING_STATE, BILLING_ZIP, PRIMARY_CARD_FLAG)
VALUES (3000001, 'Blake', 'Henry', 'DeLong', 'MSTR', '1111111111111111','01-AUG-14' ,'123', '123 Test Street','Austin', 'TX', '78751', 'Y');

INSERT INTO rider_payment (RIDER_ID, CARDHOLDER_FIRST_NAME, CARDHOLDER_MID_NAME, CARDHOLDER_LAST_NAME, CARDTYPE,
CARDNUMBER, EXPIRATION_DATE, CC_ID, BILLING_ADDRESS, BILLING_CITY, BILLING_STATE, BILLING_ZIP, PRIMARY_CARD_FLAG)
VALUES (3000002, 'Jake', 'Benry', 'DeShort', 'Visa', '2222222222222222','01-AUG-15' ,'456', '456 Rest Street','Dallas', 'TX', '78751', 'Y');

INSERT INTO rider_payment (RIDER_ID, CARDHOLDER_FIRST_NAME, CARDHOLDER_MID_NAME, CARDHOLDER_LAST_NAME, CARDTYPE,
CARDNUMBER, EXPIRATION_DATE, CC_ID, BILLING_ADDRESS, BILLING_CITY, BILLING_STATE, BILLING_ZIP, PRIMARY_CARD_FLAG)
VALUES (3000002, 'Drake', 'Sauce', 'DeMedium', 'Capt', '3333333333333333','02-AUG-14' ,'789', '789 Sea Shell Street','Houston', 'TX', '99999', 'Y');

--Insert Drivers
INSERT INTO driver (FIRST_NAME, LAST_NAME, ADDRESS, CITY, STATE, ZIP, PHONE, EMAIL, DOB, DRIVERS_LICENSE_NUM)
VALUES ('Ricky', 'Winterboard', '999 Larry Ave.', 'Detroit', 'MI', '12345', '777-777-7777', 'test@testing.com', '30-SEP-20', 13579);

INSERT INTO driver (FIRST_NAME, LAST_NAME, ADDRESS, CITY, STATE, ZIP, PHONE, EMAIL, DOB, DRIVERS_LICENSE_NUM)
VALUES ('Lando', 'Narris', '123 McLaren Ave.', 'London', 'EN', '9876', '666-666-6666', 'lando@mclaren.com', '22-SEP-98', 09876);

INSERT INTO driver (FIRST_NAME, LAST_NAME, ADDRESS, CITY, STATE, ZIP, PHONE, EMAIL, DOB, DRIVERS_LICENSE_NUM)
VALUES ('Max', 'Speed', '000 Speed Lane', 'Speed City', 'SP', '00000', '000-000-0000', 'speed@fast.com', '23-SEP-69', 00000000);

--Insert Driver Bank Account
INSERT INTO bank_account (DRIVER_ID, ROUTING_NUMBER, ACCOUNT_NUMBER)
VALUES (100001, '111111111', 551525374956748);

INSERT INTO bank_account (DRIVER_ID, ROUTING_NUMBER, ACCOUNT_NUMBER)
VALUES (100002, '222222222', 785429754028574);

INSERT INTO bank_account (DRIVER_ID, ROUTING_NUMBER, ACCOUNT_NUMBER)
VALUES (100003, '333333333', 8754823768902754);

--Insert Vehicles
INSERT INTO Vehicle (YEAR, MAKE, MODEL, COLOR, VIN, PLATE_NUMBER, INSURANCE_COMPANY, INSURANCE_POLICY_NUMBER, INSPECTION_EXP_DATE)
VALUES ('1995', 'Nissan', '300ZX', 'Red', '11111111111111111', 'NEED4SPD', 'Allstate', 534342, '01-MAY-23');

INSERT INTO Vehicle (YEAR, MAKE, MODEL, COLOR, VIN, PLATE_NUMBER, INSURANCE_COMPANY, INSURANCE_POLICY_NUMBER, INSPECTION_EXP_DATE)
VALUES ('2014', 'Lexus', 'LFA', 'Yellow', '22222222222222222', 'LFABOI', 'Farmers', 876907, '02-MAY-23');

INSERT INTO Vehicle (YEAR, MAKE, MODEL, COLOR, VIN, PLATE_NUMBER, INSURANCE_COMPANY, INSURANCE_POLICY_NUMBER, INSPECTION_EXP_DATE)
VALUES ('2018', 'Nissan', 'GTR', 'Grey', '33333333333333333', 'DRIFTY', 'Allstate', 8795493, '03-MAY-23');

--Insert Linking Vehicle Information
INSERT INTO vehicle_driver_linking (DRIVER_ID, VEHICLE_ID, ACTIVE_VEHICLE_FLAG)
VALUES (100001, 1, 'Y');

INSERT INTO vehicle_driver_linking (DRIVER_ID, VEHICLE_ID, ACTIVE_VEHICLE_FLAG)
VALUES (100002, 2, 'Y');

INSERT INTO vehicle_driver_linking (DRIVER_ID, VEHICLE_ID, ACTIVE_VEHICLE_FLAG)
VALUES (100003, 3, 'Y');

--Insert Ride information
INSERT INTO ride (DRIVER_ID, RIDER_ID, VEHICLE_ID, PICKUP_ADDRESS, DROPOFF_ADDRESS, REQUEST_DATETIME, 
START_DATETIME, END_DATETIME, INITIAL_FARE, DISCOUNT_AMOUNT, FINAL_FARE, RATING)
VALUES (100001, 3000001, 1, '123 picking st.', '456 leave ave.', '2018-12-19 09:26:03','2018-12-19 09:40:03', '2018-12-19 10:40:03', 50, 0, 50, 5);

INSERT INTO ride (DRIVER_ID, RIDER_ID, VEHICLE_ID, PICKUP_ADDRESS, DROPOFF_ADDRESS, REQUEST_DATETIME, 
START_DATETIME, END_DATETIME, INITIAL_FARE, DISCOUNT_AMOUNT, FINAL_FARE, RATING)
VALUES (100002, 3000002, 2, '666 sql hell lane', '999 sql afterlife', '2019-08-22 06:54:33','2019-08-22 07:40:03', '2019-08-22 07:50:03', 30, 0, 30, 3);

INSERT INTO ride (DRIVER_ID, RIDER_ID, VEHICLE_ID, PICKUP_ADDRESS, DROPOFF_ADDRESS, REQUEST_DATETIME, 
START_DATETIME, END_DATETIME, INITIAL_FARE, DISCOUNT_AMOUNT, FINAL_FARE, RATING)
VALUES (100003, 3000003, 3, '96 doghouse lane', '4919 Agusta Ave.', SYSDATE,SYSDATE, SYSDATE, 20, 0, 20, 4.5);

--Insert Discount
INSERT INTO discounts (RIDER_ID, DISCOUNT_TYPE, DICOUNT_PERCENT)
VALUES (3000001, 'Code', 20);

COMMIT;
