package com.example.demo.services;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by roland on 13-01-2016.
 */

public class Money {
    private enum enumHundred {сто, двести, триста, четыреста, пятьсот, шестьсот, семьсот, восемьсот, девятьсот}
    private enum enumTen {десять, двадцать, тридцать, сорок, пятьдесят, шестьдесят, семьдесят, восемьдесят, девяносто}
    private enum enumTenAfter {десять, одиннадцать, двенадцать, тринадцать, четырнадцать, пятнадцать, шестнадцать, семнадцать, восемнадцать, девятнадцать}
    private enum enumOneFemale {одна, две}
    private enum enumOneCommon {один, два, три, четыре, пять, шесть, семь, восемь, девять}
    private static String[][] endings = {
            {"рублей", "рубль", "рубля", "рубля", "рубля", "рублей", "рублей", "рублей", "рублей", "рублей"},
            {"тысяч", "тысяча", "тысячи", "тысячи", "тысячи", "тысяч", "тысяч", "тысяч", "тысяч", "тысяч"},
            {"миллионов", "миллион", "миллиона", "миллиона", "миллиона", "миллионов", "миллионов", "миллионов", "миллионов", "миллионов"},
            {"миллиардов", "миллиард", "миллиарда", "миллиарда", "миллиарда", "миллиардов", "миллиардов", "миллиардов", "миллиардов", "миллиардов"}};
    private static String[] fractEndings = {"копеек", "копейка", "копейки", "копейки", "копейки", "копеек", "копеек", "копеек", "копеек", "копеек"};

    /** Получаем окончание слова при перечислении. Например одна книгА две книгИ, одиннадцать книг
     * @param count Числительное, для которого надо получить окончание
     * @param firstEnding окончание которое используется при значениях оканчивающихся на 1, кроме 11
     * @param secondEnding окончание которое используется при значениях оканчивающихся на 2, 3, 4 кроме 12-14 и т.д.
     * @param thirdEnding окончание которое используется при значениях оканчивающихся на 0, 5, 6, 7, 8, 9 и в интервале 11-19
     * @return окончание слова для числительного @count
     */
    private static String getEnding(int count, String firstEnding, String secondEnding, String thirdEnding) {
        if (count <= 10) {
            switch (count) {
                case 1: return firstEnding;
                case 2: case 3: case 4: return secondEnding;
                default: return thirdEnding;
            }
        }
        else if (count > 10 && count < 20) {
            return thirdEnding;
        } else {
            switch (count % 10) {
                case 1: return firstEnding;
                case 2: case 3: case 4: return secondEnding;
                default: return thirdEnding;
            }
        }
    }

    private static String intText(int value) {
        return String.format("Рубл%s", getEnding(value, "ь", "я", "ей"));
    }

    private static String fractText(int value) {
        return String.format("Коп%s", getEnding(value, "ейка", "ейки", "еек"));
    }

    public static String money2DigitsText(BigDecimal value) {
        value = value.setScale(2, RoundingMode.HALF_UP);
        int left = value.intValue();
        int right = value.subtract(new BigDecimal(left).setScale(0, RoundingMode.HALF_UP)).movePointRight(2).intValue();

        return String.format("%d %s %d %s", left, intText(left), right, fractText(right));
    }

    public static String money2Text(BigDecimal Value) {
        ArrayList<String> digits = new ArrayList<String>();
        String intPart;
        String fractRart;
        String triade;        String text = "";
        // Разделяем число на целую и дробную часть
        Pattern pattern = Pattern.compile("(\\d+)?[.|,]?(\\d{0,2})?.*$");
        Matcher matcher = pattern.matcher(Value.toString());
        if (matcher.matches()) {
            intPart = (matcher.group(1) != null) ? matcher.group(1): "";
            fractRart = (matcher.group(2) != null) ? matcher.group(2): "";

            // Преобразуем целую часть числа в текст
            while (intPart.length() != 0) {
                pattern = Pattern.compile("(\\d*?)?(\\d{1,3})$");
                matcher = pattern.matcher(intPart.toString());
                if (matcher.matches()) {
                    intPart = (matcher.group(1) != null) ? matcher.group(1) : "";
                    if (matcher.group(2) != null) {
                        digits.add(matcher.group(2));
                    }
                } else {
                    intPart = "";
                }
            }
            for (int i = 0; i <= digits.size() - 1 ; i++) {
                text = String.format("%s %s", integer2Text(digits.get(i), i), text);
            }

            // Преобразуем дробную часть числа в текст
            text = String.format("%s%s", text, (fractRart.length() != 0) ? fract2Text(fractRart) : "");
        }
        return String.format("%s%s", text.substring(0,1).toUpperCase(), text.substring(1));
    }

    // Перевод в текст младшего разряда триады (единиц)
    private static String one2Text(Integer Value, Boolean male) {
        return (--Value < 0) ? "" : String.format("%s", (Value == 0 || Value == 1) ? (male) ? enumOneCommon.values()[Value].toString() : enumOneFemale.values()[Value].toString() : enumOneCommon.values()[Value].toString());
    }

    // Перевод в текст среднего и младшего разряда триады (десятков)
    private static String ten2Text(Integer ten, Integer one, Boolean male) {
        return (ten == 1) ? String.format("%s", enumTenAfter.values()[one].toString()) : (--ten < 0) ? String.format("%s", one2Text(one, male)) : String.format("%s %s", enumTen.values()[ten].toString(), one2Text(one, male));
    }

    // Перевод в текст старшего разряда триады (сотен)
    private static String hundred2Text(Integer Value) {
        return (--Value < 0) ? "" : String.format("%s", enumHundred.values()[Value].toString());
    }

    private static String triade2Text(String Value, Integer level) {
        String text = "";
        Integer one = -1;
        Integer ten = -1;
        Integer thousand = -1;
        switch (Value.length()) {
            case 1:
                one = Integer.parseInt(Value.substring(0, 1));
                text = one2Text(one, level != 1);
            break;
            case 2:
                one = Integer.parseInt(Value.substring(1, 2));
                ten = Integer.parseInt(Value.substring(0, 1));
                text = String.format("%s", ten2Text(ten, one, level != 1));
            break;
            case 3:
                one = Integer.parseInt(Value.substring(2, 3));
                ten = Integer.parseInt(Value.substring(1, 2));
                thousand = Integer.parseInt(Value.substring(0, 1));
                text = String.format("%s %s", hundred2Text(thousand), ten2Text(ten, one, level != 1));
            break;
        }

        if (text.length() != 0 || level == 0) {
            if (ten == 1) {
                text = String.format("%s %s", text.trim(), endings[level][0]);
            } else {
                text = String.format("%s %s", text.trim(), endings[level][one]);
            }
        }

        return text.trim();
    }

    // Перевод в текст триады (сотни, тысячи, миллионы, миллиарды)
    private static String integer2Text(String value, Integer level) {
        return (value.length() == 0) ? "" : triade2Text(value, level);
    }

    // Перевод в текст дробной части числа
    private static String fract2Text(String value) {
        String text;
        if (value.length() == 0) {
            text = "";
        } else {
            Integer one = Integer.parseInt(value.substring(value.length() - 1, value.length()));
            Integer ten = (value.length() > 1) ? Integer.parseInt(value.substring(value.length() - 2, value.length() - 1)) : 0;
            if (ten == 1) {
                text = String.format("%s %s", value, fractEndings[0]);
            } else {
                text = String.format("%s %s", value, fractEndings[one]);
            }
        }
        return text;
    }

}
