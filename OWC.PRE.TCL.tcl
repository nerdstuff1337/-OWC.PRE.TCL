###############################################################
###############################################################
##                                                           ##  
##                                                           ##
##                                                           ##
##       Overdose Warez Crew EggdroP - TCL preDB ScripT      ##
##                       1.0 Final                           ##
##                                                           ##
##         Dieses Script ist ausschliesslich für OWC gecodet ##
##         Solltest du es irgendwo im Netz gefunden haben,   ##
##         dann schreibe uns eine Mail an:                   ##
##         OWC (at) FU (dot) suX                             ## 
##                                                           ##
##         Copyright (c) 2009 by OWC only		    		 ##
##		   Code based on the script from Warming             ##
##         Thx an alle Tester, Jokerone(Nap), Holy           ##
##         und natürlich Warming!!                           ##      
##                                                           ##
##                                                           ##
###############################################################
###############################################################
##                     Befehle                               ##
###############################################################
###############################################################
##	!pre		| Suchwort oder Kombination 
##                Sektion+Suchwort
##
##	!preadd		| Manueller Add von pre
##
##	!prenuke	| Manueller Nuke von RLS
##
##	!preunnuke	| Manueller UnNuke von RLS
##
##	!presearch	| Site Search nach einem RLS
##			      Auf Wunsch kann dann ein
##  			  Request geaddet werden.	
##				  tur-request script wird benötigt
##				  tur-sqlsearch script wird benötigt	
##
##	!predb		| Gibt die Anzahl der Einträge 
##			      und die Groeße der DB aus.
##
##	!prehelp	| Zeigt diese Hilfe.
##
##
##
##
##
###############################################################
###############################################################
##                     Versionen                             ##
###############################################################
###############################################################
##
##
##
##
##
## 
## 1.0 Finale Version. Alle Funktionen eingebaut
## 0.5 Lauffähige Version.
## 0.3 Weitere Funktionen und einfachere Loesung.
## 0.2 Zusatzfunktionen, aufräumen
## 0.1 Erstes vorab Script
###############################################################
###############################################################
##                     Cooming soon                          ##
###############################################################
###############################################################
##
##  - nothing @ the moment
##  
##  
##  
##
###############################################################
###############################################################
##                     Bugs                                  ##
###############################################################
###############################################################
##
## - Keine Bugs bekannt.
##
##
##
##
##
##
##
##
##
###############################################################
###############################################################

#muss installiert sein
package require mysqltcl


#Der Trigger kann verändert werden
array set multi {
      "trigger" 	"\!"
      "version" 	"Version 1.0 FinaL"
      "author" 		"zer0.de's - 1337 UltrA l33t OWC pre Script | löl"
	}

bind PUB -|- "$::multi(trigger)pre" pre
bind PUB -|- "$::multi(trigger)preadd" preadd
bind PUB -|- "$::multi(trigger)prenuke" prenuke
bind PUB -|- "$::multi(trigger)preunnuke" preunnuke
bind PUB -|- "$::multi(trigger)presearch" boxsearch
bind PUB -|- "$::multi(trigger)predb" predb
bind PUB -|- "$::multi(trigger)prehelp" prehelp
bind PUB -|- "$::multi(trigger)ja" boxsearch:yes
bind PUB -|- "$::multi(trigger)nein" boxsearch:no
bind PUB -|- "$::multi(trigger)preversion" version


###############################################################
###############################################################
##                     Config
###############################################################
############################################################### 

# mySQL Daten
set sqlserver	"localhost"
set sqluser		""
set sqlpw		""
set sqldb		"pre"
set sqlport		"3306"
#nur wichtig wenn ein sitebot vorhanden ist
#der name der tabelle
set boxdb		"searchdb"
#logischerweise der nick vom sitebot, wenn identisch trotzdem eintragen
set sitebotnick	"FC"
#der pfad vom root aus, \ zum escapen!
set glftpdpfad  "\/glftpd\/site\/"
#Zeit Zone
set offset "+2"
#Max Ausagbe von pre, auf flooding Achten!
set limit "10"
###############################################################
###############################################################
##                     Config / ENDE
###############################################################
############################################################### 

