<cfcomponent>
	
	<cffunction name="init">
		<cfargument name="analysis" required="true">
		
		<cfset this.analysis = arguments.analysis>
		<cfset this.metadata = this.analysis.readJSONFile()>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="ripData" output="false">
		<cfset var fis = createObject("java", "java.io.FileInputStream").init(this.analysis.getFilePath())>
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
		<cfset var columns = {}>
		<cfset var howManyRecords = 100>
		<cfset var records = []>
		
		<!--- If there is another element then process it --->
		<cfloop condition="#reader.hasNext()#">
			<cfset event = reader.next()>
			
			<cfset countEvents++>
			
			<!--- If the current event is a 'START_ELEMENT' --->
			<cfif event EQ reader.START_ELEMENT>
				<cfset countStartElements++>
				<cfset node_path = node_path & (len(node_path) gt 0? '|' : '') & reader.getLocalName()>
				
				<!--- Find out if the CHARACTERS of the current node need to be processed. --->
				<cfset processNodeCharacters = StructKeyExists(this.metadata, node_path) AND IsStruct(this.metadata[node_path]) AND StructKeyExists(this.metadata[node_path], "process") AND this.metadata[node_path]["process"]>
				
				<cfset waitingForCharacters = processNodeCharacters>
				
				<cfset node_attributes = []>
				
				<!--- Get all the attributes for the current START_ELEMENT --->
				<cfset HowManyAttributes = reader.getAttributeCount()>
				<cfif HowManyAttributes gt 0>
					<cfloop from="1" to="#HowManyAttributes#" index="i" >
						<cfset node_path = node_path & (len(node_path) gt 0? '|@' : '') & reader.getAttributeLocalName(i-1)>
						
						<!--- Find out if the ATTRIBUTE value of the current node need to be processed. --->
						<cfset processAttribute = StructKeyExists(this.metadata, node_path) AND IsStruct(this.metadata[node_path]) AND StructKeyExists(this.metadata[node_path], "process") AND this.metadata[node_path]["process"]>
						
						<!--- If the current attribute is to be processed we get the value and we'll also need to get the column name. --->
						<cfif processAttribute>
							<cfset str[this.metadata[node_path]["columnname"]] = [reader.getAttributeValue(i-1),this.metadata[node_path]["datatype"]]>
							<cfset columns[this.metadata[node_path]["columnname"]] = "">
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
		    
		    <!--- We only process characters if there are any and if the start node has been identified as one that needs to be processed. --->
		    <cfif event EQ reader.CHARACTERS AND extractCharacters AND len(trim(reader.getText())) gt 0 AND waitingForCharacters>
				<cfset str[this.metadata[node_path]["columnname"]] = [reader.getText(),this.metadata[node_path]["datatype"]]>
				<cfset columns[this.metadata[node_path]["columnname"]] = "">
				<cfset waitingForCharacters = false>
			</cfif>
		    
		    <cfif event EQ reader.END_ELEMENT>
				<cfset node_path = ListDeleteAt(node_path, ListFind(node_path, reader.getLocalName(), '|'), '|')>
				<cfset waitingForCharacters = false>
				<cfif reader.getLocalName() is recordNode>
					<cfset ArrayAppend(records, str)>
					<cfset str = {}>
					<cfif (countRecords mod howManyRecords) eq 0>
						<cfset batchInsert(columns,records)>
						<cfset records = []>
					</cfif>
				</cfif>
			</cfif>
			
		</cfloop>
		
		<cfset reader.close()>
		 <cfabort>
	</cffunction>

	<cffunction name="batchInsert" >
		<cfargument name="columns" >
		<cfargument name="records" >
		
		<cfquery>
			INSERT INTO 	TOI_T_TOILETS 
				(<cfset count = 1><cfset arr = []><cfloop collection="#arguments.columns#" item="column">#count gt 1 ? ',' : ''##column#<cfset arr[count] = column><cfset count++></cfloop>)
			VALUES <cfset recordIterator = arguments.records.iterator()>
			<cfloop condition="recordIterator.hasNext()"><cfset str = recordIterator.next()>
				(<cfset columnIterator = arr.iterator()><cfloop condition="columnIterator.hasNext()"><cfset column = columnIterator.next()>
					#StructKeyExists(str, column) ? (str[column][2] is 'varchar' ? "'#str[column][1]#'" : str[column][1]) : 'NULL'##columnIterator.hasNext() ? ',' : ''#
				</cfloop>)#recordIterator.hasNext() ? ',' : ''#
			</cfloop>
		</cfquery>
		
	</cffunction>

	
</cfcomponent>