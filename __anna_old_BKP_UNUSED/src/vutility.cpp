#include <QApplication>
#include <QClipboard>
#include <QDeclarativeEngine>
#include <QDesktopServices>
#include <QNetworkDiskCache>
#include <QWebSettings>
#include <QDebug>
#include <QDir>
#include <QSettings>
#include "vut.h"
#include "vstd.h"
#include "vnetworkmanager.h"

#define SETTING_VERSION 7

	VUT::VUT(QDeclarativeEngine *engine, QObject *parent)
: QObject(parent),
	engine(engine)
{
	cpp_update = false;
	setting = new QSettings(this);
	userAgentMap.insert("iphone", "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53");
	userAgentMap.insert("iceweasel", "Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20140429 Firefox/24.0 Iceweasel/24.5.0");
	userAgentMap.insert("harmattan", "Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13");
	userAgentMap.insert("android", "Mozilla/5.0 (Linux; U; Android 4.1.1; he-il; Nexus 7 Build/JRO03D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30");
	userAgentMap.insert("s40", "Nokia2700c-2/2.0 (07.80) Profile/MIDP-2.1 Configuration/CLDC-1.1 nokia2700c-2/UC Browser7.7.1.88/69/444 UNTRUSTED/1.0");
	userAgentMap.insert("maemo", "Mozilla/5.0 (X11; U; Linux armv7l; en-GB; rv:1.9.2a1pre) Gecko/20090928 Firefox/3.5 Maemo Browser 1.4.1.22 RX-51 N900");
	userAgentMap.insert("wp7.5", "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0; NOKIA; Lumia 710)");
	//userAgentMap.insert("", "");
	initSettingMap.insert("setting_version", QVariant(SETTING_VERSION));
	initSettingMap.insert("default_player", QVariant(0));
    //initSettingMap.insert("external_player", QVariant(0));
	initSettingMap.insert("verenatouchhome_lock_orientation", QVariant(false));
    //initSettingMap.insert("fullscreen", QVariant(false));
    //initSettingMap.insert("player_corner", QVariant(true));
    initSettingMap.insert("browser_autoload_image", QVariant(false));
	initSettingMap.insert("browser_autoparse_video", QVariant(true));
	initSettingMap.insert("browser_html5_offlineLocalStorage", QVariant(false));
	initSettingMap.insert("user_agent", QVariant("iphone"));
	initSettingMap.insert("card_count_of_line", QVariant(2));
    initSettingMap.insert("browser_helper", QVariant(true));
    /*
	if(!QFile(setting -> fileName()).exists())
	{
#ifdef VDEBUG
		qDebug()<<"first run, the setting not found";
#endif
		resetSetting();
		cpp_update = true;
	}
    */
	if(!setting -> contains("setting_version") || setting -> value("setting_version").toInt() < SETTING_VERSION)
	{
#ifdef VDEBUG
		qDebug()<<"setting version is to low";
#endif
		setSetting("setting_version", initSettingMap["setting_version"]);
		cpp_update = true;
	}
	setUserAgent();
}

VUT::~VUT()
{
}

bool VUT::update() const
{
	return cpp_update;
}

QString VUT::castDiskCache() const
{
	if(engine && engine -> networkAccessManager() -> cache())
	{
        QNetworkDiskCache * cache = dynamic_cast<QNetworkDiskCache *>(engine -> networkAccessManager() -> cache());
		return QString(Vstd::castSize(cache -> cacheSize()) + "/" + Vstd::castSize(cache -> maximumCacheSize()));
	}
	else
	{
		return QString();
	}
}

void VUT::clearDiskCache()
{
	if(engine && engine -> networkAccessManager() -> cache())
	{
		engine -> networkAccessManager() -> cache() -> clear();
	}
}

void VUT::copyToClipboard(const QString &text) const
{
	QApplication::clipboard() -> setText(text);
}

QVariant VUT::getSetting(const QString &name)
{
	if(!setting -> contains(name))
	{
		setSetting(name, initSettingMap[name]);
	}
	return setting -> value(name);
}

void VUT::setSetting(const QString &name, const QVariant &var)
{
	setting -> setValue(name, var);
}

void VUT::resetSetting()
{
	setting -> clear();
	for(QVariantMap::iterator itor = initSettingMap.begin();
			itor != initSettingMap.end();
			++itor)
		setting -> setValue(itor.key(), itor.value());
}

QString VUT::downloadPath() const
{
	return DefaultDownloadPath;
}

void VUT::setUserAgent(){
	QString ua = getSetting("user_agent").toString();
	if(engine)
	{
        if(dynamic_cast<VNetworkAccessManager *>(engine -> networkAccessManager()))
		{
            dynamic_cast<VNetworkAccessManager *>(engine -> networkAccessManager()) -> setUserAgent(userAgentMap[ua]);
		}
	}
}

bool VUT::check(const QUrl &url) const
{
	return url.isValid();
}

bool VUT::newWindow(const QUrl &urlA, const QUrl &urlB) const
{
	return QUrl(QUrl::fromUserInput(urlA.host())).isParentOf(urlB);
}

QUrl VUT::format(const QString &userInput)
{
	return QUrl::fromUserInput(userInput);
}

QString VUT::castBrowserLocalStorage() const
{
	qint64 total = 0;
	const QString dataPath = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
	QString localStorage = dataPath + "/LocalStorage/";
	QString appCache = dataPath + "/ApplicationCache.db";
	QDir dir(localStorage);
	if(dir.exists())
	{
		QFileInfoList list = dir.entryInfoList(QDir::Files);
		for(QFileInfoList::const_iterator itor = list.begin();
				itor != list.end();
				++itor)
			total += itor -> size();
	}
	QFileInfo file(appCache);
	if(file.isFile())
		total += file.size();
	return Vstd::castSize(total);
}

void VUT::clearBrowserCache() const
{
	const QString dataPath = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
	QString localStorage = dataPath + "/LocalStorage/";
	QString appCache = dataPath + "/ApplicationCache.db";
	QDir dir(localStorage);
	if(dir.exists())
	{
		QFileInfoList list = dir.entryInfoList(QDir::Files);
		for(QFileInfoList::iterator itor = list.begin();
				itor != list.end();
				++itor)
			QFile::remove(itor -> absoluteFilePath());
	}
	QFileInfo file(appCache);
	if(file.isFile())
		QFile::remove(file.absoluteFilePath());
}
/*
	 offline s  "/home/user/.verena/LocalStorage"
	 offline  "/home/user/.verena/Databases"
	 offline web  "/home/user/.verena"
	 */