# AB HIER NICHTS MEHR AENDERN!!!
#Funktion zur brechnung und setzung der variablen
proc conf_time { secs } {
if {$secs == 0} {return "0s|0secs|"} else {
if {$secs < 60} {return "${secs}s|${secs}secs|" } else {
set mins [expr $secs / 60]
set secs [expr $secs % 60]
}
if {$mins < 60} {
set hrs 0
set mins [expr $mins % 60]
} else {
set hrs [expr $mins / 60]
set mins [expr $mins % 60]
}
if {$hrs < 24} {
set days 0
set hrs [expr $hrs % 24]
} else {
set days [expr $hrs / 24]
set hrs [expr $hrs % 24]
}
if {$days < 365} {
set yrs 0
set days [expr $days % 365]
} else {
set yrs [expr $days / 365]
set days [expr $days % 365]
}

if {$days == 0} {set daysm "" ; set daysmm ""} else {set daysm " ${days}d" ; set daysmm " ${days}tage"}
if {$hrs == 0} {set hrsm "" ; set hrsmm ""} else {set hrsm " ${hrs}h" ; set hrsmm " ${hrs}std"}
if {$mins == 0} {set minsm "" ; set minsmm ""} else {set minsm " ${mins}m" ; set minsmm " ${mins}mins"}
if {$secs == 0} {set secsm "" ; set secsmm ""} else {set secsm " ${secs}s" ; set secsmm " ${secs}sek"}
if {$yrs == 0} {set yrsm "" ; set yrsmm ""} else {set yrsm " ${yrs}s" ; set yrsmm " ${yrs}y"}
set x [string trim "${yrsmm}${daysmm}${hrsmm}${minsmm}${secsmm}"]
set y [string trim "${yrsmm}${daysm}${hrsm}${minsm}${secsm}"]
return $x
	}
}

proc pre { nick uhost handle channel arg } {
	global  sqlserver sqluser sqlpw sqldb sqlport conf_time offset regex_map limit
	
	# SQL verbindung herstellen
	set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
 	mysqluse $sql $sqldb
 	
	#eingabe nach !pre verarbeiten....
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel :11,1Syntax: !pre SUCHWORT.Blubb.Blabb"
		} else {
		if {[llength $arg]==1} {
		set search [lindex $arg 0]
		} 
		if {[llength $arg]==2} {
		set search "[lindex $arg 0].[lindex $arg 1]"
		}
		if {[llength $arg]==3} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2]"
		}
		if {[llength $arg]==4} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2].[lindex $arg 3]"
		}
		if {[llength $arg]==5} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2].[lindex $arg 3].[lindex $arg 4]"
		}
		if {[llength $arg]==6} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2].[lindex $arg 3].[lindex $arg 4].[lindex $arg 5]"
		}

#Check search vorhanden ist
set ssqqllC "SELECT COUNT(*) FROM rels WHERE name LIKE \"%$search%\""
		
		set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
		mysqluse $sql $sqldb
		set query2 [mysqlquery $sql $ssqqllC]
		
		while {[set row2 [mysqlnext $query2]]!=""} {
			set co [lindex $row2 0]
			if {$co >= 1} {
				putserv "PRIVMSG $channel : 11,1So ich such dann mal....."
				putserv "PRIVMSG $channel : 11,1#########################"
				putserv "PRIVMSG $channel : 11,1 $co Release gefunden..."
			} else {
				putserv "PRIVMSG $channel : 11,1Nix gefunden!!"
			}
		}

#Übergabe von search an die DB abfrage	
	set pre "SELECT * FROM `pre`.`rels` WHERE (`name` LIKE '\%$search\%') ORDER BY `rels`.`date` DESC LIMIT $limit" 
 	
	set query [mysqlquery $sql $pre]
		
		while {[set row [mysqlnext $query]]!=""} {

	set date    [lindex $row 1]
	set section [lindex $row 3]
	set name    [lindex $row 4]
	set size    [lindex $row 5]
	set files   [lindex $row 6]
	set nuked   [lindex $row 7]
	set genre   [lindex $row 8]
	set groupe  [lindex $row 9]
	set zeit	[lindex $row 10]
	#Datums formatierung (http://tcl.activestate.com/man/tcl8.3/TclCmd/clock.htm)
	set reldate [clock format [expr [lindex [lindex $row ] 2] + $offset] -format "%d.%m.%y um $zeit"]

	
if {$nuked ==""} {	
	#noch checken ob das wort german vorkommt und setzen der hervorbung...kommt dann noch
	regsub -all "German" $name "7,1German11,1" name
	regsub -all "german" $name "7,1German11,1" name
	regsub -all "GERMAN" $name "7,1German11,1" name
	
	#Normale Ausgabe PRIVMSG $channel
	putserv "PRIVMSG $channel : 15,1( $section11,1 ) $name 0,1( $files Files $size )0,1 pred am $reldate das ist [conf_time [expr [clock seconds] - [lindex [lindex $row ] 2]]] her."
	} else {
	putserv "PRIVMSG $channel : 15,1( $section11,1 ) $name 0,1( $files Files $size )0,1 pred am $reldate das ist [conf_time [expr [clock seconds] - [lindex [lindex $row ] 2]]] her. 4,1NUKED: $nuked"
					}
			}
	}
