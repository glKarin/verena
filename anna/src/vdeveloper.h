#ifndef VERENA_DEVELOPER_H
#define VERENA_DEVELOPER_H

#include <QVariant>
#include <QObject>


class VDeveloper : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QString appName READ appName CONSTANT FINAL)
		Q_PROPERTY(QString appVersion READ appVersion CONSTANT FINAL)
		Q_PROPERTY(QString appDeveloper READ appDeveloper CONSTANT FINAL)
		Q_PROPERTY(QString appMail READ appMail CONSTANT FINAL)
		Q_PROPERTY(QString appState READ appState CONSTANT FINAL)

	public:
		VDeveloper(QObject *parent = 0);
		~VDeveloper();
		QString appName() const;
		QString appVersion() const;
		QString appDeveloper() const;
		QString appMail() const;
		QString appState() const;
		Q_INVOKABLE void restart(); 
		Q_INVOKABLE QVariant openSourceCode(const QString &file) const;
		Q_INVOKABLE bool saveSourceCode(const QString &file, const QString &code) const;
        Q_INVOKABLE QVariant getFileList() const;

};

#endif
