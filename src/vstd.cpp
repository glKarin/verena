#include <QUrl>
#include <QDebug>

#include "vstd.h"

namespace Verena
{
	QString GetVideoUrlSuffix(const QString &url)
	{
		int dotIndex, slashIndex;
		QString extName("");

		QUrl u(url);
		QString path = u.path();
		//qDebug() <<path;
		slashIndex = path.lastIndexOf("/");
		dotIndex = path.lastIndexOf(".");
		if(dotIndex != -1 && slashIndex < dotIndex)
			extName = path.mid(dotIndex + 1);
		//qDebug()<<extName;
		return extName;
	}
};