mysqlclose $sql	
}	

#Manueler pre Add
proc preadd { nick uhost handle channel arg } {
	global  sqlserver sqluser sqlpw sqldb sqlport 

# SQL verbindung herstellen
	set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
 	mysqluse $sql $sqldb

	
#eingabe nach !AddPre verarbeiten....
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel : 11,1Syntax: !preadd Sektion ReleaseName SIZE(in MB) Files Group Genre(Optional fuer MP3)"
	} else {
	
	if {[llength $arg]==5} {
		set sektion [lindex $arg 0]
		set rlsname [lindex $arg 1]
		set size    [lindex $arg 2]
		set files   [lindex $arg 3]
		set group   [lindex $arg 4]
		set genre   [lindex $arg 5]	
		
		set row ""
		set query [mysqlquery $sql "SELECT * FROM rels WHERE name = '$rlsname'"]
		set row [mysqlnext $query]
		if {$row == ""} {
	
#Übergabe von add an die DB
		set addpre [mysqlquery $sql "INSERT INTO `pre`.`rels`(`id`, `date`,`time` , `section`, `name`, `size`, `files`, `genre`, `group`, 'zeit') VALUES (NULL, NULL, NULL, '$sektion', '$rlsname', '$size', '$files', '$genre', '$group');"]
						}
putserv "PRIVMSG $channel : 11,1ADDED -> $rlsname"
} else {
putserv "PRIVMSG $channel : 11,1Dupe -> $rlsname"
		}	
	}
mysqlclose $sql	
}

#Manueler Nuke	
proc prenuke { nick uhost handle channel arg } {
	global  sqlserver sqluser sqlpw sqldb sqlport 

	# SQL verbindung herstellen
	set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
 	mysqluse $sql $sqldb
		
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel : Syntax: !preNuke Rls Name und Grund"
	} else {
		if {[llength $arg]==2} {
		set rls [lindex $arg 0]	
		set nuke  [lindex $arg 1]
			
		#Übergabe von nuke an die DB
		set addnuke [mysqlquery $sql "UPDATE `pre`.`rels` SET `nuked` = '$nuke' WHERE `rels`.`name` ='$rls';"]
						
putserv "PRIVMSG $channel :11,1Nuked -> $rls"
} else {
putserv "PRIVMSG $channel :11,1Fehler beim Nuke -> $rls"
		}
			}
							
mysqlclose $sql							
}

#Manueler Unnuke
proc preunnuke { nick uhost handle channel arg } {
	global  sqlserver sqluser sqlpw sqldb sqlport 

	# SQL verbindung herstellen
	set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
 	mysqluse $sql $sqldb
		
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel :11,1Syntax: !preUnNuke Rls Name"
	} else {
		if {[llength $arg]==1} {
		set rls [lindex $arg 0]	
					
		#Übergabe von nuke an die DB
		set unnuke [mysqlquery $sql "UPDATE `pre`.`rels` SET `nuked` = '' WHERE `rels`.`name` ='$rls';"]

putserv "PRIVMSG $channel :11,1UnNuked -> $rls"
} else {
putserv "PRIVMSG $channel :11,1Fehler beim UnNuke -> $rls"
		}
			}				
mysqlclose $sql							
}	

#RLS Search auf einer BOX
proc boxsearch { nick uhost handle channel arg } {
	global  sqlserver sqluser sqlpw sqldb sqlport search boxdb glftpdpfad
	
	# SQL verbindung herstellen
	set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
 	mysqluse $sql $sqldb
 	
	#eingabe nach !presearch verarbeiten....
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel : 11,1Syntax: !preSearch Release Name"
	} else {
		if {[llength $arg]==1} {
		set search [lindex $arg 0]
		} 
		if {[llength $arg]==2} {
		set search "[lindex $arg 0].[lindex $arg 1]"
		}
		if {[llength $arg]==3} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2]"
		}
		if {[llength $arg]==4} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2].[lindex $arg 3]"
		}
		if {[llength $arg]==5} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2].[lindex $arg 3].[lindex $arg 4]"
		}
		if {[llength $arg]==6} {
		set search "[lindex $arg 0].[lindex $arg 1].[lindex $arg 2].[lindex $arg 3].[lindex $arg 4].[lindex $arg 5]"
		}

