SELECT DISTINCT so.name, so.type, com.text
FROM sys.objects so 
INNER JOIN sys.syscomments com ON so.object_id = com.id
WHERE so.type IN ('P', 'TR', 'FN','TF','IF','V') -- trigger  / procedure / function
AND com.text LIKE '%Computation_%'
AND com.text NOT LIKE '%Computation_Start%'
ORDER BY so.name

 
