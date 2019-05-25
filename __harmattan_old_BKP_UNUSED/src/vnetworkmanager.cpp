#include <QString>
#include <QApplication>
#include <QByteArray>
#include <QMutexLocker>
#include <QDebug>
#include <QUrl>
#include <QDir>
#include <QDateTime>
#include <QDesktopServices>
#include <QNetworkCookieJar>
#include <QNetworkDiskCache>
#include <QNetworkReply>
#include <QNetworkRequest>
#include "vnetworkmanager.h"
#include "vstd.h"
//#include <QSslConfiguration>
//#include <QSsl>

#define DEFAULT_DISKCACHE_SIZE_M 10

VNetworkAccessManager::VNetworkAccessManager(QObject *parent)
	: QNetworkAccessManager(parent),
	userAgent("Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
{
}

VNetworkAccessManager::~VNetworkAccessManager()
{
}

void VNetworkAccessManager::setUserAgent(const QByteArray &ua)
{
	userAgent = ua;
}

QNetworkReply * VNetworkAccessManager::postRequest(const QString &url, const QByteArray &data, RequestType type)
{
	QMutexLocker locker(&mutex);
	QNetworkRequest req;
	req.setUrl(QUrl(url));
	if(type == VNetworkAccessManager::Get)
	{
		return QNetworkAccessManager::get(req);
	}
	else if(type == VNetworkAccessManager::Post)
	{
		return QNetworkAccessManager::post(req, data);
	}
	else
		return 0;
}

QNetworkReply *	VNetworkAccessManager::createRequest ( QNetworkAccessManager::Operation op, const QNetworkRequest & req, QIODevice * outgoingData)
{
#ifdef VDEBUG
	//qDebug()<<op<<" -> "<<req.url();
#endif
    QNetworkRequest request(req);
    QString host = request.url().host();
    if(host == "play.youku.com" || host == "k.youku.com" || host == "ups.youku.com")
    {
        request.setAttribute(QNetworkRequest::CookieLoadControlAttribute, QNetworkRequest::Manual);
        request.setRawHeader("Referer", "http://static.youku.com");
        request.setRawHeader("User-Agent",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1"
    );
				// glBegin(2017)
        //QString s("__ysuid=" + QString::number(std::time(0))); // 2016
				QString s(QString("__ysuid=%1%2").arg(QDateTime::currentMSecsSinceEpoch()).arg(100 + qrand() % (999 - 100)));
				//qDebug()<<s;
        request.setRawHeader("Cookie", s.toAscii());
				// glEnd()
    }
    else
     request.setRawHeader("User-Agent", userAgent);
	QNetworkReply *reply = QNetworkAccessManager::createRequest(op, request, outgoingData);
	return reply;
}

	VDeclarativeNetworkAccessManagerFactory::VDeclarativeNetworkAccessManagerFactory()
:QDeclarativeNetworkAccessManagerFactory()
{
}

VDeclarativeNetworkAccessManagerFactory::~VDeclarativeNetworkAccessManagerFactory()
{
}

QNetworkAccessManager * VDeclarativeNetworkAccessManagerFactory::create(QObject *parent)
{
	QMutexLocker lock(&mutex);
	QNetworkAccessManager* manager = new VNetworkAccessManager(parent);
	QString dataPath = QDesktopServices::storageLocation(QDesktopServices::CacheLocation);
#ifdef VDEBUG
	qDebug()<<"Disk cache path -> "<<dataPath;
#endif
	QDir dir(dataPath);
	if (!dir.exists())
	{
		dir.mkpath(dir.absolutePath());
		qDebug()<<"Not exists, mkdir";
	}
	QNetworkDiskCache* diskCache = new QNetworkDiskCache(manager);
	diskCache -> setCacheDirectory(dataPath);
	diskCache -> setMaximumCacheSize(DEFAULT_DISKCACHE_SIZE_M * M_SIZE);
	manager -> setCache(diskCache);
	QNetworkCookieJar *cookieJar = VDeclarativeNetworkAccessManagerFactory::instanceCookieJar();
	manager -> setCookieJar(cookieJar);
	cookieJar -> setParent(0);
	return manager;
}

QNetworkCookieJar * VDeclarativeNetworkAccessManagerFactory::instanceCookieJar()
{
	static QNetworkCookieJar cookieJar;
	return &cookieJar;
}
