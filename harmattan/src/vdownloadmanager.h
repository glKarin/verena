#ifndef VERENA_DOWNLOADMANAGER_H
#define VERENA_DOWNLOADMANAGER_H

#include <QObject>
#include <QList>

class VNetworkAccessManager;
class QNetworkReply;
class VDownloadTask;
class VVerenaDatabase;
// 2017
class QMutex;

class VDownloadManager : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QList<QObject *> taskListDownloading READ taskListDownloading NOTIFY taskListDownloadingChanged FINAL)
		Q_PROPERTY(QList<QObject *> taskListFinished READ taskListFinished NOTIFY taskListFinishedChanged FINAL)
		Q_PROPERTY(QList<QObject *> taskListFail READ taskListFail NOTIFY taskListFailChanged FINAL)
		// 2017
		Q_ENUMS(TaskListType)

	public:
		// 2017
		enum TaskListType
		{
			Downloading,
			Finished,
			Fail,
			Total
		};

	public:
		VDownloadManager(QObject *parent = 0);
		~VDownloadManager();
		QList<QObject *> taskListDownloading() const;
		QList<QObject *> taskListFinished() const;
		QList<QObject *> taskListFail() const;
		Q_INVOKABLE void addTask(const QString &url, const QString &source, const QString &name, const QString &type, int part, const QString &id);
		Q_INVOKABLE void removeAllTask(int mask);
		// 2017
		Q_INVOKABLE void deleteOneTask(TaskListType type, const QString &taskId, bool full = false);
		Q_INVOKABLE bool checkTaskList(const QString &source, const QString &id, const QString &type, int part);
		// UNUSED 2017
		Q_INVOKABLE void continueTask(const QString &taskId);
		Q_INVOKABLE void pauseTask(const QString &taskId);
		// 2017
		Q_INVOKABLE void reloadTask(const QString &url, const QString &taskId);

Q_SIGNALS:
		void taskListDownloadingChanged();
		void taskListFinishedChanged();
		void taskListFailChanged();
		void infoChanged(const QString &info);
		void fileDownloadFinished(const QString &name);
		void fileDownloadFailed(const QString &name);
		void fileDownloadContinue(const QString &name);
		void fileDownloadStarted(const QString &name);
		void fileDownloadRestarted(const QString &name);
		void fileDownloadPaused(const QString &name);

		private slots:
			void doFinished(const QString &tid);
		void fileSaverErrorNotify(const QString &name, const QString &error);

	private:
		VDownloadManager(const VDownloadManager &manager);
		VDownloadManager & operator=(const VDownloadManager &manager);
		void loadHistory();
		void storeToDatabase(const VDownloadTask *task);

		// 2017
		VDownloadTask * takeTask(TaskListType type, const QString &taskId);

		VNetworkAccessManager *manager;
		QList<QObject *> taskList[Total];
		VVerenaDatabase *vdb;
		// 2017
		QMutex *mutex;

}; 

#endif
