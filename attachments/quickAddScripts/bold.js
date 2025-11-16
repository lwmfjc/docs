// QuickAdd Macro: Toggle Bold Markdown with Smart Replacement
// 功能：对选中的文本前面和后面各添加**，如果没有选中文本且光标前后各是**（即光标在****正中间时），删除****
// 新增功能：选中文本时，将[数字]替换为对应的译文内容

module.exports = {
    entry: start,
    settings: {
        name: "Toggle Bold Markdown",
        author: "Your Name",
        description: "为选中文本添加或删除**粗体**标记，或智能替换[数字]为译文内容"
    }
};

async function start(quickAddApi) {
    const editor = app.workspace.activeEditor?.editor;
    if (!editor) {
        new Notice("请在编辑器中运行此宏");
        return;
    }

    const selection = editor.getSelection();
    const cursor = editor.getCursor();

    // 情况1：有选中文本
    if (selection) {
        const selectionStart = editor.getCursor('from');
        const selectionEnd = editor.getCursor('to');
        
        let processedText = selection;
        let hasTranslationReplacement = false;
        
        // 新功能：如果包含[数字]模式，尝试从选中文本中查找对应内容
        if (/\[\d+\]/.test(processedText)) {
            // 直接从选中的文本中构建映射表
            const translationMap = buildTranslationMap(selection);
            
            if (Object.keys(translationMap).length > 0) {
                // 分离原文和译文部分
                const separated = separateOriginalAndTranslation(selection);
                
                if (separated.originalContent) {
                    // 只对原文内容部分进行处理：替换[数字]并添加**
                    let processedOriginal = separated.originalContent;
                    const parts = processedOriginal.split(/(\[\d+\])/);
                    processedOriginal = parts.map((part, index) => {
                        // 如果是[数字]标记，替换为译文内容（不加**）
                        if (part.match(/\[(\d+)\]/)) {
                            const number = part.match(/\[(\d+)\]/)[1];
                            if (translationMap[number]) {
                                hasTranslationReplacement = true;
                                return ` ${translationMap[number]} `;
                            }
                        }
                        // 只有非空且不是译文内容的原文片段才加**
                        return part.trim() ? `**${part}**` : part;
                    }).join('');
                    
                    // 重新组合所有部分，保留标记行，但删除译文内容
                    processedText = separated.originalStart + processedOriginal + separated.originalEnd +
                                   separated.translationStart + '\n\n'; // 只保留译文标记和两个空行，删除译文内容
                }
            } else {
                // 如果没有找到译文映射，使用默认的**  **替换
                processedText = processedText.replace(/\[\d+\]/g, '**  **');
            }
        }
        
        // 如果没有进行译文替换，执行原有的粗体切换逻辑
        if (!hasTranslationReplacement && !/\[\d+\]/.test(selection)) {
            if (processedText.startsWith('**') && processedText.endsWith('**')) {
                // 删除前后的**
                const newText = processedText.slice(2, -2);
                editor.replaceSelection(newText);
                
                // 重新选中文本
                const newLength = newText.length;
                editor.setSelection(
                    { line: selectionStart.line, ch: selectionStart.ch },
                    { line: selectionStart.line, ch: selectionStart.ch + newLength }
                );
            } else {
                // 在选中文本前后添加**
                const newText = `**${processedText}**`;
                editor.replaceSelection(newText);
                
                // 重新选中文本（包含**）
                const newLength = newText.length;
                editor.setSelection(
                    { line: selectionStart.line, ch: selectionStart.ch },
                    { line: selectionStart.line, ch: selectionStart.ch + newLength }
                );
            }
        } else {
            // 如果进行了译文替换，直接替换文本
            editor.replaceSelection(processedText);
            
            // 重新选中处理后的文本
            const newLength = processedText.length;
            editor.setSelection(
                { line: selectionStart.line, ch: selectionStart.ch },
                { line: selectionStart.line, ch: selectionStart.ch + newLength }
            );
        }
        return;
    }

    // 情况2：没有选中文本，检查光标是否在****中间
    const lineContent = editor.getLine(cursor.line);
    const pos = cursor.ch;
    
    // 检查光标前后各有两个*
    if (pos >= 2 && 
        lineContent.substring(pos - 2, pos) === "**" && 
        lineContent.substring(pos, pos + 2) === "**") {
        
        // 删除前后的**
        const newLineContent = lineContent.substring(0, pos - 2) + 
                              lineContent.substring(pos + 2);
        
        editor.setLine(cursor.line, newLineContent);
        // 将光标移动到删除后的位置
        editor.setCursor({ line: cursor.line, ch: pos - 2 });
    } else {
        // 如果不在****中间，直接插入****并将光标放在中间
        editor.replaceSelection("****");
        // 将光标移动到**中间
        editor.setCursor({ line: cursor.line, ch: cursor.ch + 2 });
    }
}

// 分离原文和译文部分，保留标记行
function separateOriginalAndTranslation(fullText) {
    const lines = fullText.split('\n');
    let originalStart = '';    // ***【原文】*** 行
    let originalContent = '';  // 原文内容
    let originalEnd = '';      // 原文结束后的空行
    let translationStart = ''; // ***【译文】*** 行
    let translationContent = ''; // 译文内容
    let translationEnd = '';   // 译文结束部分
    
    let currentSection = 'none';
    let contentLines = [];
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        if (line.includes('***【原文】***')) {
            // 在【原文】行后面添加空行
            originalStart = line + '\n\n';
            currentSection = 'original';
            contentLines = [];
        } else if (line.includes('***【译文】***')) {
            // 保存原文部分
            if (currentSection === 'original') {
                originalContent = contentLines.join('\n');
                // 确保原文内容前后没有多余的换行
                originalContent = originalContent.replace(/^\n+/, '').replace(/\n+$/, '');
                originalEnd = '\n\n';
            }
            // 在【译文】行后面添加空行
            translationStart = line + '\n';
            currentSection = 'translation';
            contentLines = [];
        } else if (currentSection === 'original') {
            contentLines.push(line);
        } else if (currentSection === 'translation') {
            contentLines.push(line);
        }
    }
    
    // 处理最后一个部分
    if (currentSection === 'original') {
        originalContent = contentLines.join('\n');
        originalContent = originalContent.replace(/^\n+/, '').replace(/\n+$/, '');
    } else if (currentSection === 'translation') {
        translationContent = contentLines.join('\n');
        translationContent = translationContent.replace(/^\n+/, '').replace(/\n+$/, '');
        // 在译文内容的最后添加一个空行
        translationEnd = '';
    }
    
    return {
        originalStart,
        originalContent,
        originalEnd,
        translationStart,
        translationContent,
        translationEnd
    };
}

// 构建译文映射表 - 从译文部分构建
function buildTranslationMap(selectedText) {
    const translationMap = {};
    
    try {
        const separated = separateOriginalAndTranslation(selectedText);
        
        if (!separated.translationContent) return translationMap;
        
        // 从译文部分匹配格式：[数字]译文内容
        const translationRegex = /\[(\d+)\]([^\n\r\[\]]*)/g;
        let match;
        
        while ((match = translationRegex.exec(separated.translationContent)) !== null) {
            const number = match[1];
            let content = match[2].trim();
            
            // 清理内容，移除开头的中英文冒号、逗号等
            content = content.replace(/^[：:，,。\.\s]+/, '').replace(/[，,。\.\s]+$/, '');
            
            if (content && content.length > 0) {
                translationMap[number] = content;
            }
        }
    } catch (error) {
        console.error("构建译文映射表时出错:", error);
    }
    
    return translationMap;
}