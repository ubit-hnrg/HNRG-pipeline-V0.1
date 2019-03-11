#!/bin/bash

installation_path=$(readlink -f ./)
verbose=0
skip_build_reference=0
annotation_dbs=0

while :; do
     case $1 in
         -h|-\?|--help)
             echo show_help    # Display a usage synopsis.
             exit
             ;;
         -v|--verbose)
             verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
             ;;
         -p|--path)       # Takes an option argument; ensure it has been specified.
             if [ "$2" ]; then
                 installation_path=$2
                 shift
             else
                 die 'ERROR: "--path" requires a non-empty option argument.'
             fi
             ;;
         --path=?*)
             installation_path=${1#*=} # Delete everything up to "=" and assign the remainder.
             ;;
         --path=)         # Handle the case of an empty --file=
             die 'ERROR: "--path" requires a non-empty option argument.'
             ;;

         -s|--skip_build_reference)
             skip_build_reference=1  # Each -v adds 1 to verbosity.
             ;;
         -a|--annotation_dbs)
             annotation_dbs=1  # Each -v adds 1 to verbosity.
             ;;

         --)              # End of all options.
             shift
             break
             ;;
         -?*)
             printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
             ;;
         *)               # Default case: No more options, so break out of the loop.
             break
     esac
 
         shift
done
 


pipelineVersion="HNRG-pipeline-V0.1"
#tools
cromwell='https://github.com/broadinstitute/cromwell/releases/download/37/cromwell-37.jar'
wdltool='https://github.com/broadinstitute/wdltool/releases/download/0.14/wdltool-0.14.jar'
bwakit='http://sourceforge.net/projects/bio-bwa/files/bwakit/bwakit-0.7.15_x64-linux.tar.bz2/download'
fastp='http://opengene.org/fastp/fastp'

# GATK version
gatkVersion='4.1.0.0'
gatklink='https://github.com/broadinstitute/gatk/releases/download/'$gatkVersion'/gatk-'$gatkVersion'.zip'

#minimal required dbs
#indels Mills&1000G
Mils_1000G_b37_vcf_file='Mills_and_1000G_gold_standard.indels.b37.vcf'
Mils_1000G_b37_vcf='ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/'$Mils_1000G_b37_vcf_file                # required for preprocessing
#dbsnp b37
dbsnp_b37_vcf='ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_20180423.vcf.gz'

https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2
# for bgzip, tabix
htslib_version='1.9'

htslibfile='htslib-'$htslib_version'.tar.bz2'
htslib='https://github.com/samtools/htslib/releases/download/'$htslib_version/$htslibfile
samtoolsfile='samtools-'$htslib_version'.tar.bz2'
samtools='https://github.com/samtools/samtools/releases/download/'$htslib_version/$samtoolsfile

#######################################
#######   directory structure  ########
#######################################


#mkdir -p $installation_path/$pipelineVersion/tools/
#mkdir $installation_path/$pipelineVersion/references/
#mkdir $installation_path/$pipelineVersion/libraries/
#mkdir $installation_path/$pipelineVersion/dbs/

src_path=$installation_path/src
tool_path=$installation_path/tools
dbpath=$installation_path/dbs


#########################################################
#####   Global installation: JAVA  and  python     ######
#########################################################


# java
# optional configuration details at this site:
# https://thishosting.rocks/install-java-ubuntu/  
if type -p java; then
    echo found java executable in PATH
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME     
    _java="$JAVA_HOME/bin/java"
else
    echo "no java, installing it just now!"
    sudo apt-get update && apt-get upgrade
    apt-get install default-jdk
fi

if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo version "$version"
    if [[ "$version" > $min_java ]]; then
        echo version is more than $min_java, OK. 
    else         
        echo version is less than $min_java, please upgrade it 
        exit 1
    fi
fi


## check and install python 2.7 if were necesary
if [ -x "$(command -v python)" ]; then
    echo "python is already instelled in your system"
    # command
