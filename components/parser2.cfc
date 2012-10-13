<cfcomponent>
	
	<cffunction name="init" output="false">
		<cfargument name="filePath" required="true" hint="The full path to the xml file you want to analyse">
		<cfargument name="howManyRecords" required="false" default="-1" hint="How many records [properties] do you want to analyse? -1 means all records.">
		<!--- @TODO Allow a user to manually enter the node that identifies the 'record' node --->
		<cfargument name="recordNode" required="false" default="Enter the node that identifies the 'record' node">
		
		<cfset var fis = createObject("java", "java.io.FileInputStream").init(arguments.filePath)>
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
						     <cfset metadata[node_path] = {"length"=len(reader.getAttributeValue(i-1)), 
						     								"datatype"=(len(reader.getAttributeValue(i-1)) gt 0 ? (isNumeric(reader.getAttributeValue(i-1)) ? 'number' : 'varchar') : ''),
							 								"nullable"=(len(reader.getAttributeValue(i-1))?true:false)}>
							  <!--- If the value is null then no datatype.
							  		If the value is numeric then number. --->
						<cfelse>
							<cfset metadata[node_path]["length"] = (len(reader.getAttributeValue(i-1)) gt metadata[node_path]["length"] ? len(reader.getAttributeValue(i-1)) : metadata[node_path]["length"])>
							<cfset metadata[node_path]["datatype"] = (metadata[node_path]["datatype"] is 'varchar' ? 'varchar' : (len(reader.getAttributeValue(i-1)) gt 0 ? (isNumeric(reader.getAttributeValue(i-1)) ? 'number' : 'varchar') : ''))>
							<cfset metadata[node_path]["nullable"] = (metadata[node_path]["nullable"] ? true : (len(reader.getAttributeValue(i-1))? true : false))>
						</cfif>
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
	                <cfset tempstr = {"length"=len(reader.getText()), 
										"datatype"=(len(reader.getText()) gt 0 ? (isNumeric(reader.getText()) ? 'number' : 'varchar') : ''), 
										"nullable"=(len(reader.getText())?true:false)}>
	                <cfset metadata[for] = tempstr>
				<cfelse>
					<cfset metadata[for]["length"] = (len(reader.getText()) gt metadata[for]["length"] ? len(reader.getText()) : metadata[for]["length"])>
					<cfset metadata[for]["datatype"] = (metadata[for]["datatype"] is 'varchar' ? 'varchar' : (len(reader.getText()) gt 0 ? (isNumeric(reader.getText()) ? 'number' : 'varchar') : ''))>
					<cfset metadata[for]["nullable"] = (metadata[for]["nullable"] ? true : (len(reader.getText())? true : false))>
				</cfif>
				<cfset waitingForCharacters = false>
	            <cfset for = "">
			</cfif>
		    
		    <cfif event EQ reader.END_ELEMENT>
				<cfset node_path = ListDeleteAt(node_path, ListFind(node_path, reader.getLocalName(), '|'), '|')>
				<cfset waitingForCharacters = false>
            	<cfset for = "">				
				<cfif reader.getLocalName() is recordNode>
					<cfif arguments.howManyRecords gte 0 AND countRecords gte arguments.howManyRecords>
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>
			
		</cfloop>
		
		<cfset setRecordCount(countRecords)>
		<cfset setMetaData(metadata)>
		<cfset reader.close()>
		 
	</cffunction>
	
	<cffunction name="getRecordCount">
		<cfreturn variables.recordcount>
    </cffunction>
    
    <cffunction name="setRecordCount">
		<cfargument name="recordcount">
		<cfset variables.recordcount = arguments.recordcount>
        <cfreturn variables.recordcount>
    </cffunction>
    
    <cffunction name="getMetaData">
        <cfreturn variables.metadata>
    </cffunction>
    
    <cffunction name="setMetaData">
		<cfargument name="metadata">
		<cfset variables.metadata = arguments.metadata>
        <cfreturn variables.metadata>
    </cffunction>
	
	
</cfcomponent>