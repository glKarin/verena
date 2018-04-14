#include <QtGui/QApplication>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QWebSettings>
#include "qmlapplicationviewer.h"
#include <QLocale>
#include <QTranslator>
#include <QTextCodec>
#include "QDebug"
#include "vdeveloper.h"
#include "vdeclarativewebview.h"
#include "vstd.h"
#include "vvideoplayer.h"
#include "vnetworkmanager.h"
#include "vdownloadmanager.h"
#include "vdownloadtask.h"
#include "vut.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
	QApplication *a = createApplication(argc, argv);
	a->setApplicationName(APPLICATION_NAME);
	a->setOrganizationName(APPLICATION_DEVELOPER);
	a->setApplicationVersion(APPLICATION_VERSION);
	QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));

	QTranslator translator;
#ifdef VDEBUG
	if(translator.load(QString("verena.zh_CN.qm"),"i18n/"))
	{
		qDebug()<<"Load i18n -> \"verena.zh_CN.qm\"";
#else
	QString locale = QLocale::system().name();

	if(translator.load(QString("verena.") + locale,"/opt/verena/i18n/"))
	{
#ifdef VDEBUG
		qDebug()<<"Load i18n -> \"verena."<<locale<<".qm\"";
#endif
#endif
		a->installTranslator(&translator);
	}

	QWebSettings::enablePersistentStorage();
	QScopedPointer<QApplication> app(a);

	qmlRegisterType<QDeclarativeWebView>("VerenaWebKit", 1, 0, "VWebView");
	qmlRegisterType<QDeclarativeWebSettings>();
	qmlRegisterType<VVideoPlayer>("karin.verena",1,5,"VPlayer");
	qmlRegisterType<VDeveloper>("karin.verena.dev",1,1,"VDeveloper");
	qmlRegisterType<VDownloadTask>("karin.verena",1,5,"VDownloadTask");
	qmlRegisterType<VDownloadManager>("karin.verena",1,5,"VDownloadManager");

	QmlApplicationViewer viewer;
	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

	VDeclarativeNetworkAccessManagerFactory factory;
	QDeclarativeEngine *engine = viewer.engine();
	engine -> setNetworkAccessManagerFactory(&factory);
	VUT vut(engine);
	viewer.rootContext() -> setContextProperty("vut", &vut);

	viewer.setMainQmlFile(QLatin1String("qml/verena/main.qml"));
	viewer.showExpanded();

	/*
		 VVerena verena;
		 verena.search(QString("nokia n950"));
		 */

	return app->exec();
}
