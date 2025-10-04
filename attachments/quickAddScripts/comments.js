module.exports = async () => {
    const editor = app.workspace.activeEditor?.editor;
    if (!editor) return;

    const selection = editor.getSelection();
    const cursor = editor.getCursor();
    const lineContent = editor.getLine(cursor.line);
    
    const beforeCursor = lineContent.slice(0, cursor.ch);
    const afterCursor = lineContent.slice(cursor.ch);
    
    // 如果有文本被选中
    if (selection.length > 0) {
        // 在选中文本前后添加波浪线
        editor.replaceSelection(` ~~${selection}~~ `);
        
        // 将光标放在修改后的文本末尾
        const newCursor = editor.getCursor();
        editor.setCursor(newCursor);
    } 
    // 如果光标在 ~~~~ 中间，则删除
    else if (beforeCursor.endsWith(' ~~') && afterCursor.startsWith('~~ ')) {
        // 删除模式：删除整对 ~~~~
        const startDeletePos = cursor.ch - 3;
        const endDeletePos = cursor.ch + 3;
        
        editor.setSelection(
            { line: cursor.line, ch: startDeletePos },
            { line: cursor.line, ch: endDeletePos }
        );
        editor.replaceSelection('');
        editor.setCursor({ line: cursor.line, ch: startDeletePos });
    } 
    // 默认情况：插入新的 ~~~~
    else {
        editor.replaceSelection(' ~~~~ ');
        editor.setCursor({ line: cursor.line, ch: cursor.ch + 3 });
    }
};