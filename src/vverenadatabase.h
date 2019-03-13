#ifndef VERENA_DATABASE_H
#define VERENA_DATABASE_H

#include <QString>
#include <QVariant>
#include <QSqlDatabase>
#include <QStringList>

class VVerenaDatabase
{
	public:
		VVerenaDatabase(const QString &name, const QString &user = QString(), const QString &password = QString());
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
		Q_DISABLE_COPY(VVerenaDatabase)
		bool check() const;

	private:
		QSqlDatabase database;

};

#endif
