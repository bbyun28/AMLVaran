SCRIPT_DIR=$(readlink -f $0)
SCRIPT_DIR=${SCRIPT_DIR%/*}

export HOST_USER_ID=$(id -u)
export HOST_GROUP_ID=$(id -g)

echo "Downloading ressources. This may take a few hours..."

cd $SCRIPT_DIR/genomes
if [ ! -f Homo_sapiens.GRCh37.67.fasta ]; then
    echo "Get reference genome..."
    sh getReference.sh
fi

cd $SCRIPT_DIR/genomes/gatk
if [ ! -f 1000G_phase1.indels.b37.vcf ]; then
    echo "Get GATK ressources..."
    sh getRessources.sh
fi

cd $SCRIPT_DIR/genomes/blast
if [ ! -f nr.05.psq ]; then
    echo "Get Blast DB for Provean [optional]..."
    sh getBlastDB.sh
fi

if [ ! -d $SCRIPT_DIR/mysql_data/amlvaran ]; then
    echo "Prepopulating MySQL database..."
    mkdir $SCRIPT_DIR/mysql_data
    cd $SCRIPT_DIR/mysql_data
    wget -O- https://static.uni-muenster.de/amlvaran/SQLdump/DB.tar.gz | tar -xz -C $SCRIPT_DIR/mysql_data
    sudo chown -R $HOST_USER_ID:$HOST_GROUP_ID $SCRIPT_DIR/mysql_data
fi

echo "Starting Docker..."
cd $SCRIPT_DIR
docker-compose up