// QuickAdd Macro: Toggle Bold Markdown with Smart Replacement
// 功能：对选中的文本前面和后面各添加**，如果没有选中文本且光标前后各是**（即光标在****正中间时），删除****
// 新增功能：选中文本时，将[数字]、(数字)或①-㊿替换为对应的译文内容

module.exports = {
    entry: start,
    settings: {
        name: "Toggle Bold Markdown",
        author: "Your Name",
        description: "为选中文本添加或删除**粗体**标记，或智能替换[数字]、(数字)或①-㊿为译文内容"
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
        
        // 新功能：如果包含[数字]、(数字)或①-㊿模式，尝试从选中文本中查找对应内容
        if (/\[\d+\]|\(\d+\)|[\u2460-\u2473\u3251-\u325F\u32B1-\u32BF]/.test(processedText)) {
            // 直接从选中的文本中构建映射表
            const translationMap = buildTranslationMap(selection);
            
            if (Object.keys(translationMap).length > 0) {
                // 分离原文和译文部分
                const separated = separateOriginalAndTranslation(selection);
                
                if (separated.originalContent) {
                    // 处理原文内容：对每一行单独处理
                    const originalLines = separated.originalContent.split('\n');
                    const processedLines = originalLines.map(line => {
                        if (line.trim() === '') return line; // 空行保持不变
                        
                        // 对每一行单独处理角标替换和加粗
                        const parts = line.split(/(\[\d+\]|\(\d+\)|[\u2460-\u2473\u3251-\u325F\u32B1-\u32BF])/);
                        let processedLine = parts.map((part, index) => {
                            // 如果是[数字]标记，替换为译文内容（不加**）
                            if (part.match(/\[(\d+)\]/)) {
                                const number = part.match(/\[(\d+)\]/)[1];
                                if (translationMap[number]) {
                                    hasTranslationReplacement = true;
                                    return ` ${translationMap[number]} `;
                                }
                            }
                            // 如果是(数字)标记，替换为译文内容（不加**）
                            else if (part.match(/\((\d+)\)/)) {
                                const number = part.match(/\((\d+)\)/)[1];
                                if (translationMap[number]) {
                                    hasTranslationReplacement = true;
                                    return ` ${translationMap[number]} `;
                                }
                            }
                            // 如果是①-㊿标记，替换为译文内容（不加**）
                            else if (part.match(/[\u2460-\u2473\u3251-\u325F\u32B1-\u32BF]/)) {
                                const symbol = part;
                                if (translationMap[symbol]) {
                                    hasTranslationReplacement = true;
                                    return ` ${translationMap[symbol]} `;
                                }
                            }
                            // 只有非空且不是译文内容的原文片段才加**
                            return part.trim() ? `**${part}**` : part;
                        }).join('');
                        
                        return processedLine;
                    });
                    
                    const processedOriginal = processedLines.join('\n');
                    
                    // 重新组合所有部分，保留标记行，但删除译文内容
                    processedText = separated.originalStart + processedOriginal + separated.originalEnd +
                                   separated.translationStart + '\n\n'; // 只保留译文标记和两个空行，删除译文内容
                }
            } else {
                // 如果没有找到译文映射，对每一行单独使用**  **替换角标
                const lines = processedText.split('\n');
                const processedLines = lines.map(line => {
                    if (line.trim() === '') return line;
                    return line.replace(/\[\d+\]|\(\d+\)|[\u2460-\u2473\u3251-\u325F\u32B1-\u32BF]/g, '**  **');
                });
                processedText = processedLines.join('\n');
            }
        }
        
        // 如果没有进行译文替换，执行原有的粗体切换逻辑
        if (!hasTranslationReplacement && !/\[\d+\]|\(\d+\)|[\u2460-\u2473\u3251-\u325F\u32B1-\u32BF]/.test(selection)) {
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
                // 对多行文本：每一行单独添加**
                const lines = processedText.split('\n');
                const processedLines = lines.map(line => {
                    if (line.trim() === '') return line; // 空行保持不变
                    return `**${line}**`;
                });
                const newText = processedLines.join('\n');
                
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
    let originalContent = '';  // 原文内容（标记行之前的所有内容）
    let translationContent = ''; // 译文内容（标记行之后的所有内容）
    let translationMarkerLine = ''; // 标记行
    
    let foundTranslationMarker = false;
    const originalLines = [];
    const translationLines = [];
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        // 检查是否是译文或注释标记行
        if ((line.includes('【译文】') || line.includes('［注释］')|| line.includes('【注释】')) && !foundTranslationMarker) {
            foundTranslationMarker = true;
            translationMarkerLine = line;
            continue;
        }
        
        if (!foundTranslationMarker) {
            // 标记行之前的所有行都是原文
            originalLines.push(line);
        } else {
            // 标记行之后的所有行都是译文/注释
            translationLines.push(line);
        }
    }
    
    // 处理原文内容
    originalContent = originalLines.join('\n');
    originalContent = originalContent.replace(/^\n+/, '').replace(/\n+$/, '');
    
    // 处理译文内容  
    translationContent = translationLines.join('\n');
    translationContent = translationContent.replace(/^\n+/, '').replace(/\n+$/, '');
    
    return {
        originalStart: '', 
        originalContent,
        originalEnd: foundTranslationMarker ? '\n\n' + translationMarkerLine + '\n' : '',
        translationStart: '',
        translationContent,
        translationEnd: ''
    };
}

// 构建译文映射表 - 从译文部分构建
function buildTranslationMap(selectedText) {
    const translationMap = {};
    
    try {
        const separated = separateOriginalAndTranslation(selectedText);
        
        if (!separated.translationContent) return translationMap;
        
        // 从译文部分匹配格式：[数字]译文内容 或 (数字)译文内容 或 ①-㊿译文内容
        // 修改正则表达式以匹配[数字]、(数字)和①-㊿
        const translationRegex = /(?:\[(\d+)\]|\((\d+)\)|([\u2460-\u2473\u3251-\u325F\u32B1-\u32BF]))([^\n\r\[\]]*)/g;
        let match;
        
        while ((match = translationRegex.exec(separated.translationContent)) !== null) {
            const numberBracket = match[1]; // [数字]格式的数字
            const numberParenthesis = match[2]; // (数字)格式的数字
            const symbol = match[3]; // ①-㊿格式的符号
            let content = match[4].trim();
            
            // 清理内容，移除开头的中英文冒号、逗号等
            content = content.replace(/^[：:，,。\.\s]+/, '').replace(/[，,。\.\s]+$/, '');
            
            if (content && content.length > 0) {
                // 根据匹配到的类型存储到映射表
                if (numberBracket) {
                    translationMap[numberBracket] = content;
                } else if (numberParenthesis) {
                    translationMap[numberParenthesis] = content;
                } else if (symbol) {
                    translationMap[symbol] = content;
                }
            }
        }
    } catch (error) {
        console.error("构建译文映射表时出错:", error);
    }
    
    return translationMap;
}