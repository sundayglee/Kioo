#ifndef IPCINTERFACE_H
#define IPCINTERFACE_H

#include <QObject>
#include <QtNetwork>
#include <QDebug>
#include <QByteArray>
#include <QString>
#include <QStringList>

class IPCInterface : public QObject
{
    Q_OBJECT
public:
    explicit IPCInterface(QObject *parent = nullptr);
    ~IPCInterface();

    QTcpSocket *tcpClient = nullptr;
    QTcpServer *tcpServer = nullptr;
    QTcpSocket *tcpServerConnection = nullptr;

    QString ipcPayload = "NoData";
    QStringList ipcPayLoadList = {};
    bool dataSent = false;

    void clientConnect();

signals:
    void linkReceived(QString data);

public slots:
    void newConnection();
    void serverReadyRead();
    void clientReadyWrite();
};

#endif // IPCINTERFACE_H
