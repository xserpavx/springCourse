package org.example.app.services;

import java.io.File;
import java.io.FileFilter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by roland on 23.07.2018.
 */
public class FileService {

    public static void deleteAllFilesFolder(String path) {
        for (File myFile : new File(path).listFiles())
           delete(myFile);
    }

    /**
     *  Рекурсивно удаляет файлы и папки
     * @param file
     */
    public static void delete(File file) {
        if(!file.exists())
            return;
        if(file.isDirectory())
        {
            for(File f : file.listFiles())
                delete(f);
            file.delete();
        }
        else
        {
            file.delete();
        }
    }

    /**
     * Проверяет корректность пути, при необходимости создает его. Имени файла в пути быть не должно
     * @param filePath Проверяемый путь
     */
    public static void checkPath(String filePath) {
        checkPath(filePath, false);

    }

    /**
     * Проверяет корректность пути, при необходимости создает его
     * @param filePath Проверяемый путь
     * @param fileNameIn true если в проверяемом пути есть имя файла
     */
    public static void checkPath(String filePath, boolean fileNameIn) {
        File path = fileNameIn ? new File(new File(filePath).getParent()) : new File(filePath);
        if (!path.exists()) {
            path.mkdirs();
        }
    }

    /**
     * Генерирует префикс к имени файла в виде год-месяц-день-час-минута-секунда
     * @return
     */
    public static String getDateTime4FileName() {
        return getDateTime4FileName(new Date());
    }

    public static String getDateTime4FileName(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
        return sdf.format(date);
    }

    public static String checkFileName(String fileName) {
        fileName = fileName.replaceAll("[ |]", "_");
        fileName = fileName.replaceAll("[*?]", "");
        fileName = fileName.replaceAll("[\"]", "'");
        fileName = fileName.replaceAll("[<]", "(");
        fileName = fileName.replaceAll("[>]", ")");
        return fileName.replaceAll("[\\/:\\\\]", "-");
    }


    /** Возвращает список папок внутри указанной. Не рекурсивная!
     * @param path путь к папке
     * @param absolute флаг возвращения абсолютных путей. Если false возвращает пути относительно path
     * @return
     */
    public static ArrayList<String> getFoldersList(String path, boolean absolute) {
        ArrayList<String> result = new ArrayList();
        File[] directories = new File(path)
                .listFiles(new FileFilter() {
                    @Override
                    public boolean accept(File pathname) {
                        return pathname.isDirectory();
                    }
                });
        for (File dir : directories) {
            result.add(absolute ? dir.getAbsolutePath() : dir.getName());
        }
        return result;
    }

    public static ArrayList<String> getFilesList(String path, boolean absolute) {
        return getFilesList(path, "*", absolute);
    }


    /** Получение списка файлов из директории по маске
     * @param path Путь к папке
     * @param mask маска файла. допускаются буквы, символ *, расширение файла отделено точкой
     * @param absolute если true - возвращается абсолютный путь к файлу. Если false - относительно path
     * @return
     */
    public static ArrayList<String> getFilesList(String path, String mask, boolean absolute) {
        mask = mask.replace(".", "\\.").replace("*", ".*");
        final Pattern pattern = Pattern.compile(mask);

        ArrayList<String> result = new ArrayList();
        File[] files = new File(path)
                .listFiles(new FileFilter() {
                    @Override
                    public boolean accept(File pathname) {
                        Matcher matcher = pattern.matcher(pathname.getName());
                        return !pathname.isDirectory() && matcher.matches();
                    }
                });
        for (File dir : files) {
            result.add(absolute ? dir.getAbsolutePath() : dir.getName());
        }
        return result;
    }


    /** Определяет корневую папку для относительного пути
     * @param path относительный путь
     * @return имя корневой папки
     */
    public static String getRootFolder(String path) {
        Path root = Paths.get(path);
        while (root.getParent() != null) {
            root = root.getParent();
        }
        return root.toString();

    }
}
