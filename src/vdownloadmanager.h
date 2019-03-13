#ifndef VERENA_DOWNLOADMANAGER_H
#define VERENA_DOWNLOADMANAGER_H

#include <QObject>
#include <QList>

class VNetworkAccessManager;
class QNetworkReply;
class VDownloadTask;
class VVerenaDatabase;
class QMutex;

class VDownloadManager : public QObject
{
	Q_OBJECT
		Q_PROPERTY(QList<QObject *> taskListDownloading READ taskListDownloading NOTIFY taskListDownloadingChanged FINAL)
		Q_PROPERTY(QList<QObject *> taskListFinished READ taskListFinished NOTIFY taskListFinishedChanged FINAL)
		Q_PROPERTY(QList<QObject *> taskListFail READ taskListFail NOTIFY taskListFailChanged FINAL)
		Q_ENUMS(TaskListType)

	public:
		enum TaskListType
		{
			Downloading,
			Finished,
			Fail,
			Total
		};

	public:
		~VDownloadManager();
		QList<QObject *> taskListDownloading() const;
		QList<QObject *> taskListFinished() const;
		QList<QObject *> taskListFail() const;
		Q_INVOKABLE void addTask(const QString &url, const QString &source, const QString &name, const QString &type, int part, const QString &id);
		Q_INVOKABLE void removeAllTask(int mask);
		Q_INVOKABLE void deleteOneTask(TaskListType type, const QString &taskId, bool full = false);
		Q_INVOKABLE bool checkTaskList(const QString &source, const QString &id, const QString &type, int part);
		// UNUSED
		Q_INVOKABLE void continueTask(const QString &taskId);
		Q_INVOKABLE void pauseTask(const QString &taskId);
		Q_INVOKABLE void reloadTask(const QString &url, const QString &taskId);
		static VDownloadManager * Instance();

		public Q_SLOTS:
			void RefreshHistory(const QString &path = QString());

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
		VDownloadManager(QObject *parent = 0);
		Q_DISABLE_COPY(VDownloadManager)
		void loadHistory();
		void storeToDatabase(const VDownloadTask *task);

		VDownloadTask * takeTask(TaskListType type, const QString &taskId);

	private:
		VNetworkAccessManager *manager;
		QList<QObject *> taskList[Total];
		VVerenaDatabase *vdb;
		QMutex *mutex;

}; 

#endif
