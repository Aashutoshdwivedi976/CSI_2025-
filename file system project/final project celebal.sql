------------Step 1'-------------------------

CREATE TABLE FileSystem (
    NodeID INT PRIMARY KEY,
    NodeName VARCHAR(50),
    ParentID INT,
    SizeBytes INT
);

INSERT INTO FileSystem (NodeID, NodeName, ParentID, SizeBytes)
VALUES 
    (1, 'Documents', NULL, NULL),
    (2, 'Pictures', NULL, NULL),
    (3, 'File1.txt', 1, 500),
    (4, 'Folder1', 1, NULL),
    (5, 'Image.jpg', 2, 1200),
    (6, 'Subfolder1', 4, NULL),
    (7, 'File2.txt', 4, 750),
    (8, 'File3.txt', 6, 300),
    (9, 'Folder2', 2, NULL),
    (10, 'File4.txt', 9, 250);

	----------step -2 -------------------------------------

	--verify the data 

	SELECT * FROM FileSystem ORDER BY NodeID;

	-------------step-3 --------------------------------------------
--Solution Using Recursive CTE

WITH FolderHierarchy AS (
    -- Base case: All folders (nodes with NULL SizeBytes)
    SELECT 
        NodeID,
        NodeName,
        ParentID,
        NodeID AS RootFolderID,
        0 AS Level
    FROM FileSystem
    WHERE SizeBytes IS NULL
    
    UNION ALL
    
    -- Recursive case: Child items
    SELECT 
        f.NodeID,
        f.NodeName,
        f.ParentID,
        h.RootFolderID,
        h.Level + 1
    FROM FileSystem f
    INNER JOIN FolderHierarchy h ON f.ParentID = h.NodeID
    WHERE f.SizeBytes IS NULL
),
FileSizes AS (
    -- Get all files with their sizes
    SELECT 
        NodeID,
        NodeName,
        ParentID,
        SizeBytes
    FROM FileSystem
    WHERE SizeBytes IS NOT NULL
),
FolderAggregates AS (
    -- Calculate total size for each folder hierarchy
    SELECT 
        h.RootFolderID,
        SUM(f.SizeBytes) AS TotalSizeBytes
    FROM FolderHierarchy h
    JOIN FileSizes f ON f.ParentID = h.NodeID
    GROUP BY h.RootFolderID
)
-- Final result combining folders and files
SELECT 
    f.NodeID,
    f.NodeName,
    CASE 
        WHEN f.SizeBytes IS NULL THEN ISNULL(a.TotalSizeBytes, 0)
        ELSE f.SizeBytes
    END AS TotalSizeBytes
FROM FileSystem f
LEFT JOIN FolderAggregates a ON f.NodeID = a.RootFolderID
ORDER BY f.NodeID;

---Step 4: Alternative Solution (Simpler Approach)

WITH FolderSizes AS (
    SELECT 
        f.NodeID,
        f.NodeName,
        COALESCE(
            (SELECT SUM(SizeBytes) FROM FileSystem WHERE ParentID = f.NodeID AND SizeBytes IS NOT NULL),
            0
        ) AS DirectFileSize,
        COALESCE(
            (SELECT SUM(SizeBytes) 
             FROM FileSystem 
             WHERE ParentID IN (SELECT NodeID FROM FileSystem WHERE ParentID = f.NodeID) 
             AND SizeBytes IS NOT NULL),
            0
        ) AS SubfolderFileSize
    FROM FileSystem f
    WHERE f.SizeBytes IS NULL
)
SELECT 
    NodeID,
    NodeName,
    (DirectFileSize + SubfolderFileSize) AS TotalSizeBytes
FROM FolderSizes
UNION ALL
SELECT 
    NodeID,
    NodeName,
    SizeBytes AS TotalSizeBytes
FROM FileSystem
WHERE SizeBytes IS NOT NULL
ORDER BY NodeID;