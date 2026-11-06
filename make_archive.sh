#!/bin/bash

# Проверка аргумента
if [ -z "$1" ]; then
    echo "Использование: $0 <путь_к_папке>"
    echo "Пример: $0 /home/evgen/Projects/odt_processor"
    echo "       $0 odt_processor"
    exit 1
fi

FOLDER_PATH="$1"

# Проверка, что папка существует
if [ ! -d "$FOLDER_PATH" ]; then
    echo "ОШИБКА: Папка '$FOLDER_PATH' не найдена."
    exit 1
fi

# Извлекаем имя папки (без пути)
FOLDER_NAME=$(basename "$FOLDER_PATH")
# Получаем абсолютный путь к родительской папке (чтобы tar мог корректно работать)
PARENT_DIR=$(cd "$(dirname "$FOLDER_PATH")" && pwd)

# Файлы создаём в ТЕКУЩЕЙ папке (откуда запущен скрипт)
ARCHIVE="${FOLDER_NAME}.tar.gz"
EXTRACT_SCRIPT="${FOLDER_NAME}_extract.sh"
FILE_LIST="${FOLDER_NAME}_list.txt"

# Проверка на недопустимые символы (для NTFS)
echo "Проверка имён файлов на наличие двоеточий..."
if find "$FOLDER_PATH" -name "*:*" | head -1 | grep -q .; then
    echo "ВНИМАНИЕ: В папке есть файлы с двоеточием в имени. При распаковке на NTFS они не сохранятся!"
    echo "Найдены:"
    find "$FOLDER_PATH" -name "*:*" | head -5
    echo "Продолжаю архивацию (автоматически)."
fi

# Создаём архив (переходим в родительскую папку, чтобы внутри архива были относительные пути)
echo "Создаю архив: $ARCHIVE"
(cd "$PARENT_DIR" && tar czf "$OLDPWD/$ARCHIVE" "$FOLDER_NAME")

# Создаём список файлов внутри архива
echo "Создаю список файлов: $FILE_LIST"
tar -tzf "$ARCHIVE" > "$FILE_LIST"

# Создаём скрипт-разархиватор
echo "Создаю скрипт-разархиватор: $EXTRACT_SCRIPT"
cat > "$EXTRACT_SCRIPT" <<EOF
#!/bin/bash
# Автоматически созданный скрипт для распаковки архива $ARCHIVE
echo "Распаковываю $ARCHIVE..."
tar xzf "$ARCHIVE"
echo "Готово! Папка '$FOLDER_NAME' восстановлена."
EOF

# Делаем скрипт исполняемым
chmod +x "$EXTRACT_SCRIPT"

echo "Готово! Созданы:"
echo "  - $ARCHIVE (архив)"
echo "  - $FILE_LIST (список файлов)"
echo "  - $EXTRACT_SCRIPT (скрипт-разархиватор)"

