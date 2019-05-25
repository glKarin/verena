#include "vdownloadtask.h"
#include <QFile>
#include <QDebug>
#include <QDir>
#include <QNetworkReply>
#include <QRegExp>
#include <QByteArray>
#include <QFileInfo>

#include "vstd.h"

VDownloadTask::VDownloadTask(QObject *parent)
	:QObject(parent),
	reply(0),
	cpp_state(VDownloadTask::Ready)
{
	file = new QFile;
	init();
}

VDownloadTask::~VDownloadTask()
{
	if(file -> isOpen())
	{
		file -> flush();
		file -> close();
	}
	delete file;
}

void VDownloadTask::init()
{
	if(!file -> fileName().isEmpty() && file -> exists())
	{
		iread = file -> size();
		setRead(Vstd::castSize(iread));
		setTotal(Vstd::castSize(itotal));
		if(itotal != 0)
		{
			setPercent(iread * 100 / itotal);
		}
		else
		{
			setPercent(0);
		}
	}
	else
	{
		setRead("0B");
		setTotal("0B");
		setPercent(0);
		iread = Q_INT64_C(0);
		itotal = Q_INT64_C(0);
	}
	if(reply)
	{
		setState(VDownloadTask::Doing);
		connect(reply, SIGNAL(readyRead()), this, SLOT(writeData()));
		connect(reply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(updateProgress(qint64, qint64)));
		connect(reply, SIGNAL(finished()), this, SLOT(doFinished()));
	}
}

void VDownloadTask::doFinished()
{
	if(cpp_state == VDownloadTask::Doing)
	{
		endWork(VDownloadTask::Done);
	}
}

bool VDownloadTask::readySave()
{
	QFileInfo info(DefaultDownloadPath);
	QDir dir(DefaultDownloadPath);
	if(!info.exists())
	{
		if(!dir.mkpath(dir.absolutePath()))
		{
			qDebug()<<"Can not mkdir -> "<<info.absoluteFilePath();;
			emit errorChanged(cpp_name, tr("Can not make download folder") + ": " + dir.absolutePath());
			return false;
		}
		qDebug()<<"mkdir -p "<<info.absoluteFilePath();
	}
	else if(!info.isDir())
	{
		if(!QFile::remove(info.absoluteFilePath()))
		{
#ifdef VDEBUG
			qDebug()<<"Can not rm -> "<<info.absoluteFilePath();
#endif
			emit errorChanged(cpp_name, tr("Can not make download folder") + ": " + dir.absolutePath());
			return false;
		}
#ifdef VDEBUG
		qDebug()<<"rm -f "<<info.absoluteFilePath();
#endif
		if(!dir.mkpath(dir.absolutePath()))
		{
			qDebug()<<"Can not mkdir -> "<<info.absoluteFilePath();;
			emit errorChanged(cpp_name, tr("Can not make download folder") + ": " + dir.absolutePath());
			return false;
		}
		qDebug()<<"mkdir -p "<<info.absolutePath();
	}
	touch();
	file -> setFileName(info.absoluteFilePath() + cpp_name);
	setPath(file -> fileName());
	if(!file -> open(QIODevice::WriteOnly))
	{
		emit errorChanged(cpp_name, tr("Can not write data to file") + ": " + file -> fileName());
#ifdef VDEBUG
		qDebug()<<"Can not open -> "<<file -> fileName();
#endif
		return false;
	}
	else
	{
#ifdef VDEBUG
		qDebug()<<"Ready write data -> "<<file -> fileName();
#endif
		setState(VDownloadTask::Ready);
		return true;
	}
}

