#include <QFile>
#include <QDebug>
#include <QDir>
#include <QRegExp>
#include <QByteArray>
#include <QFileInfo>

#include "vdownloadtask.h"
#include "vnetworkmanager.h"
#include "vdownloadmanager.h"
#include "vstd.h"

#define V_ZERO_BYTE 0
#define V_UNKNOW_SIZE -1

#ifdef VDEBUG
#define VDEBUG_D
#endif

VDownloadTask::VDownloadTask(VDownloadManager *m, QObject *parent)
	:QObject(parent),
	file(new QFile),
	reply(0),
	cpp_state(VDownloadTask::Ready),
	oManager(0)
{
	SetDownloadManager(m);
	init();
}

VDownloadTask::~VDownloadTask()
{
	if(file)
	{
		if(file->isOpen())
		{
			file->flush();
			file->close();
		}
		delete file;
	}
}

void VDownloadTask::init()
{
	if(!file -> fileName().isEmpty() && file -> exists())
	{
		SetStartBytes(file->size());
		setRead(cpp_read);
		setTotal(cpp_total);
		if(cpp_total != 0)
		{
			setPercent(cpp_read * 100 / cpp_total);
		}
		else
		{
			setPercent(0);
		}
	}
	else
	{
		setRead(0);
		setTotal(0);
		setPercent(0);
		SetStartBytes(0);
	}
	iCurrentReading = 0;
	iCurrentTotal = 0;
	if(reply)
	{
		setState(VDownloadTask::Doing);
		//connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorSLOT(QNetworkReply::NetworkError)));
		connect(reply, SIGNAL(readyRead()), this, SLOT(writeData()));
		connect(reply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(updateProgress(qint64, qint64)));
		connect(reply, SIGNAL(finished()), this, SLOT(doFinished()));
	}
}

void VDownloadTask::doFinished()
{
#ifdef VDEBUG
		qDebug() << QString("[%1]: %2 - [%3] -> 0x%4 0x%5").arg(__func__).arg(reply ? reply->error() : -1).arg(reply ? reply->errorString() : "").arg(reply ? reinterpret_cast<intptr_t>(reply->thread()) : 0, 0, 16).arg(reinterpret_cast<intptr_t>(thread()), 0, 16);
#endif
	if(cpp_state == VDownloadTask::Doing)
	{
    if(!reply || reply->error() != QNetworkReply::NoError || iCurrentTotal == 0)
		{
			if(RedirectUrl() != 0)
				endWork(VDownloadTask::Fail);
		}
		else
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
			qWarning() << "[ERROR]: Can not mkdir -> " << info.absoluteFilePath();
			emit errorChanged(cpp_name, tr("Can not make download folder") + ": " + dir.absolutePath());
			return false;
		}
		qDebug() << "[INFO]: mkdir -p " << info.absoluteFilePath();
	}
	else if(!info.isDir())
	{
		if(!QFile::remove(info.absoluteFilePath()))
		{
#ifdef VDEBUG
			qWarning() << "[WARNING]: Can not rm -> " << info.absoluteFilePath();
#endif
			emit errorChanged(cpp_name, tr("Can not make download folder") + ": " + dir.absolutePath());
			return false;
		}
#ifdef VDEBUG
		qDebug() << "[INFO]: rm -f " << info.absoluteFilePath();
#endif
		if(!dir.mkpath(dir.absolutePath()))
		{
			qWarning() << "[ERROR]: Can not mkdir -> " << info.absoluteFilePath();;
			emit errorChanged(cpp_name, tr("Can not make download folder") + ": " + dir.absolutePath());
			return false;
		}
		qDebug() << "[INFO]: mkdir -p " << info.absolutePath();
	}
	touch();
	file -> setFileName(info.absoluteFilePath() + cpp_name);
	setPath(file -> fileName());
	if(!file -> open(QIODevice::WriteOnly))
	{
		emit errorChanged(cpp_name, tr("Can not write data to file") + ": " + file -> fileName());
#ifdef VDEBUG
		qWarning() << "[ERROR]: Can not open -> " << file->fileName();
#endif
		return false;
	}
	else
	{
#ifdef VDEBUG
		qDebug() << "[INFO]: Ready write data -> " << file->fileName();
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
	qDebug() << "[DEBUG]: File name -> " << cpp_name;
#endif
}

