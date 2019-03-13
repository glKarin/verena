#include <QApplication>
#include <QTextStream>
#include <QProcess>
#include <QFile>
#include <QFileInfo>
#include <QDebug>

#include "vdeveloper.h"
#include "vstd.h"

	VDeveloper::VDeveloper(QObject *parent)
:QObject(parent)
{
}

VDeveloper::~VDeveloper()
{
}

QString VDeveloper::appName() const
{
	return APPLICATION_NAME;
}

QString VDeveloper::appVersion() const
{
	return APPLICATION_VERSION;
}

QString VDeveloper::appDeveloper() const
{
	return APPLICATION_DEVELOPER;
}

QString VDeveloper::appMail() const
{
	return APPLICATION_MAIL;
}

QString VDeveloper::appCode() const
{
	return APPLICATION_CODE;
}

QString VDeveloper::appRelease() const
{
	return APPLICATION_RELEASE;
}

QString VDeveloper::appFName() const
{
	return APPLICATION_FULLNAME;
}

#define V_APP_(x) m.insert(#x, APPLICATION_##x)
QVariant VDeveloper::AppLink() const
{
	QVariantMap m;
	V_APP_(GITHUB);
	V_APP_(OPENREPOS_DL);
	V_APP_(PANBAIDU_DL);
	V_APP_(TMO);
	return QVariant(m);
}

QVariant VDeveloper::OsInfo() const
{
	QVariantMap m;
	V_APP_(PLATFORM);
	m.insert("V_QT_VERSION", qVersion());
	V_APP_(DBG);
	return QVariant(m);
}
#undef V_APP_

void VDeveloper::restart()
{
	qApp -> quit();
	QProcess::startDetached(qApp -> applicationFilePath(), QStringList());
}

QVariant VDeveloper::openSourceCode(const QString &file) const
{
	QFileInfo info(file);
	QString code;
	bool canWritable = false;
	bool canReadable = false;
	QMap<QString, QVariant> map;
	QString name = info.absoluteFilePath();
#ifdef VDEBUG
	qDebug() << info.absoluteFilePath();
#endif
	if(!info.exists())
	{
		qWarning() << "[Error]: File is not exists -> " << file;
	}
	if(!info.isFile())
	{
		qWarning() << "[Error]: File is not a normal file -> " << file;
	}
	if(info.isReadable())
	{
		canReadable = true;
	}
	if(info.isWritable())
	{
		canWritable = true;
	}
	QFile codefile(name);
	if (codefile.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		QTextStream in(&codefile);
		code = in.readAll();
		codefile.close();
	}
	map.insert(QString("code"), QVariant(code));
	map.insert(QString("canWritable"), QVariant(canWritable));
	map.insert(QString("canReadable"), QVariant(canReadable));
	return QVariant(map);
}

bool VDeveloper::saveSourceCode(const QString &file, const QString &code) const
{
	QFileInfo info(file);
	QString name = info.absoluteFilePath();
#ifdef VDEBUG
	qDebug() << info.absoluteFilePath();
#endif
	if(!info.exists())
	{
		qWarning() << "[Error]: File is not exists -> " << file;
		return false;
	}
	if(!info.isFile())
	{
		qWarning() << "[Error]: File is not a normal file -> " << file;
		return false;
	}
	if(!info.isWritable())
	{
		qWarning() << "[Error]: File is not writable -> " << file;
		return false;
	}
	QFile codefile(name);
	if (codefile.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		QTextStream out(&codefile);
		out << code;
		codefile.flush();
		codefile.close();
		return true;
	}
	return false;
}

void VDeveloper::openExternEditor(const QString &file, const QString &terminal, const QString &editor, bool su) const
{
#ifdef _HARMATTAN
	QFileInfo info(file);
	QString name = info.absoluteFilePath();
	QStringList args;
	QString end;
	args << terminal;
	args << QString("-n")
		<< QString("-e");
	if(su)
	{
		args << QString("/bin/devel-su")
			<< QString("-c");
		end = "\"";
	}
	args << end + editor
		<< name + end;
	QString cmd = args.join(" ");
#ifdef VDEBUG
	qDebug() << cmd;
#endif
	QProcess::startDetached(cmd);
#else
	qDebug() << QString("openExternEditor(%1, %2, %3, %4)").arg(file).arg(terminal).arg(editor).arg(su);
#endif
}

QVariant VDeveloper::getFileList() const
{
	QVariantList list;
	QFileInfoList info_list;
	QStringList dirs;

	dirs << 
#ifdef _HARMATTAN
		"./verena/" << "./verena/yk/"
#else
		"./verena_symbian/" << "./verena_symbian/yk/"
#endif
		<< "./js/";

	QString path = qApp->applicationDirPath();
	QString dir;
#ifdef _HARMATTAN
#ifdef VDEBUG
	dir = path + "/qml/";
#else
	dir = path + "/../qml/";
#endif
#else
#ifdef VDEBUG
	dir = QDir::cleanPath(path + "/../qml/");
#else
	QString root = path.left(path.indexOf("/"));
	dir = root + "/private/e0629d0e/qml/";
#endif
#endif

	qDebug() << "[DEBUG]: Open source directory -> " << dir;
	Q_FOREACH(const QString &d, dirs)
	{
		QDir directory(dir + d);
		info_list << directory.entryInfoList(QDir::Files, QDir::Name);
	}

	Q_FOREACH(const QFileInfo &info, info_list)
	{
		QVariantMap m;
		m.insert("name", info.fileName());
		m.insert("path", info.absoluteFilePath());
		m.insert("suffix", info.suffix());
		list.push_back(QVariant(m));
	}

	return QVariant(list);
}

QString VDeveloper::appState() const
{
	return QString(APPLICATION_STATE);
}

VDeveloper * VDeveloper::Instance()
{
	static VDeveloper Developer;
	return &Developer;
}
