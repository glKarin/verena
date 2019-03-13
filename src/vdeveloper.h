#ifndef VERENA_DEVELOPER_H
#define VERENA_DEVELOPER_H

#include <QVariant>
#include <QObject>

#ifdef _HARMATTAN
#define V_DEFAULT_EDITOR "/usr/bin/vi"
#define V_DEFAULT_TERMINAL "/usr/bin/meego-terminal"
#else
#define V_DEFAULT_EDITOR ""
#define V_DEFAULT_TERMINAL ""
#endif

class VDeveloper : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QString appName READ appName CONSTANT FINAL)
		Q_PROPERTY(QString appVersion READ appVersion CONSTANT FINAL)
		Q_PROPERTY(QString appDeveloper READ appDeveloper CONSTANT FINAL)
		Q_PROPERTY(QString appMail READ appMail CONSTANT FINAL)
		Q_PROPERTY(QString appState READ appState CONSTANT FINAL)
		Q_PROPERTY(QString appCode READ appCode CONSTANT FINAL)
		Q_PROPERTY(QString appRelease READ appRelease CONSTANT FINAL)
		Q_PROPERTY(QVariant appLink READ AppLink CONSTANT FINAL)
		Q_PROPERTY(QVariant osInfo READ OsInfo CONSTANT FINAL)
		Q_PROPERTY(QString appFName READ appFName CONSTANT FINAL)

	public:
		~VDeveloper();
		QString appName() const;
		QString appVersion() const;
		QString appDeveloper() const;
		QString appMail() const;
		QString appState() const;
		QString appCode() const;
		QString appRelease() const;
		QVariant AppLink() const;
		QVariant OsInfo() const;
		QString appFName() const;

		Q_INVOKABLE void restart(); 
		Q_INVOKABLE QVariant openSourceCode(const QString &file) const;
		Q_INVOKABLE bool saveSourceCode(const QString &file, const QString &code) const;
		Q_INVOKABLE void openExternEditor(const QString &file, const QString &terminal = QString(V_DEFAULT_TERMINAL), const QString &editor = QString(V_DEFAULT_EDITOR), bool su = false) const;
		Q_INVOKABLE QVariant getFileList() const;
		static VDeveloper * Instance();

	private:
		VDeveloper(QObject *parent = 0);

};

#endif
