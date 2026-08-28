module.exports = async (params) => {

    const { app } = params;


    // 防止重复注册监听
    if (window.folderSyncListener) {
        new Notice("FolderSync 已经运行");
        return;
    }


    let timer = null;


    const syncIndexFile = async (file, oldPath) => {

        // 只处理文件夹
        if (!file.children) return;


        // 防抖
        clearTimeout(timer);

        timer = setTimeout(async () => {

            try {

                const folderName = file.name;

                const indexPath = `${file.path}/index.md`;

                const indexFile =
                    app.vault.getAbstractFileByPath(indexPath);


                // 没有 index.md 不处理
                if (!indexFile) return;


                let content =
                    await app.vault.read(indexFile);



                let newContent = content;


                // 修改 title
                if (/^title:.*$/m.test(newContent)) {

                    newContent =
                        newContent.replace(
                            /^title:.*$/m,
                            `title: ${folderName}`
                        );

                }



                // 修改 description
                if (/^description:.*$/m.test(newContent)) {

                    newContent =
                        newContent.replace(
                            /^description:.*$/m,
                            `description: ${folderName}`
                        );

                }



                // 修改第一个一级标题
                if (/^# .*$/m.test(newContent)) {

                    newContent =
                        newContent.replace(
                            /^# .*$/m,
                            `# ${folderName}`
                        );

                }



                // 内容没有变化，不写入
                if (content === newContent) {
                    return;
                }


                await app.vault.modify(
                    indexFile,
                    newContent
                );


                new Notice(
                    `✅ 已同步: ${folderName}`
                );


            } catch (e) {

                console.error(
                    "FolderSync Error:",
                    e
                );

            }


        }, 200);


    };



    // 注册监听
    window.folderSyncListener =
        app.vault.on(
            'rename',
            syncIndexFile
        );


    console.log(
        "FolderSync: 监听器已启动"
    );


    new Notice(
        "FolderSync 已启动"
    );

};