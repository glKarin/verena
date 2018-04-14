#include <QtGui/QApplication>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QWebSettings>
#include "qmlapplicationviewer.h"
#include <QLocale>
#include <QTranslator>
#include <QTextCodec>
#include <QLibraryInfo>
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
    //if(QString(qVersion()) >= "4.8.0")
        QApplication::setAttribute((Qt::ApplicationAttribute)11);
	QApplication *a = createApplication(argc, argv);
	a->setApplicationName(APPLICATION_NAME);
	a->setOrganizationName(APPLICATION_DEVELOPER);
	a->setApplicationVersion(APPLICATION_VERSION);
	QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));

    QString locale = QLocale::system().name();
    QTranslator qtTranslator;
    if (qtTranslator.load("qt_"+locale, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        a -> installTranslator(&qtTranslator);
    QTranslator translator;
    if (translator.load(a -> applicationName() + "." + locale, ":/i18n/"))
        a -> installTranslator(&translator);

	QWebSettings::enablePersistentStorage();
	QScopedPointer<QApplication> app(a);

	qmlRegisterType<QDeclarativeWebView>("VerenaWebKit", 1, 0, "VWebView");
	qmlRegisterType<QDeclarativeWebSettings>();
	qmlRegisterType<VVideoPlayer>("karin.verena",1,5,"VPlayer");
	qmlRegisterType<VDeveloper>("karin.verena.dev",1,1,"VDeveloper");
	qmlRegisterType<VDownloadTask>("karin.verena",1,5,"VDownloadTask");
	qmlRegisterType<VDownloadManager>("karin.verena",1,5,"VDownloadManager");

    QmlApplicationViewer viewer;
    viewer.setProperty("orientationMethod", 1);
#ifdef _SYMBIAN
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
#else
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#endif

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
