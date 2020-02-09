#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

BASEDIR='/usr/local/nginx/html'
DIRNAME=$(find $BASEDIR -name *mysqladmin* -printf '%f')
USERNAME='nginx'
CENTMINLOGDIR='/root/centminlogs'

DT=$(date +"%d%m%y-%H%M%S")
##############################################
if [ ! -d "$CENTMINLOGDIR" ]; then
mkdir $CENTMINLOGDIR
fi
##############################################
starttime=$(date +%s.%N)
{
echo "cd ${BASEDIR}/${DIRNAME}"
cd ${BASEDIR}/${DIRNAME}
rm -rf composer.lock
echo "git pull"
git pull
rm -rf composer.phar
wget -cnv https://getcomposer.org/composer.phar -O composer.phar
php composer.phar update --no-dev
if [ ! -f "$(which npm)" ]; then
	/usr/local/src/centminmod/addons/nodejs.sh install
fi
if [ ! -f /usr/bin/yarn ]; then
	npm install --global yarn
fi
# https://docs.phpmyadmin.net/en/latest/setup.html#installing-from-git
if [ ! -f ${BASEDIR}/${DIRNAME}/themes/pmahomme/css/theme.css ]; then
	yarn install
elif [ -f ${BASEDIR}/${DIRNAME}/themes/pmahomme/css/theme.css ]; then
	yarn run --silent css-compile --quiet --style=compressed
fi
chown nginx:nginx ${BASEDIR}/${DIRNAME}
chown -R nginx:nginx ${BASEDIR}/${DIRNAME}
} 2>&1 | tee ${CENTMINLOGDIR}/centminmod_phpmyadmin_update-${DT}.log
endtime=$(date +%s.%N)
INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
echo "" >> ${CENTMINLOGDIR}/centminmod_phpmyadmin_update-${DT}.log 
echo "Total phpmyadmin Update Time: $INSTALLTIME seconds" >> ${CENTMINLOGDIR}/centminmod_phpmyadmin_update-${DT}.log
