--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2020 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 10: DEVELOPING, DEPLOYING, AND MANAGING DATA RECOVERY
-- T-SQL SAMPLE 2
--

CREATE CREDENTIAL [https://ssio2019.blob.core.windows.net/onprembackup]
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
    -- Remember to remove the leading ? from the token
    SECRET = 'sv=2018-03-28&ss=…';
BACKUP DATABASE SamplesTest
    TO URL = 'https://ssio2019.blob.core.windows.net/onprembackup/db.bak';