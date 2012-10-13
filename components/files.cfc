<cfcomponent accessors="true">
	
	<cfproperty name="BaseFilePath">
	<cfproperty name="SourceFilePath">
	
	<cffunction name="init" access="public" returntype="files">
		
		<cfset setBaseFilePath(ExpandPath("."))>
		<cfset setSourceFilePath(getBaseFilePath() & '\source\')>
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
		
		<cfset var arrIsSourceFile = ArrayNew(1)>
		<cfset var arrIsJSONFile = ArrayNew(1)>
		<cfset var qry = QueryNew("")>
		
		<cfif arguments.sourceFiles.recordcount gt 0>
			<cfloop query="arguments.sourceFiles">
				
				<cfif type is 'dir'>
					<cfset ArrayAppend(arrIsSourceFile, false)>			
				<cfelse>
					<cfif ListLast(name,".") is 'xml' OR ListLast(name,".") is 'csv'>
						<cfset ArrayAppend(arrIsSourceFile, true)>
					<cfelse>
						<cfset ArrayAppend(arrIsSourceFile, false)>
						<cfset ArrayAppend(arrIsJSONFile, false)>
					</cfif>
				</cfif>	
			</cfloop>
			
			<cfset QueryAddColumn(arguments.sourceFiles,'isSourceFile',arrIsSourceFile)>
			
		<cfelse>
			
			<cfset QueryAddColumn(arguments.sourceFiles,'isSourceFile',arrIsSourceFile)>
			
		</cfif>
		
		<cfquery name="qry" dbtype="query">
			SELECT 		*
			FROM 		arguments.sourceFiles
			WHERE 		isSourceFile = 'true'
		</cfquery>
		
		<cfset setHasSourceFiles((qry.recordcount gt 0 ? true : false))>
		<cfset setSourceFiles(qry)>
		
	</cffunction>
	
	<cffunction name="setHasSourceFiles" access="private">
		<cfargument name="hasSourceFiles">
		<cfset variables.hasSourceFiles = arguments.hasSourceFiles>
	</cffunction>
	
	<cffunction name="hasSourceFiles">
		<cfreturn variables.hasSourceFiles>
	</cffunction>
	
	<cffunction name="setSourceFiles" access="private">
		<cfargument name="SourceFiles">
		<cfset variables.SourceFiles = arguments.SourceFiles>
	</cffunction>
	
	<cffunction name="getSourceFiles">
		<cfreturn variables.SourceFiles>
	</cffunction>
	
</cfcomponent>