package org.example.springcloud;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class DateTimeTest {
    public static void main(String[] args) {

        Date date = new Date();
        date.setTime(-259059600000L);
        System.out.println(date);

        String date_time = "10/17/1961 00:00:00";
        SimpleDateFormat dateParser = new SimpleDateFormat("MM/dd/yy HH:mm:ss");
        {
            try {
                TimeZone.setDefault(TimeZone.getTimeZone("GMT+08"));
                Date date2 = dateParser.parse(date_time);
                System.out.println(date.getTime());

                SimpleDateFormat dateFormatter = new SimpleDateFormat("MM/dd/yy");
                System.out.println(dateFormatter.format(date2));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

//import java.time.*;
//public class Test {
//    public static void main(String[] args) {
//        // from java.util.Date:          -259059600L
//        // from java.time.LocalDateTime: -259056000
//        LocalDateTime date = LocalDateTime.ofEpochSecond(-259056000L, 0, ZoneOffset.of("+08:00"));
//        System.out.println(date);
//        //1961-10-17T00:00
//        LocalDateTime lt = LocalDateTime.parse("1961-10-17T00:00:00.00");
//        System.out.println("LocalDateTime : "+ lt.toEpochSecond(ZoneOffset.of("+08:00")));
//        //LocalDateTime : -259056000
//    }
//}

//import org.joda.time.DateTime;
//import org.joda.time.format.DateTimeFormat;
//public class Test {
//    public static void main(String[] args) {
//        // joda org.joda.time.DateTime: -259056000000
//        DateTime datetime = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss").parseDateTime("1961-10-17 00:00:00");
//        System.out.println(datetime);
//        System.out.println(datetime.getMillis());
////        1961-10-17T00:00:00.000+08:00
////        -259056000000
//    }
//}

