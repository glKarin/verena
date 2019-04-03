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

#define V_PLACEHOLDER(x) (QString(":") + x)
#define V_DBG_ERR(x) qDebug() << QString("[WARNING]: SQL[%1] -> %2").arg(x.lastQuery()).arg(x.lastError().text())

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
			QVariantMap map;
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

	const QString DropSQL = QString("DROP TABLE IF EXISTS %1").arg(name);
	const QString CreateSQL = QString("CREATE TABLE IF NOT EXISTS %1 (%2)").arg(name).arg(args.join(","));
	QSqlQuery query(database);
	if(database.tables().contains(name))
	{
		if(over)
		{
			if(database.transaction())
			{
				query.exec(DropSQL);
				query.exec(CreateSQL);
				if(!database.commit())
				{
					V_DBG_ERR(query);
					if(!database.rollback())
					{
						V_DBG_ERR(query);
					}
				}
			}
			else
			{
				if(!query.exec(DropSQL))
				{
					V_DBG_ERR(query);
				}
				if(!query.exec(CreateSQL))
				{
					V_DBG_ERR(query);
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
			query.exec(CreateSQL);
			if(!database.commit())
			{
				V_DBG_ERR(query);
				if(!database.rollback())
				{
					V_DBG_ERR(query);
				}
			}
		}
		else
		{
			if(!query.exec(CreateSQL))
			{
				V_DBG_ERR(query);
			}
		}
	}
}

int VVerenaDatabase::queryTable(const QString &name, const QString &key, const QString &value)
{
	if(!check())
		return 0;
	const QString SQL = QString("SELECT COUNT(1) AS '_Count' FROM %1").arg(name) + (!key.isEmpty() && !value.isEmpty() ? QString(" WHERE %1 = %2").arg(key).arg(value) : "");
	QSqlQuery query(database);
	if(!query.exec(SQL))
	{
		V_DBG_ERR(query);
	}
	if(query.first())
		return query.value(0).toUInt();
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
	const QString SQL = QString("INSERT OR REPLACE INTO %1 VALUES (%2)").arg(name).arg(sl.join(","));
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.prepare(SQL);
		for(QVariantList::const_iterator itor = args.constBegin();
				itor != args.constEnd();
				++itor)
		{
			query.addBindValue(*itor);
		}
		query.exec();
		if(!database.commit())
		{
			V_DBG_ERR(query);
			if(!database.rollback()){
				V_DBG_ERR(query);
			}
		}
	}
	else
	{
		query.prepare(SQL);
		for(QVariantList::const_iterator itor = args.constBegin();
				itor != args.constEnd();
				++itor)
		{
			query.addBindValue(*itor);
		}
		if(!query.exec())
		{
			V_DBG_ERR(query);
		}
	}
}

void VVerenaDatabase::removeElementFromTable(const QString &name, const QString &key, const QString &value)
{
	if(!check())
		return;
	const QString SQL = QString("DELETE FROM %1 WHERE %2 = %3").arg(name).arg(key).arg(value);
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.exec(SQL);
		if(!database.commit())
		{
			V_DBG_ERR(query);
			if(!database.rollback()){
				V_DBG_ERR(query);
			}
		}
		V_DBG_ERR(query);
	}
	else
	{
		if(!query.exec(SQL))
		{
			V_DBG_ERR(query);
		}
	}
}

void VVerenaDatabase::clearTable(const QString &name)
{
	if(!check())
		return;
	const QString SQL = QString("DELETE FROM %1").arg(name);
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.exec(SQL);
		if(!database.commit())
		{
			V_DBG_ERR(query);
			if(!database.rollback()){
				V_DBG_ERR(query);
			}
		}
	}
	else
	{
		if(!query.exec(SQL))
		{
			V_DBG_ERR(query);
		}
	}
}

void VVerenaDatabase::closeDatabase()
{
	if(check())
		database.close();
}



void VVerenaDatabase::AddElementToTable(const QString &name, const QVariantMap &args)
{
	if(!check())
		return;

	QStringList sl;
	QStringList names;
	const QString SQL = QString("INSERT OR REPLACE INTO %1 (%2) VALUES (%3)").arg(name).arg(sl.join(",")).arg(names.join(","));
	for(QVariantMap::const_iterator itor = args.constBegin();
			itor != args.constEnd(); ++itor)
	{
		sl << itor.key();
		names << V_PLACEHOLDER(itor.key());
	}
	QSqlQuery query(database);
	if(database.transaction())
	{
		query.prepare(SQL);
		for(QVariantMap::const_iterator itor = args.constBegin();
				itor != args.constEnd(); ++itor)
		{
			query.bindValue(V_PLACEHOLDER(itor.key()), itor.value());
		}
		query.exec();
		if(!database.commit())
		{
			V_DBG_ERR(query);
			if(!database.rollback()){
				V_DBG_ERR(query);
			}
		}
	}
	else
	{
		query.prepare(SQL);
		for(QVariantMap::const_iterator itor = args.constBegin();
				itor != args.constEnd(); ++itor)
		{
			query.bindValue(V_PLACEHOLDER(itor.key()), itor.value());
		}
		if(!query.exec())
		{
			V_DBG_ERR(query);
		}
	}
}

