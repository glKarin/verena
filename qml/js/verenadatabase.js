.pragma library

var VerenaDatabase = function(name, desc, size){
	var versionCONST = "1.1";

	var db = openDatabaseSync(name, "", desc, size);

	this.createTable = function(tname, targs){
		if (db.version !== versionCONST){
			var change = function (ta){
				ta.executeSql('DROP TABLE IF EXISTS %1'.arg(tname));
				ta.executeSql('CREATE TABLE IF NOT EXISTS %1 %2'.arg(tname).arg(targs));
			}
			db.changeVersion(db.version, versionCONST, change);
		} else {
			var trans = function(ta){
				ta.executeSql('CREATE TABLE IF NOT EXISTS %1 %2'.arg(tname).arg(targs));
			}
			db.transaction(trans);
		}
	}

	this.pushElementToTable = function(tname, argv){
		var proto = [];
		for(var i in argv){
			proto.push('?');
		}
		db.transaction(function(ta){
			ta.executeSql('INSERT OR REPLACE INTO %1 VALUES (%2)'.arg(tname).arg(proto.join(',')), argv);
					});
			}

			this.loadToListModel = function(tname, model){
				db.readTransaction(function(ta){
					var rd = ta.executeSql('SELECT * FROM %1'.arg(tname));
					for (var i = rd.rows.length - 1; i >= 0; i --){
						var item = rd.rows.item(i);
						model.append(item);
					}
				});
			}

			this.loadToArray = function(tname){
				var tmp = [];
				db.readTransaction(function(ta){
					var rd = ta.executeSql('SELECT * FROM %1'.arg(tname));
					for (var i = rd.rows.length - 1; i >= 0; i --){
						var item = rd.rows.item(i);
						tmp.push(item);
					}
				});
				return tmp;
			}

			this.queryTable = function(tname, tkey, tvalue){
				var rd;
				db.readTransaction(function(ta){
					try{
						rd = ta.executeSql('SELECT %1 FROM %2 WHERE %3 = %4'.arg(tkey).arg(tname).arg(tkey).arg(tvalue)).rows.length;
					}catch(e){
						rd = 0;
					}
				});
				return rd !== 0;
			}

			this.deleteTableRows = function(tname, tkey, tvalue){
				db.transaction(function(ta){
					ta.executeSql('DELETE FROM %1 WHERE %2 = %3'.arg(tname).arg(tkey).arg(tvalue));
				});
			}

			this.clearTable = function(tname){
				db.transaction(function(ta){
					ta.executeSql('DELETE FROM %1'.arg(tname));
				});
			}

			this.getTableSize = function(tname){
				var rd = 0;
				var rs;
				db.readTransaction(function(tx){
					try{
                        rs = tx.executeSql('SELECT COUNT(1) AS \'_Count\' FROM %1'.arg(tname));
						if(rs.rows.length === 1)
							rd = rs.rows.item(0)._Count;
					}catch(e){
						rd = 0;
					}
				});
				return rd;
			}
}
