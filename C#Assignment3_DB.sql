-- =========================================================
-- Create Schema: Assignment3 (idempotent)
-- =========================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Assignment3')
BEGIN
    EXEC(N'CREATE SCHEMA [Assignment3]');
END
GO

-- =========================================================
-- 1. Assignment3.Consumers
-- =========================================================
CREATE TABLE Assignment3.Consumers (
    ConsumerId      INT IDENTITY(1,1) NOT NULL,
    AccountNumber   VARCHAR(30)       NOT NULL,
    FullName        NVARCHAR(150)     NOT NULL,
    FeederId        VARCHAR(30)       NOT NULL,
    ServiceAddress  NVARCHAR(250)     NULL,
    Category        VARCHAR(30)       NOT NULL CONSTRAINT DF_Consumers_Category DEFAULT ('RESIDENTIAL'),
    IsActive        BIT               NOT NULL CONSTRAINT DF_Consumers_IsActive DEFAULT (1),
    CreatedAtUtc    DATETIME2(3)      NOT NULL CONSTRAINT DF_Consumers_CreatedAt DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_Consumers PRIMARY KEY CLUSTERED (ConsumerId),
    CONSTRAINT UQ_Consumers_AccountNumber UNIQUE (AccountNumber)
);
GO

CREATE NONCLUSTERED INDEX IX_Consumers_FeederId
    ON Assignment3.Consumers (FeederId);
GO

-- =========================================================
-- 2. Assignment3.Meters
-- =========================================================
CREATE TABLE Assignment3.Meters (
    MeterId         INT IDENTITY(1,1) NOT NULL,
    MeterSerial     VARCHAR(50)       NOT NULL,
    ConsumerId      INT               NOT NULL,
    FeederId        VARCHAR(30)       NOT NULL,
    Status          VARCHAR(20)       NOT NULL CONSTRAINT DF_Meters_Status DEFAULT ('ACTIVE'),
    InstalledAtUtc  DATETIME2(3)      NOT NULL,
    CreatedAtUtc    DATETIME2(3)      NOT NULL CONSTRAINT DF_Meters_CreatedAt DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_Meters PRIMARY KEY CLUSTERED (MeterId),
    CONSTRAINT UQ_Meters_MeterSerial UNIQUE (MeterSerial),
    CONSTRAINT FK_Meters_Consumers FOREIGN KEY (ConsumerId)
        REFERENCES Assignment3.Consumers (ConsumerId),
    CONSTRAINT CK_Meters_Status CHECK (Status IN ('ACTIVE', 'INACTIVE', 'FAULTY', 'DISCONNECTED'))
);
GO

CREATE NONCLUSTERED INDEX IX_Meters_ConsumerId
    ON Assignment3.Meters (ConsumerId);
CREATE NONCLUSTERED INDEX IX_Meters_FeederId
    ON Assignment3.Meters (FeederId);
GO

-- =========================================================
-- 3. Assignment3.TariffSlabs
-- =========================================================
CREATE TABLE Assignment3.TariffSlabs (
    TariffSlabId     INT IDENTITY(1,1) NOT NULL,
    SlabCode         VARCHAR(30)       NOT NULL,
    ConsumerCategory VARCHAR(30)       NOT NULL CONSTRAINT DF_TariffSlabs_Category DEFAULT ('RESIDENTIAL'),
    MinUnits         DECIMAL(18,4)     NOT NULL,
    MaxUnits         DECIMAL(18,4)     NULL, -- NULL = open-ended top slab
    RatePerUnit      DECIMAL(18,4)     NOT NULL,
    FixedCharge      DECIMAL(18,2)     NOT NULL CONSTRAINT DF_TariffSlabs_FixedCharge DEFAULT (0.00),
    EffectiveFrom    DATETIME2(3)      NOT NULL,
    EffectiveTo      DATETIME2(3)      NULL,
    IsActive         BIT               NOT NULL CONSTRAINT DF_TariffSlabs_IsActive DEFAULT (1),
    UpdatedAtUtc     DATETIME2(3)      NOT NULL CONSTRAINT DF_TariffSlabs_UpdatedAt DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_TariffSlabs PRIMARY KEY CLUSTERED (TariffSlabId),
    CONSTRAINT UQ_TariffSlabs_SlabCode_EffectiveFrom UNIQUE (SlabCode, EffectiveFrom),
    CONSTRAINT CK_TariffSlabs_Units CHECK (MinUnits >= 0 AND (MaxUnits IS NULL OR MaxUnits > MinUnits)),
    CONSTRAINT CK_TariffSlabs_Rate CHECK (RatePerUnit >= 0)
);
GO

