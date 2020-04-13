--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 11
--
CREATE TABLE dbo.People (
    PersonId int NOT NULL PRIMARY KEY CLUSTERED,
    FirstName nvarchar(50) NOT NULL,
    LastName nvarchar(50) NOT NULL
) AS NODE;

CREATE TABLE dbo.Relationships (
    RelationshipType nvarchar(50) NOT NULL,
    CONSTRAINT EC_Relationship CONNECTION (dbo.People TO dbo.People),
    -- Two people can only be related once
    CONSTRAINT UX_Relationship UNIQUE ($from_id, $to_id)
) AS EDGE;

CREATE TABLE dbo.Animals (
    AnimalId int NOT NULL PRIMARY KEY CLUSTERED,
    AnimalName nvarchar(50) NOT NULL
) AS NODE;

ALTER TABLE dbo.Relationships
    DROP CONSTRAINT EC_Relationship;

ALTER TABLE dbo.Relationships
    ADD CONSTRAINT EC_Relationship CONNECTION (dbo.People TO dbo.People,
	    dbo.People TO dbo.Animals);

-- Insert a few sample people
-- $node_id is implicit and skipped
INSERT INTO People VALUES
	(1, 'Karina', 'Jakobsen'),
	(2, 'David', 'Hamilton'),
	(3, 'James', 'Hamilton'),
	(4, 'Stella', 'Rosenhain');

-- Insert a few sample relationships
-- The first sub-select retrieves the $node_id of the from_node
-- The second sub-select retrieves the $node_id of the to node
INSERT INTO Relationships VALUES
	((SELECT $node_id FROM People WHERE PersonId = 1),
	 (SELECT $node_id FROM People WHERE PersonId = 2),
	 'spouse'),
	((SELECT $node_id FROM People WHERE PersonId = 2),
	 (SELECT $node_id FROM People WHERE PersonId = 3),
	 'father'),
	((SELECT $node_id FROM People WHERE PersonId = 4),
	 (SELECT $node_id FROM People WHERE PersonId = 2),
	 'mother');

-- Simple graph query
SELECT P1.FirstName + ' is the ' + R.RelationshipType +
	' of ' + P2.FirstName + '.'
FROM People P1 LEFT JOIN Application.People P3 ON P3.PreferredName = P1.FirstName
	, People P2, Relationships R
WHERE MATCH(P1-(R)->P2);

-- SHORTEST_PATH query
-- Construct Stella Rosenhain's direct descendants' family tree
SELECT P1.FirstName
	, STRING_AGG(' is ' + P2.FirstName + '''s ' + related_to1.RelationshipType, ' ->') WITHIN GROUP (GRAPH PATH) AS [Descendants]
	, LAST_VALUE(P2.FirstName) WITHIN GROUP (GRAPH PATH) AS [Final relation]
	, COUNT(P2.PersonId) WITHIN GROUP (GRAPH PATH) AS [Level]
	, P1.FirstName + ' is ' + LAST_VALUE(P2.FirstName) WITHIN GROUP (GRAPH PATH) + '''s ' + 
		CASE WHEN COUNT(P2.PersonId) WITHIN GROUP (GRAPH PATH) = 2 THEN 'grand'
			 WHEN COUNT(P2.PersonId) WITHIN GROUP (GRAPH PATH) > 2 THEN 'great grand' END
FROM People P1
	, People FOR PATH P2
	, Relationships FOR PATH related_to1
WHERE (MATCH(SHORTEST_PATH(P1(-(related_to1)->P2)+))
	-- Stella Rosenhain
	AND P1.PersonId = 4);