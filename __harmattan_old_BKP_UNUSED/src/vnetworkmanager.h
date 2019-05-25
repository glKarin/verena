#ifndef VERENA_NETWORKMANAGER_H
#define VERENA_NETWORKMANAGER_H

#include <QNetworkAccessManager>
#include <QMutex>
#include <QDeclarativeNetworkAccessManagerFactory>

class QString;
class QUrl;
class QByteArray;
class QNetworkRequest;

#define K_SIZE 1024
#define M_SIZE 1048576

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
