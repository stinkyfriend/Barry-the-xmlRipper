<!--- The landing page for the importer process --->

<!--- This page allows a user to:

	Step 1. 
		- Either upload an XML file.
		
		  OR 
		
		  Select one that already exists in the uploads folder.
		
		- The user can also select how many records to return.
		
		
	Step 2.
		- Once the XML file has been selected display the fields for the selected number of records.
		
		
	Step 3.
		- Provide the user with an interface that allows them to
			1. Determine which fields to be imported.
			2. Alias the field names.
			3. Select a datatype for the data.
			4. Select a table name to store the data.
			5. Indicate a field as relational and select another table.  
			
--->
<cfsetting requesttimeout="240" >
<!doctype html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<title>API - Data Importer</title>
		<meta name="description" content="">
		
		<meta name="viewport" content="width=device-width">
		<link rel="stylesheet" href="css/style.css">
	
	</head>
	<body>
		<header>
			<h1>API - Data Importer</h1>
		</header>
		
		<div role="main">
			<form action="controllers/ctl_step1.cfm" method="post">
				<fieldset>
					<p>
						<input type="file" id="FileUpload" name="FileUpload" />
						<input type="submit" value="Upload" />
					</p>
					<input type="hidden" name="action" value="FileUpload" />
				</fieldset>
				<cfif application.objFiles.hasSourceFiles()>
					<fieldset>
						<cfset qry = application.objFiles.getSourceFiles()>
						<cfoutput query="qry">
							<div>
							<input type="image" src="images/document.png" name="document" value="#name#" /><br />
							#name#
							</div>
						</cfoutput>
					</fieldset>
				</cfif>
				
			</form>
			
			<div style="background-color: #000; color: #FFF;"><h2>File Name here ></h2></div>
			
			<cfset filePath = ExpandPath(".") & "/source/1/ToiletmapExport.xml">
			
			<cfset render = CreateObject("component","components.render")>
			<cfset parser = CreateObject("component","components.parser")>
			
			<cfset render.init()>
			<cfset parser.init(filePath, 1, render)>
			
			<cfset analysis = CreateObject("component","components.analysis")>
			<cfset analysis.init(filePath,-1)>
			
			<div id="output-canvas">
			    <cfoutput>
					#render.getRender()#
				</cfoutput>
			</div>
			
			<div id="output-console">
				Placeholder for database table info.
				<!---Using the '+' icons beside the nodes and attributes you wish to export from the xml file into your database.--->
				<cfif analysis.alreadyRun()>
					<cfset strFields = analysis.readJSONFile()>
					<cfset fieldsSelected = StructKeyExists(strFields, "__selected")>
					<form action="controllers/ctl_step2.cfm" method="post">
						<cfset count = 0>
						<cfloop collection="#strFields#" item="key">

							<cfif IsStruct(strFields[key])>
								<cfset count++>
								<cfset originalName = ListLast(key, "|")>
								<cfset class = (fieldsSelected ? StructKeyExists(strFields[key],"process") AND strFields[key]["process"] ? (left(originalName, 1) eq "@" ? "attribute" : "node") : 'noaction' : (left(originalName, 1) eq "@" ? "attribute" : "node"))>
								<cfoutput>
								<div class="columnDefinition #class#"> 
									<input type="checkbox" name="process_#count#" #(fieldsSelected AND StructKeyExists(strFields[key],"process") AND strFields[key]["process"] ? 'checked="checked"' : '')# />
									<input type="text" name="newFieldName_#count#" value="#(fieldsSelected AND StructKeyExists(strFields[key],"columnname") ? strFields[key]["columnname"] : originalName)#" />
									#(fieldsSelected AND StructKeyExists(strFields[key],"columnname") ? originalName : '')#
									<input type="hidden" name="originalFieldName_#count#" value="#originalName#" />
									<input type="hidden" name="fullFieldLocation_#count#" value="#key#" />
								</div>
								</cfoutput>
							</cfif>

						</cfloop>
						<cfoutput><input type="hidden" name="filePath" value="#filePath#" /></cfoutput>
						<input type="submit" name="SaveSettings" value="Save" />
						<input type="submit" name="SaveSettings" value="Schema" />
						<input type="submit" name="SaveSettings" value="Data" />
					</form>

				<cfelse>
					<cfset analysis.runAnalysis()>
					<cfoutput>#analysis.getRecordCount()#</cfoutput>
					<cfdump var="#analysis.getMetadata()#">
				</cfif>				
			</div>
			<div style="clear:both;"></div>
		</div>
		
		<footer>
		
		</footer>
		
		
		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
		<script>window.jQuery || document.write('<script src="js/libs/jquery-1.7.1.min.js"><\/script>')</script>
		
	</body>
</html>