#Übergabe von search an die DB abfrage	
	set box "SELECT * FROM `$boxdb` WHERE `path` LIKE \'%$search%\' LIMIT 1" 
 	
	set query [mysqlquery $sql $box]
		
	while {[set row [mysqlnext $query]]!=""} {

	set path		[lindex $row 1]
	set site		[lindex $row 2]
	set size		[lindex $row 3]
	set onsite		[lindex $row 4]

#zerstueckeln des Pfades das muss man an deinen pfad anpassen
regsub -all {$glftpdpfad} $path " " path2

	
if {$onsite =="0"} {
	#Normale Ausgabe
	putserv "PRIVMSG $channel : 11,1 Das Release ist nicht mehr auf der Box $site, Request? !ja !nein"
	} else {
	putserv "PRIVMSG $channel : 11,1 Das Release findest du auf der Box $site unter $path2"
			}
		}
	}
mysqlclose $sql	

}

#kein req 
proc boxsearch:no { nick host handle channel arg } {	
	global  search 
	
	putserv "PRIVMSG $channel : 11,1Dann nicht"
	
}

#req add beim site-bot
proc boxsearch:yes { nick host handle channel arg } {	
	global search sitebotnick
	#!request $search
	if {$search ==""} {
	putserv "PRIVMSG $channel : 11,1Nichts kann man nicht Requesten"
	} else {
	putserv "PRIVMSG $sitebotnick : 11,1!request $search"
	putserv "PRIVMSG $channel     : 11,1Request wurde geaddet"
			}
}
	
#Datenbank Statistik Abfragen
proc predb { nick uhost handle channel arg } {
	global  sqlserver sqluser sqlpw sqldb sqlport

	
	# SQL verbindung herstellen
	set sql [mysqlconnect -h $sqlserver -u $sqluser -password $sqlpw]
 	mysqluse $sql $sqldb

	set ssqqlinf "SELECT COUNT(*) FROM rels"	
		set query3 [mysqlquery $sql $ssqqlinf]
		
		while {[set row [mysqlnext $query3]]!=""} {
		set rls [lindex $row]
		
		set ssqqDB "Select round(sum(data_length+index_length)/1024/1024,2) from information_schema.tables where table_schema=\"pre\""	
		set query3 [mysqlquery $sql $ssqqDB]
		
		while {[set rowDB [mysqlnext $query3]]!=""} {
		set rls1 [lindex $rowDB]
				
		putserv "PRIVMSG $channel : 11,1( STATS ) ( Wir haben $rls einträge mit einem Gewicht von $rls1 MB )"
		}
	}			
mysqlclose $sql	
}
# scripter 
proc version { nick uhost handle channel arg } {
putserv "NOTICE $nick :11,1Hi ich bin $::botnick  und benutze  $::multi(author) $::multi(version)"

putserv "PRIVMSG $channel : 0,12æž2,12`æ12,2æž1,2`æ2,1æž0,1 -= (¯`·._(¯`·._(¯`·._( Pre Script 4 OWC Only 4/0!4\0 12|0 SeRvEr STaTuS: 9oN0 12|0 4/0!4\0 DatenBank: OnLinE )_.·Ž¯)_.·Ž¯)_.·Ž¯) =- 2,1`æ1,2æž12,2`æ2,12æž0,12`æ12"
}

#Hilfe Anzeigen
proc prehelp { nick uhost handle channel arg } {
	puthelp "PRIVMSG $nick : 11,1##################################BEFEHLE#######################################"
	puthelp "PRIVMSG $nick : 11,1!pre..........+suchwort gibt alle eintraege in der DB aus"
	puthelp "PRIVMSG $nick : 11,1!predb........DB info ueber eintraege und groesse"
	puthelp "PRIVMSG $nick : 11,1!preversion...sieh selbst"
	puthelp "PRIVMSG $nick : 11,1!prehelp......zeigt diese hilfe"
	puthelp "PRIVMSG $nick : 11,1!####################################ENDE#######################################"
}

#Log Ausgabe
putlog "*************************************************************************"
putlog "$::multi(author) - $::multi(version) Loaded"
putlog "*************************************************************************"