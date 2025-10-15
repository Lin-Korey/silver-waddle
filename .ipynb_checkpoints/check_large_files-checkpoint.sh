#!/bin/bash

# 设置文件大小限制（单位：字节）
SIZE_LIMIT=104857600  # 100MB

echo "开始检查文件大小，限制为 ${SIZE_LIMIT} 字节..."

# 检查当前目录及子目录下所有文件
find . -type f -size +${SIZE_LIMIT}c | while read -r file; do
    # 获取文件大小，使用 bc 处理可能超过数字最大值的情况
    file_size=$(du -b "$file" | cut -f1)
    if [ "$file_size" -gt "${SIZE_LIMIT}" ]; then
        echo "文件 $file 超过大小限制: $(du -sh "$file")"
        # 自动选择 y 忽略文件
        git update-index --assume-unchanged "$file"
        if [ $? -eq 0 ]; then
            echo "已忽略文件 $file"
        else
            echo "警告：忽略文件 $file 失败！"
            exit 1
        fi
    else
         # 文件大小符合要求
         echo "文件 $file 在大小限制内: $(du -sh "$file")"
    fi
done

echo "检查完成。"
echo "检查并更新 .gitignore (如果需要)..."
# 检查是否需要将此脚本或大文件模式添加到 .gitignore
# 这里只是示例逻辑，你可以根据需要调整
if [[ -f .gitignore ]]; then
    # 检查 .gitignore 是否已经包含脚本或类似规则
    if ! grep -q "check_large_files.sh" .gitignore; then
         echo "检查到 check_large_files.sh 未被忽略，将其添加到 .gitignore..."
         echo "check_large_files.sh" >> .gitignore
    fi
    if ! grep -q ".*\>\${SIZE_LIMIT}c" .gitignore; then
         echo "检查到类似 '.*\>\${SIZE_LIMIT}c' 的规则未被忽略，将其添加到 .gitignore..."
         echo ".*\>\${SIZE_LIMIT}c" >> .gitignore
         echo "注意：添加了通配符规则，请确认是否正确。"
    fi
else
    echo "未找到 .gitignore，创建 .gitignore 并添加 check_large_files.sh..."
    echo "check_large_files.sh" > .gitignore
    echo ".*\>\${SIZE_LIMIT}c" >> .gitignore
    echo "注意：添加了通配符规则，请确认是否正确。"
fi
echo "Gitignore 检查/更新完成。"

echo "如果需要，请手动检查 .gitignore 内容。"
# 确认是否继续
read -p "脚本运行完毕。是否继续进行 git add . 和 git push? [y/n]: " push_choice
case "$push_choice" in
    [Yy]* )
        echo "添加所有文件到暂存区..."
        git add .
        if [ $? -eq 0 ]; then
            echo "正在提交更改..."
            git commit -m "自动忽略超过 ${SIZE_LIMIT} 字节的大文件"
            echo "正在尝试推送..."
            git push
            if [ $? -eq 0 ]; then
                echo "成功推送！"
            else
                echo "推送失败。"
            fi
        else
            echo "添加文件失败。"
        fi
        ;;
    [Nn]* )
        echo "已取消。请手动执行 git add . 和 git commit。"
        ;;
    * )
        echo "无效输入，请输入 y 或 n"
        ;;
esac
