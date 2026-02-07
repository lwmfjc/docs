module.exports = async (params) => {
    const { app } = params;

    // 使用辅助函数防止逻辑冲突
    const syncIndexFile = async (file) => {
        // 只处理文件夹
        if (!file.children) return;

        const folderName = file.name;
        const indexPath = `${file.path}/index.md`;
        
        // 稍微延迟，避开文件系统重命名的瞬间死锁
        setTimeout(async () => {
            try {
                const indexFile = app.vault.getAbstractFileByPath(indexPath);
                if (!indexFile) return;

                const content = await app.vault.read(indexFile);
                
                // 执行替换逻辑
                const newContent = content
                    .replace(/^title:.*$/m, `title: ${folderName}`)
                    .replace(/^description:.*$/m, `description: ${folderName}`)
                    .replace(/^# .*$/m, `# ${folderName}`);
                
                if (content !== newContent) {
                    await app.vault.modify(indexFile, newContent);
                    new Notice(`✅ 已同步 index.md: ${folderName}`);
                }
            } catch (e) {
                console.error("FolderSync Error:", e);
            }
        }, 300); 
    };

    // 注册监听
    app.vault.on('rename', syncIndexFile);

    console.log("FolderSync: 监听器已就绪");
};