CREATE NONCLUSTERED INDEX IX_TariffSlabs_ActiveLookup
    ON Assignment3.TariffSlabs (ConsumerCategory, IsActive, EffectiveFrom, EffectiveTo);
GO

-- =========================================================
-- 4. Assignment3.MeterReadings
-- =========================================================
CREATE TABLE Assignment3.MeterReadings (
    ReadingId           BIGINT IDENTITY(1,1) NOT NULL,
    ExternalReadingId   VARCHAR(64)          NOT NULL, -- API idempotency key
    MeterId             INT                  NOT NULL,
    BatchCursor         VARCHAR(100)         NULL,
    ReadingTimestampUtc DATETIME2(3)         NOT NULL,
    PreviousValue       DECIMAL(18,4)        NULL,
    CurrentValue        DECIMAL(18,4)        NOT NULL,
    ConsumptionDelta    DECIMAL(18,4)        NULL,
    BilledAmount        DECIMAL(18,2)        NULL,
    TariffSlabId        INT                  NULL,
    IsAnomalous         BIT                  NOT NULL CONSTRAINT DF_MeterReadings_IsAnomalous DEFAULT (0),
    IngestedAtUtc       DATETIME2(3)         NOT NULL CONSTRAINT DF_MeterReadings_IngestedAt DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_MeterReadings PRIMARY KEY CLUSTERED (ReadingId),
    CONSTRAINT UQ_MeterReadings_ExternalReadingId UNIQUE (ExternalReadingId),
    CONSTRAINT UQ_MeterReadings_Meter_Timestamp UNIQUE (MeterId, ReadingTimestampUtc),
    CONSTRAINT FK_MeterReadings_Meters FOREIGN KEY (MeterId)
        REFERENCES Assignment3.Meters (MeterId),
    CONSTRAINT FK_MeterReadings_TariffSlabs FOREIGN KEY (TariffSlabId)
        REFERENCES Assignment3.TariffSlabs (TariffSlabId),
    CONSTRAINT CK_MeterReadings_CurrentValue CHECK (CurrentValue >= 0)
);
GO

CREATE NONCLUSTERED INDEX IX_MeterReadings_Meter_Timestamp
    ON Assignment3.MeterReadings (MeterId, ReadingTimestampUtc DESC)
    INCLUDE (CurrentValue, ConsumptionDelta, IsAnomalous);

CREATE NONCLUSTERED INDEX IX_MeterReadings_BatchCursor
    ON Assignment3.MeterReadings (BatchCursor);
GO

