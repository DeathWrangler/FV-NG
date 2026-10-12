package Classes.util
{
   import Classes.EmbeddedArt;
   import Display.ZLocToolTip;
   import Engine.Managers.ErrorManager;
   import ZLocalization.LocaleFormatter;
   import ZLocalization.LocalizationName;
   import ZLocalization.LocalizationObjectToken;
   import ZLocalization.LocalizationToken;
   import ZLocalization.LocalizedString;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getQualifiedClassName;
   
   public class ZLocUtils
   {
      
      public static const MASC:String = "masc";
      
      public static const FEM:String = "fem";
      
      private static const DEFAULT_GENDER:String = MASC;
      
      private static const INVALID_PREFIX:String = "NO:";
      
      private static const DEFAULT_LOCALE:String = "en_US";
      
      private static const NO_COUNT:int = -1;
      
      private static const IMAGE_PACKAGE:String = "LocalizedImages";
      
      private static const USE_ZS_AS:int = 0;
      
      private static const USE_ZS_PHP:int = 1;
      
      private static const USE_VERBOSE_ERRORS:int = 2;
      
      private static const USE_RESIZING_TEXT:int = 3;
      
      private static const USE_TF_BORDERS:int = 4;
      
      private static const USE_TF_MARQUEE:int = 5;
      
      private static const USE_TF_TOOLTIP:int = 6;
      
      private static const USE_FLAG_NAME:String = "ZLocUtilsFlags";
      
      private static const USE_FLAG_DEFAULT:int = 0;
      
      private static var m_errorStatSampleRate:int = 0;
      
      private static var m_tokens:Array = new Array();
      
      public function ZLocUtils()
      {
         super();
      }
      
      private static function getZLocUtilsFlags() : int
      {
         return Global.farmGameSettingsManager.getInt(USE_FLAG_NAME,USE_FLAG_DEFAULT);
      }
      
      public static function showZsAs() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_ZS_AS);
      }
      
      public static function showZsPhp() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_ZS_PHP);
      }
      
      public static function showVerboseErrors() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_VERBOSE_ERRORS);
      }
      
      public static function showResizingText() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_RESIZING_TEXT);
      }
      
      public static function showTfBorders() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_TF_BORDERS);
      }
      
      public static function showTfMarquee() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_TF_MARQUEE);
      }
      
      public static function showTfTooltip() : Boolean
      {
         return 0 != (ZLocUtils.getZLocUtilsFlags() & 1 << USE_TF_TOOLTIP);
      }
      
      public static function hasString(pkg:String, key:String = null) : Boolean
      {
         var parts:Array = null;
         var result:Boolean = false;
         if(pkg != null)
         {
            if(key == null)
            {
               parts = pkg.split(":");
               if(parts.length == 2)
               {
                  pkg = parts[0];
                  key = parts[1];
               }
            }
            if(key != null)
            {
               if(ZLoc.instance != null)
               {
                  if(ZLoc.instance.getString(pkg,key) != null)
                  {
                     if(ZLoc.instance.getString(pkg,key).getVariation("original") != null)
                     {
                        result = true;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public static function isObject(pkg:String, key:String = null) : Boolean
      {
         var parts:Array = null;
         var result:Boolean = false;
         if(pkg != null)
         {
            if(key == null)
            {
               parts = pkg.split(":");
               if(parts.length == 2)
               {
                  pkg = parts[0];
                  key = parts[1];
               }
            }
            if(key != null && ZLoc.instance != null)
            {
               if(null != ZLoc.instance.getString(pkg,key))
               {
                  if(0 != ZLoc.instance.getString(pkg,key).getVariation("singular").indexOf("false"))
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      public static function debugTrapOnKey(key:String) : void
      {
         if(key == "england_quests_sendhelp_helped")
         {
         }
      }
      
      public static function debugTrapOnResult(result:String) : void
      {
         if(result.indexOf("#:") == -1)
         {
            if(result.indexOf("SM_FeedPrompt") != -1)
            {
            }
         }
      }
      
      public static function t(pkg:String, key:String, replacements:Object = null) : String
      {
         var result:String = null;
         var theKey:String = null;
         var prop:* = undefined;
         result = " ";
         for(theKey in replacements)
         {
            if(replacements[theKey] == null)
            {
               delete replacements[theKey];
            }
         }
         debugTrapOnKey(key);
         if(!ZLocUtils.hasString(pkg,key))
         {
            if(ZLocUtils.showVerboseErrors())
            {
               result = INVALID_PREFIX + pkg + ":" + key;
            }
            else
            {
               result = "";
            }
            GlobalEngine.log("localization","bundleName: " + pkg + " resource: " + key);
         }
         else
         {
            try
            {
               result = ZLoc.t(pkg,key,replacements);
            }
            catch(e:Error)
            {
               result = "#:" + pkg + ":" + key + ":#";
               if(ZLocUtils.showVerboseErrors())
               {
                  result += " " + e.message + " ";
                  while(ZLocUtils.m_tokens.length > 0)
                  {
                     result += ZLocUtils.m_tokens.pop();
                  }
                  for(prop in replacements)
                  {
                     if(replacements[prop])
                     {
                        result += "\n" + prop + "=" + replacements[prop].toString();
                     }
                  }
               }
               GlobalEngine.log("localization","bundleName: " + pkg + " resource: " + key);
            }
         }
         if(ZLocUtils.showZsAs())
         {
            result = "Z_" + result + "_Z";
         }
         ZLocUtils.m_tokens.length = 0;
         debugTrapOnResult(result);
         return result;
      }
      
      public static function getExistingLocalizationKey(pkg:String, requestedKey:String, fallBackKey:String) : String
      {
         var result:String = requestedKey;
         if(!ZLocUtils.hasString(pkg,requestedKey))
         {
            result = fallBackKey;
         }
         return result;
      }
      
      public static function tk(pkg:String, key:String, attributes:String = "", count:int = -1) : LocalizationObjectToken
      {
         var isAdult:Boolean = false;
         var adultKey:String = null;
         var result:LocalizationObjectToken = null;
         if(!ZLocUtils.hasString(pkg,key))
         {
            result = null;
         }
         else
         {
            isAdult = false;
            if(Global.farmSocialNetwork != null)
            {
               isAdult = Global.farmSocialNetwork.userIsAdult();
            }
            if(isAdult)
            {
               adultKey = key + "_ADULT";
               if(ZLocUtils.hasString(pkg,adultKey))
               {
                  key = adultKey;
               }
            }
            if(isObject(pkg,key))
            {
               try
               {
                  ZLocUtils.m_tokens.push("=" + pkg + ":" + key + ":" + attributes + ":" + count);
                  result = ZLoc.tk(pkg,key,attributes,count);
               }
               catch(e:Error)
               {
               }
            }
            else
            {
               result = new LocalizationObjectToken(new LocalizedString(ZLocUtils.t(pkg,key)),"singular");
            }
         }
         return result;
      }
      
      public static function tn(name:String, gender:String = "masc") : LocalizationName
      {
         var result:LocalizationName = null;
         try
         {
            result = ZLoc.tn(name,gender);
         }
         catch(e:Error)
         {
         }
         return result;
      }
      
      public static function ti(path:String) : String
      {
         return path;
      }
      
      public static function tiEmbeddedArt(path:String) : Class
      {
         return EmbeddedArt[path];
      }
      
      public static function hasTokenInString(token:String, pkg:String, key:String = null) : Boolean
      {
         var parts:Array = null;
         var original:String = null;
         var result:Boolean = false;
         if(key == null)
         {
            parts = pkg.split(":");
            if(parts.length == 2)
            {
               pkg = parts[0];
               key = parts[1];
            }
         }
         if(ZLocUtils.hasString(pkg,key))
         {
            original = ZLoc.instance.getString(pkg,key).getVariation("original");
            result = -1 != original.indexOf("{" + token + ",");
            if(!result)
            {
               result = -1 != original.indexOf("{" + token + "}");
            }
         }
         return result;
      }
      
      public static function hasTokenAttributeInString(token:String, attribute:String, pkg:String, key:String = null) : Boolean
      {
         var parts:Array = null;
         var original:String = null;
         var result:Boolean = false;
         if(key == null)
         {
            parts = pkg.split(":");
            if(parts.length == 2)
            {
               pkg = parts[0];
               key = parts[1];
            }
         }
         if(ZLocUtils.hasString(pkg,key))
         {
            original = ZLoc.instance.getString(pkg,key).getVariation("original");
            result = -1 != original.indexOf("{" + token + ",");
            if(!result)
            {
               result = -1 != original.indexOf("{" + token + "}");
            }
            if(result)
            {
               result = -1 != original.indexOf("," + attribute + "}");
            }
         }
         return result;
      }
      
      public static function tg(gender:String) : String
      {
         var zg:String = FEM;
         if(gender != null && gender.charAt().toLowerCase() == "m")
         {
            zg = MASC;
         }
         return zg;
      }
      
      public static function t_pk(pkg:String, key:String = null, locobj:Object = null) : String
      {
         var parts:Array = null;
         if(key == null || key == "")
         {
            parts = pkg.split(":");
            if(parts.length == 2)
            {
               pkg = parts[0];
               key = parts[1];
            }
         }
         return ZLocUtils.t(pkg,key,locobj);
      }
      
      public static function tk_pk(pkgkey:String, attributes:String = "", count:int = -1) : LocalizationObjectToken
      {
         var pkg:String = null;
         var key:String = null;
         var parts:Array = null;
         var result:LocalizationObjectToken = null;
         if(null != pkgkey && pkgkey != "")
         {
            parts = pkgkey.split(":");
            if(parts.length == 2)
            {
               pkg = parts[0];
               key = parts[1];
               result = ZLocUtils.tk(pkg,key,attributes,count);
            }
         }
         return result;
      }
      
      public static function tk_pk_asTitle(pkgkey:String) : String
      {
         var result:String = null;
         var parts:Array = null;
         var pkg:String = null;
         var key:String = null;
         var token:LocalizationObjectToken = null;
         if(pkgkey == null || pkgkey == "")
         {
            result = "";
         }
         else
         {
            parts = pkgkey.split(":");
            if(parts.length == 2)
            {
               pkg = parts[0];
               key = parts[1];
            }
            if(ZLocUtils.hasString(pkg,key))
            {
               if(ZLocUtils.isObject(pkg,key))
               {
                  token = ZLocUtils.tk(pkg,key,"singular");
                  if(token == null)
                  {
                     result = "Npk:" + pkgkey;
                  }
                  else
                  {
                     result = ZLocUtils.t("Items","showTitle",{"item":token});
                  }
               }
               else
               {
                  result = ZLocUtils.t(pkg,key);
               }
            }
            else
            {
               result = "";
            }
         }
         return result;
      }
      
      public static function tk_pk_asTitlePlural(pkgkey:String) : String
      {
         var result:String = null;
         var parts:Array = null;
         var pkg:String = null;
         var key:String = null;
         var token:LocalizationObjectToken = null;
         if(pkgkey == null || pkgkey == "")
         {
            result = "";
         }
         else
         {
            parts = pkgkey.split(":");
            if(parts.length == 2)
            {
               pkg = parts[0];
               key = parts[1];
            }
            if(ZLocUtils.hasString(pkg,key))
            {
               if(ZLocUtils.isObject(pkg,key))
               {
                  token = ZLocUtils.tk(pkg,key,"plural");
                  if(token == null)
                  {
                     result = "Npk:" + pkgkey;
                  }
                  else
                  {
                     result = ZLocUtils.t("Items","showTitlePlural",{"item":token});
                  }
               }
               else
               {
                  result = ZLocUtils.t(pkg,key);
               }
            }
            else
            {
               result = "";
            }
         }
         return result;
      }
      
      public static function isValid(input:String) : Boolean
      {
         return INVALID_PREFIX != input.substring(0,INVALID_PREFIX.length);
      }
      
      public static function setText(tf:Object, target:String, pkg:String, key:String, params:Object = null) : void
      {
         var targs:Array = null;
         var objStr:String = null;
         var tfName:String = null;
         if(Boolean(tf && target && pkg) && Boolean(key) && ZLocUtils.hasString(pkg,key))
         {
            targs = target.split(".");
            for each(objStr in targs)
            {
               if(tf[objStr] == null)
               {
                  break;
               }
               tf = tf[objStr];
            }
         }
         if(tf is TextField)
         {
            tf.text = ZLocUtils.t(pkg,key,params);
            ZLocUtils.autoFormatSize(tf as TextField,16720418);
         }
         else if(tf is String)
         {
            tf = ZLocUtils.t(pkg,key,params);
         }
         else
         {
            tfName = getQualifiedClassName(tf);
         }
      }
      
      public static function setTextAsTitle(tf:Object, target:String, pkgKey:String) : void
      {
         var targs:Array = null;
         var objStr:String = null;
         var tfName:String = null;
         var title:String = ZLocUtils.tk_pk_asTitle(pkgKey);
         if(Boolean(tf) && Boolean(target) && Boolean(title))
         {
            targs = target.split(".");
            for each(objStr in targs)
            {
               if(tf[objStr] == null)
               {
                  break;
               }
               tf = tf[objStr];
            }
         }
         if(tf is TextField)
         {
            tf.text = title;
            ZLocUtils.autoFormatSize(tf as TextField,16720418);
         }
         else if(tf is String)
         {
            tf = title;
         }
         else
         {
            tfName = getQualifiedClassName(tf);
         }
      }
      
      public static function autoFormatSize(tf:TextField, borderColor:uint = 2293538) : void
      {
         var minFontSize:Number = NaN;
         var format:TextFormat = null;
         var ellipsis:String = null;
         var zToolTip:ZLocToolTip = null;
         if(DEFAULT_LOCALE != Global.masterLocale || ZLocUtils.showZsAs())
         {
            if(ZLocUtils.showResizingText())
            {
               minFontSize = 10;
               while(tf != null && (tf.textWidth > tf.width || tf.textHeight > tf.height))
               {
                  format = tf.getTextFormat();
                  format.size = Number(format.size) - 1;
                  if(format.size < minFontSize)
                  {
                     break;
                  }
                  tf.setTextFormat(format);
               }
            }
            if(ZLocUtils.showTfTooltip() && (tf.textWidth > tf.width || tf.textHeight > tf.height))
            {
               if(tf.parent != null)
               {
                  if(tf.text.indexOf("_tf") < 0)
                  {
                     zToolTip = new ZLocToolTip();
                     zToolTip.toolTip = tf.text;
                     zToolTip.attachToolTip(tf.parent);
                  }
               }
               ellipsis = "…";
               while(tf != null && tf.text.length > ellipsis.length + 3 && (tf.textWidth > tf.width || tf.textHeight > tf.height))
               {
                  tf.text = tf.text.substr(0,tf.text.length - ellipsis.length - 1);
                  tf.appendText(ellipsis);
               }
            }
            if(ZLocUtils.showTfBorders())
            {
               tf.border = true;
               tf.borderColor = borderColor;
            }
         }
      }
      
      public static function splitString(splitMe:String, lines:int) : Array
      {
         var len:int = 0;
         var index:int = 0;
         var prev:int = 0;
         var subStr:String = null;
         var i:int = 0;
         var result:Array = new Array();
         if(null != splitMe)
         {
            len = splitMe.length / lines;
            prev = 0;
            i = 0;
            while(i < lines)
            {
               index = splitMe.indexOf(" ",len);
               if(-1 < index && index < splitMe.length)
               {
                  subStr = splitMe.substring(prev,index);
                  i++;
               }
               else
               {
                  subStr = splitMe.substring(prev,splitMe.length);
                  i = lines;
               }
               prev = index;
               len += prev;
               result.push(subStr);
            }
         }
         return result;
      }
      
      public static function makeToken(strpkg:String, strkey:String, insertkey:String, insertinfo:String) : LocalizationToken
      {
         var parentStr:String = null;
         var testStr:String = null;
         var sindex:int = 0;
         var tokenType:String = null;
         var attribs:String = null;
         var eindex:int = 0;
         var info:Array = null;
         var token:LocalizationToken = null;
         if(ZLocUtils.hasString(strpkg,strkey))
         {
            parentStr = ZLoc.instance.getString(strpkg,strkey).getVariation("original");
            testStr = "{" + insertkey;
            sindex = parentStr.indexOf(testStr);
            if(-1 < sindex)
            {
               tokenType = null;
               attribs = "";
               eindex = parentStr.indexOf("}",sindex);
               testStr = parentStr.substring(sindex + 1,eindex);
               sindex = testStr.indexOf(",");
               if(-1 < sindex)
               {
                  testStr = testStr.substring(sindex + 1,testStr.length);
                  sindex = testStr.indexOf(",");
               }
               if(-1 < sindex)
               {
                  tokenType = testStr.substring(0,sindex);
                  attribs = testStr.substring(sindex + 1,testStr.length);
               }
               else
               {
                  tokenType = testStr;
               }
               if(null != tokenType && 0 < tokenType.length)
               {
                  info = insertinfo.split(":");
                  if(2 > info.length)
                  {
                     info.push("");
                  }
                  if(3 > info.length)
                  {
                     info.push("-1");
                  }
                  if("object" == tokenType || "count" == tokenType)
                  {
                     token = ZLocUtils.tk(info[0],info[1],attribs,int(info[2]));
                  }
                  else if("name" == tokenType)
                  {
                     token = ZLocUtils.tn(info[0],info[1]);
                  }
               }
            }
         }
         return token;
      }
      
      public static function formatNumber(raw:Number) : String
      {
         return LocaleFormatter.formatNumber(raw);
      }
      
      public static function formatDateTime(date:Date) : String
      {
         var part:String = null;
         var tmp:String = null;
         var result:String = "";
         var localeStr:String = ZLoc.instance.localeCode;
         var pattern:String = "";
         if(DEFAULT_LOCALE == localeStr)
         {
            pattern = "n/j/Y h:i:s a";
         }
         else
         {
            pattern = "d/m/Y H:i:s";
         }
         for(var i:int = 0; i < pattern.length; i++)
         {
            tmp = pattern.charAt(i);
            part = LocaleFormatter.getFormattedDateTime(tmp,date);
            if(null != part && "" != part)
            {
               result += part;
            }
            else
            {
               result += tmp;
            }
         }
         return result;
      }
      
      public static function getAcceptedLocales() : Array
      {
         var acceptedLocalesStr:String = "";
         if(Config.DEBUG_MODE)
         {
            acceptedLocalesStr = Global.farmGameSettingsManager.getString("supportedLocalesDev",DEFAULT_LOCALE);
         }
         else
         {
            acceptedLocalesStr = Global.farmGameSettingsManager.getString("supportedLocalesProd",DEFAULT_LOCALE);
         }
         return acceptedLocalesStr.split(",");
      }
      
      public static function getDefaultLocale() : String
      {
         return DEFAULT_LOCALE;
      }
      
      public static function getRuntimeLanguageFallback(proposedLocale:String) : String
      {
         var locale:String = null;
         var localeParts:Array = null;
         var acceptedLocales:Array = ZLocUtils.getAcceptedLocales();
         var goodLocale:String = "";
         var foundFallback:Boolean = false;
         var proposedLocaleParts:Array = proposedLocale.split("_");
         for each(locale in acceptedLocales)
         {
            if(proposedLocale == locale)
            {
               goodLocale = locale;
               foundFallback = true;
               break;
            }
            localeParts = locale.split("_");
            if(proposedLocaleParts[0] == localeParts[0])
            {
               goodLocale = locale;
               foundFallback = true;
               break;
            }
         }
         if(!foundFallback)
         {
            goodLocale = DEFAULT_LOCALE;
         }
         return goodLocale;
      }
      
      public static function localizeWithOverrideSuffix(zLocPkg:String, zLocKey:String, zLocReplacements:Object, suffix:String) : String
      {
         var result:String = null;
         if(ZLocUtils.hasString(zLocPkg,zLocKey + suffix))
         {
            result = ZLocUtils.t(zLocPkg,zLocKey + suffix,zLocReplacements);
         }
         else
         {
            result = ZLocUtils.t(zLocPkg,zLocKey,zLocReplacements);
         }
         return result;
      }
      
      public static function getZLocString(pkg:String, featurePrefix:String, defaultPrefix:String, suffix:String, attributes:Object = null) : String
      {
         return ZLocUtils.getFailoverLocString([new ZLocFailoverEntry(pkg,featurePrefix + "_" + suffix),new ZLocFailoverEntry(pkg,defaultPrefix + "_" + suffix)],attributes);
      }
      
      public static function getFailoverLocString(failoverEntryArray:Array, params:Object = null) : String
      {
         var found:Boolean = false;
         var failoverEntry:ZLocFailoverEntry = null;
         var errorString:String = null;
         var iEntry:uint = 0;
         var entry:ZLocFailoverEntry = null;
         var result:String = "";
         if(failoverEntryArray == null || failoverEntryArray.length == 0)
         {
            ErrorManager.addError("failoverLocString: failoverEntryArray is null");
         }
         else
         {
            found = false;
            for each(failoverEntry in failoverEntryArray)
            {
               if(failoverEntry)
               {
                  if(ZLocUtils.hasString(failoverEntry.pkg,failoverEntry.key))
                  {
                     result = ZLocUtils.t(failoverEntry.pkg,failoverEntry.key,params);
                     found = true;
                     break;
                  }
               }
            }
            if(found == false)
            {
               errorString = "failoverLocString: no strings found:";
               for(iEntry = 0; iEntry < failoverEntryArray.length; iEntry++)
               {
                  entry = failoverEntryArray[iEntry];
                  if(entry)
                  {
                     errorString += " index " + iEntry + ": " + entry.pkg + ":" + entry.key;
                  }
               }
               ErrorManager.addError(errorString);
            }
         }
         return result;
      }
      
      public static function splitPkgKey(pkgkey:Array) : void
      {
         var pkg:String = null;
         var key:String = null;
         var compoundChar:String = null;
         var pkgArray:Array = null;
         var keyArray:Array = null;
         if(Boolean(pkgkey) && pkgkey.length > 0)
         {
            pkg = null;
            key = null;
            pkg = pkgkey[0];
            if(pkgkey.length >= 2)
            {
               key = pkgkey[1];
            }
            compoundChar = ":";
            if(Boolean(pkg) && pkg.indexOf(compoundChar) >= 0)
            {
               pkgArray = pkg.split(compoundChar);
               pkg = pkgArray[0];
               if(key == null)
               {
                  key = pkgArray[1];
               }
            }
            else if(Boolean(key) && key.indexOf(compoundChar) >= 0)
            {
               keyArray = key.split(compoundChar);
               key = keyArray[1];
               if(pkg == null)
               {
                  pkg = keyArray[0];
               }
            }
            pkgkey[0] = pkg;
            pkgkey[1] = key;
         }
         else
         {
            if(pkgkey == null)
            {
               pkgkey = new Array();
            }
            pkgkey[0] = null;
            pkgkey[1] = null;
         }
      }
      
      public static function setErrorStatSampleRate(rate:int) : void
      {
         if(rate >= 0)
         {
            m_errorStatSampleRate = rate;
         }
      }
   }
}

