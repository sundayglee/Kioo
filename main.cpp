#include <QGuiApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QStringList>
#include <QDebug>
#include <QObject>
#include <QFile>
#include <windows.h>
#include <addon.h>

int main(int argc, char *argv[])
{    
    QGuiApplication app(argc, argv);
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    SetThreadExecutionState(ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED | ES_CONTINUOUS);    

//    QStringList args = app.arguments();
//    qDebug() << urlHandler.getArgs(args[1])

    AddOn addon;

    app.setOrganizationName("Kioo Media");
    app.setOrganizationDomain("kioomedia.com");
    app.setApplicationName("Kioo Media Player");

    QQmlApplicationEngine engine;
 //   engine.rootContext()->setContextProperty("mrr",&mrr);
    engine.rootContext()->setContextProperty("addon", &addon);
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;



//    QObject *object = engine.rootObjects()[0];

 //   QObject *object = engine.rootObjects()[0];

//    QObject *kioo = object->findChild<QObject*>("kioo");

//    if (kioo && !file.isEmpty()) {
//        if (!file.startsWith(QLatin1String("file:")) && QFile(file).exists())
//            file.prepend(QLatin1String("file:")); //qml use url and will add qrc: if no scheme
//        file.replace(QLatin1String("\\"), QLatin1String("/"));
//        kioo->setProperty("source", file);
//    }

    return app.exec();
}


