#include <QProcess>
#include <QDesktopServices>
#include <QStringList>
#include <QDebug>
#include <QFileInfo>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QUrl>
#ifdef VHAS_MAEMO_MEEGOTOUCH_INTERFACES_DEV
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#else
#define VIDEO_SUITE "/usr/bin/video-suite"
#endif

#include "vvideoplayer.h"
#include "vut.h"

#define GROB "/usr/bin/grob"
#define KMPLAYER "/usr/bin/kmplayer"

VVideoPlayer::VVideoPlayer(QObject *parent)
	:QObject(parent),
	cpp_player(PLAYER_VIDEO_SUITE),
	cpp_autoStart(false)
{
}

VVideoPlayer::~VVideoPlayer()
{
}

#ifdef _HARMATTAN
void VVideoPlayer::openGrobPlayer(const QString &url) const
{
#if 0
	QStringList arg(url);
	QProcess::startDetached(QString(GROB), arg);
#else
	QDesktopServices::openUrl(url);
#endif
}

void VVideoPlayer::openMMVideoSuitePlayer(const QString &url)
{
	if(url.startsWith("file://"))
	{
			//qDebug()<<"File:"<<url.right(url.length() - 7);
		if(!QFileInfo(url.right(url.length() - 7)).isFile())
		{
			emit msgChanged(tr("File not found in local file system -> ") + url);
			return;
		}
	}
	QStringList arg(url);
#ifdef VHAS_MAEMO_MEEGOTOUCH_INTERFACES_DEV
	VideoSuiteInterface player;
	player.play(QStringList(arg));
#ifdef VDEBUG
	qDebug() << "[DEBUG]: maemo-meegotouch-interfaces -> videosuiteinterface";
#endif
#else
	QProcess::startDetached(QString(VIDEO_SUITE), arg);
#endif
}

void VVideoPlayer::openExternalKMPlayer(const QString &url)
{
	if(QFileInfo(KMPLAYER).isExecutable())
	{
		QStringList arg(url);
		QProcess::startDetached(QString(KMPLAYER), arg);
	}
	else
		emit msgChanged(tr("Not fount executable file -> ") + KMPLAYER);
}
#endif

void VVideoPlayer::openPlayer(const QString &url)
{
#ifdef _SYMBIAN
	QString path = QDir::tempPath();
	QDir dir(path);
	if (!dir.exists()) dir.mkpath(path);
	QString ramPath = path+"/video.ram";
	QFile file(ramPath);
	if (file.exists()) file.remove();
	if (file.open(QIODevice::ReadWrite)){
		QTextStream out(&file);
		out << url;
		file.close();
		QDesktopServices::openUrl(QUrl("file:///"+ramPath));
	}
#elif defined(_HARMATTAN)
	openMMVideoSuitePlayer(url);
#else
	qDebug() << "[INFO]: Play video -> " << url;
#endif
}

void VVideoPlayer::setUrl(const QString &url)
{
	if(cpp_url != url)
	{
		cpp_url = url;
		emit urlChanged();
	}
	if(cpp_autoStart)
	{
		play();
#ifdef VDEBUG
		qDebug() << "[DEBUG]: Auto play";
#endif
	}
}

void VVideoPlayer::setPlayer(int player)
{
	if(cpp_player != player)
	{
		cpp_player = player;
		emit playerChanged();
	}
}

void VVideoPlayer::setAutoStart(bool b)
{
	if(cpp_autoStart != b)
	{
		cpp_autoStart = b;
		emit autoStartChanged();
	}
}

void VVideoPlayer::load(const QString &url, const QString &source, const QString &type, int part, const QString &id, const QVariant &data)
{
	Q_UNUSED(source);
	Q_UNUSED(type);
	Q_UNUSED(part);
	Q_UNUSED(id);
	Q_UNUSED(data);
	
	setUrl(url);
	if(!cpp_autoStart)
		play();
}

void VVideoPlayer::addMsg(const QString &msg)
{
	emit msgChanged(msg);
}

void VVideoPlayer::play()
{
#ifdef _HARMATTAN
	if(cpp_player == PLAYER_VIDEO_SUITE)
		openPlayer(cpp_url); // default
	else if(cpp_player == PLAYER_GROB_BROWSER)
		openGrobPlayer(cpp_url);
	else if(cpp_player == PLAYER_KMPLAYER)
		openExternalKMPlayer(cpp_url);
#else
		openPlayer(cpp_url); // default
#endif
}

QString VVideoPlayer::url() const
{
	return cpp_url;
}

bool VVideoPlayer::autoStart() const
{
	return cpp_autoStart;
}

int VVideoPlayer::player() const
{
	return cpp_player;
}

