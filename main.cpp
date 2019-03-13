#include <QtGui/QApplication>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QWebSettings>
#include <QLocale>
#include <QTranslator>
#include <QTextCodec>
#ifdef _SYMBIAN
#include <QLibraryInfo>
#endif
#include "QDebug"

#include "qmlapplicationviewer.h"
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
	VUT *vut;
	VDownloadManager *manager;
	VDeveloper *developer;
	QTranslator translator;
	QString qm, qmdir;
	QApplication *a;
	QDeclarativeEngine *engine;
	VDeclarativeNetworkAccessManagerFactory factory;
	const QString RegisterUncreatableTypeMsg(QString("[ERROR]: %1 -> %2").arg(QObject::tr("Can not create a single-instance object")));

#ifdef _SYMBIAN
	QApplication::setAttribute(Qt::ApplicationAttribute(11));
#endif
	a = createApplication(argc, argv);
	a->setApplicationName(APPLICATION_NAME);
	a->setOrganizationName(APPLICATION_DEVELOPER);
	a->setApplicationVersion(APPLICATION_VERSION);
	QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));

	QString locale = QLocale::system().name();
#ifdef _HARMATTAN
#ifdef VDEBUG
	qm = "verena.zh_CN.qm";
	qmdir = "i18n/";
#else
	qm = QString("verena.") + locale;
	qmdir = "/opt/verena/i18n/";
#endif
#else
#ifdef VDEBUG
	Q_INIT_RESOURCE(verena);
	qm = QString(":/i18n/verena.") + locale;
#else
	qm = QString("qt_") + locale;
	qmdir = QLibraryInfo::location(QLibraryInfo::TranslationsPath);
#endif
#endif
	if(translator.load(qm, qmdir))
	{
		qDebug() << QString("[INFO]: Load i18n -> %1: %2 [%3]").arg(locale).arg(qm).arg(qmdir);
		a->installTranslator(&translator);
	}
	else
		qWarning() << QString("[DEBUG]: Not found i18n -> %1: %2 [%3]").arg(locale).arg(qm).arg(qmdir);

	QWebSettings::enablePersistentStorage();
	QScopedPointer<QApplication> app(a);

	qmlRegisterType<QDeclarativeWebView>("VerenaWebKit", 1, 0, "VWebView");
	qmlRegisterType<QDeclarativeWebSettings>();
	qmlRegisterType<VVideoPlayer>("karin.verena", VERENA_QML_MAJOR_VERSION, VERENA_QML_MINOR_VERSION, "VPlayer");
	qmlRegisterType<VDownloadTask>("karin.verena", VERENA_QML_MAJOR_VERSION, VERENA_QML_MINOR_VERSION, "VDownloadTask");
	qmlRegisterUncreatableType<VDownloadManager>("karin.verena", VERENA_QML_MAJOR_VERSION, VERENA_QML_MINOR_VERSION, "VDownloadManager", RegisterUncreatableTypeMsg.arg("VDownloadManager"));

	QmlApplicationViewer viewer;
#ifdef _HARMATTAN
	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#else
	viewer.setProperty("orientationMethod", 1);
	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
#endif

	engine = viewer.engine();
	vut = VUT::Instance();
	engine->setNetworkAccessManagerFactory(&factory);
	vut->SetDeclarativeEngine(engine);
	developer = VDeveloper::Instance();
	manager = VDownloadManager::Instance();

	viewer.rootContext()->setContextProperty("vut", vut);
	viewer.rootContext()->setContextProperty("developer", developer);
	viewer.rootContext()->setContextProperty("vdlmanager", manager);

#ifdef _HARMATTAN
	viewer.setMainQmlFile(QLatin1String("qml/verena/main.qml"));
#else
	viewer.setMainQmlFile(QLatin1String("qml/verena_symbian/main.qml"));
#endif
	viewer.showExpanded();

	/*
		 VVerena verena;
		 verena.search(QString("nokia n950"));
		 */

	return app->exec();
}
