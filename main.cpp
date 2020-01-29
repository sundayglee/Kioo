/****************************************************************************************************
    Kioo Media Player: A Player With Clear Crystal Sound, Extra Sharp Video, with a Beautiful Design.
    Copyright (C) 2017 - 2020 Kioo Media Player <support@kiooplayer.com>.
    Homepage: https://www.kiooplayer.com
    Developer: Godfrey E Laswai <sundayglee@gmail.com>
    All rights reserved.

    Use of this source code is governed by a BSD-3-Clause license that can be
    found in the BSD-LICENSE file or see it here <https://opensource.org/licenses/BSD-3-Clause>.
****************************************************************************************************/

#include <QGuiApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QStringList>
#include <QDebug>
#include <QObject>
#include <QFile>
#include "addon.h"
#include <QLockFile>
#include <QDir>
#include <QString>
#include <QtAV>
#include "ipcinterface.h"
#include <QDBusInterface>
#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QtAndroid>
#include <QAndroidJniEnvironment>
#endif

#if defined(Q_OS_UNIX)
#endif

#if defined(Q_OS_WIN)
#include <windows.h>
#endif


#if defined (Q_OS_ANDROID)
#include <QtAndroid>
const QVector<QString> permissions({"android.permission.INTERNET",
                                    "android.permission.WRITE_EXTERNAL_STORAGE",
                                    "android.permission.READ_EXTERNAL_STORAGE"});
#endif

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

        if(cmdLine[1].trimmed().isEmpty()) {
           // qDebug() << "Empty payload";
            return 1;
        }
        ipcInterface.ipcPayload = cmdLine[1].trimmed();
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

#ifdef Q_OS_ANDROID

    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");

    QAndroidJniObject contentResolver = activity.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");
    QAndroidJniEnvironment env;
    QAndroidJniObject MediaStore_Images_Media_DATA
            = QAndroidJniObject::getStaticObjectField(
            "android/provider/MediaStore$MediaColumns", "DATA", "Ljava/lang/String;");

    QString s = "";
    if (activity.isValid()) {
        QAndroidJniObject intent = activity.callObjectMethod("getIntent", "()Landroid/content/Intent;");
        if (intent.isValid()) {
            QAndroidJniObject uri = intent.callObjectMethod("getData", "()Landroid/net/Uri;");
            if (uri.isValid()) {
                QAndroidJniObject nullObj;
                jstring emptyJString = env->NewStringUTF("");
                jobjectArray projection = (jobjectArray)env->NewObjectArray(
                    1,
                    env->FindClass("java/lang/String"),
                    emptyJString
                );

                jobject projection0 = env->NewStringUTF( MediaStore_Images_Media_DATA.toString().toStdString().c_str() );
                env->SetObjectArrayElement(
                    projection, 0, projection0 );

                //	Cursor cursor = getContentResolver().query(uri, proj,  null, null, null);
                QAndroidJniObject cursor = contentResolver.callObjectMethod("query",
                    "(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
                    uri.object<jobject>(), projection, nullObj.object<jstring>(), nullObj.object<jobjectArray>(), nullObj.object<jstring>());
                qDebug() << __FUNCTION__ << "cursor.isValid()=" << cursor.isValid();

                //int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                jint column_index = cursor.callMethod<jint>(
                            "getColumnIndexOrThrow","(Ljava/lang/String;)I", MediaStore_Images_Media_DATA.object<jstring>());
                qDebug() << "column_index=" << column_index;

                //cursor.moveToFirst();
                cursor.callMethod<jboolean>("moveToFirst");

                //	String path = cursor.getString(column_index);
                QAndroidJniObject path = cursor.callObjectMethod(
                            "getString",
                            "(I)Ljava/lang/String;", column_index );
                qDebug() << __FUNCTION__ << "path.isValid()=" << path.isValid();
                s = QUrl("file:" + path.toString().toUtf8()).toString();

                addon.setMediaFile(s);

                //cursor.close();
                cursor.callMethod<jboolean>("close");

                env->DeleteLocalRef(emptyJString);
                env->DeleteLocalRef(projection);
                env->DeleteLocalRef(projection0);
            }
        }
    }
#endif

    app.setOrganizationName("Kioo Media");
    app.setOrganizationDomain("kioomedia.com");
    app.setApplicationName("Kioo Media");
    app.setApplicationVersion("v1.0");

    // qDebug() << "SSL Version: " + QSslSocket::sslLibraryBuildVersionString();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("addon", &addon);
    engine.rootContext()->setContextProperty("ipcInterface", &ipcInterface);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

#if defined (Q_OS_ANDROID)
    //Request requiered permissions at runtime
    for(const QString &permission : permissions){
        auto result = QtAndroid::checkPermission(permission);
        if(result == QtAndroid::PermissionResult::Denied){
            auto resultHash = QtAndroid::requestPermissionsSync(QStringList({permission}));
            if(resultHash[permission] == QtAndroid::PermissionResult::Denied)
                qDebug() << "Permission failed";
        }
    }
#endif

    return app.exec();
}


