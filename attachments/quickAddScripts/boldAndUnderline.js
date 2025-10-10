// 正确的 QuickAdd 脚本 - 添加星号包围文本
module.exports = async (params) => {
    const { app } = params;
    
    // 获取当前编辑器
    const editor = app.workspace.activeEditor?.editor;
    if (!editor) {
        console.log("没有找到活跃的编辑器");
        return;
    }
    
    // 获取选中的文本
    const selection = editor.getSelection();
    if (!selection) {
        console.log("请先选择文本");
        return;
    }
    
    // 分析文本的前导空格和尾随空格
    const leadingSpaces = selection.match(/^\s*/)[0];
    const trailingSpaces = selection.match(/\s*$/)[0];
    const content = selection.slice(leadingSpaces.length, selection.length - trailingSpaces.length);
    
    // 构建新文本：前导空格 + *** + 内容 + *** + 尾随空格
    const newText = `${leadingSpaces}***${content}***${trailingSpaces}`;
    
    // 替换选中的文本
    editor.replaceSelection(newText);
    
    console.log("已成功添加星号包围文本");
};