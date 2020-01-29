/************************************************************************************************
    Kioo Media Player: A Player With Clear Crystal Sound, Extra Sharp Video, with a Beautiful Design.
    Copyright (C) 2017 - 2020 Kioo Media Player <support@kiooplayer.com>.
    Homepage: https://www.kiooplayer.com
    Developer: Godfrey E Laswai <sundayglee@gmail.com>
    All rights reserved.

    Use of this source code is governed by a BSD-3-Clause license that can be
    found in the BSD-LICENSE file or see it here <https://opensource.org/licenses/BSD-3-Clause>.
*************************************************************************************************/

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
