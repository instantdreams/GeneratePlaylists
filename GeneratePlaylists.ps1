## ---- [Script Parameters] ----
Param
(
    [Parameter(Mandatory=$True)] [String] $Source,
    [Parameter(Mandatory=$True)] [String] $Destination,
    [Parameter(Mandatory=$False)] [Switch] $Relative
)

# Function Create Playlist - one per artist, many per release, an entry per track
function CreatePlaylist
{
    <#
    .SYNOPSIS
        Creates a playlist from a folder
    .DESCRIPTION
        When given a source, will generate a playlist in the destination location
    .EXAMPLE
        .\CreatePlaylist -Source "E:\ServerFolders\Music\Adele" -Destination "E:\ServerFolders\Playlists"
        .\CreatePlaylist -Source "E:\ServerFolders\Music\Amy Winehouse" -Destination "E:\ServerFolders\PlaylistsRelative" -Relative
    .PARAMETER Source
        Folder containing the music files
    .PARAMETER Destination
        Path where the playlist should be saved
    .PARAMETER Relative
        Switch to generate playlists with relative paths
    .OUTPUTS
        Playlist file with absolute paths by default, relative if switch specified
    .NOTES
        Version:        1.0
        Author:         Dean Smith | deanwsmith@outlook.com
        Creation Date:  2014-05-12
        Purpose/Change: Initial script creation
        Version:        1.1
        Author:         Dean Smith | deanwsmith@outlook.com
        Update Date:    2019-06-04
        Purpose/Change: Merged scripts to use functions
    #>
    ## ---- [Function Parameters] ----
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True)] [String] $Source,
        [Parameter(Mandatory=$True)] [String] $Destination,
        [Parameter(Mandatory=$False)] [Switch] $Relative
    )

    # Check if the Destination Folder exists and if not create it
    If ((Test-Path $Destination) -eq $False) { New-Item $Destination -Type directory }

    # Set the working directory to the Destination folder (used for Relative path generation)
    Push-Location -Path $Destination

    # Get the name of the playlist from the lowest level directory of the source and build the variables, then use these to create and clear the playlist
    $PlaylistName =  (Split-Path $Source -Leaf) + '.m3u'
    $PlaylistPath = $Destination + "\" + $PlaylistName
    If ((Test-Path $PlaylistPath) -eq $False) { New-Item $PlaylistPath -Type file }
    If ((Test-Path $PlaylistPath) -eq $True)  { Clear-Content $PlaylistPath }
    $Timestamp = Get-Date -UFormat "%T"
    Write-Output ("`r`n$Timestamp`t`t${JobName}`nPlaylist Name:`t$PlaylistName`nPlaylist Path:`t$PlaylistPath")

    # Get a collection of all releases for this artist
    $Artist = Get-ChildItem -Path $Source -Directory | 
        Sort Name |
        Select-Object -ExpandProperty FullName
    $Timestamp = Get-Date -UFormat "%T"
    Write-Output ("`r`n$Timestamp`t`t${JobName}`nReleases:`t`t" + $Artist.Count)

    # Loop through each release and add an entry to the playlist for each track found
    ForEach ($Release in $Artist)
    {
        If ($Relative) { $ReleaseFiles = (Get-Childitem -Path $Release -Recurse -Include *.mp3,*.m4a,*.flac,*.wma,*.ape -Force | Sort Name | Resolve-Path -Relative) }
        Else           { $ReleaseFiles = (Get-Childitem -Path $Release -Recurse -Include *.mp3,*.m4a,*.flac,*.wma,*.ape -Force | Sort Name) }
        ForEach ($Track in $ReleaseFiles)
        {
            Add-Content -Path $PlaylistPath -Value $Track -Encoding UTF8
        }
        $Timestamp = Get-Date -UFormat "%T"
    }

    # Reset the working directory
    Pop-Location
}