void VDownloadTask::touch()
{
	QString name = cpp_title.replace(QRegExp("[/\\\\\\?><\\|\\*\":']"), "_");
	QString proto = QString("%1-%2_%3(%4)_%5verena.%6");
	QString tmp = proto.arg(cpp_source).arg(name).arg(cpp_streamtype).arg(cpp_part).arg("").arg(cpp_extName);
	int i = 1;
	while(QFileInfo(DefaultDownloadPath + tmp).exists())
	{
		tmp = proto.arg(cpp_source).arg(name).arg(cpp_streamtype).arg(cpp_part).arg(QString("[%1]_").arg(i)).arg(cpp_extName);
		i++;
	}
	setName(tmp);
#ifdef VDEBUG
	qDebug()<<"File name -> "<<cpp_name;
#endif
}

void VDownloadTask::endWork(VDownloadTask::State state)
{
	setState(state);
	if(file -> exists())
		iread = file -> size();
	else
		iread = 0;
	reply -> deleteLater();
#ifdef VDEBUG
	qDebug()<<"Save end -> "<<file -> fileName();
#endif
	file -> flush();
	file -> close();
	reply = 0;
	emit taskStateChanged(cpp_taskId);
}

void VDownloadTask::abort()
{
	if(cpp_state == VDownloadTask::Doing)
	{
		//removeFile();
#ifdef VDEBUG
		qDebug()<<"Abort";
#endif
        if(reply != 0 && reply -> isRunning())
		{
			reply -> abort();
		}
	}
}

void VDownloadTask::writeData()
{
	if(reply -> error() != QNetworkReply::NoError)
	{
		emit errorChanged(cpp_name, QString("QNetworkReply::NetworkError = ") + QString::number(reply -> error()));
		endWork(VDownloadTask::Fail);
		abort();
		return;
	}
	if(!file -> exists())
	{
		emit errorChanged(QString(cpp_name), tr("File is not exists"));
		endWork(VDownloadTask::Fail);
		abort();
		return;
	}
	if(file -> isOpen() && cpp_state == VDownloadTask::Doing)
	{
		file -> write(reply -> readAll());
	}
}

void VDownloadTask::updateProgress(qint64 read, qint64 total)
{
	if(read == 0 && total == 0)
	{
		emit errorChanged(QString(cpp_name), tr("No download associated"));
		endWork(VDownloadTask::Fail);
		abort();
		return;
	}
	if(total > 0){
		if(total > itotal)
		{
			itotal = total;
			setTotal(Vstd::castSize(itotal));
		}
	}
	else if(total == -1)
	{
		itotal = total;
		cpp_total = tr("Unknow Size");
		setPercent(itotal);
	}
	if(read > 0)
	{
		qint64 cread = iread + read;
		setRead(Vstd::castSize(cread));
		if(itotal != 0)
			setPercent(cread * 100 / itotal);
	}
}

void VDownloadTask::setTotal(const QString &total)
{
	if(cpp_total != total)
	{
		cpp_total = total;
		emit totalChanged();
	}
}

void VDownloadTask::setState(VDownloadTask::State s)
{
	if(cpp_state != s)
	{
		cpp_state = s;
		emit stateChanged();
	}
}

void VDownloadTask::setPath(const QString &path)
{
	if(cpp_path != path)
	{
		cpp_path = path;
		emit pathChanged();
	}
}

void VDownloadTask::setName(const QString &s)
{
	if(cpp_name != s)
	{
		cpp_name = s;
		emit nameChanged();
	}
}

void VDownloadTask::setExtName(const QString &s)
{
	cpp_extName = s;
}

void VDownloadTask::setReply(QNetworkReply *r)
{
	if(reply == 0 && r != 0)
	{
		if(cpp_state != VDownloadTask::Done)
		{
			reply = r;
			init();
			return;
		}
	}
	reply -> deleteLater();
}

bool VDownloadTask::removeFile()
{
	if(file -> isOpen())
	{
		file -> flush();
		file -> close();
	}
	if(!file -> exists())
		return true;
	else
	{
		if(!file -> remove())
		{
#ifdef VDEBUG
			qDebug()<<"Can not remove file -> "<<file -> fileName();
#endif
			return false;
		}
		else
			return true;
	}
	return false;
}

