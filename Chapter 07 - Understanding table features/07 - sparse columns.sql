--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 8
--

CREATE TABLE OrderDetails (
    OrderId int NOT NULL,
    OrderDetailId int NOT NULL,
    ProductId int NOT NULL,
    Quantity int NOT NULL,
    ReturnedDate date SPARSE NULL,
    ReturnedReason varchar(50) SPARSE NULL);