-- =========================================================
-- 5. Assignment3.DispatchAlerts
-- =========================================================
CREATE TABLE Assignment3.DispatchAlerts (
    DispatchAlertId   BIGINT IDENTITY(1,1) NOT NULL,
    ExternalTicketId  VARCHAR(64)          NOT NULL,
    FeederId          VARCHAR(30)          NOT NULL,
    MeterId           INT                  NULL,
    AlertType         VARCHAR(40)          NOT NULL, -- OUTAGE, TAMPER, VOLTAGE_DROP
    Severity          VARCHAR(20)          NOT NULL, -- LOW, MEDIUM, HIGH, CRITICAL
    Description       NVARCHAR(500)        NULL,
    Status            VARCHAR(20)          NOT NULL CONSTRAINT DF_DispatchAlerts_Status DEFAULT ('OPEN'),
    ReportedAtUtc     DATETIME2(3)         NOT NULL,
    SyncedAtUtc       DATETIME2(3)         NOT NULL CONSTRAINT DF_DispatchAlerts_SyncedAt DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_DispatchAlerts PRIMARY KEY CLUSTERED (DispatchAlertId),
    CONSTRAINT UQ_DispatchAlerts_ExternalTicketId UNIQUE (ExternalTicketId),
    CONSTRAINT FK_DispatchAlerts_Meters FOREIGN KEY (MeterId)
        REFERENCES Assignment3.Meters (MeterId),
    CONSTRAINT CK_DispatchAlerts_Severity CHECK (Severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);
GO

CREATE NONCLUSTERED INDEX IX_DispatchAlerts_Feeder_Status
    ON Assignment3.DispatchAlerts (FeederId, Status, ReportedAtUtc DESC);
GO

-- =========================================================
-- 6. Assignment3.ReconciliationAuditLog
-- =========================================================
CREATE TABLE Assignment3.ReconciliationAuditLog (
    AuditId           BIGINT IDENTITY(1,1) NOT NULL,
    RunId             UNIQUEIDENTIFIER     NOT NULL,
    FeederId          VARCHAR(30)          NULL,
    BatchCursor       VARCHAR(100)         NULL,
    StartedAtUtc      DATETIME2(3)         NOT NULL,
    CompletedAtUtc    DATETIME2(3)         NOT NULL CONSTRAINT DF_ReconciliationAuditLog_CompletedAt DEFAULT (SYSUTCDATETIME()),
    TotalFetched      INT                  NOT NULL CONSTRAINT DF_ReconciliationAuditLog_Total DEFAULT (0),
    InsertedCount     INT                  NOT NULL CONSTRAINT DF_ReconciliationAuditLog_Inserted DEFAULT (0),
    DuplicateCount    INT                  NOT NULL CONSTRAINT DF_ReconciliationAuditLog_Duplicate DEFAULT (0),
    AnomalyCount      INT                  NOT NULL CONSTRAINT DF_ReconciliationAuditLog_Anomaly DEFAULT (0),
    FailedCount       INT                  NOT NULL CONSTRAINT DF_ReconciliationAuditLog_Failed DEFAULT (0),
    RunStatus         VARCHAR(20)          NOT NULL, -- SUCCESS, PARTIAL_SUCCESS, FAILED
    ErrorMessage      NVARCHAR(MAX)        NULL,

    CONSTRAINT PK_ReconciliationAuditLog PRIMARY KEY CLUSTERED (AuditId),
    CONSTRAINT UQ_ReconciliationAuditLog_RunId UNIQUE (RunId),
    CONSTRAINT CK_ReconciliationAuditLog_Status CHECK (RunStatus IN ('SUCCESS', 'PARTIAL_SUCCESS', 'FAILED'))
);
GO

CREATE NONCLUSTERED INDEX IX_ReconciliationAuditLog_CompletedAt
    ON Assignment3.ReconciliationAuditLog (CompletedAtUtc DESC);
GO

-- =========================================================
-- 7. Assignment3.MeterReadingAnomalies
-- =========================================================
CREATE TABLE Assignment3.MeterReadingAnomalies (
    AnomalyId           BIGINT IDENTITY(1,1) NOT NULL,
    RunId               UNIQUEIDENTIFIER     NULL,
    ExternalReadingId   VARCHAR(64)          NULL,
    MeterId             INT                  NULL, -- NULL when MeterSerial is unknown
    MeterSerial         VARCHAR(50)          NOT NULL,
    ReadingTimestampUtc DATETIME2(3)         NULL,
    PreviousValue       DECIMAL(18,4)        NULL,
    ReportedValue       DECIMAL(18,4)        NULL,
    VarianceDelta       DECIMAL(18,4)        NULL,
    AnomalyType         VARCHAR(40)          NOT NULL, -- UNKNOWN_METER, NEGATIVE_DELTA, HIGH_VARIANCE, MALFORMED_PAYLOAD
    Reason              NVARCHAR(400)        NOT NULL,
    RawPayload          NVARCHAR(MAX)        NULL,
    LoggedAtUtc         DATETIME2(3)         NOT NULL CONSTRAINT DF_MeterReadingAnomalies_LoggedAt DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_MeterReadingAnomalies PRIMARY KEY CLUSTERED (AnomalyId),
    CONSTRAINT FK_MeterReadingAnomalies_Meters FOREIGN KEY (MeterId)
        REFERENCES Assignment3.Meters (MeterId),
    CONSTRAINT FK_MeterReadingAnomalies_AuditLog FOREIGN KEY (RunId)
        REFERENCES Assignment3.ReconciliationAuditLog (RunId)
);
GO

CREATE NONCLUSTERED INDEX IX_MeterReadingAnomalies_Type_LoggedAt
    ON Assignment3.MeterReadingAnomalies (AnomalyType, LoggedAtUtc DESC);
CREATE NONCLUSTERED INDEX IX_MeterReadingAnomalies_MeterSerial
    ON Assignment3.MeterReadingAnomalies (MeterSerial);
GO

SET NOCOUNT ON;

DECLARE @Run1 UNIQUEIDENTIFIER = NEWID();
DECLARE @Run2 UNIQUEIDENTIFIER = NEWID();

-- =========================================================
-- 1. Assignment3.Consumers
-- =========================================================
INSERT INTO Assignment3.Consumers (AccountNumber, FullName, FeederId, ServiceAddress, Category, IsActive)
VALUES
    ('ACC-1001', N'Aarav Sharma',    'FDR-01', N'14 Green Park, Sector 4',     'RESIDENTIAL', 1),
    ('ACC-1002', N'Priya Nair',      'FDR-01', N'22 Lakeview Rd, Block B',     'RESIDENTIAL', 1),
    ('ACC-1003', N'Vikram Mehta',    'FDR-02', N'88 Industrial Estate Phase 2', 'COMMERCIAL',  1),
    ('ACC-1004', N'Neha Kulkarni',   'FDR-02', N'05 Hilltop Colony',           'RESIDENTIAL', 1);

-- =========================================================
-- 2. Assignment3.Meters
-- =========================================================
INSERT INTO Assignment3.Meters (MeterSerial, ConsumerId, FeederId, Status, InstalledAtUtc)
VALUES
    ('MTR-9001', (SELECT ConsumerId FROM Assignment3.Consumers WHERE AccountNumber = 'ACC-1001'), 'FDR-01', 'ACTIVE',       '2025-01-15T08:00:00'),
    ('MTR-9002', (SELECT ConsumerId FROM Assignment3.Consumers WHERE AccountNumber = 'ACC-1002'), 'FDR-01', 'ACTIVE',       '2025-02-10T09:30:00'),
    ('MTR-9003', (SELECT ConsumerId FROM Assignment3.Consumers WHERE AccountNumber = 'ACC-1003'), 'FDR-02', 'ACTIVE',       '2025-03-05T10:15:00'),
    ('MTR-9004', (SELECT ConsumerId FROM Assignment3.Consumers WHERE AccountNumber = 'ACC-1004'), 'FDR-02', 'FAULTY',       '2025-04-20T11:00:00');

-- =========================================================
-- 3. Assignment3.TariffSlabs
-- =========================================================
INSERT INTO Assignment3.TariffSlabs (SlabCode, ConsumerCategory, MinUnits, MaxUnits, RatePerUnit, FixedCharge, EffectiveFrom, EffectiveTo, IsActive)
VALUES
    ('RES-T1', 'RESIDENTIAL', 0.0000,   100.0000, 4.5000, 50.00,  '2026-01-01T00:00:00', NULL, 1),
    ('RES-T2', 'RESIDENTIAL', 100.0000, 300.0000, 6.7500, 75.00,  '2026-01-01T00:00:00', NULL, 1),
    ('RES-T3', 'RESIDENTIAL', 300.0000, NULL,     8.5000, 100.00, '2026-01-01T00:00:00', NULL, 1),
    ('COM-T1', 'COMMERCIAL',  0.0000,   NULL,     9.2500, 250.00, '2026-01-01T00:00:00', NULL, 1);

-- =========================================================
-- 4. Assignment3.MeterReadings
-- =========================================================
INSERT INTO Assignment3.MeterReadings (
    ExternalReadingId, MeterId, BatchCursor, ReadingTimestampUtc,
    PreviousValue, CurrentValue, ConsumptionDelta, BilledAmount, TariffSlabId, IsAnomalous
)
VALUES
    (
        'EXT-RD-001',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9001'),
        'CUR-20261124-01', '2026-11-24T00:00:00',
        1200.0000, 1280.0000, 80.0000, 410.00,
        (SELECT TariffSlabId FROM Assignment3.TariffSlabs WHERE SlabCode = 'RES-T1' AND EffectiveFrom = '2026-01-01T00:00:00'),
        0
    ),
    (
        'EXT-RD-002',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9001'),
        'CUR-20261125-01', '2026-11-25T00:00:00',
        1280.0000, 1430.0000, 150.0000, 1087.50,
        (SELECT TariffSlabId FROM Assignment3.TariffSlabs WHERE SlabCode = 'RES-T2' AND EffectiveFrom = '2026-01-01T00:00:00'),
        0
    ),
    (
        'EXT-RD-003',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9002'),
        'CUR-20261125-01', '2026-11-25T00:00:00',
        500.0000, 565.5000, 65.5000, 344.75,
        (SELECT TariffSlabId FROM Assignment3.TariffSlabs WHERE SlabCode = 'RES-T1' AND EffectiveFrom = '2026-01-01T00:00:00'),
        0
    ),
    (
        'EXT-RD-004',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9003'),
        'CUR-20261125-02', '2026-11-25T00:00:00',
        8400.0000, 8920.0000, 520.0000, 5060.00,
        (SELECT TariffSlabId FROM Assignment3.TariffSlabs WHERE SlabCode = 'COM-T1' AND EffectiveFrom = '2026-01-01T00:00:00'),
        0
    ),
    (
        'EXT-RD-005',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9004'),
        'CUR-20261125-02', '2026-11-25T00:00:00',
        450.0000, 410.0000, -40.0000, 0.00,
        NULL,
        1
    );

-- =========================================================
-- 5. Assignment3.DispatchAlerts
-- =========================================================
INSERT INTO Assignment3.DispatchAlerts (ExternalTicketId, FeederId, MeterId, AlertType, Severity, Description, Status, ReportedAtUtc)
VALUES
    (
        'TKT-5001', 'FDR-02',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9004'),
        'TAMPER', 'HIGH', N'Reverse meter delta detected on smart meter MTR-9004.', 'OPEN', '2026-11-25T01:15:00'
    ),
    (
        'TKT-5002', 'FDR-01',
        NULL,
        'OUTAGE', 'CRITICAL', N'Substation feeder FDR-01 tripped due to transformer overload.', 'IN_PROGRESS', '2026-11-25T03:40:00'
    );

-- =========================================================
-- 6. Assignment3.ReconciliationAuditLog
-- =========================================================
INSERT INTO Assignment3.ReconciliationAuditLog (
    RunId, FeederId, BatchCursor, StartedAtUtc, CompletedAtUtc,
    TotalFetched, InsertedCount, DuplicateCount, AnomalyCount, FailedCount, RunStatus, ErrorMessage
)
VALUES
    (
        @Run1, 'FDR-01', 'CUR-20261125-01', '2026-11-25T06:00:00', '2026-11-25T06:00:04',
        3, 2, 1, 0, 0, 'SUCCESS', NULL
    ),
    (
        @Run2, 'FDR-02', 'CUR-20261125-02', '2026-11-25T06:05:00', '2026-11-25T06:05:06',
        4, 2, 0, 2, 0, 'PARTIAL_SUCCESS', N'2 anomalous records logged (1 negative delta, 1 unknown meter serial).'
    );

-- =========================================================
-- 7. Assignment3.MeterReadingAnomalies
-- =========================================================
INSERT INTO Assignment3.MeterReadingAnomalies (
    RunId, ExternalReadingId, MeterId, MeterSerial, ReadingTimestampUtc,
    PreviousValue, ReportedValue, VarianceDelta, AnomalyType, Reason, RawPayload
)
VALUES
    (
        @Run2, 'EXT-RD-005',
        (SELECT MeterId FROM Assignment3.Meters WHERE MeterSerial = 'MTR-9004'),
        'MTR-9004', '2026-11-25T00:00:00',
        450.0000, 410.0000, -40.0000, 'NEGATIVE_DELTA',
        N'Current reading (410.0000) is lower than previous reading (450.0000).',
        N'{"externalReadingId":"EXT-RD-005","meterSerial":"MTR-9004","currentValue":410.0}'
    ),
    (
        @Run2, 'EXT-RD-999',
        NULL,
        'MTR-UNKNOWN-77', '2026-11-25T00:00:00',
        NULL, 215.7500, NULL, 'UNKNOWN_METER',
        N'MeterSerial MTR-UNKNOWN-77 does not exist in Assignment3.Meters.',
        N'{"externalReadingId":"EXT-RD-999","meterSerial":"MTR-UNKNOWN-77","currentValue":215.75}'
    );

SELECT * FROM Assignment3.Consumers;
SELECT * FROM Assignment3.Meters;
SELECT * FROM Assignment3.TariffSlabs;
SELECT * FROM Assignment3.MeterReadings;
SELECT * FROM Assignment3.DispatchAlerts;
SELECT * FROM Assignment3.ReconciliationAuditLog;
SELECT * FROM Assignment3.MeterReadingAnomalies;