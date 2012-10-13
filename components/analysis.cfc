<cfcomponent>
	
	<cffunction name="init">
		<cfargument name="filePath" required="true" hint="The full path to the xml file you want to analyse">
		<cfargument name="howManyRecords" required="false" default="-1" hint="How many records [properties] do you want to analyse? -1 means all records.">
		<!--- @TODO Allow a user to manually enter the node that identifies the 'record' node, multiple record nodes. --->
		<cfargument name="recordNode" required="false" default="Enter the node that identifies the 'record' node">
		
		<cfset setFilePath(arguments.filePath)>
		<cfset setRecordLimit(arguments.howManyrecords)>
		<cfset setRecordNode(arguments.recordNode)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="runAnalysis" output="false">
		<cfset var fis = createObject("java", "java.io.FileInputStream").init(getFilePath())>
		<cfset var bis = createObject("java", "java.io.BufferedInputStream").init(fis)>
		<cfset var XMLInputFactory = createObject("java", "javax.xml.stream.XMLInputFactory").newInstance()>
		<cfset var reader = XMLInputFactory.createXMLStreamReader(bis)>
		<cfset var countStartElements = 0>
		<cfset var countEvents = 0>
		<cfset var countRecords = 0>
		<cfset var extractCharacters = false>
		<cfset var metadata = {}>
		<cfset var node_path = "">
		<cfset var event = "">
		<cfset var node_attributes = []>
		<cfset var tempstr = {}>
		<cfset var for = "">
		<cfset var howManyRecords = getRecordLimit()>
		
		<!--- If there is another element then process it --->
		<cfloop condition="#reader.hasNext()#">
			<cfset event = reader.next()>
			
			<cfset countEvents++>
			
			<!--- If the current event is a 'START_ELEMENT' --->
			<cfif event EQ reader.START_ELEMENT>
				<cfset countStartElements++>
				<cfset node_path = node_path & (len(node_path) gt 0? '|' : '') & reader.getLocalName()>
				
				<cfif not StructKeyExists(metadata, node_path)>
				     <cfset metadata["#node_path#"] = "">
				</cfif>
				<cfset for = node_path>
				<cfset waitingForCharacters = true>
				
				<cfset node_attributes = []>
				
				<!--- Get all the attributes for the current START_ELEMENT --->
				<cfset HowManyAttributes = reader.getAttributeCount()>
				<cfif HowManyAttributes gt 0>
					<cfloop from="1" to="#HowManyAttributes#" index="i" >
						<cfset node_path = node_path & (len(node_path) gt 0? '|@' : '') & reader.getAttributeLocalName(i-1)>
						<cfif not StructKeyExists(metadata, node_path)>
						     <cfset local.datatype = (len(reader.getAttributeValue(i-1)) gt 0 ? (isNumeric(reader.getAttributeValue(i-1)) ? (reader.getAttributeValue(i-1) contains '.' ? 'decimal' : 'integer') : 'varchar') : '')>
						     <cfset local.length = local.datatype is 'decimal' ? (len(getToken(reader.getAttributeValue(i-1),1,".")) + len(getToken(reader.getAttributeValue(i-1),2,"."))) & ',' & len(getToken(reader.getAttributeValue(i-1),2,".")) : len(reader.getAttributeValue(i-1))> 
						     <cfset local.nullable = (len(reader.getAttributeValue(i-1))?true:false)>
							  <!--- If the value is null then no datatype.
							  		If the value is numeric then number. --->
						<cfelse>
							<cfset local.datatype = (metadata[node_path]["datatype"] is 'varchar' ? 'varchar' : (len(reader.getAttributeValue(i-1)) gt 0 ? (isNumeric(reader.getAttributeValue(i-1)) ? (reader.getAttributeValue(i-1) contains '.' ? 'decimal' : 'integer') : 'varchar') : ''))>
							<cfset local.length = local.datatype is 'decimal' ? 
										((len(getToken(reader.getAttributeValue(i-1),1,".")) + len(getToken(reader.getAttributeValue(i-1),2,"."))) gt len(getToken(metadata[node_path]["length"],1,",")) ? (len(getToken(reader.getAttributeValue(i-1),1,".")) + len(getToken(reader.getAttributeValue(i-1),2,"."))) : len(getToken(metadata[node_path]["length"],1,",")))
										& ',' &
										(len(getToken(reader.getAttributeValue(i-1),2,".")) gt len(getToken(metadata[node_path]["length"],2,",")) ? len(getToken(reader.getAttributeValue(i-1),2,".")) : len(getToken(metadata[node_path]["length"],2,",")))
										: (len(reader.getAttributeValue(i-1)) gt metadata[node_path]["length"] ? len(reader.getAttributeValue(i-1)) : metadata[node_path]["length"])>
							<cfset local.nullable = (metadata[node_path]["nullable"] ? true : len(local.length) ? true : false)>
						</cfif>
						<cfset metadata[node_path]["length"] = local.length>
						<cfset metadata[node_path]["datatype"] = local.datatype>
						<cfset metadata[node_path]["nullable"] = local.nullable>
						<cfset node_path = ListDeleteAt(node_path, ListFind(node_path, '@' & reader.getAttributeLocalName(i-1), '|'), '|')>
					</cfloop>
				</cfif>
				
		        <!--- If we're on the first "start element" then we can assume this is the root node. --->
				<cfif countStartElements eq 1>
					<cfset rootNode = reader.getLocalName()>
					<cfset extractCharacters = false>
				</cfif>
				
				<cfif countStartElements gte 2>
					
					<!--- If we're on the second "start element" then we can assume this identifies a record. --->
					<cfif countStartElements eq 2>
						<cfset recordNode = reader.getLocalName()>
						<cfset extractCharacters = false>
						<cfset countRecords++>
					</cfif>
			        
			        <cfif countStartElements gt 2>
						<cfset extractCharacters = true>
						<cfif reader.getLocalName() is recordNode>
							<cfset countRecords++>
						</cfif>
					</cfif>
				</cfif>
		    </cfif>
		    
		    <!--- We only process characters if there are any --->
		    <cfif event EQ reader.CHARACTERS AND extractCharacters AND len(trim(reader.getText())) gt 0 AND waitingForCharacters>
				<cfif not IsStruct(metadata[for])>
					<cfset local.datatype = (len(reader.getText()) gt 0 ? (isNumeric(reader.getText()) ? (reader.getText() contains '.' ? 'decimal' : 'integer') : 'varchar') : '')>
					<cfset local.length = local.datatype is 'decimal' ? len(getToken(reader.getText(),1,".")) & ',' & len(getToken(reader.getText(),2,".")) : len(reader.getText())> 
					<cfset local.nullable = (len(reader.getText()) ? true : false)>
	                <cfset metadata[for] = {}>
	                <!---<cfset local.datatype = (len(reader.getText()) gt 0 ? (isNumeric(reader.getText()) ? 'number' : 'varchar') : '')>--->
					<!---<cfset local.length = len(reader.getText())>---> 
					<!---<cfset local.nullable = (len(reader.getText())?true:false)>--->
				<cfelse>
					<cfset local.datatype = (metadata[for]["datatype"] is 'varchar' ? 'varchar' : (len(reader.getText()) gt 0 ? (isNumeric(reader.getText()) ? (reader.getText() contains '.' ? 'decimal' : 'integer') : 'varchar') : ''))>
					<cfset local.length = local.datatype is 'decimal' ? 
								(len(getToken(reader.getText(),1,".")) gt len(getToken(metadata[for]["length"],1,",")) ? len(getToken(reader.getText(),1,".")) : len(getToken(metadata[for]["length"],1,",")))
								& ',' &
								(len(getToken(reader.getText(),2,".")) gt len(getToken(metadata[for]["length"],2,",")) ? len(getToken(reader.getText(),2,".")) : len(getToken(metadata[for]["length"],2,",")))
								: (len(reader.getText()) gt metadata[for]["length"] ? len(reader.getText()) : metadata[for]["length"])>
					<cfset local.nullable = (metadata[for]["nullable"] ? true : len(local.length) ? true : false)>
					
					<!---<cfset local.datatype = (metadata[for]["datatype"] is 'varchar' ? 'varchar' : (len(reader.getText()) gt 0 ? (isNumeric(reader.getText()) ? 'number' : 'varchar') : ''))>--->
					<!---<cfset local.length = (len(reader.getText()) gt metadata[for]["length"] ? len(reader.getText()) : metadata[for]["length"])>--->
					<!---<cfset local.nullable = (metadata[for]["nullable"] ? true : (len(reader.getText())? true : false))>--->
				</cfif>
				<cfset metadata[for]["length"] = local.length>
				<cfset metadata[for]["datatype"] = local.datatype>
				<cfset metadata[for]["nullable"] = local.nullable>
				<cfset waitingForCharacters = false>
	            <cfset for = "">
			</cfif>
		    
		    <cfif event EQ reader.END_ELEMENT>
				<cfset node_path = ListDeleteAt(node_path, ListFind(node_path, reader.getLocalName(), '|'), '|')>
				<cfset waitingForCharacters = false>
            	<cfset for = "">				
				<cfif reader.getLocalName() is recordNode>
					<cfif howManyRecords gte 0 AND countRecords gte howManyRecords>
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>
			
		</cfloop>
		
		<cfset setRecordCount(countRecords)>
		<cfset setMetaData(metadata)>
		<cfset save(data=metadata, type="analysis")>
		<cfset reader.close()>
		 
	</cffunction>
	
	<cffunction name="createTable">
		<cfset var s = readCreateFile()>
		
		<cfquery datasource="stinkylittlefriend">
			#s#
		</cfquery> 
		
	</cffunction>
	
	<cffunction name="getFilePath">
		<cfreturn this.FilePath>
    </cffunction>
    
    <cffunction name="setFilePath">
		<cfargument name="FilePath">
		<cfset this.FilePath = arguments.FilePath>
    </cffunction>
    
    <cffunction name="getRecordLimit">
		<cfreturn variables.howManyRecords>
    </cffunction>
    
    <cffunction name="setRecordLimit">
		<cfargument name="howManyRecords">
		<cfset variables.howManyRecords = arguments.howManyRecords>
    </cffunction>
    
    <cffunction name="getRecordNode">
		<cfreturn variables.RecordNode>
    </cffunction>
    
    <cffunction name="setRecordNode">
		<cfargument name="RecordNode">
		<cfset variables.RecordNode = arguments.RecordNode>
    </cffunction>
	
	<cffunction name="getRecordCount">
		<cfreturn variables.recordcount>
    </cffunction>
    
    <cffunction name="setRecordCount">
		<cfargument name="recordcount">
		<cfset variables.recordcount = arguments.recordcount>
    </cffunction>
    
    <cffunction name="getMetaData">
        <cfreturn variables.metadata>
    </cffunction>
    
    <cffunction name="setMetaData">
		<cfargument name="metadata">
		<cfset variables.metadata = arguments.metadata>
        <cfreturn variables.metadata>
    </cffunction>
    
    <cffunction name="getJSONFilePath">
		<cfset local.filePath = ListDeleteAt(getFilePath(), ListLen(getFilePath(),"\"), "\")>
		<cfset local.fileAnalysisFor = ListFirst(ListLast(getFilePath(), "\"),".")>
		<cfset local.jsonFilePath = local.filePath & "\" & local.fileAnalysisFor & "-json.txt">
        <cfreturn local.jsonFilePath>
    </cffunction>
    
    <cffunction name="getCreateScriptFilePath">
		<cfset local.filePath = ListDeleteAt(getFilePath(), ListLen(getFilePath(),"\"), "\")>
		<cfset local.fileAnalysisFor = ListFirst(ListLast(getFilePath(), "\"),".")>
		<cfset local.jsonFilePath = local.filePath & "\" & local.fileAnalysisFor & "-create.txt">
        <cfreturn local.jsonFilePath>
    </cffunction>
    
    <cffunction name="alreadyRun">
		<cfset local.JSONFilePath = getJSONFilePath()>
		
		<cfset local.exists = FileExists(local.JSONFilePath) ? true : false> 
		
        <cfreturn local.exists>
    </cffunction>
    
    <cffunction name="save">
		<cfargument name="data">
		<cfargument name="type">
		
		<cfswitch expression="#lcase(arguments.type)#">
			<cfcase value="analysis">
				<cfset local.data = serializeJSON(arguments.data)>
				<cfset local.path = getJSONFilePath()>
			</cfcase>
			<cfcase value="create">
				<cfset local.data = arguments.data>
				<cfset local.path = getCreateScriptFilePath()>
			</cfcase>
		</cfswitch>
		
		
		<cfset writeToFile(local.data,local.path)>
		
    </cffunction>
    
    <cffunction name="writeToFile">
		<cfargument name="data">
		<cfargument name="path">
		
		<cffile action="write" file="#arguments.path#" output="#arguments.data#" >
		
    </cffunction>
    
    <cffunction name="readJSONFile">
		
		<cfset local.jsonAnalysis = "">
		<cfset local.str = "">
		
		<cffile action="read" file="#getJSONFilePath()#" variable="local.jsonAnalysis" >
		
		<cfset local.str = deserializeJSON(local.jsonAnalysis)>
		
		<cfreturn local.str>
    </cffunction>
    
    <cffunction name="readCreateFile">
		
		<cfset local.s = "">
		
		<cffile action="read" file="#getCreateScriptFilePath()#" variable="local.s" >
		
		<cfreturn local.s>
    </cffunction>

</cfcomponent>