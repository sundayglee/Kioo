#include "ipcinterface.h"

IPCInterface::IPCInterface(QObject *parent) : QObject(parent)
{
    this->tcpServer = new QTcpServer();
    connect(tcpServer,SIGNAL(newConnection()),this,SLOT(newConnection()));
    if(!tcpServer->listen(QHostAddress::LocalHost,9898)) {
       // qDebug() << "Failed to listen to local port";
    }
}

IPCInterface::~IPCInterface()
{
    delete tcpClient;
    delete tcpServer;
    delete tcpServerConnection;
}

void IPCInterface::clientConnect()
{
   // qDebug() << "Connecting to server";
    this->tcpClient = new QTcpSocket();
    connect(tcpClient,SIGNAL(connected()),this,SLOT(clientReadyWrite()));
    tcpClient->connectToHost(QHostAddress::LocalHost,9898);
    if(!tcpClient->waitForConnected(3000)){
      //  qDebug() << "Failed to connected";
        dataSent = true;
    }
    return;
}

void IPCInterface::newConnection()
{
    this->tcpServerConnection = tcpServer->nextPendingConnection();
    connect(tcpServerConnection,SIGNAL(readyRead()),this,SLOT(serverReadyRead()));
}

void IPCInterface::serverReadyRead()
{
    QString str = QString(tcpServerConnection->readLine());
    emit linkReceived(str);
}

void IPCInterface::clientReadyWrite()
{
    // qDebug() << "Connected to server, sending data..";
    tcpClient->write(ipcPayload.toUtf8());
    tcpClient->waitForBytesWritten(2000);
    this->dataSent = true;
}
