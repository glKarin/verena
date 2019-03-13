#ifndef VERENA_UTILITYTOOLKIT_H
#define VERENA_UTILITYTOOLKIT_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QMap>
#include <QUrl>
#include <QByteArray>

#define SETTING_SETTING_VERSION	"setting_version"
#define SETTING_DEFAULT_PLAYER "default_player"
#define SETTING_EXTERNAL_PLAYER	"external_player"
#define SETTING_VERENATOUCHHOME_LOCK_ORIENTATION "verenatouchhome_lock_orientation"
#define SETTING_FULLSCREEN	"fullscreen"
#define SETTING_PLAYER_CORNER	"player_corner"
#define SETTING_BROWSER_AUTOLOAD_IMAGE "browser_autoload_image"
#define SETTING_BROWSER_AUTOPARSE_VIDEO	"browser_autoparse_video"
#define SETTING_BROWSER_HTML5_OFFLINELOCALSTORAGE	"browser_html5_offlineLocalStorage"
#define SETTING_USER_AGENT "user_agent"
#define SETTING_CARD_COUNT_OF_LINE "card_count_of_line"
#define SETTING_BROWSER_HELPER "browser_helper"
#define SETTING_PLAYER_ORIENTATION "player_orientation"

#define SETTING_YOUKU_VIDEO_URL_LOAD_ONCE "youku_video_url_load_once"

#define SETTING_YOUKU_CCODE	"youku/ccode"
#define SETTING_YOUKU_CLIENT_IP	"youku/client_ip"
#define SETTING_YOUKU_CKEY "youku/ckey"
#define SETTING_YOUKU_UA "youku/ua"
#define SETTING_YOUKU_REFERER "youku/referer"

class QSettings;
class QDeclarativeEngine;

class VUT : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QString downloadPath READ downloadPath CONSTANT FINAL)
		Q_PROPERTY(bool update READ update CONSTANT FINAL)
		Q_PROPERTY(QVariant userAgent READ UserAgent CONSTANT FINAL)
		Q_PROPERTY(int vdebug READ VDebug CONSTANT FINAL)

	public:
		~VUT();
		QString downloadPath() const;
		bool update() const;
		Q_INVOKABLE QVariant castDiskCache() const;
		Q_INVOKABLE void clearDiskCache();
		Q_INVOKABLE void copyToClipboard(const QString &text) const;
		Q_INVOKABLE void setSetting(const QString &name, const QVariant &var);
		Q_INVOKABLE QVariant getSetting(const QString &name);
		Q_INVOKABLE void setUserAgent();
		Q_INVOKABLE void resetSetting();
		Q_INVOKABLE bool check(const QUrl &url) const;
		Q_INVOKABLE bool newWindow(const QUrl &urlA, const QUrl &urlB) const;
		Q_INVOKABLE QUrl format(const QString &userInput);
		Q_INVOKABLE qint64 castBrowserLocalStorage() const;
		Q_INVOKABLE void clearBrowserCache() const;
		
		static VUT * Instance();
		void SetDeclarativeEngine(QDeclarativeEngine *e) { engine = e; }
		QDeclarativeEngine * DeclarativeEngine() { return engine; }
		template <class T> T GetSetting(const QString &name);
		Q_INVOKABLE void ResetYoukuSetting();
		Q_INVOKABLE QString OpenAPIv3MD5Sign(const QVariant &sys, const QVariant &user = QVariant(), const QString &secret = QString()) const;
		Q_INVOKABLE QByteArray GetFileMD5(const QString &filePath) const;
		Q_INVOKABLE QByteArray GetStringMD5(const QString &str) const;
		QVariant UserAgent() const;
		QByteArray GetUserAgent(const QString &name) const;
		int VDebug() const;
		Q_INVOKABLE QString XXX(const QString &url) const;

	private:
		VUT(QDeclarativeEngine *engine = 0, QObject *parent = 0);
		Q_DISABLE_COPY(VUT)
		void InitUserAgent();

	private:
		QSettings *setting;
		QDeclarativeEngine *engine;
		QMap<QString, QPair<QByteArray, QString> > userAgentMap;
		QVariantMap initSettingMap;
		bool cpp_update;
};

template <class T> T VUT::GetSetting(const QString &name)
{
	QVariant v = getSetting(name);
	return v.value<T>();
}

#endif
