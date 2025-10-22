module.exports = async () => {
    const editor = app.workspace.activeEditor?.editor;
    if (!editor) return;

    const selection = editor.getSelection();
    
    if (selection.length > 0) {
        const selectionStart = editor.getCursor('from');
        const selectionEnd = editor.getCursor('to');
        
        // 检查选中的文本是否以 ' ~~' 开头和 '~~ ' 结尾
        if (selection.startsWith(' ~~') && selection.endsWith('~~ ')) {
            // 删除模式：移除前面的 ' ~~' 和后面的 '~~ '
            const newText = selection.slice(3, -3); // 移除前面的3个字符(' ~~')和后面的3个字符('~~ ')
            editor.replaceSelection(newText);
            
            // 重新选中清理后的文本
            const newStart = selectionStart.ch;
            const newEnd = selectionStart.ch + newText.length;
            
            editor.setSelection(
                { line: selectionStart.line, ch: newStart },
                { line: selectionStart.line, ch: newEnd }
            );
        } else {
            // 插入模式：在选中文本前后添加 ' ~~' 和 '~~ '
            editor.replaceSelection(` ~~${selection}~~ `);
            
            // 重新选中原来的文本（包含前后添加的 ~~）
            const newStart = selectionStart.ch;
            const newEnd = selectionStart.ch + selection.length + 6; // 原文本长度 + 前后各3个字符
            
            editor.setSelection(
                { line: selectionStart.line, ch: newStart },
                { line: selectionStart.line, ch: newEnd }
            );
        }
        
    } else {
        const cursor = editor.getCursor();
        const lineContent = editor.getLine(cursor.line);
        const beforeCursor = lineContent.slice(0, cursor.ch);
        const afterCursor = lineContent.slice(cursor.ch);
        
        // 新增判断：如果光标位于空行行首
        if (lineContent.trim() === '' && cursor.ch === 0) {
            // 在空行行首插入 '~~' 和 '~~  '，光标位于中间
            editor.replaceSelection('~~');
            editor.setCursor({ line: cursor.line, ch: cursor.ch + 2 });
            editor.replaceSelection('~~  ');
            // 将光标移回两个 ~~ 之间
            editor.setCursor({ line: cursor.line, ch: cursor.ch - 4 });
        }
        // 原有的判断：如果光标位于 ~~ 之间
        else if (beforeCursor.endsWith(' ~~') && afterCursor.startsWith('~~ ')) {
            const startDeletePos = cursor.ch - 3;
            const endDeletePos = cursor.ch + 3;
            
            editor.setSelection(
                { line: cursor.line, ch: startDeletePos },
                { line: cursor.line, ch: endDeletePos }
            );
            editor.replaceSelection('');
            editor.setCursor({ line: cursor.line, ch: startDeletePos });
        } else {
            // 默认情况：插入 ' ~~~~ '
            editor.replaceSelection(' ~~~~ ');
            editor.setCursor({ line: cursor.line, ch: cursor.ch + 3 });
        }
    }
};