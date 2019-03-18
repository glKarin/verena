#ifndef VERENA_STD_H
#define VERENA_STD_H

#include <QDir>
#include <QMap>
#include <QHash>

#define APPLICATION_FULLNAME "Verena"
#define APPLICATION_RELEASE "20150119"
#define APPLICATION_CODE "FarAwayFromHome"

#ifdef _HARMATTAN
#define APPLICATION_PLATFORM "MeeGo Harmattan"
#else
#define APPLICATION_PLATFORM "Symbian"
#endif

#ifdef VDEBUG
#define APPLICATION_DBG 1
#else
#define APPLICATION_DBG 0
#endif

#define APPLICATION_GITHUB "https://github.com/glKarin/verena"
#define APPLICATION_OPENREPOS_DL "https://openrepos.net/content/karinzhao/verena"
#define APPLICATION_PANBAIDU_DL "https://pan.baidu.com/s/1pJyu0Qn"
#define APPLICATION_TMO "http://talk.maemo.org/member.php?u=70254"

#define APPLICATION_NAME "verena"
#define APPLICATION_VERSION "0.9.0harmattan2"
#define APPLICATION_DEVELOPER "Karin"
#define APPLICATION_STATE "devel"
#define APPLICATION_MAIL "beyondk2000@gmail.com"

#define APPLICATION_HOME_DIRECTORY "/.verena/"

#define K_SIZE 1024
#define M_SIZE 1048576
#define G_SIZE 1073741824

#define VERENA_QML_MAJOR_VERSION 1
#define VERENA_QML_MINOR_VERSION 5

#ifdef _HARMATTAN
const QString DefaultDownloadPath(QDir::homePath() + "/MyDocs/" + APPLICATION_NAME + "/");
#else
#include <QFileInfo>
const QString DefaultDownloadPath = QFileInfo("E:/").exists() ? QString("E:/") + APPLICATION_NAME + "/" : QDir::homePath() + "/";
#endif

namespace Verena
{
	inline QString castSize(qint64 i)
	{
		if(i >= 0 && i < K_SIZE)
			return QString::number(i) + "B";
		else if(i >= K_SIZE && i < M_SIZE)
			return QString("%1K").arg(double(qRound((double)i * 100 / K_SIZE)) / 100);
		else if(i >= M_SIZE && i < G_SIZE)
			return QString("%1M").arg(double(qRound((double)i * 100 / M_SIZE)) / 100);
		else
			return QString("%1G").arg(double(qRound((double)i * 100 / G_SIZE)) / 100);
	}

	template <class T, class U> inline QMap<T, U> Map__operator_vv(QMap<T, U> &m, const T &t, const U &u)
	{
		m.insert(t, u);
		return m;
	}

	template <class T, class U> inline QHash<T, U> Map__operator_vv(QHash<T, U> &m, const T &t, const U &u)
	{
		m.insert(t, u);
		return m;
	}

	QString GetVideoUrlSuffix(const QString &url);
};

#endif
