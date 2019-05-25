#include "vvideoplayer.h"

#include <QDesktopServices>
#include <QString>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QUrl>
#include <QDebug>

VVideoPlayer::VVideoPlayer(QObject *parent)
	:QObject(parent),
	cpp_player(0),
	cpp_autoStart(false)
{
}

VVideoPlayer::~VVideoPlayer()
{
}

void VVideoPlayer::openPlayer(const QString &url) const
{
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
        openPlayer(cpp_url);
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
