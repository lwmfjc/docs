module.exports = async (params) => {

    const { app } = params;



    const syncIndexFile = async (file) => {


        // 只处理文件夹
        if (!file.children) return;



        const folderName = file.name;

        const indexPath =
            `${file.path}/index.md`;



        // 延迟300ms，等待文件系统稳定
        setTimeout(async () => {


            try {


                const indexFile =
                    app.vault.getAbstractFileByPath(indexPath);



                if (!indexFile) return;



                const content =
                    await app.vault.read(indexFile);



                const yamlString =
                    JSON.stringify(folderName);



                const newContent =
                    content
                        .replace(
                            /^title:.*$/m,
                            `title: ${yamlString}`
                        )
                        .replace(
                            /^description:.*$/m,
                            `description: ${yamlString}`
                        );



                if (content !== newContent) {


                    await app.vault.modify(
                        indexFile,
                        newContent
                    );



                    new Notice(
                        `✅ 已同步 index.md: ${folderName}`
                    );

                }



            } catch(e) {


                console.error(
                    "FolderSync Error:",
                    e
                );

            }


        },300);

    };




    app.vault.on(
        'rename',
        syncIndexFile
    );



    new Notice(
        "FolderSync 已启动"
    );


    console.log(
        "FolderSync: 监听器已就绪"
    );

};