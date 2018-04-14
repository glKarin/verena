#ifndef VERENA_UTILITYTOOLKIT_H
#define VERENA_UTILITYTOOLKIT_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QMap>
#include <QUrl>
#include <QByteArray>

class QSettings;
class QDeclarativeEngine;

class VUT : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QString downloadPath READ downloadPath CONSTANT FINAL)
		Q_PROPERTY(bool update READ update CONSTANT FINAL)

	public:
		VUT(QDeclarativeEngine *engine, QObject *parent = 0);
		~VUT();
		QString downloadPath() const;
		bool update() const;
		Q_INVOKABLE QString castDiskCache() const;
		Q_INVOKABLE void clearDiskCache();
		Q_INVOKABLE void copyToClipboard(const QString &text) const;
		Q_INVOKABLE void setSetting(const QString &name, const QVariant &var);
		Q_INVOKABLE QVariant getSetting(const QString &name);
		Q_INVOKABLE void setUserAgent();
		Q_INVOKABLE void resetSetting();
		Q_INVOKABLE bool check(const QUrl &url) const;
		Q_INVOKABLE bool newWindow(const QUrl &urlA, const QUrl &urlB) const;
		Q_INVOKABLE QUrl format(const QString &userInput);
		Q_INVOKABLE QString castBrowserLocalStorage() const;
		Q_INVOKABLE void clearBrowserCache() const;

	private:
		VUT(const VUT &ut);
		VUT & operator=(const VUT &ut);
		QSettings *setting;
		QDeclarativeEngine *engine;
		QMap<QString, QByteArray> userAgentMap;
		QVariantMap initSettingMap;
		bool cpp_update;
};

#endif
