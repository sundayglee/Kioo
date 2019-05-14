#include <QGuiApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QStringList>
#include <QDebug>
#include <QObject>
#include <QFile>
//#include <windows.h>
#include "addon.h"
#include <QLockFile>
#include <QDir>
#include <QString>
#include <QtAV>
#include "ipcinterface.h"
#include <QDBusInterface>

int main(int argc, char *argv[])
{    
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling); // Must be the first line
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
   // QCoreApplication::setAttribute(Qt::AA_X11InitThreads);
   // QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/icon.ico"));

#if defined(Q_OS_ANDROID)

#elif defined(Q_OS_BLACKBERRY)

#elif defined(Q_OS_IOS)

#elif defined(Q_OS_MACOS)

#elif defined(Q_OS_WIN)
    SetThreadExecutionState(ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED | ES_CONTINUOUS);
#elif defined(Q_OS_UNIX)
    // KDE(>= 4) and GNOME(>= 3.10) ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.freedesktop.ScreenSaver"), QLatin1String("/ScreenSaver"),
                    QLatin1String("org.freedesktop.ScreenSaver")).call(QDBus::AutoDetect,QLatin1String("Inhibit"));

    // KDE(< 4.0) and GNOME (<= 2.6) ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.freedesktop.PowerManagement"), QLatin1String("/org/freedesktop/PowerManagement"),
                    QLatin1String("org.freedesktop.PowerManagement")).call(QDBus::AutoDetect,QLatin1String("Inhibit"));

    // GNOME(>= 2.26) ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.gnome.SessionManger"), QLatin1String("/org/gnome/SessionManager"),
                    QLatin1String("org.gnome.SessionManager")).call(QDBus::AutoDetect, QLatin1String("Inhibit"));

    // MATE - ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.mate.SessionManager"), QLatin1String("/org/mate/SessionManager"),
                    QLatin1String("org.mate.SessionManager")).call(QDBus::AutoDetect, QLatin1String("Inhibit"));

    QDBusInterface("org.freedesktop.ScreenSaver","/ScreenSaver","org.freedesktop.ScreenSaver",QDBusConnection::sessionBus()).call("Inhibit",0,2,2);

#elif defined(Q_OS_LINUX)    
    // KDE(>= 4) and GNOME(>= 3.10) ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.freedesktop.ScreenSaver"), QLatin1String("/ScreenSaver"),
                    QLatin1String("org.freedesktop.ScreenSaver")).call(QDBus::AutoDetect,QLatin1String("Inhibit"));

    // KDE(< 4.0) and GNOME (<= 2.6) ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.freedesktop.PowerManagement"), QLatin1String("/org/freedesktop/PowerManagement"),
                    QLatin1String("org.freedesktop.PowerManagement")).call(QDBus::AutoDetect,QLatin1String("Inhibit"));

    // GNOME(>= 2.26) ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.gnome.SessionManger"), QLatin1String("/org/gnome/SessionManager"),
                    QLatin1String("org.gnome.SessionManager")).call(QDBus::AutoDetect, QLatin1String("Inhibit"));

    // MATE - ScreenSaver Inhibit
    QDBusInterface(QLatin1String("org.mate.SessionManager"), QLatin1String("/org/mate/SessionManager"),
                    QLatin1String("org.mate.SessionManager")).call(QDBus::AutoDetect, QLatin1String("Inhibit"));

   // QDBusInterface("org.freedesktop.ScreenSaver","/ScreenSaver","org.freedesktop.ScreenSaver",QDBusConnection::sessionBus()).call("Inhibit",0,2,2);

#endif

    AddOn addon;
    IPCInterface ipcInterface;

    QString tmpDir = QDir::tempPath();
    QLockFile lockFile(tmpDir + "/KiooMediaPlayer");
    QStringList cmdLine = QCoreApplication::arguments();

    if(!lockFile.tryLock(10)) {
       // qDebug() << "Already running....";
        ipcInterface.ipcPayload = "AlphaBetaKing";
        QStringList cmdLine = QCoreApplication::arguments();

        if(cmdLine[1].isEmpty()) {
           // qDebug() << "Empty payload";
            return 1;
        }
        ipcInterface.ipcPayload = cmdLine[1];
#ifdef Q_OS_WIN
        ipcInterface.ipcPayload.replace(QLatin1String("\\"), QLatin1String("/"));
#endif
        ipcInterface.clientConnect();
        while(!ipcInterface.dataSent) { }
        return 1;
    }


#ifdef Q_OS_LINUX
    QDBusInterface kdeSessionManager("org.freedesktop.ScreenSaver","/ScreenSaver","org.freedesktop.ScreenSaver",QDBusConnection::sessionBus());
    QDBusMessage response = kdeSessionManager.call("Inhibit","kioo","Playing Movie");
    if (response.type() == QDBusMessage::ErrorMessage) {
        qDebug() << "ScreenSaver::ScreenSaver: error:" << response.errorName() << ":" << response.errorMessage();
    } else {
        qDebug() << "ScreenSaver Inhibit Successfully";
    }
#endif

    app.setOrganizationName("Kioo Media");
    app.setOrganizationDomain("kioomedia.com");
    app.setApplicationName("Kioo Media");
    app.setApplicationVersion("v1.0");

    // qDebug() << "SSL Version: " + QSslSocket::sslLibraryBuildVersionString();

    QQmlApplicationEngine engine;
    //   engine.rootContext()->setContextProperty("mrr",&mrr);
    engine.rootContext()->setContextProperty("addon", &addon);
    engine.rootContext()->setContextProperty("ipcInterface", &ipcInterface);
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

   // QMetaObject::invokeMethod(qApp, "quit", Qt::QueuedConnection);

    return app.exec();
}