void VDownloadTask::endWork(VDownloadTask::State state)
{
	setState(state);
#ifdef VDEBUG
	qDebug() << "[DEBUG]: Save end -> " << int(state) << ": " <<file->fileName();
#endif
	if(reply)
		reply->deleteLater();
	file->flush();
	file->close();
	reply = 0;
	if(file->exists())
	{
		if(state == VDownloadTask::Fail)
		{
			iCurrentReading = 0;
			iCurrentTotal = 0;
			setRead(0);
			setTotal(0);
			setPercent(0);
			SetStartBytes(0);
			file->remove();
		}
		else
			SetStartBytes(file->size());
	}
	else
	{
		SetStartBytes(0); // iStartBytes = 0;
		setRead(0);
		setTotal(0);
		setPercent(0);
	}
	emit taskStateChanged(cpp_taskId);
}

void VDownloadTask::abort()
{
	if(cpp_state == VDownloadTask::Doing)
	{
		//removeFile();
#ifdef VDEBUG
		qDebug() << "[DEBUG]: Abort";
#endif
		if(reply != 0
#ifndef _HARMATTAN
				&& reply->isRunning() //k necc???
#endif
				)
		{
			reply -> abort();
		}
	}
}

void VDownloadTask::writeData()
{
#ifdef VDEBUG_D
		qDebug() << QString("[%1]: 0x%2 0x%3").arg(__func__).arg(reinterpret_cast<intptr_t>(reply->thread()), 0, 16).arg(reinterpret_cast<intptr_t>(thread()), 0, 16);
#endif
	if(reply -> error() != QNetworkReply::NoError)
	{
		emit errorChanged(cpp_name, QString("QNetworkReply::NetworkError = %1:[%2]").arg(QString::number(reply->error())).arg(reply->errorString()));
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

void VDownloadTask::updateProgress(qint64 read, qint64 total) // current reading and total bytes
{
#ifdef VDEBUG_D
		qDebug() << QString("[%1]: %2 - %3 %4 -> 0x%5 0x%6").arg(__func__).arg(read).arg(total).arg(iStartBytes).arg(reinterpret_cast<intptr_t>(reply->thread()), 0, 16).arg(reinterpret_cast<intptr_t>(thread()), 0, 16);
#endif
	if(read == 0 && total == 0)
	{
		emit errorChanged(QString(cpp_name), tr("No download associated"));
		endWork(VDownloadTask::Fail);
		abort();
		return;
	}

	if(total > 0)
	{
		if(cpp_total == 0) // first download
		{
			setTotal(total);
			iCurrentTotal = total;
		}
		else // breakpoint
		{
			if(iCurrentTotal != total)
			{
				iCurrentTotal = total;
				//k setTotal(Verena::castSize(itotal));
			}
		}
	}
	else if(total == -1)
	{
		if(cpp_total != -1 || iCurrentTotal != -1)
		{
			iCurrentTotal = total;
			setTotal(V_UNKNOW_SIZE);
			UpdatePercent(); //k setPercent(V_UNKNOW_SIZE);
		}
	}

	if(read > 0)
	{
		iCurrentReading = read;
		qint64 cread = iStartBytes + iCurrentReading;
		setRead(cread);
		//k if(cpp_total != 0)
			UpdatePercent();
	}
}

void VDownloadTask::setTotal(const qint64 &total)
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
			qDebug() << "[WARNING]: Can not remove file -> " << file->fileName();
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

qint64 VDownloadTask::total() const
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
		qWarning() << "[WARNING]: Not exist file -> " << file->fileName();
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
		qWarning() << "[ERROR]: Not exist file -> " << file->fileName();
		return false;
	}
	if(!file -> open(QIODevice::Append))
	{
		emit errorChanged(cpp_name, tr("Can not append data to file") + ": " + file -> fileName());
#ifdef VDEBUG
		qWarning() << "[ERROR]: Can not append -> " << file->fileName();
#endif
		setState(VDownloadTask::Fail);
		return false;
	}
	else
	{
		SetStartBytes(file->size());
		setState(VDownloadTask::Ready);
#ifdef VDEBUG
		qDebug() << "[INFO]: Ready write data -> " << file->fileName();
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

void VDownloadTask::load()
{
	file -> setFileName(cpp_path);
	//k setTotal(Verena::castSize(itotal));
	if(file -> exists())
	{
		SetStartBytes(file->size());
		setRead(iStartBytes);
	}
	else
	{
		SetStartBytes(0);
		setRead(0);
		setState(VDownloadTask::Fail);
	}
	UpdatePercent();
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

void VDownloadTask::errorSLOT(QNetworkReply::NetworkError code)
{
	if(code != QNetworkReply::NoError)
	{
#ifdef VDEBUG
		qDebug() << QString("[%1]: %2 - [%3]").arg(__func__).arg(code).arg(reply->errorString());
#endif
		emit errorChanged(cpp_name, QString("QNetworkReply::NetworkError = %1:[%2]").arg(QString::number(code)).arg(reply->errorString()));
		endWork(VDownloadTask::Fail);
		abort();
	}
}

void VDownloadTask::Zero()
{
	setTotal(0);
}

int VDownloadTask::RedirectUrl()
{
	int r;

	if(!reply)
		return -2;

	r = 0;
	int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

#ifdef VDEBUG
	switch (statusCode)
	{
		case 302:
			{
				qDebug() << "302 Redirection";
				break;
			}
		case 202:
			{
				qDebug() << "202 Forbidden";
				break;
			}
		case 400:
			{
				qDebug() << "Network error (HTTP400/Bad Request)";
				break;
			}
		case 403:
			{
				qDebug() << "403 Permission denied";
				break;
			}
		case 200:
		default:
			{
				qDebug() << statusCode;
				break;
			}
	}
#endif

	if(statusCode == 302) // redirection
	{
		QUrl redirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
		if(!redirectUrl.toString().isEmpty())
		{
			reply->deleteLater();
			reply = 0;
#ifdef VDEBUG
			qDebug() << "[DEBUG]: Redirection -> "<< file -> fileName() << redirectUrl;
#endif
			Request(redirectUrl.toString()); // not setUrl
			r = 0;
		}
		else
			r = -1; // no redirection url
	}
	else
		r = (statusCode == 200 ? 0 : statusCode);

	return r;
}

qint64 VDownloadTask::CurrentReadingBytes() const
{
	return iCurrentReading;
}

qint64 VDownloadTask::CurrentTotalBytes() const
{
	return iCurrentTotal;
}

void VDownloadTask::UpdatePercent()
{
	if(cpp_total > 0)
		setPercent(cpp_read * 100 / cpp_total);
	else
		setPercent(cpp_total);
}

void VDownloadTask::SetStartBytes(qint64 i)
{
	if(iStartBytes != i)
	{
		iStartBytes = i;
	}
}

qint64 VDownloadTask::StartBytes() const
{
	return iStartBytes;
}

QNetworkReply * VDownloadTask::SetRequest(const QString &u)
{
	if(!u.isEmpty())
		setUrl(u);

	return Request(url());
}

QNetworkReply * VDownloadTask::Request(const QString &ru)
{
	QString u;
	QNetworkReply *r;
	QNetworkAccessManager *m;
	qint64 last;
	
	u = ru.isEmpty() ? url() : ru;

	if(!oManager || u.isEmpty())
		return 0;

	m = oManager->NetworkManager();
	QNetworkRequest req(u);

	Verena::SpecialRequest(&req, Verena::YoukuSpecialHeaders());
	last = castCurrentFileSize();
	if(last != 0)
		req.setRawHeader(QByteArray("Range"), QString("bytes=%1-").arg(last).toAscii());
	r = m->get(req);
#ifdef VDEBUG
	qDebug()<<"A: "<<thread()<<m->thread()<<oManager->thread()<<m->parent()<<r->thread();
#endif
	r->setParent(0);
	r->moveToThread(thread());
	setReply(r);
#ifdef VDEBUG
	qDebug()<<"A2: "<<thread()<<m->thread()<<oManager->thread()<<m->parent()<<r->thread();
#endif
	return r;
}

void VDownloadTask::SetDownloadManager(VDownloadManager *m)
{
	QThread *thread;
	oManager = m;
	if(oManager)
	{
		thread = oManager->DownloadThread();
		if(thread)
			moveToThread(thread);
	}
}
