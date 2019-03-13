#include <QApplication>
#include <QClipboard>
#include <QDeclarativeEngine>
#include <QDesktopServices>
#include <QNetworkDiskCache>
#include <QWebSettings>
#include <QDebug>
#include <QDir>
#include <QSettings>
#include <QCryptographicHash>

#include "vut.h"
#include "vstd.h"
#include "vvideoplayer.h"
#include "vnetworkmanager.h"

#define SETTING_VERSION 8

	VUT::VUT(QDeclarativeEngine *engine, QObject *parent)
: QObject(parent),
	engine(engine)
{
	cpp_update = false;
	setting = new QSettings(this);

	InitUserAgent();

	initSettingMap.insert(SETTING_SETTING_VERSION, QVariant(SETTING_VERSION));
	initSettingMap.insert(SETTING_DEFAULT_PLAYER, QVariant(0));
	initSettingMap.insert(SETTING_EXTERNAL_PLAYER, QVariant(PLAYER_VIDEO_SUITE));
	initSettingMap.insert(SETTING_VERENATOUCHHOME_LOCK_ORIENTATION, QVariant(false));
	initSettingMap.insert(SETTING_FULLSCREEN, QVariant(false));
	initSettingMap.insert(SETTING_PLAYER_CORNER, QVariant(
#ifdef _HARMATTAN
				true
#else
				false
#endif
				));
	initSettingMap.insert(SETTING_BROWSER_AUTOLOAD_IMAGE, QVariant(true));
	initSettingMap.insert(SETTING_BROWSER_AUTOPARSE_VIDEO, QVariant(true));
	initSettingMap.insert(SETTING_BROWSER_HTML5_OFFLINELOCALSTORAGE, QVariant(false));
	initSettingMap.insert(SETTING_USER_AGENT, QVariant("iphone"));
	initSettingMap.insert(SETTING_CARD_COUNT_OF_LINE, QVariant(2));
	initSettingMap.insert(SETTING_BROWSER_HELPER, QVariant(
#ifdef _HARMATTAN
				false
#else
				true
#endif
				));

	initSettingMap.insert(SETTING_YOUKU_VIDEO_URL_LOAD_ONCE, QVariant(true));
	initSettingMap.insert(SETTING_PLAYER_ORIENTATION, QVariant(PLAYER_LOCK_LANDSCAPE));

	initSettingMap.insert(SETTING_YOUKU_CCODE, QVariant("0521"));
	initSettingMap.insert(SETTING_YOUKU_CLIENT_IP, QVariant("192.168.1.1"));
	initSettingMap.insert(SETTING_YOUKU_CKEY, QVariant("DIl58SLFxFNndSV1GFNnMQVYkx1PP5tKe1siZu/86PR1u/Wh1Ptd+WOZsHHWxysSfAOhNJpdVWsdVJNsfJ8Sxd8WKVvNfAS8aS8fAOzYARzPyPc3JvtnPHjTdKfESTdnuTW6ZPvk2pNDh4uFzotgdMEFkzQ5wZVXl2Pf1/Y6hLK0OnCNxBj3+nb0v72gZ6b0td+WOZsHHWxysSo/0y9D2K42SaB8Y/+aD2K42SaB8Y/+ahU+WOZsHcrxysooUeND"));
	initSettingMap.insert(SETTING_YOUKU_UA, QVariant("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"));
  initSettingMap.insert(SETTING_YOUKU_REFERER, QVariant("https://tv.youku.com"));
	// initSettingMap.insert("youku_ccode_tv", QVariant("0590"));
	// initSettingMap.insert("youku_ccode_tudou", QVariant("0512"));
	
#ifdef _HARMATTAN
	if(!QFile(setting -> fileName()).exists())
	{
#ifdef VDEBUG
		qDebug() << "[INFO]: first run, the setting not found";
#endif
		resetSetting();
		cpp_update = true;
	}
#endif

	if(!setting -> contains(SETTING_SETTING_VERSION) || setting -> value(SETTING_SETTING_VERSION).toInt() < SETTING_VERSION)
	{
#ifdef VDEBUG
		qDebug() << "[INFO]: setting version is to low";
#endif
		setSetting("setting_version", initSettingMap[SETTING_SETTING_VERSION]);
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

QVariant VUT::castDiskCache() const
{
	QVariantMap m;
	if(engine && engine->networkAccessManager()->cache())
	{
		QNetworkDiskCache * cache = static_cast<QNetworkDiskCache *>(engine->networkAccessManager()->cache());
		m.insert("current", cache->cacheSize());
		m.insert("total", cache->maximumCacheSize());
	}
	else
	{
		m.insert("current", 0);
		m.insert("total", 0);
	}
	return QVariant(m);
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
		if(static_cast<VNetworkAccessManager *>(engine -> networkAccessManager()))
		{
			static_cast<VNetworkAccessManager *>(engine -> networkAccessManager())->setUserAgent(userAgentMap[ua].first);
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

qint64 VUT::castBrowserLocalStorage() const
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
			total += itor->size();
	}
	QFileInfo file(appCache);
	if(file.isFile())
		total += file.size();
	return total;
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

VUT * VUT::Instance()
{
	static VUT Vut;
	return &Vut;
}

void VUT::ResetYoukuSetting()
{
#define YOUKU_RESET_SETTING(x) setSetting(x, initSettingMap[x])
	YOUKU_RESET_SETTING(SETTING_YOUKU_CCODE);
	YOUKU_RESET_SETTING(SETTING_YOUKU_CLIENT_IP);
	YOUKU_RESET_SETTING(SETTING_YOUKU_CKEY);
	YOUKU_RESET_SETTING(SETTING_YOUKU_UA);
	YOUKU_RESET_SETTING(SETTING_YOUKU_REFERER);

	YOUKU_RESET_SETTING(SETTING_YOUKU_VIDEO_URL_LOAD_ONCE);
#undef YOUKU_RESET_SETTING
}

// MD5
QString VUT::OpenAPIv3MD5Sign(const QVariant &sys, const QVariant &user, const QString &secret) const
{
	QString r;
	QVariantMap sysp = sys.toMap();

	QMap<QString, QVector<QVariant> > p;
	for(QVariantMap::const_iterator itor = sysp.constBegin();
			itor != sysp.constEnd(); ++itor)
	{
		if(p.contains(itor.key()))
			p[itor.key()].push_back(itor.value());
		else
			p.insert(itor.key(), QVector<QVariant>() << itor.value());
	}
	if(!user.isNull())
	{
		QVariantMap userp = user.toMap();
		for(QVariantMap::const_iterator itor = userp.constBegin();
				itor != userp.constEnd(); ++itor)
		{
			if(p.contains(itor.key()))
				p[itor.key()].push_back(itor.value());
			else
				p.insert(itor.key(), QVector<QVariant>() << itor.value());
		}
	}
	for(QMap<QString, QVector<QVariant> >::const_iterator itor = p.constBegin();
			itor != p.constEnd(); ++itor)
	{
		for(QVector<QVariant>::const_iterator i = itor.value().constBegin();
				i != itor.value().constEnd(); ++i)
		{
			r += itor.key();
			r += QUrl::toPercentEncoding(i->toString());
			//r += i->toString();
		}
	}

	if(!secret.isEmpty())
		r += secret;

	//qDebug() << r;

	QByteArray md5 = GetStringMD5(r);
	//qDebug() << md5 << QString(md5);

	return QString(md5);
}

QByteArray VUT::GetFileMD5(const QString &filePath) const
{
    const quint64 Buf_Size = 4096;
    QFile file(filePath);
    quint64 total = 0;
    quint64 written = 0;
    quint64 unwrite = 0;
    QByteArray buf;

    if (!file.open(QFile::ReadOnly))
    {
        return 0;
    }

    QCryptographicHash ch(QCryptographicHash::Md5);

    total = file.size();
    unwrite = total;

    while(written < total)
    {
        buf = file.read(qMin(unwrite, Buf_Size));
        ch.addData(buf);
        written += buf.length();
        unwrite -= buf.length();
        buf.resize(0);
    }

    file.close();
    QByteArray md5 = ch.result();
    return md5.toHex();
}

QByteArray VUT::GetStringMD5(const QString &str) const
{
    QCryptographicHash ch(QCryptographicHash::Md5);
		ch.addData(str.toAscii());
    QByteArray md5 = ch.result();
    return md5.toHex();
}

void VUT::InitUserAgent()
{
	userAgentMap.clear();

	userAgentMap.insert("iphone", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like MAC OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15a372 Safari/604.1",
				//"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
				tr("iPhone(IOS 11)")
			));
	userAgentMap.insert("iceweasel", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20140429 Firefox/24.0 Iceweasel/24.5.0",
				tr("Debian IceWeasel 24.5.0(based on FireFox 24.0)")
			));
	userAgentMap.insert("harmattan", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13",
				tr("MeeGo(Nokia N9/50 Harmattan edition Grob browser)")
			));
	userAgentMap.insert("android", qMakePair<QByteArray, QString>(
				//"Mozilla/5.0 (Linux; U; Android 4.1.1; he-il; Nexus 7 Build/JRO03D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30",
				//tr("Android(Google Nexus 7 version 4.1.1)")
				"Mozilla/5.0 (Linux; Android 8.1; Nokia X6 Build/OPR1.170623.026; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/48.0.2564.116 Mobile Safari/537.36 T7/10.10 baiduboxapp/10.10.0.12 (Baidu; P1 8.1.0)",
				tr("Android(Nokia X6 Android 8.1)")
			));
	userAgentMap.insert("s40", qMakePair<QByteArray, QString>(
				"Nokia2700c-2/2.0 (07.80) Profile/MIDP-2.1 Configuration/CLDC-1.1 nokia2700c-2/UC Browser7.7.1.88/69/444 UNTRUSTED/1.0",
				tr("Nokia S40(Nokia 2700c S40 v6 Fp1)")
			));
	userAgentMap.insert("maemo", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (X11; U; Linux armv7l; en-GB; rv:1.9.2a1pre) Gecko/20090928 Firefox/3.5 Maemo Browser 1.4.1.22 RX-51 N900",
				tr("MicroB(Nokia N900 browser, based on FireFox 3)")
			));
	userAgentMap.insert("wp7.5", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0; NOKIA; Lumia 710)",
				tr("Windows Phone 7.5 Mango(Nokia Lumia 710)")
			));
	userAgentMap.insert("wp8", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)",
				tr("Windows Phone 8(Nokia Lumia 920)")
			));
	userAgentMap.insert("symbian", qMakePair<QByteArray, QString>(
				"Mozilla/5.0 (Symbian/3; Series60/5.2 NokiaN8-00/012.002; Profile/MIDP-2.1 Configuration/CLDC-1.1 ) AppleWebKit/533.4 (KHTML, like Gecko) NokiaBrowser/7.3.0 Mobile Safari/533.4 3gpp-gba",
				tr("Symbian^3(Nokia N8)")
			));
}

QVariant VUT::UserAgent() const
{
	QVariantMap r;
	for(QMap<QString, QPair<QByteArray, QString> >::const_iterator itor = userAgentMap.constBegin();
			itor != userAgentMap.constEnd(); ++itor)
	{
		r.insert(itor.key(), itor.value().second);
	}
	return QVariant::fromValue<QVariantMap>(r);
}

QByteArray VUT::GetUserAgent(const QString &name) const
{
	return userAgentMap[name].first;
}

int VUT::VDebug() const
{
	return APPLICATION_DBG;
}

QString VUT::XXX(const QString &url) const
{
	static const QString U("http://127.0.0.60/self.php?&b=1&url=%1"); // see also in "qml/image/self.php"

	QByteArray b64(url.toAscii());
	QString r = U.arg(QString(b64.toBase64()));
#ifdef VDEBUG
			qDebug() << r;
#endif
			return r;
}
