#ifndef VERENA_NETWORKMANAGER_H
#define VERENA_NETWORKMANAGER_H

#include <QNetworkAccessManager>
#include <QMutex>
#include <QNetworkCookieJar>
#include <QDeclarativeNetworkAccessManagerFactory>
#include <QMap>

class QString;
class QUrl;
class QByteArray;
class QNetworkRequest;

#define K_SIZE 1024
#define M_SIZE 1048576

namespace Verena
{
	typedef QMap<QByteArray, QByteArray> VNetworkHeaders_t;
	bool SpecialRequest(QNetworkRequest *req, const VNetworkHeaders_t &headers = VNetworkHeaders_t());
	VNetworkHeaders_t YoukuSpecialHeaders();
	QString RandIP(quint8 min = 50, quint8 max = 250);
}

class VNetworkCookieJar : public QNetworkCookieJar
{
	Q_OBJECT

	public:
		virtual ~VNetworkCookieJar();
		static VNetworkCookieJar * Instance();
		virtual QList<QNetworkCookie>	cookiesForUrl(const QUrl &url) const;
		virtual bool setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url);

		virtual void Save();
		virtual void Restore();

	private:
		VNetworkCookieJar(QObject *parent = 0);

};

class VNetworkAccessManager : public QNetworkAccessManager
{
	Q_OBJECT

	public:
		enum RequestType{
			Get = 0,
			Post
		};
		VNetworkAccessManager(QObject *parent = 0);
		virtual ~VNetworkAccessManager();
		QNetworkReply * postRequest(const QString &url, const QByteArray &data = QByteArray(), RequestType type = Get);
		void setUserAgent(const QByteArray &ua);

		virtual QNetworkReply *	createRequest ( Operation op, const QNetworkRequest & req, QIODevice * outgoingData = 0 );

	private:
			QMutex mutex;
			QByteArray userAgent;
};

class VDeclarativeNetworkAccessManagerFactory : public QDeclarativeNetworkAccessManagerFactory
{
	public:
		VDeclarativeNetworkAccessManagerFactory();
		~VDeclarativeNetworkAccessManagerFactory();
		QNetworkAccessManager * create(QObject *parent);
		static QNetworkCookieJar * instanceCookieJar();

	private:
		QMutex mutex;
};

#endif
