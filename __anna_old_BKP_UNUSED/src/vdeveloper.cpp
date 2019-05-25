#include "vdeveloper.h"
#include "vstd.h"
#include <QApplication>
#include <QTextStream>
#include <QProcess>
#include <QFile>
#include <QFileInfo>
#include <QDebug>

	VDeveloper::VDeveloper(QObject *parent)
:QObject(parent)
{
}

VDeveloper::~VDeveloper()
{
}

QString VDeveloper::appName() const
{
	return QString(APPLICATION_NAME);
}

QString VDeveloper::appVersion() const
{
	return QString(APPLICATION_VERSION);
}

QString VDeveloper::appDeveloper() const
{
	return QString(APPLICATION_DEVELOPER);
}

QString VDeveloper::appMail() const
{
	return QString(APPLICATION_MAIL);
}

void VDeveloper::restart()
{
	qApp -> quit();
	QProcess::startDetached(qApp -> applicationFilePath(), QStringList());
}

QVariant VDeveloper::openSourceCode(const QString &file) const
{
	QString ext = file.mid(file.lastIndexOf(".") + 1);
	QString dir;
    if(ext == "js" && file.at(0).isLower())
		dir = "js/";
	else
        dir = "verena/";
#ifdef _SIMULATOR
            QFileInfo info(QString(qApp -> applicationDirPath() + "/../qml/" + dir + file));
#else
    QString path = qApp -> applicationDirPath();
    QString root = path.left(path.indexOf("/"));
            QFileInfo info(root + "/private/e0629d0e/qml/" + dir + file);
#endif
	QString code;
	bool canWritable = false;
	bool canReadable = false;
	QMap<QString, QVariant> map;
	QString name = info.absoluteFilePath();
#ifdef VDEBUG
	qDebug()<<info.absoluteFilePath();
#endif
	if(!info.exists())
	{
		qDebug()<<"File is not exists";
	}
	if(!info.isFile())
	{
		qDebug()<<"File is not a normal file";
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
	QString ext = file.mid(file.lastIndexOf(".") + 1);
	QString dir;
    if(ext == "js" && file.at(0).isLower())
		dir = "js/";
	else
        dir = "verena/";
#ifdef _SIMULATOR
            QFileInfo info(QString(qApp -> applicationDirPath() + "/../qml/" + dir + file));
#else
    QString path = qApp -> applicationDirPath();
    QString root = path.left(path.indexOf("/"));
            QFileInfo info(root + "/private/e0629d0e/qml/" + dir + file);
#endif
	QString name = info.absoluteFilePath();
#ifdef VDEBUG
	qDebug()<<info.absoluteFilePath();
#endif
	if(!info.exists())
	{
		qDebug()<<"File is not exists";
		return false;
	}
	if(!info.isFile())
	{
		qDebug()<<"File is not a normal file";
		return false;
	}
	if(!info.isWritable())
	{
		qDebug()<<"File is not allow to write";
		return false;
	}
	QFile codefile(name);
	if (codefile.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		QTextStream out(&codefile);
		out<<code;
		codefile.flush();
		codefile.close();
		return true;
	}
	return false;
}

QVariant VDeveloper::getFileList() const
{
	QStringList list;
#ifdef _SIMULATOR
            QString dir = QDir::cleanPath(qApp -> applicationDirPath() + "/../qml/");
            qDebug()<<dir;
#else
    QString path = qApp -> applicationDirPath();
    QString root = path.left(path.indexOf("/"));
            QString dir = root + "/private/e0629d0e/qml/";
#endif
    list<<QDir(dir + "verena/").entryList(QDir::Files, QDir::Name)
        <<QDir(dir + "js/").entryList(QDir::Files, QDir::Name);
	return QVariant(list);
}

QString VDeveloper::appState() const
{
	return QString(APPLICATION_STATE);
}
