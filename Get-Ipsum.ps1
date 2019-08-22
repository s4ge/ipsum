<#
	.Synopsis
		Script to pull JSON from BaconIpsum site
	.Description
		This script will invoke webrequest to API on site using parameters defined below.
	.Parameter Name
		$meatoption = all-meat or meat-and-filler
		$paratotal = number of paragraphs to display (default = 5) (range 1 - 99)
		$senttotal = number of sentences to display (range 0 - 999). Enter 0 to prevent override of paragraphs.
		$ipsumoption = 0 or 1. Enter 1 to start first paragraph with the ‘Bacon ipsum dolor sit amet’. 
		$formatoption = output format. json, text or html (default = json)
	.Example
		./Get-Ipsum.ps1 all-meat 5 1 1 json
	.Notes
		Versions
		01		11 Aug 2019		G Frew			Initial Version
	.Link
		https://baconipsum.com/json-api/
		
#>
	[CmdLetBinding()]
	Param(
			[Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage = "Enter either all-meat or meat-and-filler.")]
			[ValidateSet ("all-meat","meat-and-filler")]
			[String]
			#$MeatOption = "all-meat"
			$MeatOption = $env:MeatOption
			,
			[Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage = "Enter number of paragraphs (default=5).")]
			[ValidateRange (1, 99)]
			[Int]
			#$ParaTotal = "5"
			$ParaTotal = $env:ParaTotal
			,
			[Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage = "Enter number of sentences. Enter 0 to prevent override of paragraphs")]
			[ValidateRange (0, 999)]
			[Int]
			#$SentTotal = $NULL
			$SentTotal = $env:SentTotal
			,
			[Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage = "Enter 1 to start 1st paragraph with Bacon ipsum dolor sit amet.")]
			[ValidateRange (0,1)]
			[Int]
			#$LoremFlag = $NULL
			$LoremFlag = $env:LoremFlag
			,
			[Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage = "Enter either json, html or text (default=json).")]
			[ValidateSet ("json","text","html")]
			[String]
			#$FormatOption = "json"
			$FormatOption = $env:FormatOption
		)
					
			
	# Set Website URL
	$Site = "baconipsum.com"
	$baseURI = "https://baconipsum.com/api/?"

	write-debug " Testing connection to website"
	try {
		$connected = test-connection $Site -count 1
	} #Try
	catch {
		Write-host "Could not connect to site, it appears to be down or there is network issues. Please investigate and try again."
		Exit
	} #Catch
	
	write-debug " Set TLS to 1.2"
	try {
		$TLS12 = [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	} #Try
	catch {
		write-host "Could not set TLS to v1.2. Please investigate..."
		Exit
	} #Catch
	
	write-debug " Testing response status from site"
	
	try {
		$response = Invoke-WebRequest $baseUri -method GET -ErrorAction Stop
		if (!($response.StatusDescription -eq "OK"))
			{
				write-host "Site is not resopnding to request. Please investigate..."
				Exit
				
		} #End If
		
		else {
			write-debug "Response from site is good."
			
		} #End Else
		
		} # End Try
	
	catch {
		write-host "Cannot obtain response from URI"
		$error.count
		Write-Host $_.Exception.Message
		Exit
	} # End Catch
	
	write-debug " Assembling URI query from choices made"
		
		$URIparams = "type=$MeatOption&paras=$ParaTotal&sentences=$SentTotal&start-with-lorem=$LoremFlag&format=$FormatOption"
		$finalURI = $baseURI+$URIparams
		
		
	write-debug " Invoking web request"
		$response = Invoke-WebRequest $finalUri -method GET -UseBasicParsing
				
	
	write-debug " Returning content "
	
	return $response.Content
	
	
	
	
	
