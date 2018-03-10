#include "addon.h"

//AddOn::AddOn(QObject *parent) : QObject(parent)
//{
//    theHash = "";
//}

void AddOn::downloadSub(const QString &url,const QString &fileName, const QString &filePath) {
    if (!m_isReady)
        return;
    m_isReady = false;

    QString rFilePath = filePath;
    rFilePath = rFilePath.left(rFilePath.lastIndexOf("/")).replace("file:","");
    if(rFilePath.startsWith("///")) {
        rFilePath.replace("//","");
    }
    theSubFile = rFilePath +"/"+ fileName; // your filePath should end with a forward slash "/"
    m_file = new QFile();
    m_file->setFileName(theSubFile);
    m_file->open(QIODevice::WriteOnly);
    if (!m_file->isOpen()) {
        qDebug() << "Failed to open device";
        m_isReady = true;
        return; // TODO: permission check?
    }

    QNetworkAccessManager *manager = new QNetworkAccessManager;

    QNetworkRequest request;
    request.setUrl(QUrl(url));

    // qDebug() << "The url is:"+url;
    connect(manager, SIGNAL(finished(QNetworkReply *)), this, SLOT(onSubComplete(QNetworkReply *)));

    manager->get(request);
}

void AddOn::setSubFile(QString ufile) {
    // qDebug() << "Full path is: " +ufile;
    QStringList list = ufile.split("|");
    downloadSub(list[0],list[1],list[2]);
}

void AddOn::setSourceUrl(const QString &a) {
    QString ab = a;
    ab.replace("file:","");
    if(ab.startsWith("///")) {
        ab.replace("//","");
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

QString AddOn::sourceUrl() const {
    return theHash;
}

QString AddOn::subFile() const {
    return theSubFile;
}

void AddOn::onSubComplete(QNetworkReply *reply) {
    // qDebug() << "...download complete";
    if (!m_file->isWritable()) {
        m_isReady = true;
        return; // TODO: error check
    }

    QByteArray uncompressed_data = "";
    QByteArray compressed_data = reply->readAll();
    gzipDecompress(compressed_data,uncompressed_data);

    m_file->write(uncompressed_data);
    m_file->close(); // TODO: delete the file from the system later on

    m_isReady = true;
    emit subFileChanged();
}

bool AddOn::gzipDecompress(QByteArray input, QByteArray &output)
{
    // Prepare output
    output.clear();

    // Is there something to do?
    if(input.length() > 0)
    {
        // Prepare inflater status
        z_stream strm;
        strm.zalloc = Z_NULL;
        strm.zfree = Z_NULL;
        strm.opaque = Z_NULL;
        strm.avail_in = 0;
        strm.next_in = Z_NULL;

        // Initialize inflater
        int ret = inflateInit2(&strm, GZIP_WINDOWS_BIT);

        if (ret != Z_OK)
            return(false);

        // Extract pointer to input data
        char *input_data = input.data();
        int input_data_left = input.length();

        // Decompress data until available
        do {
            // Determine current chunk size
            int chunk_size = qMin(GZIP_CHUNK_SIZE, input_data_left);

            // Check for termination
            if(chunk_size <= 0)
                break;

            // Set inflater references
            strm.next_in = (unsigned char*)input_data;
            strm.avail_in = chunk_size;

            // Update interval variables
            input_data += chunk_size;
            input_data_left -= chunk_size;

            // Inflate chunk and cumulate output
            do {

                // Declare vars
                char out[GZIP_CHUNK_SIZE];

                // Set inflater references
                strm.next_out = (unsigned char*)out;
                strm.avail_out = GZIP_CHUNK_SIZE;

                // Try to inflate chunk
                ret = inflate(&strm, Z_NO_FLUSH);

                switch (ret) {
                case Z_NEED_DICT:
                    ret = Z_DATA_ERROR;
                case Z_DATA_ERROR:
                case Z_MEM_ERROR:
                case Z_STREAM_ERROR:
                    // Clean-up
                    inflateEnd(&strm);

                    // Return
                    return(false);
                }

                // Determine decompressed size
                int have = (GZIP_CHUNK_SIZE - strm.avail_out);

                // Cumulate result
                if(have > 0)
                    output.append((char*)out, have);

            } while (strm.avail_out == 0);

        } while (ret != Z_STREAM_END);

        // Clean-up
        inflateEnd(&strm);

        // Return
        return (ret == Z_STREAM_END);
    }
    else
        return(true);
}

bool AddOn::gzipCompress(QByteArray input, QByteArray &output, int level)
{
    // Prepare output
    output.clear();

    // Is there something to do?
    if(input.length())
    {
        // Declare vars
        int flush = 0;

        // Prepare deflater status
        z_stream strm;
        strm.zalloc = Z_NULL;
        strm.zfree = Z_NULL;
        strm.opaque = Z_NULL;
        strm.avail_in = 0;
        strm.next_in = Z_NULL;

        // Initialize deflater
        int ret = deflateInit2(&strm, qMax(-1, qMin(9, level)), Z_DEFLATED, GZIP_WINDOWS_BIT, 8, Z_DEFAULT_STRATEGY);

        if (ret != Z_OK)
            return(false);

        // Prepare output
        output.clear();

        // Extract pointer to input data
        char *input_data = input.data();
        int input_data_left = input.length();

        // Compress data until available
        do {
            // Determine current chunk size
            int chunk_size = qMin(GZIP_CHUNK_SIZE, input_data_left);

            // Set deflater references
            strm.next_in = (unsigned char*)input_data;
            strm.avail_in = chunk_size;

            // Update interval variables
            input_data += chunk_size;
            input_data_left -= chunk_size;

            // Determine if it is the last chunk
            flush = (input_data_left <= 0 ? Z_FINISH : Z_NO_FLUSH);

            // Deflate chunk and cumulate output
            do {

                // Declare vars
                char out[GZIP_CHUNK_SIZE];

                // Set deflater references
                strm.next_out = (unsigned char*)out;
                strm.avail_out = GZIP_CHUNK_SIZE;

                // Try to deflate chunk
                ret = deflate(&strm, flush);

                // Check errors
                if(ret == Z_STREAM_ERROR)
                {
                    // Clean-up
                    deflateEnd(&strm);

                    // Return
                    return(false);
                }

                // Determine compressed size
                int have = (GZIP_CHUNK_SIZE - strm.avail_out);

                // Cumulate result
                if(have > 0)
                    output.append((char*)out, have);

            } while (strm.avail_out == 0);

        } while (flush != Z_FINISH);

        // Clean-up
        (void)deflateEnd(&strm);

        // Return
        return(ret == Z_STREAM_END);
    }
    else
        return(true);
}

int AddOn::MAX(int x, int y)
{
    if((x) > (y))
        return x;
    else
        return y;
}

uint64_t AddOn::compute_hash(ifstream &f)
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

