<!doctype html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<title>XML Ripper</title>
		<meta name="description" content="">
		<meta name="viewport" content="width=device-width">
		<link rel="stylesheet" href="css/style.css">
		<link rel="stylesheet" href="css/sublime.css">
	</head>
	<body>
		<header>
			<h1>XML Ripper</h1>
		</header>
		
		<div role="main">
			<form action="index.cfm" method="post" enctype="multipart/form-data">
				<!--- 
				
				@TODO: Add file upload functionality
				
				<fieldset>
					<p>
						<input type="file" id="FileUpload" name="FileUpload" />
						<input type="submit" value="Upload" />
					</p>
					<input type="hidden" name="action" value="FileUpload" />
				</fieldset> --->
				<cfif application.objFileManager.hasSourceFiles()>
					<fieldset>
						<cfset qry = application.objFileManager.getSourceFiles()>
						<cfoutput query="qry">
							<div>
							<input type="image" src="images/document.png" name="document" value="#fileID#" /><br />
							#name#
							</div>
						</cfoutput>
					</fieldset>
				</cfif>
				
			</form>
			
			<cfif not StructIsEmpty(form)>
				<!--- If an XML file has been selected to be parsed then we run it through the 'render'
						@TODO - add the analysis functionality. ---> 	 
				<cfquery name="qryFile" dbtype="query">
					SELECT 		*
					FROM 		qry
					WHERE 		fileID = '#form.document#'
				</cfquery>
				
				<div style="background-color: #000; color: #FFF;"><h2>File: <cfoutput>#qryFile.name#</cfoutput></h2></div>
				
				<div id="output-canvas">
					<!--- Render the first 'record' in the XML file. ---> 
				    <div class="canvas"><cfinclude template="render.cfm"></div>
				</div>
				
				<div id="output-console">
					<!--- Once the analysis has run over the whole XML file then show the available fields.
						@TODO - add the analysis functionality. --->
					<cfinclude template="console.cfm">
				</div>
				<div style="clear:both;"></div>
			</cfif>
		</div>
		
		<footer>
		
		</footer>
				
		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
		<script>window.jQuery || document.write('<script src="js/libs/jquery-1.7.1.min.js"><\/script>')</script>
		
	</body>
</html>