# Function Manage Artists - get list of artists and pass to Create Playlist one at a time
function ManageArtists
{
    <#
    .SYNOPSIS
        Determines all the artists from a source
    .DESCRIPTION
        When given a source, will produce a list of all artists - which is then used to create playlists
    .EXAMPLE
        .\ManageArtists -Source "E:\ServerFolders\Music" -Destination "E:\ServerFolders\Playlists"
        .\ManageArtists -Source "E:\ServerFolders\Music" -Destination "E:\ServerFolders\PlaylistsRelative" -Relative
    .PARAMETER Source
        Path containing the music files
    .PARAMETER Destination
        Path where the playlist should be saved
    .PARAMETER Relative
        Switch to generate playlists with relative paths
    .OUTPUTS
        A collection of artists passed to CreatePlaylist
    .NOTES
        Version:        1.0
        Author:         Dean Smith | deanwsmith@outlook.com
        Creation Date:  2014-05-12
        Purpose/Change: Initial script creation
        Version:        1.1
        Author:         Dean Smith | deanwsmith@outlook.com
        Update Date:    2019-06-04
        Purpose/Change: Merged scripts to use functions
    #>
    ## ---- [Function Parameters] ----
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True)] [String] $Source,
        [Parameter(Mandatory=$True)] [String] $Destination,
        [Parameter(Mandatory=$False)] [Switch] $Relative
    )

    # Get a collection of artists within the source folder
    $Artists = Get-ChildItem -Path $Source -Directory -Exclude "3M Littmann Stethoscopes", "Playlists", "PlaylistsPath", "Podcasts", "Ringtones" | 
        Sort Name |
        Select-Object -ExpandProperty FullName
    $Timestamp = Get-Date -UFormat "%T"
    Write-Output ("`r`n$Timestamp`t`t${JobName}`nArtists:`t`t" + $Artists.Count)

    # Loop through each artist and create a playlist for each one
    ForEach ($Artist in $Artists)
    {
        If ($Relative) { CreatePlaylist -Source $Artist -Destination $Destination -Relative }
        Else           { CreatePlaylist -Source $Artist -Destination $Destination }
    }
}

<#
.SYNOPSIS
    Generate playlists for all artists in a source folder
.DESCRIPTION
    Uses two functions, Manage Artists and Create Playlist, to loop through artists and releases to create playlist files
.EXAMPLE
    .\GeneratePlaylists.ps1 -Source "E:\ServerFolders\Music" -Destination "E:\ServerFolders\Playlists"
    .\GeneratePlaylists.ps1 -Source "E:\ServerFolders\Music" -Destination "E:\ServerFolders\PlaylistsRelative" -Relative
.PARAMETER Source
    Path containing the music files
.PARAMETER Destination
    Path where the playlist should be saved
.PARAMETER Relative
    Switch to generate playlists with relative paths
.OUTPUTS
    Playlists
.NOTES
    Version:        1.0
    Author:         Dean Smith | deanwsmith@outlook.com
    Creation Date:  2014-05-12
    Purpose/Change: Initial script creation
    Version:        1.1
    Author:         Dean Smith | deanwsmith@outlook.com
    Update Date:    2019-06-04
    Purpose/Change: Merged scripts to use functions
#>

## ---- [Execution] ----
# Load configuration details and set up job and log details
$ConfigurationFile = ".\GeneratePlaylists.xml"
If (Test-Path $ConfigurationFile)
{
	Try
	{
		$Job = [xml](Get-Content $ConfigurationFile)
		$JobFolder = $Job.Configuration.JobFolder
		$JobName = $Job.Configuration.JobName
        $JobDate = Get-Date -Format FileDateTime
		$LogFolder = $Job.Configuration.LogFolder
        $LogFile = "$LogFolder\$JobName-$JobDate.log"
	}
	Catch [system.exception] { }
}

# Start Transcript
Start-Transcript -Path $Logfile -NoClobber -Verbose -IncludeInvocationHeader
$Timestamp = Get-Date -UFormat "%T"
Write-Output ("-" * 79 + "`r`n$Timestamp`t${JobName}: Starting Transcript`r`n" + "-" * 79)

# Call Manage Artists with the parameters
ManageArtists -Source $Source -Destination $Destination

## Stop Transcript
$Timestamp = Get-Date -UFormat "%T"
Write-Output ("`r`n" + "-" * 79 + "`r`n$Timestamp`t${JobName}: Stopping Transcript`r`n" + "-" * 79)
Stop-Transcript