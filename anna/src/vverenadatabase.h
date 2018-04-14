#ifndef VERENA_DATABASE_H
#define VERENA_DATABASE_H

#include <QString>
#include <QVariant>
#include <QSqlDatabase>
#include <QStringList>

class VVerenaDatabase
{
	public:
        VVerenaDatabase(const QString &name/*, const QString &user, const QString &password*/);
		~VVerenaDatabase();
		void openDatabase();
		void addTable(const QString &name, const QStringList &args, bool over = false);
		int queryTable(const QString &name, const QString &key, const QString &value);
		QVariantList getAllDataFromTable(const QString &name) const;
		void addElementToTable(const QString &name, const QVariantList &args);
		void removeElementFromTable(const QString &name, const QString &key, const QString &value);
		void clearTable(const QString &name);
		void closeDatabase();
		
	private:
		bool check() const;
		QSqlDatabase database;

};

#endif
