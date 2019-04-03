#ifndef VERENA_DOWNLOADTASK_H
#define VERENA_DOWNLOADTASK_H

#include <QObject>
#include <QString>
#include <QNetworkReply>

class QFile;
class VDownloadManager;

class VDownloadTask : public QObject
{
	Q_OBJECT

	public:
		enum State{
			Ready,
			Fail,
			Doing,
			Pause,
			Done
		};
		Q_PROPERTY(QString name READ name NOTIFY nameChanged() FINAL)
		Q_PROPERTY(QString title READ title NOTIFY titleChanged() FINAL)
		Q_PROPERTY(QString path READ path NOTIFY pathChanged FINAL)
		Q_PROPERTY(qint64 read READ read NOTIFY readChanged FINAL)
		Q_PROPERTY(qint64 total READ total NOTIFY totalChanged FINAL)
		Q_PROPERTY(int percent  READ percent NOTIFY percentChanged FINAL)
		Q_ENUMS(State)
		Q_PROPERTY(State state READ state NOTIFY stateChanged FINAL)

		Q_PROPERTY(int part READ part NOTIFY partChanged FINAL)
		Q_PROPERTY(QString vid READ vid NOTIFY vidChanged FINAL)
		Q_PROPERTY(QString streamtype READ streamtype NOTIFY streamtypeChanged FINAL)
		Q_PROPERTY(QString taskId READ taskId NOTIFY taskIdChanged FINAL)
		Q_PROPERTY(QString url READ url NOTIFY urlChanged FINAL)
		Q_PROPERTY(QString source READ source NOTIFY sourceChanged FINAL)
		
	public:
		VDownloadTask(VDownloadManager *m = 0, QObject *parent = 0);
		~VDownloadTask();
		bool readySave();
		bool continueSave();
		QNetworkReply * getReply() const { return reply; }
		void endWork(State state);
		void abort();
		QString path() const;
		qint64 read() const { return cpp_read; }
		QString source() const;
		qint64 total() const;
		int percent() const {return cpp_percent; }
		QString name() const;
		QString title() const;
		State state() const;
		void setRead(const qint64 &read) {
			if(cpp_read != read)
			{
				cpp_read = read;
				emit readChanged();
			}
		}
		void setTotal(const qint64 &total);
		void setState(State s);
		void setSource(const QString &s);
		void setPercent(int i) {
			if(cpp_percent != i)
			{
				cpp_percent = i;
				emit percentChanged();
			}
		}
		void setExtName(const QString &ext);
		void setName(const QString &s);
		void setTitle(const QString &s);
		void setPath(const QString &s);
		void setReply(QNetworkReply *r);
		bool removeFile();
		qint64 castCurrentFileSize() const;
		void load();

		void Zero();
		qint64 CurrentReadingBytes() const;
		qint64 CurrentTotalBytes() const;
		qint64 StartBytes() const;
		QNetworkReply * Request(const QString &url = QString());
		QNetworkReply * SetRequest(const QString &url);
		void SetDownloadManager(VDownloadManager *m = 0);

		void setVid(const QString &vid);
		void setStreamtype(const QString &st);
		void setTaskId(const QString &id);
		void setPart(int part);
		void setUrl(const QString &url);
		QString url() const;
		QString vid() const;
		QString taskId() const;
		QString streamtype() const;
		int part() const;

Q_SIGNALS:
		void errorChanged(const QString &name, const QString &error);
		void readChanged();
		void totalChanged();
		void percentChanged();
		void stateChanged();
		void nameChanged();
		void pathChanged();
		void titleChanged();
		void urlChanged();

		void vidChanged();
		void partChanged();
		void taskIdChanged();
		void streamtypeChanged();
		void sourceChanged();

		void taskStateChanged(const QString &tid);

		private slots:
			void doFinished();
		void writeData();
		void updateProgress(qint64 read, qint64 total);
		void errorSLOT(QNetworkReply::NetworkError code);

	private:
		Q_DISABLE_COPY(VDownloadTask)
		void init();
		void touch();
		int RedirectUrl();
		void SetStartBytes(qint64 i = 0);
		void UpdatePercent();

	private:
		QFile *file;
		QString cpp_name;
		QNetworkReply *reply;
		qint64 cpp_read;
		qint64 cpp_total;
		qint64 iStartBytes;
		int cpp_percent;
		qint64 iCurrentReading;
		qint64 iCurrentTotal;

		QString cpp_url;
		State cpp_state;
		QString cpp_extName;
		QString cpp_path;
		QString cpp_title;

		QString cpp_vid;
		QString cpp_streamtype;
		int cpp_part;
		QString cpp_taskId;
		QString cpp_source;

		VDownloadManager *oManager;

		friend class VDownloadManager;
};

#endif
