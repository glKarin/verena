#include <QNetworkRequest>
#include <QNetworkReply>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QByteArray>
#include <QMutexLocker>
#include <QMutex>

#include "vdownloadmanager.h"
#include "vnetworkmanager.h"
#include "vdownloadtask.h"
#include "vstd.h"
#include "vut.h"
#include "vverenadatabase.h"

#define DATABASE_TABLE_NAME_1 "DownloadTask"
#define DBNAME "verena.downloadmanager"
#define USERNAME "verena"
#define PASSWORD "loginme"
#define TASKID "TaskId"
#define PATH "Path"
#define STATE "State"
#define SIZE "Size"
#define URL "Url"
#define NAME "Name"

inline QString GetVideoUrl(const QString &url)
{
	static const int VDebug = VUT::Instance()->VDebug();
	if(VDebug)
		return VUT::Instance()->XXX(url);
	else
		return url;
}

	VDownloadManager::VDownloadManager(QObject *parent)
:QObject(parent)
{
	manager = new VNetworkAccessManager(this);
	vdb = new VVerenaDatabase(DBNAME
#ifdef _HARMATTAN
			, USERNAME, PASSWORD
#endif
			);
	mutex = new QMutex(QMutex::Recursive);
	vdb -> openDatabase();
	QStringList list;
	list<<QString(TASKID) + " TEXT UNIQUE NOT NULL"
		<<QString(STATE) + " INTEGER"
		<<QString(PATH) + " TEXT"
		<<QString(NAME) + " TEXT"
		<<QString(URL) + " TEXT"
		<<QString(SIZE) + " INTEGER";
	vdb -> addTable(DATABASE_TABLE_NAME_1, list);
	loadHistory();
}

VDownloadManager::~VDownloadManager()
{
	removeAllTask(7);
	vdb -> closeDatabase();
	delete mutex;
	delete vdb;
}

void VDownloadManager::storeToDatabase(const VDownloadTask *task)
{
	QMutexLocker lock(mutex);
	QVariantList list;
	list<<QVariant(task -> taskId())
		<<QVariant(static_cast<int>(task -> state()))
		<<QVariant(task -> path())
		<<QVariant(task -> title())
		<<QVariant(task -> url())
		<<QVariant(task -> byteOfTotal());
	vdb -> addElementToTable(DATABASE_TABLE_NAME_1, list);
}

void VDownloadManager::addTask(const QString &url, const QString &source, const QString &name, const QString &type, int part, const QString &vid)
{
	QMutexLocker lock(mutex);
	QString s = QString("%1_%2_%3_%4").arg(source).arg(vid).arg(type).arg(part);
	VDownloadTask *task = takeTask(VDownloadManager::Fail, s);
	if(task)
	{
		emit taskListFailChanged();
		task -> setUrl(url);
		if(task -> state() == VDownloadTask::Pause)
		{
			if(task -> continueSave()){
				QNetworkRequest req;
				req.setUrl(QUrl(task -> url()));
				qint64 last = task -> castCurrentFileSize();
				if(last != 0)
				{
					req.setRawHeader(QByteArray("Range"), QString("bytes=%1-").arg(last).toAscii());
				}
#ifdef VDEBUG
				qDebug() << "[INFO]: Ready to redownload -> " << last;
#endif
				QNetworkReply *reply = manager -> get(req);
				task -> setReply(reply);
				connect(task, SIGNAL(taskStateChanged(const QString &)), this, SLOT(doFinished(const QString &)));
				connect(task, SIGNAL(errorChanged(const QString &, const QString &)), this, SLOT(fileSaverErrorNotify(const QString &, const QString &)));
				taskList[VDownloadManager::Downloading].push_back(dynamic_cast<QObject *>(task));
				emit taskListDownloadingChanged();
				emit fileDownloadContinue(task -> name());
			}
			else
			{
				task -> setState(VDownloadTask::Fail);
				taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
				emit taskListFailChanged();
			}
			storeToDatabase(task);
			return;
		}
		else
		{
			vdb -> removeElementFromTable(DATABASE_TABLE_NAME_1, TASKID, "'" + task -> taskId() + "'");
			task -> removeFile();
			emit fileDownloadRestarted(task -> name());
			delete task;
		}
	}
	//qDebug()<<s;
	VDownloadTask *task2 = new VDownloadTask;
	task2 -> setVid(vid);
	task2 -> setStreamtype(type);
	task2 -> setSource(source);
	task2 -> setPart(part);
	task2 -> setTitle(name);
	task2 -> setTaskId(s);
	task2 -> setUrl(url);
	//task -> setExtName(url.mid(url.lastIndexOf(".") + 1,)); //2015
	task2->setExtName(Verena::GetVideoUrlSuffix(url));

	if(task2 -> readySave())
	{
		QNetworkReply *reply = manager -> postRequest(GetVideoUrl(url));
		task2 -> setReply(reply);
		connect(task2, SIGNAL(taskStateChanged(const QString &)), this, SLOT(doFinished(const QString &)));
		connect(task2, SIGNAL(errorChanged(const QString &, const QString &)), this, SLOT(fileSaverErrorNotify(const QString &, const QString &)));
		taskList[VDownloadManager::Downloading].push_back(dynamic_cast<QObject *>(task2));
#ifdef VDEBUG
		qDebug() << "[INFO]: Download file name -> " << task2->name();
#endif
		emit taskListDownloadingChanged();
		emit fileDownloadStarted(task2 -> name());
	}
	else
	{
		task2 -> setState(VDownloadTask::Fail);
		taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task2));