QString VDownloadTask::path() const
{
	return cpp_path;
}

QString VDownloadTask::total() const
{
	return cpp_total;
}

QString VDownloadTask::name() const
{
	return cpp_name;
}

VDownloadTask::State VDownloadTask::state() const
{
	return cpp_state;
}

QString VDownloadTask::vid() const
{
	return cpp_vid;
}

QString VDownloadTask::streamtype() const
{
	return cpp_streamtype;
}

int VDownloadTask::part() const
{
	return cpp_part;
}

QString VDownloadTask::taskId() const
{
	return cpp_taskId;
}

QString VDownloadTask::title() const
{
	return cpp_title;
}

void VDownloadTask::setVid(const QString &vid)
{
	if(cpp_vid != vid)
	{
		cpp_vid = vid;
		emit vidChanged();
	}
}

void VDownloadTask::setStreamtype(const QString &st)
{
	if(cpp_streamtype != st)
	{
		cpp_streamtype = st;
		emit streamtypeChanged();
	}
}

void VDownloadTask::setPart(int part)
{
	if(cpp_part != part)
	{
		cpp_part = part;
		emit partChanged();
	}
}

void VDownloadTask::setTaskId(const QString &id)
{
	if(cpp_taskId != id)
	{
		cpp_taskId = id;
		emit taskIdChanged();
	}
}

void VDownloadTask::setTitle(const QString &t)
{
	if(cpp_title != t)
	{
		cpp_title = t;
		emit titleChanged();
	}
}

qint64 VDownloadTask::castCurrentFileSize() const
{
	if(file -> fileName().isEmpty())
		return 0;
	if(!file -> exists())
	{
#ifdef VDEBUG
		qDebug()<<"Not exist file -> "<<file -> fileName();
#endif
		return 0;
	}
	return file -> size();
}

bool VDownloadTask::continueSave()
{
	if(file -> fileName().isEmpty())
		return false;
	if(!file -> exists())
	{
		qDebug()<<"Not exist file -> "<<file -> fileName();
		return false;
	}
	if(!file -> open(QIODevice::Append))
	{
		emit errorChanged(cpp_name, tr("Can not append data to file") + ": " + file -> fileName());
#ifdef VDEBUG
		qDebug()<<"Can not append -> "<<file -> fileName();
#endif
		setState(VDownloadTask::Fail);
		return false;
	}
	else
	{
		iread = file -> size();
		setState(VDownloadTask::Ready);
#ifdef VDEBUG
		qDebug()<<"Ready write data -> "<<file -> fileName();
#endif
		return true;
	}
}

void VDownloadTask::setUrl(const QString &url)
{
	if(cpp_url != url)
	{
		cpp_url = url;
		emit urlChanged();
	}
}

QString VDownloadTask::url() const
{
	return cpp_url;
}

qint64 VDownloadTask::byteOfRead() const
{
	return iread;
}

qint64 VDownloadTask::byteOfTotal() const
{
	return itotal;
}

void VDownloadTask::setIRead(qint64 i)
{
	iread = i;
}

void VDownloadTask::setITotal(qint64 i)
{
	itotal = i;
}

void VDownloadTask::load()
{
	file -> setFileName(cpp_path);
	setTotal(Vstd::castSize(itotal));
	if(file -> exists())
	{
		iread = file -> size();
		setRead(Vstd::castSize(iread));
	}
	else
	{
		iread = 0;
		setRead("0B");
		setState(VDownloadTask::Fail);
	}
	if(itotal != 0)
		setPercent(iread * 100 / itotal);
	else
		setPercent(0);
}

QString VDownloadTask::source() const
{
	return cpp_source;
}

void VDownloadTask::setSource(const QString &s)
{
	if(cpp_source != s)
	{
		cpp_source = s;
		emit sourceChanged();
	}
}
