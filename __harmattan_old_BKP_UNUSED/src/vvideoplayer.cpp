#include "vvideoplayer.h"

#include <QProcess>
#include <QString>
#include <QStringList>
#include <QDebug>
#include <QFileInfo>
#ifdef VHAS_MAEMO_MEEGOTOUCH_INTERFACES_DEV
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#else
#define VIDEO_SUITE "/usr/bin/video-suite"
#endif

#define GROB "/usr/bin/grob"
#define KMPLAYER "/usr/bin/kmplayer"

VVideoPlayer::VVideoPlayer(QObject *parent)
	:QObject(parent),
	cpp_player(0),
	cpp_autoStart(false)
{
}

VVideoPlayer::~VVideoPlayer()
{
}

void VVideoPlayer::openGrobPlayer(const QString &url) const
{
	QStringList arg(url);
	QProcess::startDetached(QString(GROB), arg);
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
	qDebug()<<"maemo-meegotouch-interfaces -> videosuiteinterface";
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
		qDebug()<<"Auto play";
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

void VVideoPlayer::load(const QString &url, const QString &source, const QString &type, int part, const QString &id)
{
	Q_UNUSED(source);
	Q_UNUSED(type);
	Q_UNUSED(part);
	Q_UNUSED(id);
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
	if(cpp_player == 0)
		openMMVideoSuitePlayer(cpp_url);
	else if(cpp_player == 1)
		openGrobPlayer(cpp_url);
	else if(cpp_player == 2)
		openExternalKMPlayer(cpp_url);
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