#ifdef VDEBUG
		qWarning() << "[ERROR]: Not create local file name -> " << task2->name();
#endif
		emit taskListFailChanged();
		emit fileDownloadFailed(task2 -> name());
	}
	storeToDatabase(task2);
}

void VDownloadManager::doFinished(const QString &tid)
{
	QMutexLocker lock(mutex);
	VDownloadTask *task = takeTask(VDownloadManager::Downloading, tid);
	if(task)
	{
		emit taskListDownloadingChanged();
		switch(task -> state())
		{
			case VDownloadTask::Done:
				taskList[VDownloadManager::Finished].push_back(dynamic_cast<QObject *>(task));
				emit taskListFinishedChanged();
				emit fileDownloadFinished(task -> name());
				break;
			case VDownloadTask::Fail:
				taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
				emit taskListFailChanged();
				emit fileDownloadFailed(task -> name());
				break;
			case VDownloadTask::Pause:
				taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
				emit taskListFailChanged();
				emit fileDownloadPaused(task -> name());
				break;
			default:
				break;
		}
		storeToDatabase(task);
	}
}

void VDownloadManager::removeAllTask(int mask)
{
	if(mask & 1)
	{
		while(!taskList[VDownloadManager::Downloading].isEmpty())
		{
			VDownloadTask *task = dynamic_cast<VDownloadTask *>(taskList[VDownloadManager::Downloading].takeAt(0));
			task -> endWork(VDownloadTask::Pause);
			task -> abort();
			storeToDatabase(task);
			delete task;
		}
#ifdef VDEBUG
		qDebug() << "[INFO]: Downloading list -> delete";
#endif
		emit taskListDownloadingChanged();
	}
	if(mask & 2)
	{
		while(!taskList[VDownloadManager::Finished].isEmpty())
			delete taskList[VDownloadManager::Finished].takeAt(0);
		emit taskListFinishedChanged();
#ifdef VDEBUG
		qDebug() << "[INFO]: Finished list -> delete";
#endif
	}
	if(mask & 4)
	{
		while(!taskList[VDownloadManager::Fail].isEmpty())
			delete taskList[VDownloadManager::Fail].takeAt(0);
		emit taskListFailChanged();
#ifdef VDEBUG
		qDebug() << "[INFO]: Fail list -> delete";
#endif
	}
}

void VDownloadManager::fileSaverErrorNotify(const QString &name, const QString &error)
{
	emit infoChanged(tr("Download file fail") + ": " + name + ". " + tr("Error") + ": " + error);
}

