#ifndef VERENA_DOWNLOADTASK_H
#define VERENA_DOWNLOADTASK_H

#include <QObject>
#include <QString>
#include <QNetworkReply>

class QFile;

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
		Q_PROPERTY(QString read READ read NOTIFY readChanged FINAL)
		Q_PROPERTY(QString total READ total NOTIFY totalChanged FINAL)
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
		VDownloadTask(QObject *parent = 0);
		~VDownloadTask();
		bool readySave();
		bool continueSave();
		QNetworkReply * getReply() const { return reply; }
		void endWork(State state);
		void abort();
		QString path() const;
		QString read() const { return cpp_read; }
		QString source() const;
		QString total() const;
		int percent() const {return cpp_percent; }
		QString name() const;
		QString title() const;
		State state() const;
		void setRead(const QString &read) {
			if(cpp_read != read)
			{
				cpp_read = read;
				emit readChanged();
			}
		}
		void setTotal(const QString &total);
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
		qint64 byteOfRead() const;
		qint64 byteOfTotal() const;
		void setIRead(qint64 i);
		void setITotal(qint64 i);
		void load();
		void Zero();
		qint64 CurrentReadingBytes() const;
		qint64 CurrentTotalBytes() const;

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

	private:
		QFile *file;
		QString cpp_name;
		QNetworkReply *reply;
		QString cpp_read;
		QString cpp_total;
		qint64 iread;
		qint64 itotal;
		int cpp_percent;
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

		qint64 m_currentReading;
		qint64 m_currentTotal;
};

#endif
