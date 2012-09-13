/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
function getDatabase() {
     return openDatabaseSync("Wazapp", "1.0", "StorageDatabase", 100000);
}
 
function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
	  });
}
 
function setSetting(setting, value) {
	var db = getDatabase();
	var res = "";
	db.transaction(function(tx) {
		var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
		if (rs.rowsAffected > 0) {
			res = "OK";
		} else {
			res = "Error";
		}
	});
	return res;
}

function getSetting(setting, defval) {
	var db = getDatabase();
	var res="";
	db.transaction(function(tx) {
		var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
		if (rs.rows.length > 0) {
		  res = rs.rows.item(0).value;
		} else {
		 res = defval;
		}
	});
	return res
}
