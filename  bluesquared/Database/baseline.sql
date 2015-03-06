--
-- File generated with SQLiteStudio v3.0.3 on Fri Mar 6 09:26:30 2015
--
-- Text encoding used: windows-1252
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: RateTypes
CREATE TABLE RateTypes (
    RateType_ID INTEGER PRIMARY KEY AUTOINCREMENT
                        NOT NULL,
    RateType    TEXT    NOT NULL ON CONFLICT ABORT
);


-- Table: AccountNumbers
CREATE TABLE AccountNumbers (
    AcctNumbers_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    CompaniesID    INTEGER REFERENCES Companies (Companies_ID) ON UPDATE CASCADE,
    CarriersID     INTEGER REFERENCES Carriers (Carrier_ID) ON UPDATE CASCADE,
    AcctNumber     TEXT
);


-- Table: ShipVia
CREATE TABLE ShipVia (
    ShipVia_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
    CarrierID        INTEGER REFERENCES Carriers (Carrier_ID) ON DELETE CASCADE
                                                              ON UPDATE CASCADE,
    ShipViaCode      TEXT    UNIQUE ON CONFLICT ABORT,
    FreightPayerType TEXT    NOT NULL ON CONFLICT ABORT,
    ShipViaName      TEXT    NOT NULL ON CONFLICT ABORT,
    ShipmentType     TEXT    NOT NULL ON CONFLICT ABORT,
    RateType         TEXT,
    RateTable        TEXT
);


-- Table: Modules
CREATE TABLE Modules (
    Mod_ID                INTEGER PRIMARY KEY AUTOINCREMENT,
    ModuleName            VARCHAR NOT NULL ON CONFLICT ABORT
                                  UNIQUE ON CONFLICT ABORT,
    EnableModNotification BOOLEAN DEFAULT (1) 
);


-- Table: DistributionTypes
CREATE TABLE DistributionTypes (
    DistributionType_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    DistTypeName        TEXT    UNIQUE ON CONFLICT ABORT
);


-- Table: Schema
CREATE TABLE Schema (
    idx         INTEGER PRIMARY KEY AUTOINCREMENT,
    Day         INTEGER NOT NULL ON CONFLICT ROLLBACK,
    Month       INTEGER NOT NULL ON CONFLICT ROLLBACK,
    Year        INTEGER NOT NULL ON CONFLICT ROLLBACK,
    ProgramVers TEXT    NOT NULL ON CONFLICT ROLLBACK,
    SchemaVers  TEXT
);


-- Table: Containers
CREATE TABLE Containers (
    Container_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Container    TEXT    NOT NULL ON CONFLICT ABORT
);


-- Table: Packages
CREATE TABLE Packages (
    Pkg_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
    Package TEXT    NOT NULL ON CONFLICT ABORT
);


-- Table: Customer
CREATE TABLE Customer (
    Cust_ID  TEXT    PRIMARY KEY
                     NOT NULL ON CONFLICT ABORT
                     UNIQUE ON CONFLICT ABORT,
    CustName TEXT    NOT NULL ON CONFLICT ABORT,
    Status   BOOLEAN
);


-- Table: FreightRates
CREATE TABLE FreightRates (
    RateTable_ID         REFERENCES CarrierName (RateTable),
    WeightLow1   INTEGER,
    WeightHigh1  INTEGER,
    ShippingCost VARCHAR
);


-- Table: ShippingClasses
CREATE TABLE ShippingClasses (
    ShippingClass_ID INTEGER PRIMARY KEY AUTOINCREMENT
                             NOT NULL,
    ShippingClass    TEXT    NOT NULL ON CONFLICT ABORT
);


-- Table: CustomerShipVia
CREATE TABLE CustomerShipVia (
    CustomerShipVia_ID INTEGER PRIMARY KEY AUTOINCREMENT
                               NOT NULL,
    CustID             INTEGER REFERENCES Customer (Cust_ID),
    ShipViaID          INTEGER REFERENCES ShipVia (ShipVia_ID) 
);


-- Table: EmailNotifications
CREATE TABLE EmailNotifications (
    EN_ID             INTEGER PRIMARY KEY AUTOINCREMENT
                              NOT NULL,
    ModuleName        VARCHAR NOT NULL,
    EventName         VARCHAR NOT NULL
                              UNIQUE ON CONFLICT ABORT,
    EventNotification BOOLEAN NOT NULL,
    EmailFrom         VARCHAR NOT NULL ON CONFLICT ABORT,
    EmailTo           VARCHAR NOT NULL ON CONFLICT ABORT,
    EmailSubject      VARCHAR NOT NULL ON CONFLICT ABORT,
    EmailBody         VARCHAR NOT NULL ON CONFLICT ABORT
);


-- Table: ShipmentTypes
CREATE TABLE ShipmentTypes (
    ShipmentType_ID INTEGER PRIMARY KEY AUTOINCREMENT
                            NOT NULL,
    ShipmentType    TEXT    NOT NULL ON CONFLICT ABORT
);


-- Table: EventNotifications
CREATE TABLE EventNotifications (
    Event_ID                INTEGER PRIMARY KEY AUTOINCREMENT,
    ModID                   NONE    NOT NULL ON CONFLICT ABORT
                                    REFERENCES Modules (Mod_ID),
    EventName               VARCHAR NOT NULL ON CONFLICT ABORT,
    EventSubstitutions      VARCHAR,
    EnableEventNotification BOOLEAN DEFAULT (1) 
);


