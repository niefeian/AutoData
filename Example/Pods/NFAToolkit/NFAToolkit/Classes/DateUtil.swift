//
//  DateUtil.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation

open class DateUtil {
      
    public static  let zodiacs: [String] = ["鼠年", "牛年", "虎年", "兔年", "龙年", "蛇年", "马年", "羊年", "猴年", "鸡年", "狗年", "猪年"]
    public static let heavenlyStems: [String] = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    public static let earthlyBranches: [String] = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    public static let timeodaa = ["00:00-00:59早子","01:00-02:59丑时","03:00-04:59寅时","05:00-06:59卯时","07:00-08:59辰时","09:00-10:59巳时","11:00-12:59午时","13:00-14:59未时","15:00-16:59申时","17:00-18:59酉时","19:00-20:59戌时","21:00-22:59亥时","23:00-23:59晚子"]
    
     public static let chineseTimedate = ["早子","丑时","丑时","寅时","寅时","卯时","卯时","辰时","辰时","巳时","巳时","午时","午时","未时","未时","申时","申时","酉时","酉时","戌时","戌时","亥时","亥时","晚子"]
    
    
    public static let chineseMonths = ["正月","二月","三月","四月", "五月", "六月", "七月", "八月","九月", "十月", "冬月", "腊月"]
    public static let chineseDays = [ "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十","十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十","廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    //星座国外
    public static let usazodiacs = ["白羊座","金牛座","双子座","巨蟹座","狮子座","处女座","天秤座","天蝎座","射手座","摩羯座","水瓶座","双鱼座"]
    
    
      /// 时间差：客户端与服务器的时间差,采用服务端-客户端
      fileprivate static var timediff : TimeInterval = 0
      
      open class func calcTimeDiff(_ servtime : Double, beginCall : Double) {
          let client_seconds = Date().timeIntervalSince1970 * 1000
          timediff = servtime - beginCall - (client_seconds - beginCall) / 2
      }
      
      /// 获取到1970年的时间差。注意，这个独立成一个方法主要是需要包含服务端与客户端的时间差
      open class func getTimeSince1970() -> TimeInterval {
          //+客户端与服务端时间差
          return Date().timeIntervalSince1970 + timediff/1000
      }
      
      open class func getTimeStamp() -> TimeInterval {
          return Date().timeIntervalSince1970 * 1000 + timediff
      }
      
      /// 当前时间。加上了客户端与服务端的时间差
      open class func curDate() -> Date {
          return Date(timeIntervalSince1970: getTimeSince1970())
      }
      
      /// 2016年起点
      open class func time2016() -> Date {
          return dateTimeFromStr("2015-01-01 00:00:00")
      }
      
      /// 获取年月日...秒的时间
      open class func dateTimeToStr(_ date : Date) -> String {
          
          return formatDateToStr(date, format: "yyyy-MM-dd HH:mm:ss")
      }
      
      
      open class func dateTimeToStr2(_ date : Date) -> String {
          
          return formatDateToStr(date, format: "yyyy年MM月dd日 HH:mm:ss")
      }
      
      
      /// 获取年月日的时间
      open class func dateToStr(_ date : Date) -> String {
          return formatDateToStr(date, format: "yyyy-MM-dd")
      }
    
    
    open class func  deltasCalculated(_ maxDate : Date , _ date : Date) -> (Int,Int,Int) {
        
        let dateStrings = dateToStr(date).components(separatedBy: "-")
        let maxdateStrings = dateToStr(maxDate).components(separatedBy: "-")
        if dateStrings.count == 3
        {
            let oldYear = Int(dateStrings[0]) ?? 2020
            let oldMonth = Int(dateStrings[1]) ?? 1
            let oldDay = Int(dateStrings[2]) ?? 2
            
            var maxYear = Int(maxdateStrings[0]) ?? 2020
            var maxMonth = Int(maxdateStrings[1]) ?? 1
            let maxDay = Int(maxdateStrings[2]) ?? 2
            
            var dayNum = 0
            var monthNum = 0
            if maxDay < oldDay
            {
                dayNum = maxDay + reDayCount(maxYear, maxMonth) - oldDay
                maxMonth -= 1
            }
            else
            {
               dayNum = maxDay - oldDay
            }
            
            if maxMonth < oldMonth
            {
                 monthNum = maxMonth - oldMonth + 12
                maxYear -= 1
            }
            else
            {
              monthNum = maxMonth - oldMonth
            }
            
            return (maxYear-oldYear,monthNum,dayNum)
            
        }
        return (0,0,0)
    }
    
    open class func getYMD(_ date : Date) -> (Int,Int,Int) {
        let dateStrings = dateToStr(date).components(separatedBy: "-")
        if dateStrings.count == 3
        {
            let oldYear = Int(dateStrings[0]) ?? 2020
            let oldMonth = Int(dateStrings[1]) ?? 1
            let oldDay = Int(dateStrings[2]) ?? 2
            return (oldYear,oldMonth,oldDay)
        }
         return (2020,1,1)
    }
    
    open class func addDateToStr(_ date : Date , year : Int = 0, month : Int = 0 , day : Int = 0 ) -> Date {
        let dateStrings = dateToStr(date).components(separatedBy: "-")
        if dateStrings.count == 3
        {
             var oldYear = Int(dateStrings[0]) ?? 2020
             var oldMonth = Int(dateStrings[1]) ?? 1
             let oldDay = Int(dateStrings[2]) ?? 2
            
            //日期转换成增加了多少的年月日
            func dayCarry(_ surplusDay : Int , carryMonth : Int = 0 , carryYear : Int = 0)->(Int,Int,Int)
            {
                if surplusDay > 0 && reDayCount(oldYear+carryYear, oldMonth+carryMonth) < surplusDay
                {
                    return dayCarry(surplusDay - reDayCount(oldYear+carryYear, oldMonth+carryMonth), carryMonth: carryMonth + 1, carryYear: carryYear + 1)
                }
                else
                {
                    return (surplusDay,carryMonth,carryYear)
                }
            }
            
            let days = dayCarry(oldDay+day, carryMonth: 0, carryYear: 0)
            let maxMonth = oldMonth + days.1 + month
            oldMonth = (maxMonth - 1 )%12 + 1
            oldYear = Int(floor(Double(maxMonth/12))) + year + oldYear
            return dateFromStr("\(oldYear)-\(getDayString(oldMonth))-\(getDayString(days.0))")
        }
        return date
    }
    
    
    open class func getDayString(_ day : Int) -> String {
        return day < 10 ?  "0\(day)" : "\(day)"
    }
    
    
    //根据年月获得当月共多少天
       
      
      open class func dateToStrCN(_ date : Date) -> String {
          return formatDateToStr(date, format: "yyyy年MM月dd")
      }
      
      open class func dateToStrCNM(_ date : Date) -> String {
          
          return formatDateToStr(date, format: "yyyy年MM月")
      }
      
      /// 获取格式化的日期
      open class func formatDateToStr(_ date : Date, format : String) -> String {
          let df = DateFormatter()
          df.dateFormat = format
          return df.string(from: date)
      }
      
      /// 文本转时间
      open class func dateTimeFromStr(_ strDate : String) -> Date {
          return formatStrToDate(strDate, format: "yyyy-MM-dd HH:mm:ss")
      }
      
      open class func dateTimeFromStrCND(_ strDate : String) -> Date {
          return formatStrToDate(strDate, format: "yyyy年MM月dd")
      }
      
      open class func dateFromStr(_ strDate : String) -> Date {
          return formatStrToDate(strDate, format: "yyyy-MM-dd")
      }
      
      open class func formatStrToDate(_ strDate : String, format : String) -> Date {
          let fmt = DateFormatter()
          fmt.dateFormat = format
          return fmt.date(from: strDate)!
      }
      
           /// 转换秒成时间格式
      open class func transTimeIntervalToYYYYMMDD(_ curTimes : TimeInterval , showAll : Bool = false) -> String{
            let h = Int(curTimes / 3600)
            var t = ""
            if h > 0 {
                if h > 0 && h < 10 {
                    t = "0\(h):"
                } else {
                    t = "\(h):"
                }
            }
            else if showAll
            {
               t = "00:"
            }
            let min = Int((Int(curTimes) - h * 3600) / 60)
            if min > 0 {
                if min < 10 {
                    t += "0\(min):"
                } else {
                    t += "\(min):"
                }
            } else if t != "" {
                t += "00:"
            }
            
            let sec = Int(curTimes.truncatingRemainder(dividingBy: 60))
            if sec > 0 {
                if sec < 10 {
                    t += "0\(sec)"
                } else {
                    t += "\(sec)"
                }
            } else if t != "" {
                t += "00"
            }
            return t
        }
      
      /// 获取显示的时间：传入毫秒数
      open class func getShowTimeWithMillisecond(_ toTime : Double) -> String{
          return getShowTime(toTime / 1000)
      }
      
      /// 传入秒数
      open class func getShowTime(_ toTime : Double, simpleDateFormat : String = "MM/dd") -> String{
          // 比较时间
          let toDateTime = Date(timeIntervalSince1970: toTime)
          let toDate = DateUtil.formatDateToStr(toDateTime, format : "yyyy/MM/dd")
          // 当前日期
          let curDateTime = DateUtil.curDate()
          let curDate = DateUtil.formatDateToStr(curDateTime, format : "yyyy/MM/dd")
          
          if toDate == curDate {
              // 同一天
              return DateUtil.formatDateToStr(toDateTime, format : "HH:mm")
          } else {
              if (toDate.prefix(5) == curDate.prefix(5)) {
                  // 同一年
                  return DateUtil.formatDateToStr(toDateTime, format : simpleDateFormat)
              } else {
                  return toDate
              }
          }
      }
      
      
      /// 获得显示显示：原始格式：yyyyMMddHHmmss。
      /// 刚刚、xx分钟前、xx小时前、同一年的显示月-日，最后yyyy/MM/dd
      open class func getShowTime2(_ time : String, format : String = "yyyyMMddHHmmss") -> String{
          let dateTime = DateUtil.formatStrToDate(time, format: format)
          let curDate = DateUtil.formatDateToStr(dateTime, format : "yyyy/MM/dd")
          let today = DateUtil.curDate()
          let date = DateUtil.formatDateToStr(today, format : "yyyy/MM/dd")
          var ret : String!
          if date == curDate {
              // 同一天
              let oldTime = DateUtil.formatStrToDate(time, format: format).timeIntervalSince1970
              let nowTime = getTimeSince1970()
              let sub = nowTime - oldTime
              if sub < 60 {
                  ret = "刚刚"
              } else if sub < 60 * 60 {
                  ret = "\(Int(sub / 60))分钟前"
              } else {
                  ret = "\(Int(sub / 3600))小时前"
              }
          } else {
              if (date.prefix(5) == curDate.prefix(5)) {
                  // 同一年
                  ret = DateUtil.formatDateToStr(dateTime, format : "MM-dd")
              } else {
                  ret = curDate
              }
          }
          return ret
      }
      
      /// 返回MM-dd HH:mm 格式
      open class func getShowDateTime(_ time : String, format : String = "yyyyMMddHHmmss") -> String{
          let dateTime = DateUtil.formatStrToDate(time, format: format)
          let curDate = DateUtil.formatDateToStr(dateTime, format : "yyyy/MM/dd")
          let today = DateUtil.curDate()
          let date = DateUtil.formatDateToStr(today, format : "yyyy/MM/dd")
          var ret : String!
          if (date.prefix(5) == curDate.prefix(5)) {
              // 同一年
              ret = DateUtil.formatDateToStr(dateTime, format : "MM-dd HH:mm")
          } else {
              ret = curDate
          }
          
          return ret
      }
      
      /// 获得显示显示：原始格式：yyyyMMddHHmmss
      open class func getShowTime(_ time : String, format : String = "yyyyMMddHHmmss") -> String{
          let dateTime = DateUtil.formatStrToDate(time, format: format)
          let curDate = DateUtil.formatDateToStr(dateTime, format : "yyyy/MM/dd")
          let today = DateUtil.curDate()
          let date = DateUtil.formatDateToStr(today, format : "yyyy/MM/dd")
          var ret : String!
          if date == curDate {
              // 同一天
              let oldTime = DateUtil.formatStrToDate(time, format: format).timeIntervalSince1970
              let nowTime = getTimeSince1970()
              let sub = nowTime - oldTime
              if sub < 60 {
                  ret = "刚刚"
              } else if sub < 60 * 60 {
                  ret = "\(Int(sub / 60))分钟前"
              } else {
                  ret = "\(Int(sub / 3600))小时前"
              }
          } else {
              if (date.prefix(5) == curDate.prefix(5)) {
                  // 同一年
                  ret = DateUtil.formatDateToStr(dateTime, format : "MM月dd日 HH:mm")
              } else {
                  ret = curDate
              }
          }
          return ret
      }
    
    open class func dateToStrt(_ date : Date) -> String {
           return formatDateToStr(date, format: "yyyy-MM-dd-HH")
    }
      
      open class func startOfThisWeek() -> Date {
          let date = Date()
          let calendar = NSCalendar.current
          let components = calendar.dateComponents(
              Set<Calendar.Component>([.yearForWeekOfYear, .weekOfYear]), from: date)
          let startOfWeek = calendar.date(from: components)!
          return startOfWeek
      }
      
      open class func endOfThisWeek(returnEndTime:Bool = false) -> Date {
          let calendar = NSCalendar.current
          var components = DateComponents()
          if returnEndTime {
              components.day = 7
              components.second = -1
          } else {
              components.day = 6
          }
          
          let endOfMonth =  calendar.date(byAdding: components, to: startOfThisWeek())!
          return endOfMonth
      }
      
      //本月开始日期
      open class func startOfCurrentMonth() -> Date {
          let date = Date()
          let calendar = NSCalendar.current
          let components = calendar.dateComponents(
              Set<Calendar.Component>([.year, .month]), from: date)
          let startOfMonth = calendar.date(from: components)!
          return startOfMonth
      }
      
      //本月结束日期
      open class func endOfCurrentMonth(returnEndTime:Bool = false) -> Date {
          let calendar = NSCalendar.current
          var components = DateComponents()
          components.month = 1
          if returnEndTime {
              components.second = -1
          } else {
              components.day = -1
          }
          
          let endOfMonth =  calendar.date(byAdding: components, to: startOfCurrentMonth())!
          return endOfMonth
      }
      
      
      open class func currentMonth()->String{
          let startOfMonth = self.dateToStrCN(startOfCurrentMonth())
          let endOfMonth = self.dateToStrCN(endOfCurrentMonth())
          return startOfMonth + "日-" + endOfMonth.subString(start: endOfMonth.count-2, length: 2)
      }
      
      open class func thisWeek()->String{
          let startOfMonth = self.dateToStrCN(startOfThisWeek())
          let endOfMonth = self.dateToStrCN(endOfThisWeek())
          return startOfMonth + "日-"  + endOfMonth.subString(start: endOfMonth.count-2, length: 2)
      }
      
      open class func currentYear()->String{
          let startOfMonth = self.dateToStrCN(startOfCurrentYear())
          let endOfMonth = self.dateToStrCN(endOfCurrentYear())
          return startOfMonth + "日-"  + endOfMonth.subString(start: endOfMonth.count-5, length: 5)
      }
      
      //本年开始日期
      open class func startOfCurrentYear() -> Date {
          let date = Date()
          let calendar = NSCalendar.current
          let components = calendar.dateComponents(Set<Calendar.Component>([.year]), from: date)
          let startOfYear = calendar.date(from: components)!
          return startOfYear
      }
      
      //本年结束日期
      open class func endOfCurrentYear(returnEndTime:Bool = false) -> Date {
          let calendar = NSCalendar.current
          var components = DateComponents()
          components.year = 1
          if returnEndTime {
              components.second = -1
          } else {
              components.day = -1
          }
          
          let endOfYear = calendar.date(byAdding: components, to: startOfCurrentYear())!
          return endOfYear
      }
      
      open class func erayWeekOfYear2(_ date : Date) -> String {
          let calendar: Calendar = Calendar(identifier: .gregorian)
          return  " 【\(calendar.component(.weekOfYear, from: date))周】" + featureWeekday(date).replacingOccurrences(of: "星期", with: "周")
      }
      
    open class func featureWeekday(_ date : Date) -> String {
          let calendar = Calendar.current
          let weekDay = calendar.component(.weekday, from: date)
          switch weekDay {
          case 1:
              return "星期日"
          case 2:
              return "星期一"
          case 3:
              return "星期二"
          case 4:
              return "星期三"
          case 5:
              return "星期四"
          case 6:
              return "星期五"
          case 7:
              return "星期六"
          default:
              return ""
          }
      }
      
      open class func erayWeekOfYear(_ date : Date) -> String {
          let calendar: Calendar = Calendar(identifier: .gregorian)
          return  " 第 \(calendar.component(.weekOfYear, from: date)) 周 " +  featureWeekday(date)
      }
      
      open class func erayAll(_ date : Date) -> String {
          let calendar: Calendar = Calendar(identifier: .chinese)
          return era(year: calendar.component(.year, from: date)) + zodiac(date) + " " + era(year: calendar.component(.month, from: date)) + "月 "  +   era(year: calendar.component(.day, from: date)) + "日"
      }
      
      private class func era(year: Int) -> String {
          
          let heavenlyStemIndex: Int = (year - 1) % heavenlyStems.count
          let heavenlyStem: String = heavenlyStems[heavenlyStemIndex]
          
          let earthlyBrancheIndex: Int = (year - 1) % earthlyBranches.count
          let earthlyBranche: String = earthlyBranches[earthlyBrancheIndex]
          return heavenlyStem + earthlyBranche
      }
      
      // 生肖
      open class func zodiac(_ date : Date) -> String {
          let calendar: Calendar = Calendar(identifier: .chinese)
          return zodiac(year: calendar.component(.year, from: date))
      }
      
      private class  func zodiac(year: Int) -> String {
          let zodiacIndex: Int = (year - 1) % zodiacs.count
          return zodiacs[zodiacIndex]
      }
      
    open class func reDayCount(_ year : Int ,_ month : Int) -> Int {
        if [1,3,5,7,8,10,12].contains(month){
          return 31
        }else if month == 2 {
          if year%4 == 0 {
              return 29
          }else{
              return 28
          }
        } else {
          return 30
        }
    }
}
