--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 5
--

USE [WideWorldImporters];
GO

-- Add a unique constraint on WideWorldImporters.Application.Countries
-- Note: one already exists, UQ_Application_Countries_CountryName
ALTER TABLE [Application].Countries WITH CHECK
    ADD CONSTRAINT UC_CountryName UNIQUE (CountryName);

-- Add check contraint on WideWorldImporters.Sales.Invoices
ALTER TABLE Sales.Invoices WITH CHECK
    ADD CONSTRAINT CH_Comments CHECK (LastEditedWhen < '2019-09-01' OR Comments IS NOT NULL);

-- Add a new column with default constraint to Application.People
ALTER TABLE [Application].People
    ADD PrimaryLanguage nvarchar(50) NOT NULL
        CONSTRAINT DF_Application_People_PrimaryLanguage DEFAULT 'English';