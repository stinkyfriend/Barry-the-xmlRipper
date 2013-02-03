<cfcomponent accessors="true">
	
	<cfproperty name="BaseFilePath">
	<cfproperty name="SourceFilePath">
	<cfproperty name="SourceFiles">
		
	<cffunction name="init" access="public" returntype="obj_FileManager">
		
		<cfset setBaseFilePath(ExpandPath("/"))>
		<cfset setSourceFilePath(getBaseFilePath() & 'data/')>
		<cfset processAllFiles(getSourceFilePath())>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processAllFiles" access="private">
		<cfargument name="sourceFilePath">
		
		<cfset var qry = QueryNew("")>
		
		<cfdirectory action="list" directory="#arguments.sourceFilePath#" name="qry" recurse="true">
		
		<cfset processFiles(qry)>
		
	</cffunction>
	
	<cffunction name="processFiles" access="private">
		<cfargument name="sourceFiles">
		
		<cfset var arrIsSourceFile = []>
		<cfset var arrIsJSONFile = []>
		<cfset var arrFileID = []>
		<cfset var qry = QueryNew("")>
		
		<cfif arguments.sourceFiles.recordcount gt 0>
			<!--- We need to add a couple of extra columns to the cfdirectory query.
					These columns identify whether or not there are XML files; generated JSON files; it also creates a 'fileID' column. --->
			<cfloop query="arguments.sourceFiles">
				<cfset IsSourceFile = false>
				<cfset fileID = "">
					<cfif ListLast(name,".") is 'xml' OR ListLast(name,".") is 'csv'>
						<cfset IsSourceFile = true>
						<cfset fileID = hash(directory & '\' & name)>
					</cfif>
				
				<cfset ArrayAppend(arrIsSourceFile, IsSourceFile)>
				<cfset ArrayAppend(arrFileID, fileID)>
				<cfset ArrayAppend(arrIsJSONFile, false)>
				
			</cfloop>
		</cfif>
			
		<cfset QueryAddColumn(arguments.sourceFiles,'isSourceFile',arrIsSourceFile)>
		<cfset QueryAddColumn(arguments.sourceFiles,'fileID',arrFileID)>
				
		<cfquery name="qry" dbtype="query">
			SELECT 		*
			FROM 		arguments.sourceFiles
			WHERE 		isSourceFile = 'true'
		</cfquery>
		
		<cfset setHasSourceFiles((qry.recordcount gt 0 ? true : false))>
		<cfset setSourceFiles(qry)>
		
	</cffunction>
	
	<cffunction name="createNewFolder" access="public">
		<cfset var str = {}>
		<cfset var folder = mid(CreateUUID(), 3, 2)>
		<cfset var path = getSourceFilePath() & folder & "/">
		
		<cfdirectory action="create" directory="#path#">
		
		<cfset str["folder"] = folder>
		<cfset str["path"] = path>
		
		<cfreturn str>
	</cffunction>
	
	<cffunction name="setHasSourceFiles" access="private">
		<cfargument name="hasSourceFiles">
		<cfset variables.hasSourceFiles = arguments.hasSourceFiles>
	</cffunction>
	
	<cffunction name="hasSourceFiles">
		<cfreturn variables.hasSourceFiles>
	</cffunction>
	
</cfcomponent>