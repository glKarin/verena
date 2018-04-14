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
	QFileInfo info(QString(qApp -> applicationDirPath() + "/"
#ifndef VDEBUG
				+ "."
#endif
				+ "./qml/" + dir + file));
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
	QFileInfo info(QString(qApp -> applicationDirPath() + "/"
#ifndef VDEBUG
				+ "."
#endif
				+ "./qml/" + dir + file));
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

void VDeveloper::openExternEditor(const QString &file, const QString &terminal, const QString &editor, bool su) const
{
	QString ext = file.mid(file.lastIndexOf(".") + 1);
	QString dir;
	if(ext == "js" && file.at(0).isLower())
		dir = "js/";
	else
		dir = "verena/";
	QFileInfo info(QString(qApp -> applicationDirPath() + "/"
#ifndef VDEBUG
				+ "."
#endif
				+ "./qml/" + dir + file));
	QString name = info.absoluteFilePath();
	QStringList args;
	QString end;
	args<<terminal;
	args<<QString("-n")
		<<QString("-e");
	if(su)
	{
		args<<QString("/bin/devel-su")
			<<QString("-c");
		end = "\"";
	}
	args<<end + editor
		<<name + end;
	QString cmd = args.join(" ");
	qDebug()<<cmd;
	QProcess::startDetached(cmd);
}

QVariant VDeveloper::getFileList() const
{
	QStringList list;
	list<<QDir(QString(qApp -> applicationDirPath() + "/"
#ifndef VDEBUG
				+ "."
#endif
				+ "./qml/verena/")).entryList(QDir::Files, QDir::Name)
		<<QDir(QString(qApp -> applicationDirPath() + "/"
#ifndef VDEBUG
				+ "."
#endif
				+ "./qml/js/")).entryList(QDir::Files, QDir::Name);
	return QVariant(list);
}

QString VDeveloper::appState() const
{
	return QString(APPLICATION_STATE);
}
