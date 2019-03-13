#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlField>
#include <QSqlError>
#include <QSqlTableModel>
#include <QDebug>
#include <QDesktopServices>

#include "vverenadatabase.h"
#include "vstd.h"

#define V_SQL "QSQLITE"

VVerenaDatabase::VVerenaDatabase(const QString &name, const QString &user, const QString &password)
{
	database = QSqlDatabase::addDatabase(V_SQL, name);
	database.setDatabaseName(
#ifdef _HARMATTAN
			QDesktopServices::storageLocation(QDesktopServices::DataLocation) + "/" + 
#endif
			name + ".db");

#ifdef _HARMATTAN
	if(!user.isEmpty())
	{
		database.setUserName(user);
		if(!password.isEmpty())
			database.setPassword(password);
	}
#endif
	database.setHostName(APPLICATION_DEVELOPER);
}

VVerenaDatabase::~VVerenaDatabase()
{
	closeDatabase();
}

void VVerenaDatabase::openDatabase()
{
	if(database.isValid())
	{
		database.open(); //???
	}
}

bool VVerenaDatabase::check() const
{
	return database.isValid() && database.isOpen();
}

QVariantList VVerenaDatabase::getAllDataFromTable(const QString &name) const
{
	QVariantList list;
	if(check())
	{
		QSqlTableModel model(0, database);
		model.setTable(name);
        model.select();
		for (int i = 0; i < model.rowCount(); i++)
		{
			QSqlRecord record = model.record(i);
			QMap<QString, QVariant> map;
			for(int j = 0; j < record.count(); j++)
			{
				map.insert(record.field(j).name(), record.value(j));
			}
			list.push_back(QVariant(map));
		}
	}
	return list;
}

void VVerenaDatabase::addTable(const QString &name, const QStringList &args, bool over)
{
	if(!check())
		return;
	QSqlQuery query(database);
	if(database.tables().contains(name))
	{
		if(over)
		{
			if(database.transaction())
			{
				query.exec(QString("DROP TABLE IF EXISTS %1").arg(name));
				query.exec(QString("CREATE TABLE IF NOT EXISTS %1 (%2)").arg(name).arg(args.join(",")));
				if(!database.commit())
				{
					qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
					if(!database.rollback())
					{
						qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
					}
				}
			}
			else
			{
				if(!query.exec(QString("DROP TABLE IF EXISTS %1").arg(name)))
				{
					qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
				}
				if(!query.exec(QString("CREATE TABLE IF NOT EXISTS %1 (%2)").arg(name).arg(args.join(","))))
				{
					qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
				}
			}
		}
		else
		{
			return;
		}
	}
	else
	{
		if(database.transaction())
		{
			query.exec(QString("CREATE TABLE IF NOT EXISTS %1 (%2)").arg(name).arg(args.join(",")));
			if(!database.commit())
			{
				qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
				if(!database.rollback())
				{
					qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
				}
			}
		}
		else
		{
			if(!query.exec(QString("CREATE TABLE IF NOT EXISTS %1 (%2)").arg(name).arg(args.join(","))))
			{
				qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			}
		}
	}
}

int VVerenaDatabase::queryTable(const QString &name, const QString &key, const QString &value)
{
	if(check())
	{
		QSqlQuery query(database);
		if(!query.exec(QString("SELECT %1 FROM %2 WHERE %3 = %4").arg(key).arg(name).arg(key).arg(value)))
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
		}
		return query.size();
	}
	return 0;
}

void VVerenaDatabase::addElementToTable(const QString &name, const QVariantList &args)
{
	if(!check())
		return;
	QStringList sl;
	for(int i = 0; i < args.length(); i++)
	{
		sl<<"?";
	}
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.prepare(QString("INSERT OR REPLACE INTO %1 VALUES (%2)").arg(name).arg(sl.join(",")));
		for(QVariantList::const_iterator itor = args.constBegin();
				itor != args.constEnd();
				++itor)
		{
			query.addBindValue(*itor);
		}
		query.exec();
		if(!database.commit())
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			if(!database.rollback()){
				qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			}
		}
	}
	else
	{
		query.prepare(QString("INSERT OR REPLACE INTO %1 VALUES (%2)").arg(name).arg(sl.join(",")));
		for(QVariantList::const_iterator itor = args.constBegin();
				itor != args.constEnd();
				++itor)
		{
			query.addBindValue(*itor);
		}
		if(!query.exec())
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
		}
	}
}

void VVerenaDatabase::removeElementFromTable(const QString &name, const QString &key, const QString &value)
{
	if(!check())
		return;
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.exec(QString("DELETE FROM %1 WHERE %2 = %3").arg(name).arg(key).arg(value));
		if(!database.commit())
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			if(!database.rollback()){
				qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			}
		}
		qDebug() << "[WARNING]: SQL -> " << query.lastQuery();
	}
	else
	{
		if(!query.exec(QString("DELETE FROM %1 WHERE %2 = %3").arg(name).arg(key).arg(value)))
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
		}
	}
}

void VVerenaDatabase::clearTable(const QString &name)
{
	if(!check())
		return;
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.exec(QString("DELETE FROM %1").arg(name));
		if(!database.commit())
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			if(!database.rollback()){
				qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
			}
		}
	}
	else
	{
		if(!query.exec(QString("DELETE FROM %1").arg(name)))
		{
			qDebug() << "[WARNING]: SQL -> " << query.lastError().text();
		}
	}
}

void VVerenaDatabase::closeDatabase()
{
	if(check())
		database.close();
}
