#!/bin/bash
# 全量备份+Binlog备份脚本

BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d)
LOG_FILE="/var/log/mysql_backup.log"

# 创建备份目录
mkdir -p $BACKUP_DIR/full $BACKUP_DIR/binlog

# 1. 执行全量备份
echo "$(date) - 开始全量备份" >> $LOG_FILE
mysqldump -u root -p密码 --single-transaction --master-data=2 --flush-logs \
  --all-databases > $BACKUP_DIR/full/full_backup_$DATE.sql 2>> $LOG_FILE

# 2. 备份Binlog
echo "$(date) - 开始Binlog备份" >> $LOG_FILE
# 获取全量备份时的Binlog位置
BINLOG_FILE=$(grep "CHANGE MASTER TO" $BACKUP_DIR/full/full_backup_$DATE.sql | awk '{print $6}' | tr -d ";'")
BINLOG_POS=$(grep "CHANGE MASTER TO" $BACKUP_DIR/full/full_backup_$DATE.sql | awk '{print $9}' | tr -d ";'")

# 备份从该位置之后的所有Binlog
mysqlbinlog --read-from-remote-server --host=localhost --user=root --password=密码 \
  --raw --start-position=$BINLOG_POS $BINLOG_FILE \
  --result-file=$BACKUP_DIR/binlog/binlog_backup_ 2>> $LOG_FILE &

echo "$(date) - 备份完成" >> $LOG_FILE