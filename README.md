# GeneratePlaylists

A PowerShell script that generates [playlists in .m3u](https://en.wikipedia.org/wiki/M3U) format for your music collection.

If you have a large collection of music files you probably use a tool like MusicBrainz Picard to manage and tag the files. You likely use a folder structure in this format:

* {Artist}
	* {Year} - {Release Name}
	* {Year} - {Release Name}

Sometimes it's just nice to have a set of playlists generated that match this folder structure, especially if you have a large music collection.


## Features

The Generate Playlists PowerShell script will:

* Generate playlists by artist for each release
* Generate using absolute paths or relative paths
* Write results to a log file


## Prerequisites

To install the script on your system you will need the following information:

* A script location for your PowerShell scripts (e.g. "C:\Tools\Scripts" or "D:\ServerFolders\Company\Scripts")
* A folder for log files  (e.g. "C:\Tools\Scripts\Logs" or "D:\ServerFolders\Company\Scripts\Logs")


## Installation

A simple clone of the repository is all that is required:

* On the [GitHub page for this repository](https://github.com/instantdreams/GeneratePlaylists) select "Clone or Download" and copy the web URL
* Open your GIT Bash of choice and enter the following commands:
	* cd {base location of your scripts folder} (e.g. /d/ServerFolders/Company/Scripts)
	* git clone {repository url} (e.g. https://github.com/instantdreams/GeneratePlaylists.git)

This will install a copy of the scripts and files in the folder "GeneratePlaylists" under your script location.


## Configuration

Minor configuration is required before running the script:

* Open File Explorer and navigate to your script location
* Copy file "GeneratePlaylists-Sample.xml" and rename the result to "GeneratePlaylists.xml"
* Edit the file with your favourite text or xml editor
	* For JobFolder enter the full path to the script folder (e.g. "C:\Tools\Scripts\GeneratePlaylists")
	* For LogFolder enter the full path to the log folder (e.g. "C:\Tools\Scripts\Logs")
* Save the file and exit the editor


## Running

To run the script, open a PowerShell window and use the following commands:
```
Set-Location {script location}
.\GeneratePlaylists.ps1 -Source {music location} -Destination {playlist location}
```
For example:
```
Set-Location "C:\Tools\Scripts\GeneratePlaylists"
.\GeneratePlaylists.ps1 -Source "E:\Music" -Destination "E:\Playlists"
```
If you would like to generate relative playlist paths, try this example:
```
Set-Location "C:\Tools\Scripts\GeneratePlaylists"
.\GeneratePlaylists.ps1 -Source "E:\Music" -Destination "E:\Music\Playlists" -Relative
```

## Scheduling

Running this script frequently and in the background will keep your playlists updated without you having to remember to refresh them. With Windows or Windows Server, the easiest way of doing this is to use Task Scheduler.

1. Start Task Scheduler
2. Select Task Scheduler Library
3. Right click and select Create Simple Task
4. Use the following entries:
* Name:			GeneratePlaylists
* Description:	Generate playlists for all artists in a source folder
* Account:		Use your script execution account
* Run whether user is logged on or not
* Trigger:		Monthly at 01:00, enabled (All months, first day)
* Action:		Start a program
	* Program:		PowerShell
	* Arguments:	-ExecutionPolicy Bypass -NoLogo -NonInteractive -File "{script location}\GeneratePlaylists\GeneratePlaylists.ps1" -Source "{music location}" -Destination "{playlist location}"
	* Start in:	{script location}\GeneratePlaylists

Adjust the trigger as needed, and you will have refreshed playlists automatically.


## Troubleshooting

Please review the log files located in the log folder to determine any issues.


## Author

* **Dean W. Smith** - *Script Creation* - [instantdreams](https://github.com/instantdreams)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details


## Security

This project has a security policy - see the [SECURITY.md](SECURITY.md) file for details