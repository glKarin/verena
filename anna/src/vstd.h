#ifndef VERENA_STD_H
#define VERENA_STD_H

#include <QDir>
#include <QFileInfo>

#define APPLICATION_NAME "verena"
#define APPLICATION_VERSION "0.7.9jinx1"
#define APPLICATION_DEVELOPER "Karin"
#define APPLICATION_STATE "devel"
#define APPLICATION_MAIL "beyondk2000@gmail.com"
#define APPLICATION_HOME_DIRECTORY "/.verena/"

#define K_SIZE 1024
#define M_SIZE 1048576

const QString DefaultDownloadPath = QFileInfo("E:/").exists() ? QString("E:/") + APPLICATION_NAME + "/" : QDir::homePath() + "/";

namespace Vstd
{
	inline QString castSize(qint64 i)
	{
		if(i >= 0 && i < K_SIZE)
			return QString::number(i) + "B";
		else if(i >= K_SIZE && i < M_SIZE)
			return QString("%1K").arg(double(i) / double(K_SIZE), 0, 'f', 1);
		else //if(i > M_SIZE)
			return QString("%1M").arg(double(i) / double(M_SIZE), 0, 'f', 1);
	}
};

#endif
