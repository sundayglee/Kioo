#ifndef MIRROR_H
#define MIRROR_H

#include <QObject>
#include <QStringList>
#include <QCoreApplication>
#include <QStringList>
#include <QString>
#include <QDir>
#include <QUrl>

class Mirror : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString link READ link WRITE setLink NOTIFY linkChanged)
    public:
        void setLink(const QString &a) {
            if (a != m_link) {
                m_link = a;
                emit linkChanged();
            }
        }

        QString link() const {
            const QStringList args = QCoreApplication::arguments();
            return QDir::toNativeSeparators(args[1]);
        }

    signals:
        void linkChanged();
    private:
        QString m_link;
};

#endif // MIRROR_H
