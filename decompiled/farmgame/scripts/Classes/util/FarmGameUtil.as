package Classes.util
{
   import Cache.Classes.UI.ZCacheUI;
   import Cache.Interfaces.IZCache;
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.FarmJSONEncoder;
   import Classes.Friend;
   import Classes.Player;
   import Display.GenericXMLDialog;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Tooltips.FarmTextTooltip;
   import by.blooddy.crypto.Base64;
   import by.blooddy.crypto.serialization.JSON;
   import com.adobe.crypto.MD5;
   import com.adobe.serialization.json.JSONDecoder;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import mx.utils.Base64Decoder;
   
   public class FarmGameUtil
   {
      
      public static const SUNDAY:String = "sunday";
      
      public static const MONDAY:String = "monday";
      
      public static const TUESDAY:String = "tuesday";
      
      public static const WEDNESDAY:String = "wednesday";
      
      public static const THURSDAY:String = "thursday";
      
      public static const FRIDAY:String = "friday";
      
      public static const SATURDAY:String = "saturday";
      
      public static const MILLISECONDS:int = 0;
      
      public static const SECONDS:int = 1;
      
      public static const HOURS:int = 3;
      
      public static const DAYS:int = 4;
      
      public static const WEEKS:int = 5;
      
      public static const MONTHS:int = 6;
      
      public static const NUM_MONTHS_IN_YEAR:uint = 12;
      
      public static const NUM_DAYS_IN_WEEK:uint = 7;
      
      public static const NUM_DAYS_IN_MONTH:uint = 30;
      
      public static const NUM_HOURS_IN_DAY:uint = 24;
      
      public static const NUM_MINUTES_IN_DAY:uint = 1440;
      
      public static const NUM_MINUTES_IN_HOUR:uint = 60;
      
      public static const NUM_SECS_IN_WEEK:uint = 604800;
      
      public static const NUM_SECS_IN_DAY:uint = 86400;
      
      public static const NUM_SECS_IN_HOUR:uint = 3600;
      
      public static const NUM_SECS_IN_MINUTE:uint = 60;
      
      public static const NUM_MSECS_IN_DAY:uint = 86400000;
      
      public static const NUM_MSECS_IN_HOUR:uint = 3600000;
      
      public static const NUM_MSECS_IN_MINUTE:uint = 60000;
      
      public static const NUM_MSECS_IN_SECOND:uint = 1000;
      
      public static const KEYBOARD_KEY_SPACE:uint = 32;
      
      public static const KEYBOARD_KEY_ESC:uint = 27;
      
      public static const KEYBOARD_KEY_M:uint = 77;
      
      public static const KEYBOARD_KEY_O:uint = 79;
      
      public static const KEYBOARD_KEY_R:uint = 82;
      
      public static const KEYBOARD_KEY_S:uint = 83;
      
      private static const SANDBOX_OFFSET_X:Number = 20;
      
      private static var m_browserData:String = null;
      
      private static const badWordsList:Array = new Array("shit","fuck","bitch","cunt","sex","s e x","se x","s ex","cock","nigger","nigga","niggger","faggot","fag","tits","titties","boob","breast","penis","vagina","cum","blowjob","asshole","s3x","secks","f u c k","s h i t","orgy","orgies","horny","naked","5ex","camera","web cam","webcam"," cam ","camm","caam","kam","pussy","dick","cheat","cyber","strip","stripper","porn","prostitute","hooker","naughty","dirty","xxx","damn","hell","ass","slut");
      
      public function FarmGameUtil()
      {
         super();
      }
      
      public static function applyPartialStatic(func:Function, args:Array) : Function
      {
         var anonFunc:Function = null;
         anonFunc = function(... params):*
         {
         };
         if(func == null)
         {
            ErrorManager.addError("Cannot bind a null function!");
         }
         else if(!args || args.length < 1)
         {
            ErrorManager.addError("Need at least one argument! If no arguments are needed, then applyPartialStatic isn\'t needed.");
         }
         else
         {
            anonFunc = func;
         }
         return function(... params):*
         {
            return anonFunc.apply(undefined,args.concat(params));
         };
      }
      
      public static function randomizeArray(a:*, b:*) : int
      {
         return Math.random() > 0.5 ? 1 : -1;
      }
      
      public static function getNumericDayFromStringDay(day:String) : int
      {
         var result:int = -1;
         switch(day.toLowerCase())
         {
            case SUNDAY:
               result = 0;
               break;
            case MONDAY:
               result = 1;
               break;
            case TUESDAY:
               result = 2;
               break;
            case WEDNESDAY:
               result = 3;
               break;
            case THURSDAY:
               result = 4;
               break;
            case FRIDAY:
               result = 5;
               break;
            case SATURDAY:
               result = 6;
         }
         return result;
      }
      
      public static function getRandomNum(max:Number, min:Number = 0) : Number
      {
         var result:Number = 0;
         if(max < min)
         {
            result = getRandomNum(min,max);
         }
         else
         {
            result = Math.random() * (max - min) + min;
         }
         return result;
      }
      
      public static function getRandomInt(max:int, min:int = 0) : int
      {
         return Math.round(getRandomNum(max,min));
      }
      
      public static function convertPositionToRankString(rank:int) : String
      {
         var lastDigit:int = 0;
         var suffix:String = "";
         var secondToLastDigit:int = rank / 10 % 10;
         if(secondToLastDigit == 1)
         {
            suffix = "th";
         }
         else
         {
            lastDigit = rank % 10;
            switch(lastDigit)
            {
               case 1:
                  suffix = "st";
                  break;
               case 2:
                  suffix = "nd";
                  break;
               case 3:
                  suffix = "rd";
                  break;
               default:
                  suffix = "th";
            }
         }
         return rank + suffix;
      }
      
      public static function convertMonthNumberToStringMonth(monthNo:int) : String
      {
         var result:String = "";
         var months:Array = ["January ","February","March","April","May","June","July","August","September","October","November","December "];
         if(monthNo >= 0 && monthNo < 12)
         {
            result = months[monthNo];
         }
         return result;
      }
      
      public static function getGlobalServerUTCOffsetHours() : int
      {
         var result:int = Global.farmGameSettingsManager.getInt("globalServerUTCOffsetHours");
         var isDST:Boolean = GlobalEngine.isDST;
         if(!isDST)
         {
            result += 1;
         }
         return result;
      }
      
      public static function synchronizedDateToNumber(dateStr:String) : Number
      {
         var synchronizedOffsetInMsecs:int = getGlobalServerUTCOffsetHours() * NUM_MSECS_IN_HOUR;
         return Utilities.dateToNumber(dateStr,true) + synchronizedOffsetInMsecs;
      }
      
      public static function synchronizedDateTimeToNumber(dateTimeStr:String) : Number
      {
         var synchronizedOffsetInMsecs:int = getGlobalServerUTCOffsetHours() * NUM_MSECS_IN_HOUR;
         var dateTimeArr:Array = String(dateTimeStr).split(" ",2);
         var dateArr:Array = String(dateTimeArr[0]).split("/",3);
         var timeArr:Array = String(dateTimeArr[1]).split(":",3);
         if(timeArr.length < 2)
         {
            timeArr[0] = 0;
            timeArr[1] = 0;
            timeArr[2] = 0;
         }
         else if(timeArr.length == 2)
         {
            timeArr[2] = 0;
         }
         var dateInMs:Number = Date.UTC(parseInt(dateArr[2]),parseInt(dateArr[0]) - 1,parseInt(dateArr[1]),parseInt(timeArr[0]),parseInt(timeArr[1]),parseInt(timeArr[2]));
         return dateInMs + synchronizedOffsetInMsecs;
      }
      
      public static function zeroPad(numString:String, maxLength:Number) : String
      {
         var result:String = numString;
         if(maxLength > 0 && numString.length < maxLength)
         {
            while(result.length < maxLength)
            {
               result = "0" + result;
            }
         }
         return result;
      }
      
      public static function isFeatureInActivePeriod(endDate:String, redeemAdditionalDays:int = 0) : Boolean
      {
         var result:Boolean = false;
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeRemaining -= redeemAdditionalDays * FarmGameUtil.NUM_SECS_IN_DAY;
         if(timeRemaining > 0)
         {
            result = true;
         }
         return result;
      }
      
      public static function parseTimeLeft(timeLeft:Number) : Array
      {
         var numDays:uint = timeLeft / NUM_SECS_IN_DAY;
         var numHours:uint = timeLeft % NUM_SECS_IN_DAY / NUM_SECS_IN_HOUR;
         var numMins:uint = timeLeft % NUM_SECS_IN_HOUR / NUM_SECS_IN_MINUTE;
         var numSecs:uint = timeLeft % NUM_SECS_IN_MINUTE;
         return new Array(numDays,numHours,numMins,numSecs);
      }
      
      public static function parseTimeLeftZLoc(timeLeft:Number) : Array
      {
         var numDays:uint = timeLeft / NUM_SECS_IN_DAY;
         var numHours:uint = timeLeft % NUM_SECS_IN_DAY / NUM_SECS_IN_HOUR;
         var numMins:uint = timeLeft % NUM_SECS_IN_HOUR / NUM_SECS_IN_MINUTE;
         var numSecs:uint = timeLeft % NUM_SECS_IN_MINUTE;
         var timeLeftInUnits:Array = new Array();
         timeLeftInUnits["Days"] = numDays;
         timeLeftInUnits["Hours"] = numHours;
         timeLeftInUnits["Minutes"] = numMins;
         timeLeftInUnits["Seconds"] = numSecs;
         return timeLeftInUnits;
      }
      
      public static function getFormattedTimeLeftText(parsedTime:Array) : String
      {
         var formattedTime:String = "";
         if(parsedTime[0] > 0)
         {
            formattedTime = ZLocUtils.t("FarmGame","General_FriendlyTimeDays",{"days":parsedTime[0] + 1});
         }
         else
         {
            formattedTime = parsedTime[1] + ":" + FarmGameUtil.numberToStringPadZeros(parsedTime[2]) + ":" + FarmGameUtil.numberToStringPadZeros(parsedTime[3]);
         }
         return ZLocUtils.t("Dialogs","TimeLeftSuffix",{"timeStr":formattedTime});
      }
      
      public static function swapItems(array:Array, item1:Object, item2:Object) : void
      {
         var tempItem:Object = null;
         var item1pos:int = array.indexOf(item1);
         var item2pos:int = array.indexOf(item2);
         if(item1pos != -1 && item2pos != -1)
         {
            tempItem = array[item2pos];
            array[item2pos] = array[item1pos];
            array[item1pos] = tempItem;
         }
      }
      
      public static function numberToStringPadZeros(value:Number, digitCount:uint = 2) : String
      {
         var paddedNumber:String = String(value);
         var len:uint = uint(paddedNumber.length);
         while(len < digitCount)
         {
            paddedNumber = "0" + paddedNumber;
            len++;
         }
         return paddedNumber;
      }
      
      public static function numberToBinaryStringPadZeros(value:Number, digitCount:uint = 2) : String
      {
         var paddedBinaryNumber:String = value.toString(2);
         var len:uint = uint(paddedBinaryNumber.length);
         while(len < digitCount)
         {
            paddedBinaryNumber = "0" + paddedBinaryNumber;
            len++;
         }
         return paddedBinaryNumber;
      }
      
      public static function isTimeWithinDateRange(startDate:String, endDate:String, serverTimeMs:Number = 0) : Boolean
      {
         var result:Boolean = true;
         var startTimestamp:Number = synchronizedDateToNumber(startDate);
         var endTimestamp:Number = synchronizedDateToNumber(endDate);
         if(0 == serverTimeMs)
         {
            serverTimeMs = GlobalEngine.serverTime;
         }
         if(startTimestamp > serverTimeMs || endTimestamp < serverTimeMs)
         {
            result = false;
         }
         return result;
      }
      
      public static function getMsecsSinceStartDate(startDate:String) : Number
      {
         var result:Number = 0;
         var startTimestamp:Number = synchronizedDateToNumber(startDate);
         return GlobalEngine.serverTime - startTimestamp;
      }
      
      public static function getDaysSinceStartDate(startDate:String) : int
      {
         return int(getMsecsSinceStartDate(startDate) / FarmGameUtil.NUM_MSECS_IN_DAY);
      }
      
      public static function getTimeLeftText(endDate:Number, localizedPrefix:String = "", extraParams:Array = null, showRetiredText:Boolean = false) : String
      {
         var minuteDiff:Number = NaN;
         var dayDiff:Number = NaN;
         var timeDiff:Number = (endDate - GlobalEngine.serverTime / 1000) / 3600;
         var timeLeftStr:String = "";
         if(timeDiff >= 0)
         {
            if(timeDiff < 1)
            {
               minuteDiff = int(timeDiff * 60);
               timeLeftStr = ZLocUtils.t("Dialogs",localizedPrefix + "MinutesLeft",{
                  "quantity":minuteDiff,
                  "minuteword":ZLocUtils.tk("SocialMission","min_word","",minuteDiff)
               });
            }
            else if(timeDiff <= 24)
            {
               timeLeftStr = ZLocUtils.t("Dialogs",localizedPrefix + "HoursLeft",{
                  "quantity":int(timeDiff),
                  "hourword":ZLocUtils.tk("SocialMission","hr_word","",int(timeDiff))
               });
            }
            else
            {
               dayDiff = Math.round(timeDiff / 24);
               timeLeftStr = getTimeLeftTextInDays(dayDiff,localizedPrefix);
            }
         }
         else if(showRetiredText && Boolean(extraParams))
         {
            timeLeftStr = ZLocUtils.t("Dialogs",localizedPrefix + "Retired",{"quantity":extraParams});
         }
         return timeLeftStr;
      }
      
      public static function getFeatureExpiryDateText(endDate:String, expiryTextKey:String, redeemAdditionalDays:int = 0) : String
      {
         var expiryTimeSecond:int = 0;
         var secondsLeft:int = 0;
         var currentTimeSeconds:int = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var redeemAdditionalTimeInSeconds:int = redeemAdditionalDays * NUM_SECS_IN_DAY;
         if(endDate)
         {
            expiryTimeSecond = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND);
            secondsLeft = expiryTimeSecond - redeemAdditionalTimeInSeconds - currentTimeSeconds;
            secondsLeft = secondsLeft < 0 ? int(secondsLeft + redeemAdditionalTimeInSeconds) : secondsLeft;
         }
         var timeLeftFriendlyName:String = FarmGameUtil.toFriendlyTime(secondsLeft);
         return ZLocUtils.t("Dialogs",expiryTextKey,{"time":timeLeftFriendlyName});
      }
      
      public static function getExpiryDateText(endDate:String) : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(!isNaN(timeRemaining))
         {
            if(numDays > 1)
            {
               result = numDays.toString() + " Days";
            }
            else
            {
               result = HUD.getformattedTimeLeft(timeRemaining);
            }
         }
         return result;
      }
      
      public static function getTimeLeftTextInDays(days:Number, localizedPrefix:String = "") : String
      {
         return ZLocUtils.t("Dialogs",localizedPrefix + "DaysLeft",{
            "quantity":days,
            "dayword":ZLocUtils.tk("SocialMission","day_word","",days)
         });
      }
      
      public static function toFriendlyTime(timeLeft:Number, useSingleUnit:Boolean = false) : String
      {
         var friendlyTime:String = null;
         var timeAmounts:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(timeAmounts[0] > 0)
         {
            if(timeAmounts[1] > 0 && !useSingleUnit)
            {
               friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeDaysHours",{
                  "days":timeAmounts[0],
                  "hours":timeAmounts[1]
               });
            }
            else
            {
               friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeDays",{"days":timeAmounts[0]});
            }
         }
         else if(timeAmounts[1] > 0)
         {
            if(timeAmounts[2] > 0 && !useSingleUnit)
            {
               friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeHoursMins",{
                  "hours":timeAmounts[1],
                  "minutes":timeAmounts[2]
               });
            }
            else
            {
               friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeHours",{"hours":timeAmounts[1]});
            }
         }
         else if(timeAmounts[2] > 0 && !useSingleUnit)
         {
            friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeMinsSecs",{
               "minutes":timeAmounts[2],
               "seconds":timeAmounts[3]
            });
         }
         else if(timeAmounts[2] > 0)
         {
            friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeMins",{"minutes":timeAmounts[2]});
         }
         else
         {
            friendlyTime = ZLocUtils.t("FarmGame","General_FriendlyTimeSecs",{"seconds":timeAmounts[3]});
         }
         return friendlyTime;
      }
      
      public static function toFriendlyTimeZLoc(timeLeft:Number) : Array
      {
         return FarmGameUtil.parseTimeLeftZLoc(timeLeft);
      }
      
      public static function getYearMonthDayInUTC() : String
      {
         var result:String = "";
         var date:Date = new Date(GlobalEngine.serverTime);
         result += date.fullYearUTC.toString().slice(2);
         if(date.monthUTC < 9)
         {
            result += "0" + (date.monthUTC + 1).toString();
         }
         else
         {
            result += (date.monthUTC + 1).toString();
         }
         if(date.dateUTC < 10)
         {
            result += "0" + date.dateUTC;
         }
         else
         {
            result += date.dateUTC;
         }
         return result;
      }
      
      public static function getMidnightTimestamp() : Number
      {
         var synchronizedOffsetInMsecs:int = getGlobalServerUTCOffsetHours() * NUM_MSECS_IN_HOUR;
         var timezoneOffset:Number = new Date().timezoneOffset * NUM_MSECS_IN_MINUTE;
         var date:Date = new Date(GlobalEngine.serverTime + timezoneOffset - synchronizedOffsetInMsecs);
         date.setHours(0,0,0,0);
         return date.getTime() - timezoneOffset + synchronizedOffsetInMsecs;
      }
      
      public static function redirectHomeNoError(event:GenericPopupEvent = null) : void
      {
         redirectHome(null,false);
      }
      
      public static function redirectHome(event:Event = null, addErrorCode:Boolean = true) : void
      {
         var url:String = "index.php?ref=flashRedirectHome";
         if(addErrorCode)
         {
            url += "&ooscode=" + TransactionManager.lastError + "&oosfunc=" + TransactionManager.lastFunc + "&oosmsg=" + TransactionManager.lastMsg;
         }
         Global.farmSocialNetwork.redirectTop(url);
      }
      
      public static function getFriendIconByUid(uid:String) : String
      {
         var owner:Friend = null;
         var iconUrl:String = "";
         if(uid == Global.player.snUser.uid)
         {
            iconUrl = Global.player.snUser.picture;
         }
         else
         {
            owner = Global.friendManager.getFriendData(uid);
            if(Boolean(owner) && Boolean(owner.picture))
            {
               iconUrl = owner.picture;
            }
         }
         if(!iconUrl)
         {
            iconUrl = Global.getAssetURL(Player.NO_PROFILE_PIC_URL);
         }
         return iconUrl;
      }
      
      public static function secondsElapsed(time:Number) : Number
      {
         return GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - time;
      }
      
      public static function getTimeDelta(time:Number, metric:int = 0) : Number
      {
         var result:Number = GlobalEngine.serverTime - time;
         switch(metric)
         {
            case MILLISECONDS:
               break;
            case SECONDS:
               result /= NUM_MSECS_IN_SECOND;
               break;
            case HOURS:
               result /= NUM_MSECS_IN_HOUR;
               break;
            case DAYS:
               result /= NUM_MSECS_IN_DAY;
               break;
            case WEEKS:
               result = getTimeDelta(time,DAYS) / NUM_DAYS_IN_WEEK;
               break;
            case MONTHS:
               result = getTimeDelta(time,DAYS) / NUM_DAYS_IN_MONTH;
         }
         return result;
      }
      
      public static function launchURL(url:String, target:String = "_blank", variables:Object = null, redirectTop:Boolean = false) : void
      {
         var useNavigateToURL:Boolean = true;
         try
         {
            if(ExternalInterface.available && GlobalEngine.getFlashVar("iframeRedirect") > 0 && !redirectTop)
            {
               ExternalInterface.call("ZYFrameManager.navigateTo",url);
               useNavigateToURL = false;
            }
         }
         catch(error:SecurityError)
         {
            useNavigateToURL = true;
         }
         if(useNavigateToURL)
         {
            if(GlobalEngine.getFlashVar("FEATURE_IFRAME"))
            {
               if(target == "_parent")
               {
                  target = "_top";
               }
            }
            Utilities.launchURL(url,target,variables);
         }
      }
      
      public static function hasBadWord(word:String) : Boolean
      {
         var badWord:Boolean = false;
         var tempWord:String = word.replace(/\W/gi,"");
         for(var i:int = 0; i < badWordsList.length; i++)
         {
            if(tempWord.toLowerCase().indexOf(badWordsList[i]) >= 0)
            {
               badWord = true;
               break;
            }
         }
         var blankWord:String = word.replace(/^\s+|\s+$/gs,"");
         if(blankWord == "")
         {
            badWord = true;
         }
         return badWord;
      }
      
      public static function censorString(word:String) : String
      {
         var cleanWord:String = word;
         for(var i:int = 0; i < badWordsList.length; i++)
         {
            cleanWord = cleanWord.split(badWordsList[i]).join("***");
         }
         return cleanWord;
      }
      
      public static function isDescendant(ancestor:DisplayObjectContainer, descendant:DisplayObject) : Boolean
      {
         var result:Boolean = false;
         if(descendant != null)
         {
            if(descendant == ancestor || descendant.parent == ancestor)
            {
               result = true;
            }
            else
            {
               result = isDescendant(ancestor,descendant.parent);
            }
         }
         return result;
      }
      
      public static function toUpperCaseFirst(str:String) : String
      {
         return str.substr(0,1).toUpperCase() + str.substr(1);
      }
      
      public static function checkDateGate(limitedStartDate:String, limitedEndDate:String) : Boolean
      {
         var limitedStartTimestamp:Number = NaN;
         var limitedEndTimestamp:Number = NaN;
         var limitedDateGate:Boolean = true;
         if(Boolean(limitedStartDate) && Boolean(limitedEndDate))
         {
            limitedStartTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(limitedStartDate);
            limitedEndTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(limitedEndDate);
            if(limitedStartTimestamp > GlobalEngine.serverTime || limitedEndTimestamp < GlobalEngine.serverTime)
            {
               limitedDateGate = false;
            }
         }
         return limitedDateGate;
      }
      
      public static function isStringSWFUrl(candidateString:String) : Boolean
      {
         var result:Boolean = false;
         if(candidateString.indexOf(".swf") > -1)
         {
            result = true;
         }
         return result;
      }
      
      public static function checkStartDateGate(limitedStartDate:String) : Boolean
      {
         var limitedStartTimestamp:Number = NaN;
         var limitedDateGate:Boolean = true;
         if(limitedStartDate)
         {
            limitedStartTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(limitedStartDate);
            if(limitedStartTimestamp > GlobalEngine.serverTime)
            {
               limitedDateGate = false;
            }
         }
         return limitedDateGate;
      }
      
      public static function checkEndDateGate(limitedEndDate:String) : Boolean
      {
         var limitedEndTimestamp:Number = NaN;
         var limitedDateGate:Boolean = true;
         if(limitedEndDate)
         {
            limitedEndTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(limitedEndDate);
            if(limitedEndTimestamp < GlobalEngine.serverTime)
            {
               limitedDateGate = false;
            }
         }
         return limitedDateGate;
      }
      
      public static function checkDateGateWithRangeNumber(date:String, days:Number = 0) : Boolean
      {
         var dateTimestamp:Number = NaN;
         var daysInMs:Number = NaN;
         var result:Boolean = true;
         if(date)
         {
            dateTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(date);
            daysInMs = days * NUM_MSECS_IN_DAY;
            if(dateTimestamp + daysInMs > GlobalEngine.serverTime)
            {
               result = false;
            }
         }
         return result;
      }
      
      public static function snuidToUid(uidString:String) : String
      {
         var colon:int = uidString.indexOf(":");
         if(colon >= 0)
         {
            uidString = uidString.split(":")[1];
         }
         return uidString;
      }
      
      public static function getLimitedStackTrace(depthLimit:int = 100) : String
      {
         var error:Error = new Error();
         var str:String = error.getStackTrace();
         var regxPattern:RegExp = /(Global|:{2}(\w+)).*:{1}(\d*)/mg;
         var matches:Object = regxPattern.exec(str);
         matches = regxPattern.exec(str);
         var resultString:String = "";
         var className:String = null;
         var lineNumber:String = null;
         var currentDepth:int = 0;
         while(matches != null && currentDepth < depthLimit)
         {
            if(matches[1] == "Global")
            {
               className = matches[1].toString();
            }
            else
            {
               className = matches[2].toString();
            }
            lineNumber = matches[3].toString();
            resultString = resultString + className + ":" + lineNumber + "->";
            matches = regxPattern.exec(str);
            currentDepth++;
         }
         return resultString;
      }
      
      public static function getPsuedoRandomNumber(salt:String) : Number
      {
         var hexPlaces:int = 7;
         var numMax:Number = 268435456;
         var hashedSalt:String = MD5.hash(salt);
         var hexString:String = "0x" + hashedSalt.substr(-hexPlaces).toUpperCase();
         var hexValue:int = int(hexString);
         var bucket:Number = Math.abs(hexValue % numMax + 1);
         return bucket * 100 / numMax;
      }
      
      public static function hsvToRgb(h:Number, s:Number, v:Number) : Array
      {
         var color:Array = null;
         var i:int = 0;
         var f:Number = NaN;
         var m:Number = NaN;
         var n:Number = NaN;
         if(s == 0)
         {
            color = [v,v,v];
         }
         else
         {
            i = int(h);
            f = h - i;
            if(!(i & 1))
            {
               f = 1 - f;
            }
            m = v * (1 - s);
            n = v * (1 - s * f);
            switch(i)
            {
               case 1:
                  color = [n,v,m];
                  break;
               case 2:
                  color = [m,v,n];
                  break;
               case 3:
                  color = [m,n,v];
                  break;
               case 4:
                  color = [n,m,v];
                  break;
               case 5:
                  color = [v,m,n];
                  break;
               default:
                  color = [v,n,m];
            }
         }
         return color;
      }
      
      public static function rgbToHex(r:Number, g:Number, b:Number) : uint
      {
         r *= 255;
         g *= 255;
         b *= 255;
         var string:String = "0x" + r.toString(16) + g.toString(16) + b.toString(16);
         return uint("0x" + r.toString(16) + g.toString(16) + b.toString(16));
      }
      
      public static function getFramesInPerfectLoop(clip:MovieClip, frames:Number = 1, depth:Number = 0) : Number
      {
         var result:Number = NaN;
         var i:Number = NaN;
         var child:MovieClip = null;
         if(clip.framesLoaded > 0)
         {
            result = FarmGameUtil.getLowestCommonDenominator(clip.framesLoaded,frames);
         }
         else
         {
            result = frames;
         }
         if(depth <= 5)
         {
            for(i = 0; i < clip.numChildren; i++)
            {
               child = clip.getChildAt(i) as MovieClip;
               if(child)
               {
                  result = getFramesInPerfectLoop(child,result,depth + 1);
               }
            }
         }
         return result;
      }
      
      public static function getLowestCommonDenominator(num1:Number, num2:Number) : Number
      {
         var result:Number = NaN;
         var divisor:Number = NaN;
         var multiplier:Number = NaN;
         var big:Number = Math.max(num1,num2);
         var small:Number = Math.min(num1,num2);
         if(big % small == 0)
         {
            result = big;
         }
         else
         {
            divisor = getLargestDivisor(big,small);
            multiplier = big / divisor;
            result = small * multiplier;
         }
         return result;
      }
      
      public static function getLargestDivisor(num1:Number, num2:Number) : Number
      {
         var result:Number = NaN;
         var big:Number = NaN;
         var small:Number = NaN;
         var remainder:Number = NaN;
         if(num1 == num2)
         {
            result = num1;
         }
         else
         {
            big = Math.max(num1,num2);
            small = Math.min(num1,num2);
            remainder = big % small;
            if(remainder == 0)
            {
               result = small;
            }
            else
            {
               result = getLargestDivisor(small,remainder);
            }
         }
         return result;
      }
      
      public static function getSkewedBitmap(displayObject:DisplayObject, skewAngleX:Number, skewAngleY:Number) : Bitmap
      {
         var expandHeightValue:Number = Math.tan(skewAngleY) * displayObject.width;
         var expandHeightTrans:Number = 0;
         var expandHeight:Number = expandHeightValue;
         if(expandHeightValue < 0)
         {
            expandHeight = expandHeightTrans = Math.abs(expandHeightValue);
         }
         var expandWidthValue:Number = Math.tan(skewAngleX) * displayObject.height;
         var expandWidthTrans:Number = 0;
         var expandWidth:Number = expandWidthValue;
         if(expandWidthValue < 0)
         {
            expandWidth = expandWidthTrans = Math.abs(expandWidthValue);
         }
         var transformMatrix:Matrix = new Matrix(1,Math.tan(skewAngleY),Math.tan(skewAngleX),1,expandWidthTrans,expandHeightTrans);
         var bitmapData:BitmapData = new BitmapData(displayObject.width + expandWidth,displayObject.height + expandHeight,true,0);
         bitmapData.draw(displayObject,transformMatrix,null,null,null,true);
         return new Bitmap(bitmapData,PixelSnapping.NEVER,true);
      }
      
      public static function itemCodeAsInt(itemCode:String) : int
      {
         var result:int = 0;
         var last:int = itemCode.length - 1;
         for(var charIdx:* = last; charIdx >= 0; charIdx--)
         {
            result += itemCode.charCodeAt(charIdx) << (last - charIdx) * 8;
         }
         return result;
      }
      
      public static function itemCodeFromInt(intCode:int) : String
      {
         var result:String = "";
         while(intCode > 0)
         {
            result = String.fromCharCode(intCode & 0xFF) + result;
            intCode >>= 8;
         }
         return result;
      }
      
      public static function getSafeString(obj:Object, key:String, def:String = "") : String
      {
         var result:String = def;
         if(Boolean(obj) && obj.hasOwnProperty(key))
         {
            result = obj[key];
         }
         return result;
      }
      
      public static function xmlNodeToAttributes(nodeXml:XML) : Object
      {
         var attribute:XML = null;
         var node:Object = new Object();
         var attributes:XMLList = nodeXml.attributes();
         for each(attribute in attributes)
         {
            node[String(attribute.name())] = String(attribute);
         }
         return node;
      }
      
      public static function consoleLog(message:String) : void
      {
         ExternalUtil.instance.call("safeConsoleLog",message);
      }
      
      public static function strToBool(value:String) : Boolean
      {
         var result:Boolean = false;
         value = value.toLowerCase();
         switch(value)
         {
            case "1":
            case "true":
            case "yes":
               result = true;
               break;
            case "0":
            case "false":
            case "no":
               result = false;
               break;
            default:
               result = Boolean(value);
         }
         return result;
      }
      
      public static function showZCachePermissionsPrompt(callback:Function = null) : void
      {
         var zCache:IZCache = GlobalZCache.instance;
         var sandboxUrl:String = Global.getAssetURL(Global.farmGameSettingsManager.getString("zCacheSandboxUrl"));
         var zCacheUI:ZCacheUI = new ZCacheUI(zCache,Global.stage,sandboxUrl,true,true);
         zCacheUI.offsets = new Point(SANDBOX_OFFSET_X,0);
         zCacheUI.showPermissionsPrompt(callback);
      }
      
      public static function getXmlBackupFilename(name:String) : String
      {
         var app_url:String = String(GlobalEngine.getFlashVar("app_url"));
         var reg:RegExp = /(?P<protocol>[a-zA-Z]+) : \/\/  (?P<host>[^:\/]*) (:(?P<port>\d+))?  ((?P<path>[^?]*))? ((?P<parameters>.*))? /x;
         var results:Array = reg.exec(name);
         var protocol:String = results.protocol;
         var host:String = results.host;
         var port:String = results.port;
         var path:String = results.path;
         var paramsStr:String = results.parameters;
         var tokens:Array = path.split("/");
         return app_url + "xml/gz/" + tokens[tokens.length - 1];
      }
      
      public static function collectEnvironmentInfo(reportData:Object) : void
      {
         var flashRevisionObject:Object;
         var expDict:Dictionary;
         var expData:Object;
         var key:* = undefined;
         var GET_NAVIGATOR_INFO:String = (<![CDATA[
                function() {
                    return {
                        appName: navigator.appName,
                        appVersion: navigator.appVersion,
                        userAgent: navigator.userAgent
                    } ;
                } ]]>).toString();
         try
         {
            if(ExternalInterface.available)
            {
               reportData["browserInfo"] = ExternalInterface.call(GET_NAVIGATOR_INFO);
            }
         }
         catch(e:Error)
         {
            GlobalEngine.error("FarmGame::handleUncaughtException","Error getting browser info: " + e);
         }
         reportData["capabilities"] = Capabilities.serverString;
         if(Capabilities.isDebugger)
         {
            reportData["flashPlayerType"] = "debug";
         }
         else
         {
            reportData["flashPlayerType"] = "standard";
         }
         flashRevisionObject = GlobalEngine.getFlashVar("flashRevision");
         if(flashRevisionObject != null)
         {
            reportData["revision"] = flashRevisionObject.toString();
         }
         else
         {
            reportData["revision"] = "0";
         }
         reportData["version"] = Capabilities.version;
         reportData["signedParams"] = TransactionManager.additionalSignedParams;
         expDict = Global.experimentManager.getAllExperiments();
         expData = {};
         for(key in expDict)
         {
            expData[key] = expDict[key];
         }
         reportData["experimentData"] = expData;
      }
      
      public static function sendJavaScriptReport(reportEndpoint:String, reportData:Object, statsKingdom:String, onCompleteCallback:Function = null, onErrorCallback:Function = null) : void
      {
         var js:FarmJSONEncoder = null;
         var url:String = null;
         var request:URLRequest = null;
         var urlLoader:URLLoader = null;
         var isEncoded:Boolean = false;
         var requestVars:URLVariables = new URLVariables();
         try
         {
            js = new FarmJSONEncoder(reportData);
            requestVars.data = js.getString();
            isEncoded = true;
         }
         catch(e:Error)
         {
            FarmStatsManager.count(statsKingdom,"errors","json_encoding");
         }
         if(isEncoded)
         {
            url = Config.BASE_PATH + reportEndpoint;
            request = new URLRequest(url);
            request.method = URLRequestMethod.POST;
            request.data = requestVars;
            urlLoader = new URLLoader();
            urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
            addEventListeners(urlLoader);
            if(onCompleteCallback != null)
            {
               urlLoader.addEventListener(Event.COMPLETE,onCompleteCallback,false,0,true);
            }
            if(onErrorCallback != null)
            {
               urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onErrorCallback,false,0,true);
               urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onErrorCallback,false,0,true);
            }
            urlLoader.load(request);
            StatsManager.sendStats(true);
         }
      }
      
      private static function addEventListeners(loader:URLLoader) : void
      {
         loader.addEventListener(Event.COMPLETE,onSendJavaScriptReportComplete);
         loader.addEventListener(IOErrorEvent.IO_ERROR,onSendJavaScriptReportError);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSendJavaScriptReportError);
      }
      
      private static function removeEventListeners(loader:URLLoader) : void
      {
         loader.removeEventListener(Event.COMPLETE,onSendJavaScriptReportComplete);
         loader.removeEventListener(IOErrorEvent.IO_ERROR,onSendJavaScriptReportError);
         loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSendJavaScriptReportError);
      }
      
      private static function onSendJavaScriptReportComplete(event:Event) : void
      {
         removeEventListeners(event.target as URLLoader);
      }
      
      private static function onSendJavaScriptReportError(event:IOErrorEvent) : void
      {
         GlobalEngine.error("Reports","Error sending JavaScript report: " + event.text);
         FarmStatsManager.featureSample("errors","flash","send_js_report_fail",event.type);
         removeEventListeners(event.target as URLLoader);
      }
      
      public static function reportClientError(error:ErrorEvent, errorType:String = "unknown", errorText:String = "", reportEndpoint:String = "report_exception.php", statsKingdom:String = "UncaughtException", onCompleteCallback:Function = null, onErrorCallback:Function = null) : void
      {
         var reportData:Object = {};
         FarmGameUtil.collectEnvironmentInfo(reportData);
         if(error != null)
         {
            reportData["errorType"] = error.type;
            reportData["errorMessage"] = error.text;
         }
         else
         {
            reportData["errorType"] = errorType;
            reportData["errorMessage"] = errorText;
         }
         FarmGameUtil.sendJavaScriptReport(reportEndpoint,reportData,statsKingdom,onCompleteCallback,onErrorCallback);
      }
      
      public static function reportClientLog(message:String) : void
      {
         var reportData:Object = {};
         FarmGameUtil.collectEnvironmentInfo(reportData);
         reportData["message"] = message;
         FarmGameUtil.sendJavaScriptReport("report_log.php",reportData,"ClientLog");
      }
      
      public static function logClientInfo() : void
      {
         var userAgent:String = null;
         var verOffset:* = undefined;
         userAgent = getBrowserVersion();
         var flashVersion:String = Capabilities.version;
         var flashOs:String = Capabilities.os;
         var flashScreenRes:String = Capabilities.screenResolutionX + " x " + Capabilities.screenResolutionY;
         var flashLanguage:String = Capabilities.language;
         var totalMemory:int = System.totalMemory / (1024 * 1024);
         StatsManager.count("client_info",userAgent,flashVersion,flashOs,flashScreenRes,flashLanguage,totalMemory);
         var platform:String = Capabilities.supports64BitProcesses ? "64bit" : "32bit";
         var browser:String = "";
         var browserVersion:* = "";
         var worldType:String = Global.worldManager.currentWorldType;
         userAgent = ExternalInterface.call("window.navigator.userAgent.toString") || ExternalInterface.call("navigator.userAgent.toString") || ExternalInterface.call("window. navigator.userAgent.toString()") || ExternalInterface.call("navigator.userAgent.toString()");
         verOffset = userAgent.indexOf("Firefox");
         if(verOffset > -1)
         {
            browser = "Mozilla Firefox";
            browserVersion = userAgent.substring(verOffset + 8);
         }
         else
         {
            verOffset = userAgent.indexOf("Safari");
            if(verOffset != -1 && userAgent.indexOf("Chrome") == -1)
            {
               browser = "Safari";
               browserVersion = userAgent.substring(verOffset + 7);
               verOffset = userAgent.indexOf("Version");
               if(verOffset != -1)
               {
                  browserVersion = userAgent.substring(verOffset + 8);
               }
            }
            else if(userAgent.indexOf("MSIE") > -1)
            {
               browser = "Microsoft Internet Explorer";
               browserVersion = userAgent.substring(verOffset + 5);
            }
            else if(userAgent.indexOf("Edge") > -1)
            {
               browser = "Microsoft Edge";
            }
            else if(userAgent.indexOf("Opera") > -1 || userAgent.indexOf("OPR") > -1)
            {
               browser = "Opera";
               browserVersion = userAgent.substring(verOffset + 6);
               verOffset = userAgent.indexOf("Version");
               if(verOffset != -1)
               {
                  browserVersion = userAgent.substring(verOffset + 8);
               }
            }
            else
            {
               verOffset = userAgent.indexOf("Chrome");
               if(verOffset != -1)
               {
                  browser = "Google Chrome/Chromium";
                  browserVersion = userAgent.substring(verOffset + 7);
               }
               else if(userAgent.indexOf("SamsungBrowser") > -1)
               {
                  browser = "Samsung Internet";
               }
               else
               {
                  browser = "unknown";
               }
            }
         }
         StatsManager.count("browser_info",flashOs,platform,browser,browserVersion,worldType);
      }
      
      public static function getBrowserVersion() : String
      {
         var GET_BROWSER_INFO:String = null;
         var browserData:Object = null;
         if(m_browserData == null)
         {
            GET_BROWSER_INFO = (<![CDATA[
                    function() {
                        return {
                            userAgent: navigator.userAgent
                        } ;
                    } ]]>).toString();
            browserData = null;
            if(ExternalInterface.available)
            {
               try
               {
                  browserData = ExternalInterface.call(GET_BROWSER_INFO);
               }
               catch(e:Error)
               {
                  GlobalEngine.error("FarmGameUtil::logClientInfo","Error getting browser info: " + e);
               }
               m_browserData = browserData ? browserData["userAgent"] : "unavailable";
            }
         }
         return m_browserData;
      }
      
      public static function showCraftingWindowWithItem(recipeId:String) : void
      {
         var prompt:GenericXMLDialog = null;
         var craftShop:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         var craftshopOpened:Boolean = false;
         if(CraftingManager.getInstance().showCraftingWindowForRecipe(recipeId))
         {
            craftshopOpened = true;
         }
         if(!craftshopOpened)
         {
            prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName("craftingworkshop_finished","icon",false),100,100,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Message"),null,true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Button"),function(event:Event):void
            {
               Global.world.enterForcePlaceMode("craftingworkshop_finished",true,0,false,false,{"suppressGiftRepop":true});
            });
            UI.displayPopup(prompt,true,"",true);
         }
      }
      
      public static function getTooltipTextForAskButton(timeLeft:Number) : String
      {
         var parsedTime:Array = null;
         var message:String = "";
         if(Boolean(timeLeft) && timeLeft > 0)
         {
            parsedTime = FarmGameUtil.parseTimeLeft(timeLeft);
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
               "hrs":parsedTime[1],
               "min":parsedTime[2]
            });
         }
         return message;
      }
      
      public static function disableButtonAndShowTooltip(farmButton:FarmButton, tooltipText:String) : void
      {
         if(farmButton)
         {
            farmButton.enabled = false;
            farmButton.element.mouseEnabled = farmButton.element.mouseChildren = true;
            farmButton.attachTooltip(new FarmTextTooltip(tooltipText));
         }
      }
      
      public static function uncompressAndDecode(compressedString:String, classString:String = "") : Object
      {
         var result:Object = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_JSON_OPTIMIZATION);
         if(variant == Experiments.VARIANT_OPS_JSON_ACTIVE)
         {
            result = uncompressAndDecodeCrypto(compressedString);
         }
         else
         {
            result = uncompressAndDecodeDefault(compressedString);
         }
         return result;
      }
      
      private static function uncompressAndDecodeDefault(compressedData:String) : Object
      {
         var decoder:Base64Decoder = new Base64Decoder();
         decoder.decode(compressedData);
         var zippedData:ByteArray = decoder.toByteArray();
         zippedData.uncompress();
         return JSONDecodeDefault(zippedData.toString());
      }
      
      private static function uncompressAndDecodeCrypto(compressedData:String) : Object
      {
         var zippedData:ByteArray = Base64.decode(compressedData);
         zippedData.uncompress();
         return JSONDecodeCrypto(zippedData.toString());
      }
      
      public static function JSONDecode(JSONString:String, classString:String = "") : Object
      {
         var result:Object = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_JSON_OPTIMIZATION);
         if(variant == Experiments.VARIANT_OPS_JSON_ACTIVE)
         {
            result = JSONDecodeCrypto(JSONString);
         }
         else
         {
            result = JSONDecodeDefault(JSONString);
         }
         return result;
      }
      
      private static function JSONDecodeDefault(JSONString:String) : Object
      {
         var jsonData:JSONDecoder = new JSONDecoder(JSONString);
         return jsonData.getValue();
      }
      
      private static function JSONDecodeCrypto(JSONString:String) : Object
      {
         return by.blooddy.crypto.serialization.JSON.decode(JSONString);
      }
      
      public static function getSaturationMatrix(value:Number) : Array
      {
         var nRed:Number = 0.3086;
         var nGreen:Number = 0.6094;
         var nBlue:Number = 0.082;
         var nA:Number = (1 - value) * nRed + value;
         var nB:Number = (1 - value) * nGreen;
         var nC:Number = (1 - value) * nBlue;
         var nD:Number = (1 - value) * nRed;
         var nE:Number = (1 - value) * nGreen + value;
         var nF:Number = (1 - value) * nBlue;
         var nG:Number = (1 - value) * nRed;
         var nH:Number = (1 - value) * nGreen;
         var nI:Number = (1 - value) * nBlue + value;
         return [nA,nB,nC,0,0,nD,nE,nF,0,0,nG,nH,nI,0,0,0,0,0,1,0];
      }
   }
}