void VDownloadManager::deleteOneTask(VDownloadManager::TaskListType type, const QString &taskId, bool full)
{
	QMutexLocker lock(mutex);
	VDownloadTask *task = takeTask(type, taskId);
	if(!task)
		return;
	switch(type)
	{
		case VDownloadManager::Downloading:
			emit taskListDownloadingChanged();
			emit infoChanged(tr("Remove downloading task") + ": " + task -> name());
			task -> endWork(VDownloadTask::Pause);
			task -> abort();
			break;
		case VDownloadManager::Finished:
			emit taskListFinishedChanged();
			break;
		case VDownloadManager::Fail:
			emit taskListFailChanged();
			break;
		default:
			break;
	}
	vdb -> removeElementFromTable(DATABASE_TABLE_NAME_1, TASKID, "'" + task -> taskId() + "'");
	if(full)
		task -> removeFile();
	delete task;
}

QList<QObject *> VDownloadManager::taskListFinished() const
{
	return taskList[Finished];
}

QList<QObject *> VDownloadManager::taskListFail() const
{
	return taskList[Fail];
}

QList<QObject *> VDownloadManager::taskListDownloading() const
{
	return taskList[Downloading];
}

void VDownloadManager::loadHistory()
{
	QVariantList list = vdb -> getAllDataFromTable(DATABASE_TABLE_NAME_1);
	for(QVariantList::iterator itor = list.begin();
			itor != list.end();
			++itor)
	{
		QMap<QString, QVariant> map = itor -> toMap();
		VDownloadTask *task = new VDownloadTask;
		QString s = map[TASKID].toString();
		QStringList sl = s.split("_", QString::SkipEmptyParts);
		task -> setTaskId(s);
		task -> setSource(sl[0]);
		task -> setVid(sl[1]);
		task -> setStreamtype(sl[2]);
		task -> setPart(sl[3].toInt());
		task -> setPath(map[PATH].toString());
		task -> setName(map[PATH].toString().mid(map[PATH].toString().lastIndexOf("/") + 1));
		task -> setUrl(map[URL].toString());
		// 2015 task -> setExtName(task -> url().mid(task -> url().lastIndexOf(".") + 1));
		task->setExtName(Verena::GetVideoUrlSuffix(task->url()));

		task -> setTitle(map[NAME].toString());
		task -> setITotal(map[SIZE].toLongLong());
		task -> setState(static_cast<VDownloadTask::State>(map[STATE].toInt()));
		if(map[STATE].toInt() == VDownloadTask::Done)
		{
			taskList[VDownloadManager::Finished].push_back(dynamic_cast<QObject *>(task));
			emit taskListDownloadingChanged();
		}
		else
		{
			taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
			emit taskListFailChanged();
		}
		task -> load();
	}
}

bool VDownloadManager::checkTaskList(const QString &source, const QString &id, const QString &type, int part)
{
	QMutexLocker lock(mutex);
	QString s = QString("%1_%2_%3_%4").arg(source).arg(id).arg(type).arg(part);
	for(int i = VDownloadManager::Downloading; i < VDownloadManager::Fail; i++)
	{
		for(QList<QObject *>::const_iterator ci = taskList[i].constBegin();
				ci != taskList[i].constEnd();
				++ci)
		{
			const VDownloadTask *task = dynamic_cast<const VDownloadTask *>(*ci);
			if(task && task -> taskId() == s)
				return true;
		}
	}
	return false;
}

void VDownloadManager::pauseTask(const QString &taskId)
{
	QMutexLocker lock(mutex);
	VDownloadTask *task = takeTask(VDownloadManager::Downloading, taskId);
	if(!task)
		return;
	emit taskListDownloadingChanged();
	task -> endWork(VDownloadTask::Pause);
	task -> abort();
	emit fileDownloadPaused(task -> name());
	taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
	emit taskListFailChanged();
	storeToDatabase(task);
}

