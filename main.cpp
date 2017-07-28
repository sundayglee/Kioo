#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QStringList>
#include <QDebug>
#include <QObject>
#include <QFile>
#include "mirror.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QString file;

//    QStringList args = app.arguments();
//    qDebug() << urlHandler.getArgs(args[1]);
    Mirror mrr;


    app.setOrganizationName("Kioo Media");
    app.setOrganizationDomain("kioomedia.com");
    app.setApplicationName("Kioo Media Player");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("mrr",&mrr);
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    QObject *object = engine.rootObjects()[0];

    QObject *kioo = object->findChild<QObject*>("kioo");

    file = app.arguments().last();

    if (kioo && !file.isEmpty()) {
        if (!file.startsWith(QLatin1String("file:")) && QFile(file).exists())
            file.prepend(QLatin1String("file:")); //qml use url and will add qrc: if no scheme
        file.replace(QLatin1String("\\"), QLatin1String("/"));
        kioo->setProperty("source", file);
    }

    return app.exec();
}