else
    echo "Installing python 2.7"
    sudo apt update
    sudo apt upgrade
    sudo apt install python2.7 python-pip
fi



################################################
######   local installations (tools).   ########
################################################

### INSTALL HTSLIB!!!! 
wget -O- $htslib |tar xjf -
mv htslib-$htslib_version $tool_path
cd $tool_path/htslib-$htslib_version
./configure
sudo make
sudo make install
ln -sr $tool_path/htslib-$htslib_version/bgzip $tool_path
ln -sr $tool_path/htslib-$htslib_version/tabix $tool_path

#descomprimir y compilar!!!

wget -O- $samtools |tar xjf -
mv samtools-$htslib_version $tool_path
cd $tool_path/samtools-$htslib_version
./configure --without-curses --prefix=$tool_path
sudo make
sudo make install
ln -sr $tool_path/samtools-$htslib_version/samtools $tool_path


# cromwell
wget $cromwell -P $tool_path 
# wdltool 
wget $wdltool -P $tool_path

# install GATK  (from  docker)
jarname='gatk-package-'$gatkVersion'-local.jar'
gatkzip='gatk-'$gatkVersion'.zip'
folder='gatk-'$gatkVersion
wget $gatklink -P $tool_path/
unzip -p $tool_path/$gatkzip $folder/$jarname > $tool_path/$jarname # extract only the precompiled jarfile


#bwa + reference building
wget -O- $bwakit |tar xjf - # get bwa-kit
mv './bwa.kit/' $tool_path/
ln -rs $tool_path/bwa.kit/bwa $tool_path/  # create link to binary


if(($skip_build_reference == '0'))
then
    $tool_path/bwa.kit/run-gen-ref hs37d5      # get reference
    $tool_path/bwa.kit/bwa index hs37d5.fa     # build indices
    mkdir $installation_path/references/hs37d5/ 
    mv hs37d5* $installation_path/references/hs37d5/ # move indices to refernce path
elif
    $echo 'WARNING SKIPING BUILD REFERENCE'

gzip -dk $installation_path/libraries/GRCh37/S07604624_SureSelectHumanAllExonV6+UTRs_Padded_GRCh37.interval_list.gz


#fastp 
wget $fastp -P $tool_path/
chmod a+x $tool_path/fastp

# dbs (for preprocessing & annotation prouposes)

wget $Mils_1000G_b37_vcf'.gz' -P $dbpath/       # for preprocessing
gzip -d $dbpath/$Mils_1000G_b37_vcf_file'.gz'
$toolpath/bgzip $dbpath/$Mils_1000G_b37_vcf_file
$toolpath/tabix $dbpath/$Mils_1000G_b37_vcf_file'.gz'
#wget $Mils_1000G_b37_vcf'.idx.gz' -P $dbpath/

# dbSNP 
echo  'downloading dbSNP (at less 15gb), take a coffe.'
wget $dbsnp_b37_vcf -P $dbpath/            # for preprocessing
wget $dbsnp_b37_vcf'.tbi' -P $dbpath/


### For annotation prouposes
if(($annotation_dbs == '1'))
then
$src_path/get_external_dbs.sh $installation_path
fi

### WDL input_main.json generation
sed -e "s|__installation_path__|$installation_path|g" $installation_path/src/wdl/template_inputs_main.json > $installation_path/src/wdl/inputs_main.json
#sudo java -jar ./tools/gatk-package-4.0.6.0-local.jar BedToIntervalList -I=./libraries/GRCh37/S07604624_SureSelectHumanAllExonV6+UTRs_Padded_GRCh37.bed.gz -O=./libraries/GRCh37/S07604624_SureSelectHumanAllExonV6+UTRs_Padded_GRCh37.interval_list -SD=references/hs37d5/hs37d5.fa.dict
#sudo java -jar ./tools/gatk-package-4.0.6.0-local.jar CreateSequenceDictionary --REFERENCE=./references/hs37d5/hs37d5.fa --OUTPUT=hs37d5.dict
