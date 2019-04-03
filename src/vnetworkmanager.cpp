#include <QString>
#include <QApplication>
#include <QByteArray>
#include <QMutexLocker>
#include <QDebug>
#include <QUrl>
#include <QDir>
#include <QDateTime>
#include <QDesktopServices>
#include <QNetworkDiskCache>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSslConfiguration>
#include <QSsl>
#include <QSslSocket>

#include "vnetworkmanager.h"
#include "vstd.h"
#include "vut.h"

#define DEFAULT_DISKCACHE_SIZE_M 10

static const QVector<QString> YoukuSpecialUrl(QVector<QString>() << "ups.youku.com"
#if 0
		<< "vali.cp31.ott.cibntv.net"
    << "play.youku.com" << "k.youku.com" 
#endif
			);

VNetworkAccessManager::VNetworkAccessManager(QObject *parent)
	: QNetworkAccessManager(parent),
	userAgent(VUT::Instance()->GetUserAgent(VUT::Instance()->GetSetting<QString>(SETTING_USER_AGENT)))
{
#if 1
	QNetworkCookieJar *cookieJar = VNetworkCookieJar::Instance();
	setCookieJar(cookieJar);
	cookieJar->setParent(0);
#endif
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
	VUT *ut;

	ut = VUT::Instance();
    QNetworkRequest request(req);

#ifndef _HARMATTAN
		if(request.url().scheme() == "https")
		{
			QSslConfiguration config;
			config.setPeerVerifyMode(QSslSocket::VerifyNone);
			config.setProtocol(QSsl::TlsV1);
			request.setSslConfiguration(config);
		}
#endif

    if(!Verena::SpecialRequest(&request))
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
	qDebug() << "[DEBUG]: Disk cache path -> " << dataPath;
#endif
	QDir dir(dataPath);
	if (!dir.exists())
	{
		dir.mkpath(dir.absolutePath());
#ifdef VDEBUG
		qDebug() << "[DEBUG]: Not exists, mkdir";
#endif
	}
	QNetworkDiskCache* diskCache = new QNetworkDiskCache(manager);
	diskCache -> setCacheDirectory(dataPath);
	diskCache -> setMaximumCacheSize(DEFAULT_DISKCACHE_SIZE_M * M_SIZE);
	manager -> setCache(diskCache);
#if 0
	QNetworkCookieJar *cookieJar = VDeclarativeNetworkAccessManagerFactory::instanceCookieJar();
	manager -> setCookieJar(cookieJar);
	cookieJar -> setParent(0);
#endif
	return manager;
}

QNetworkCookieJar * VDeclarativeNetworkAccessManagerFactory::instanceCookieJar()
{
	static QNetworkCookieJar cookieJar;
	return &cookieJar;
}



VNetworkCookieJar::VNetworkCookieJar(QObject *parent)
	: QNetworkCookieJar(parent)
{
	Restore();
}

VNetworkCookieJar::~VNetworkCookieJar()
{
	Save();
}


void VNetworkCookieJar::Save()
{
	//qDebug() << allCookies();
}

void VNetworkCookieJar::Restore()
{
}

VNetworkCookieJar * VNetworkCookieJar::Instance()
{
	static VNetworkCookieJar Cookie_jar;
	return &Cookie_jar;
}

// do not save cookies of youku video url
QList<QNetworkCookie>	VNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
	//qDebug() << "GET" << url << QNetworkCookieJar::cookiesForUrl(url);
	return QNetworkCookieJar::cookiesForUrl(url);

	QString host = url.host();
	if(YoukuSpecialUrl.contains(host))
	{
		return QList<QNetworkCookie>();
	}
	return QNetworkCookieJar::cookiesForUrl(url);
}

bool VNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
	//qDebug() << "SET" << url << cookieList;
	return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);

	QString host = url.host();
	if(YoukuSpecialUrl.contains(host))
	{
		return false;
	}
	return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}

namespace Verena
{
	bool SpecialRequest(QNetworkRequest *req, const VNetworkHeaders_t &headers)
	{
		bool r;
		VUT *ut;
		QString host;

		r = false;

		if(!req)
			goto __Exit;

		ut = VUT::Instance();
		host = req->url().host();
		if(YoukuSpecialUrl.contains(host))
		{
			req->setRawHeader("Referer", ut->GetSetting<QByteArray>(SETTING_YOUKU_REFERER));
			req->setRawHeader("User-Agent", ut->GetSetting<QByteArray>(SETTING_YOUKU_UA));

#if 0 //k (2016)
			//QString s("__ysuid=" + QString::number(std::time(0)));
			QString s(QString("__ysuid=%1%2").arg(QDateTime::currentMSecsSinceEpoch()).arg(100 + qrand() % (999 - 100)));
			qDebug()<<s;
			request.setRawHeader("Cookie", s.toAscii());
#endif
			r = true;
			goto __Exit;
		}

		if(!headers.isEmpty())
		{
#ifdef VDEBUG
			qDebug() << "[DEBUG]: Special url -> " << req->url();
#endif
			for(QMap<QByteArray, QByteArray>::const_iterator itor = headers.constBegin();
					itor != headers.constEnd(); ++itor)
			{
				req->setRawHeader(itor.key(), itor.value());
#ifdef VDEBUG
				qDebug() << "[DEBUG]: Special header -> " << itor.key() << itor.value();
#endif
			}
			r = true;
			goto __Exit;
		}

__Exit:
		return r;
	}

	VNetworkHeaders_t YoukuSpecialHeaders()
	{
		VNetworkHeaders_t headers;
		VUT *ut;
		QByteArray ip;

		ut = VUT::Instance();
		ip.append(RandIP());

		headers.insert("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); //                "Accept-Encoding: gzip, deflate, br",
		headers.insert("Accept-Language", "zh-CN,en-US;q=0.7,en;q=0.3");
		//headers.insert("Referer", ut->GetSetting<QByteArray>(SETTING_YOUKU_REFERER));
		headers.insert("User-Agent", 
				//k ut->GetSetting<QByteArray>(SETTING_YOUKU_UA)
				"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
				);
		/*
		headers.insert("HTTP_X_FORWARDED_FOR", ip);
		headers.insert("CLIENT-IP", ip);
		*/
		headers.insert("X-Forwarded-For", ip);
		//headers.insert("Client-Ip", ip);

		return headers;
	}

	QString RandIP(quint8 min, quint8 max)
	{
#define _V_R(m, n) (qrand() % (n - m) + m)
		qsrand(QDateTime::currentMSecsSinceEpoch());
		return QString("%1.%2.%3.%4").arg(_V_R(min, max)).arg(_V_R(min, max)).arg(_V_R(min, max)).arg(_V_R(min, max));
#undef _V_R
	}
}
