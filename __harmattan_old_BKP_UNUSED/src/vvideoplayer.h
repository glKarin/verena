#ifndef VERENA_VIDEOPLAYER_H
#define VERENA_VIDEOPLAYER_H

#include <QObject>

class VVideoPlayer : public QObject
{
	Q_OBJECT

	public:
		Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged FINAL)
			Q_PROPERTY(int player READ player WRITE setPlayer NOTIFY playerChanged FINAL)
			Q_PROPERTY(bool autoStart READ autoStart WRITE setAutoStart NOTIFY autoStartChanged FINAL)

	public:
			VVideoPlayer(QObject *parent = 0);
			~VVideoPlayer();
			QString url() const;
			bool autoStart() const;
			void setUrl(const QString &url);
			void setPlayer(int player);
			void setAutoStart(bool b);

			int player() const;
			Q_INVOKABLE void openGrobPlayer(const QString &url) const;
			Q_INVOKABLE void openMMVideoSuitePlayer(const QString &url);
			Q_INVOKABLE void openExternalKMPlayer(const QString &url);
			Q_INVOKABLE void load(const QString &url, const QString &source = QString(), const QString &type = QString(), int part = 0, const QString &id = QString());
			Q_INVOKABLE void addMsg(const QString &msg);

Q_SIGNALS:
			void urlChanged();
			void playerChanged();
			void autoStartChanged();
			void msgChanged(const QString &msg);

	private:
			void play();
			QString cpp_url;
			int cpp_player;
			bool cpp_autoStart;

};

#endif
