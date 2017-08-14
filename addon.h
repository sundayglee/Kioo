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
#include <QBytearray>
#include <zlib.h>
#include <QQuickItem>

#include <iostream>
#include <fstream>

typedef unsigned __int64 uint64_t;
#define GZIP_WINDOWS_BIT 15 + 16
#define GZIP_CHUNK_SIZE 32 * 1024
using namespace std;

class AddOn : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sourceUrl READ sourceUrl WRITE setSourceUrl NOTIFY sourceUrlChanged)
    Q_PROPERTY(QString subFile READ subFile WRITE setSubFile NOTIFY subFileChanged)

    QFile *m_file;
    bool m_isReady = true;

public:
 //   explicit AddOn(QObject *parent = nullptr);
    virtual ~AddOn() { delete m_file; }
    void downloadSub(const QString &url, const QString &fileName, const QString &filePath);

    void setSubFile(QString ufile) {
        qDebug() << "Full path is: " +ufile;
        QStringList list = ufile.split("|");
        downloadSub(list[0],list[1],list[2]);
    }

    void setSourceUrl(const QString &a) {
        QString ab = a;
        ab.replace("file:","");       
        if(ab.startsWith("///")) {
            ab.replace("///","");
        }
        qDebug() << "The path is: "+ab;
        QByteArray ba = ab.toLatin1();
        const char *ch = ba.data();

        ifstream f;
        uint64_t myhash;

        f.open(ch, ios::in|ios::binary|ios::ate);
        if (!f.is_open()) {
           cerr << "Error opening file" << endl;
        }

        myhash = compute_hash(f);
        f.close();

        theHash = QString::number( myhash, 16 );

        emit sourceUrlChanged();
    }
    QString sourceUrl() const {
        return theHash;
    }
    QString subFile() const {
        return theSubFile;
    }

    static bool gzipDecompress(QByteArray input, QByteArray &output);
    static bool gzipCompress(QByteArray input, QByteArray &output, int level);

private:
    QString theHash = "";
    QString theSubFile = "";

    int MAX(int x, int y)
    {
       if((x) > (y))
           return x;
       else
           return y;
    }
    uint64_t compute_hash(ifstream& f)
    {
       uint64_t hash, fsize;

       f.seekg(0, ios::end);
       fsize = f.tellg();
       f.seekg(0, ios::beg);

       hash = fsize;
       for(uint64_t tmp = 0, i = 0; i < 65536/sizeof(tmp) && f.read((char*)&tmp, sizeof(tmp)); i++, hash += tmp);
       f.seekg(MAX(0, (uint64_t)fsize - 65536), ios::beg);
       for(uint64_t tmp = 0, i = 0; i < 65536/sizeof(tmp) && f.read((char*)&tmp, sizeof(tmp)); i++, hash += tmp);
       return hash;
    }

signals:
    void sourceUrlChanged();
    void subFileChanged();

public slots:
    void onSubComplete(QNetworkReply *reply);
};

#endif // ADDON_H
