USE msdb;
GO
--Check if there is any record in msdb.dbo.suspect_pages
--Update the email recipient parameter in line 13 for testing and other purposes
IF (
SELECT	COUNT(*)
FROM	dbo.suspect_pages
WHERE	event_type IN (1,2,3)
	) > 0
	BEGIN
	--Start building the email properties and content
		DECLARE @recipients NVARCHAR(MAX);
		SELECT	@recipients = 'ssbcidbaalerts@ssbinfo.com';
		DECLARE @tableHTML NVARCHAR(MAX);
		DECLARE @Table NVARCHAR(MAX) = N'';

		SELECT @Table = @Table +'<tr style="background-color:white;font-size: 12px;text-align:center;">' +
			'<td>' + CAST(@@servername AS VARCHAR(128)) + '</td>' +
			'<td>' + CAST([d].[name] AS VARCHAR(128)) + '</td>' +
			'<td>' + CAST([sp].[database_id] AS VARCHAR(8)) + '</td>' +
			'<td>' + CAST([sp].[file_id] AS VARCHAR(8)) + '</td>' +
			'<td>' + CAST([sp].[page_id] AS VARCHAR(128)) + '</td>' +
			'<td>' + CAST([sp].[event_type] AS VARCHAR(128)) + '</td>' +
			'<td>' + CAST([sp].[error_count] AS VARCHAR(128)) + '</td>' +
			'<td>' + CAST([sp].[last_update_date] AS VARCHAR(64)) + '</td>' +
			'</tr>'
		FROM	dbo.suspect_pages AS sp
			INNER JOIN sys.databases AS d ON sp.database_id = d.database_id
		WHERE	sp.event_type IN (1,2,3);

		SELECT @tableHTML =
		N'https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/manage-the-suspect-pages-table-sql-server?view=sql-server-2017' +
		N'<table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;" >' +--text-align:center;" >' +
		N'<tr style ="font-size: 12px;font-weight: normal;background: white;">
		<th>ServerName</th>
		<th>DatabaseName</th>
		<th>database_id</th>
		<th>file_id</th>
		<th>page_id</th>
		<th>event_type</th>
		<th>error_count</th>
		<th>last_update_date</th></tr>' + @Table +	N'</table>';

		DECLARE @Subj varchar(128);
		SELECT @Subj = @@servername + '.msdb.dbo.suspect_pages Monitor';

		EXEC msdb.dbo.sp_send_dbmail
			  @recipients = @recipients
			, @subject = @Subj
			, @body_format = 'HTML'
			, @Body = @tableHTML;
	END
GO