-- Table: Carriers
CREATE TABLE Carriers (
    Carrier_ID INTEGER PRIMARY KEY AUTOINCREMENT
                       NOT NULL,
    Name       TEXT    NOT NULL ON CONFLICT ABORT
                       UNIQUE ON CONFLICT ABORT,
    RateType   VARCHAR,
    RateTable  VARCHAR
);


-- Table: Users
CREATE TABLE Users (
    User_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
    UserLogin TEXT,
    UserName  TEXT,
    UserPwd   TEXT
);


-- Table: IntlLicense
CREATE TABLE IntlLicense (
    License_ID  INTEGER PRIMARY KEY AUTOINCREMENT
                        NOT NULL,
    LicenseAbbr VARCHAR NOT NULL
                        UNIQUE ON CONFLICT ABORT,
    LicenseDesc VARCHAR
);


-- Table: CSRs
CREATE TABLE CSRs (
    CSR_ID    VARCHAR (6, 0) PRIMARY KEY ON CONFLICT ABORT
                             NOT NULL
                             UNIQUE ON CONFLICT ABORT,
    FirstName VARCHAR        NOT NULL,
    LastName  VARCHAR,
    Email     VARCHAR,
    Status    BOOLEAN        DEFAULT (1) 
);


-- Table: SubHeaders
CREATE TABLE SubHeaders (
    SubHeader_ID  INTEGER PRIMARY KEY AUTOINCREMENT
                          NOT NULL,
    SubHeaderName VARCHAR UNIQUE ON CONFLICT FAIL,
    HeaderID      INTEGER REFERENCES Headers (Header_ID) 
);


-- Table: Companies
CREATE TABLE Companies (
    Companies_ID        INTEGER PRIMARY KEY AUTOINCREMENT,
    Companies_Name      TEXT,
    Companies_Attn      TEXT,
    Companies_Add1      TEXT,
    Companies_Add2      TEXT,
    Companies_Add3      TEXT,
    Companies_StateAbbr TEXT,
    Companies_Zip       TEXT,
    Companies_CtryCode  TEXT    REFERENCES Countries (CountryCode) ON UPDATE CASCADE
);


-- Table: DistributionClasses
CREATE TABLE DistributionClasses (
    DistClass_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
    DistClassName TEXT
);


-- Table: PubTitle
CREATE TABLE PubTitle (
    Title_ID     INTEGER PRIMARY KEY AUTOINCREMENT,
    TitleName    TEXT    NOT NULL ON CONFLICT ABORT,
    CustID       TEXT    REFERENCES Customer (Cust_ID),
    Status       BOOLEAN,
    CSRID        VARCHAR REFERENCES CSRs (CSR_ID),
    SaveLocation TEXT
);


-- Table: Countries
CREATE TABLE Countries (
    Country_ID  INTEGER     PRIMARY KEY AUTOINCREMENT
                            NOT NULL,
    CountryCode VARCHAR (2) NOT NULL
                            UNIQUE,
    CountryName TEXT        NOT NULL
);


-- Table: IntlShipTerms
CREATE TABLE IntlShipTerms (
    Terms_ID  INTEGER PRIMARY KEY AUTOINCREMENT
                      NOT NULL,
    TermsAbbr VARCHAR NOT NULL
                      UNIQUE ON CONFLICT ABORT,
    TermsDesc VARCHAR,
    IncoTerms INTEGER
);


-- Table: EmailSetup
CREATE TABLE EmailSetup (
    Email_ID                INTEGER PRIMARY KEY AUTOINCREMENT
                                    NOT NULL,
    EmailServer             VARCHAR NOT NULL,
    EmailPassword           VARCHAR,
    EmailPort               INTEGER,
    EmailLogin              VARCHAR,
    GlobalEmailNotification BOOLEAN NOT NULL
                                    DEFAULT (1),
    TLS                     BOOLEAN DEFAULT (0) 
);


-- Table: UOM
CREATE TABLE UOM (
    UOM_ID INTEGER PRIMARY KEY AUTOINCREMENT
                   NOT NULL,
    UOM    VARCHAR NOT NULL
                   UNIQUE ON CONFLICT ABORT
);


-- Table: Headers
CREATE TABLE Headers (
    Header_ID          INTEGER PRIMARY KEY AUTOINCREMENT
                               NOT NULL,
    InternalHeaderName TEXT    NOT NULL
                               UNIQUE ON CONFLICT ABORT,
    HeaderMaxLength    INTEGER NOT NULL ON CONFLICT ABORT,
    OutputHeaderName   TEXT    NOT NULL ON CONFLICT ABORT,
    Widget             TEXT    NOT NULL ON CONFLICT ABORT,
    Highlight          TEXT,
    AlwaysDisplay      BOOLEAN,
    Required           BOOLEAN,
    DefaultWidth       INTEGER,
    ResizeColumn       BOOLEAN,
    DisplayOrder       INTEGER
);


-- Table: Provinces
CREATE TABLE Provinces (
    Prov_ID           INTEGER  PRIMARY KEY AUTOINCREMENT
                               NOT NULL,
    ProvAbbr          CHAR (3) NOT NULL,
    ProvName          TEXT     NOT NULL,
    PostalCodeLowEnd  TEXT,
    PostalCodeHighEnd TEXT,
    CountryID         INTEGER  REFERENCES Countries (Country_ID) ON DELETE CASCADE
);


-- Table: FreightPayer
CREATE TABLE FreightPayer (
    FreightPayer_ID INTEGER PRIMARY KEY AUTOINCREMENT
                            NOT NULL,
    Payer           TEXT    NOT NULL ON CONFLICT ABORT
);


COMMIT TRANSACTION;
