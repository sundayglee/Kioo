#ifndef ADDON_H
#define ADDON_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>
#include <QFile>
#include <QByteArray>
//#include <C:/Qt/zlib-1.2.11/zlib.h> //Zlib for MSCV 2017 64 bit
#include <zlib.h>
#include <QQuickItem>

#include <iostream>
#include <fstream>

#define GZIP_WINDOWS_BIT 15 + 16
#define GZIP_CHUNK_SIZE 32 * 1024
using namespace std;

class AddOn : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sourceUrl READ sourceUrl WRITE setSourceUrl NOTIFY sourceUrlChanged)
    Q_PROPERTY(QString subFile READ subFile WRITE setSubFile NOTIFY subFileChanged)

    QFile *m_file = nullptr;
    bool m_isReady = true;

public:
    //   explicit AddOn(QObject *parent = nullptr);
    virtual ~AddOn() { delete m_file; }
    void downloadSub(const QString &url, const QString &fileName, const QString &filePath);

    void setSubFile(QString ufile);

    void setSourceUrl(const QString &a);
    QString sourceUrl() const;
    QString subFile() const;

    static bool gzipDecompress(QByteArray input, QByteArray &output);
    static bool gzipCompress(QByteArray input, QByteArray &output, int level);

private:
    QString theHash = "";
    QString theSubFile = "";

    int MAX(int x, int y);
    uint64_t compute_hash(ifstream& f);

signals:
    void sourceUrlChanged();
    void subFileChanged();

public slots:
    void onSubComplete(QNetworkReply *reply);
    void onSslError(QNetworkReply *reply, const QList<QSslError> &errors);
};

#endif // ADDON_H
