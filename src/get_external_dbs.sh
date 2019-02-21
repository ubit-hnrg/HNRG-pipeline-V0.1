repository_path=$1
tool_path=$repository_path/tools
dbpath=$repository_path/dbs

# static dbs 
#indels 1000    
indels_1000Gfile='1000G_phase1.indels.b37.vcf.gz'
indels_1000G_phase1='ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/'$indels_1000Gfile

#snp HConfidence 1000G
snpHCfile='1000G_phase1.snps.high_confidence.b37.vcf.gz'
snps_high_confidence_1000G_phase1='ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/'$snpHCfile

# 1000G omni2
omni2file='1000G_omni2.5.b37.vcf.gz'
omni2_1000G='ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/'$omni2file

#hapmap
hapmapVersion='hapmap_3.3.b37.vcf'
hapmap='ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/'$hapmapVersion

#gwascat
gwascatfile='gwascatalog.txt'
gwascat='http://www.genome.gov/admin/'$gwascatfile

#EVS
evsfile='ESP6500SI-V2-SSA137.GRCh38-liftover.snps_indels.vcf.tar.gz'
evsDB='http://evs.gs.washington.edu/evs_bulk_data/'$evsfile

#PharmaGKB
#PharmaGKBfile='PharmGKBvcf_2016.vcf'
#PharmaGKB='https://github.com/ubit-hnrg/HNRG-pipeline-V0.1/blob/master/dbs/'$PharmaGKBfile


### 
#dbsnp b37
dbsnp_version='All_20180423.vcf.gz'
dbsnp_b37_vcf='ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/'$dbsnp_version

#dbNSFP 
dbNSFPversion='4.0b1a'
dbNSFPzipfile='dbNSFP'$dbNSFPversion'.zip'
dbNSFP='ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/'$dbNSFPzipfile

#CADD
caddfile='whole_genome_SNVs.tsv.gz'
cadd='https://krishna.gs.washington.edu/download/CADD/v1.4/GRCh37/'$caddfile

#Clinvar
clinvar='ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar.vcf.gz'

#ExAC
ExACfile='ExAC.r1.sites.vep.vcf.gz'
ExAC='ftp://ftp.broadinstitute.org/pub/ExAC_release/release1/'$ExACfile


# dbSNP 
if [ -e $dbsnp_version]
then
    echo "dbSNP is already in your bundle"
else
    wget $dbsnp_b37_vcf -P $dbpath/
    wget $dbsnp_b37_vcf'.tbi' -P $dbpath/
fi


### For annotation prouposes

#First dbs that not change over time

#omni2
if [ -e $dbpath/$omni2file]
then
    echo "omni2 is already in your bundle"
else
    wget $omni2_1000G -P $dbpath/
    wget $omni2_1000G'.tbi' -P $dbpath/
fi


#hamap
if [ -e $dbpath/$hapmapVersion]
then
    echo "hapmap is already in your bundle"
else
    wget $hapmap'.gz' -P $dbpath/
    wget $hapmap'.idx.gz' -P $dbpath/
fi


#GwasCatalog  
if [ -e $dbpath/$gwascatfile]
then
    echo "gwasCatalog is already in your bundle"
else
    wget $gwascat -P $dbpath/
#    ln -s $dbpath/'gwascatalog.txt' $dbpath/snpEff/
fi


#EVS
if [ -e $dbpath/$evsfile]
then
    echo "EVS database is already in your bundle"
else
    wget $evsDB -P $dbpath/
fi


# DBs that are continuously updated
## snpEFF
if [ -e $dbpath/snpEFF]
then
    echo "snpEff annotation tool is already updated"
else
    wget $snpEff -P $dbpath
    unzip $dbpath/snpEff_latest_core.zip  -d $dbpath 
    ln -rs $dbpath/snpEff/SnpSift.jar $tool_path/ 
    ln -rs $dbpath/snpEff/snpEff.jar $tool_path/ 
    ln -rs $dbpath/clinEff/ClinEff.jar $tool_path/ 
    rm $dbpath/snpEff_latest_core.zip
fi


#dbNSFP 
if [ -e $dbpath/dbNSFP$dbNSFPversion'.gz'|]
then
    echo "dbNSFP database is already updated"
else
    cd $dbpath
    ln -s $src_path/make_dbNSFP.sh $dbpath/
    wget $dbNSFP -P $dbpath/
    $dbpath/make_dbNSFP.sh $dbpath/$dbNSFPzipfile
fi


#CADD
if [ -e $dbpath/$caddfile]
then
    echo "CADD database is already updated"
else
    wget $cadd -P $dbpath/
    wget $cadd.tbi -P $dbpath/
fi


#CLINVAR
wget $clinvar -P $dbpath/
wget $clinvar.tbi -P $dbpath/


#ExAC
if [ -e $dbpath/$ExACfile]
then
    echo "ExAC database tool is already updated"
else
    wget $ExAC -P $dbpath/
    wget $ExAC.tbi -P $dbpath/
fi