VDownloadTask * VDownloadManager::takeTask(VDownloadManager::TaskListType type, const QString &taskId)
{
	for(int i = 0; i < taskList[type].size(); i++)
	{
		VDownloadTask *t = dynamic_cast<VDownloadTask *>(taskList[type][i]);
		if(t && t -> taskId() == taskId)
		{
			VDownloadTask *task = dynamic_cast<VDownloadTask *>(taskList[type].takeAt(i));
			return task;
		}
	}
	return 0;
}

void VDownloadManager::reloadTask(const QString &url, const QString &taskId)
{
	QMutexLocker lock(mutex);
	VDownloadTask *task = takeTask(VDownloadManager::Finished, taskId);
	if(!task)
		return;
	emit taskListFinishedChanged();
	task -> removeFile();
	task->Zero();
	task -> setUrl(url);
	task -> setState(VDownloadTask::Ready);
	if(task -> readySave())
	{
		QNetworkReply *reply = manager -> postRequest(url);
		task -> setReply(reply);
		connect(task, SIGNAL(taskStateChanged(const QString &)), this, SLOT(doFinished(const QString &)));
		connect(task, SIGNAL(errorChanged(const QString &, const QString &)), this, SLOT(fileSaverErrorNotify(const QString &, const QString &)));
		taskList[VDownloadManager::Downloading].push_back(dynamic_cast<QObject *>(task));
#ifdef VDEBUG
		qDebug() << "[INFO]: Redownload file name -> " << task->name();
#endif
		emit taskListDownloadingChanged();
		emit fileDownloadStarted(task -> name());
	}
	else
	{
		task -> setState(VDownloadTask::Fail);
		taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
#ifdef VDEBUG
		qWarning() << "[ERROR]: Not create local file name -> " << task->name();
#endif
		emit taskListFailChanged();
		emit fileDownloadFailed(task -> name());
	}
	storeToDatabase(task);
}

void VDownloadManager::RefreshHistory(const QString &path) // QFileSystemWatcher::directoryChanged(const QString &)
{
	Q_UNUSED(path);

	VDownloadTask *task;

	for(int i = VDownloadManager::Finished; i < VDownloadManager::Total; i++)
	{
		QList<QObject *> &list = taskList[i];
		for(QList<QObject *>::iterator itor = list.begin();
				itor != list.end();
				++itor)
		{
			if(!(*itor))
				continue;
			task = static_cast<VDownloadTask *>(*itor);
			task->load();
		}
	}
}

// UNUSED
void VDownloadManager::continueTask(const QString &taskId)
{
	QMutexLocker lock(mutex);
	VDownloadTask *task = takeTask(VDownloadManager::Fail, taskId);
	if(!task)
		return;
	emit taskListFailChanged();
	if(task -> state() == VDownloadTask::Pause)
	{
		if(task -> continueSave())
		{
			QNetworkRequest req;
			req.setUrl(QUrl(task -> url()));
			qint64 last = task -> castCurrentFileSize();
			if(last != 0)
			{
				req.setRawHeader(QByteArray("Range"), QString("bytes=%1-").arg(last).toAscii());
			}
			QNetworkReply *reply = manager -> get(req);
			task -> setReply(reply);
			connect(task, SIGNAL(taskStateChanged(const QString &)), this, SLOT(doFinished(const QString &)));
			connect(task, SIGNAL(errorChanged(const QString &, const QString &)), this, SLOT(fileSaverErrorNotify(const QString &, const QString &)));
			emit fileDownloadRestarted(task -> name());
			taskList[VDownloadManager::Downloading].push_back(dynamic_cast<QObject *>(task));
			emit taskListDownloadingChanged();
		}
		else
		{
			task -> setState(VDownloadTask::Fail);
			taskList[VDownloadManager::Fail].push_back(dynamic_cast<QObject *>(task));
			emit taskListFailChanged();
		}
		storeToDatabase(task);
	}
}

VDownloadManager * VDownloadManager::Instance()
{
	static VDownloadManager Manager;
	return &Manager;
}
