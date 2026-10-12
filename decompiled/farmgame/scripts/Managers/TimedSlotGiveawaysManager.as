package Managers
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.XMLKeys;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TRefreshGifts;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.IconToasterWindow;
   import Widgets.Windows.TimedGiveawayWindow;
   import Widgets.Windows.TimedSlotRewardTemplatePopup;
   
   public class TimedSlotGiveawaysManager
   {
      
      private static const GIVEAWAY_FEATURENAME:String = "timedSlotGiveaways";
      
      private static const XML_SLOTGIVEAWAY:String = "slotGiveaway";
      
      private static const XML_NAME:String = "name";
      
      private static const XML_ATTR_NAME:String = "@name";
      
      private static const XML_PREREQ:String = "prereq";
      
      private static const XML_PREREQS:String = "prereqs";
      
      private static const XML_SWF:String = "swf";
      
      private static const XML_SWF2:String = "swf2";
      
      private static const XML_ATTR_PATH:String = "@path";
      
      private static const XML_ATTR_PREREQ:String = "@prereq";
      
      private static const XML_LEADERBOARD:String = "leaderboard";
      
      private static const XML_PLACE:String = "place";
      
      private static const XML_ATTR_GIFT:String = "@gift";
      
      private static const XML_ATTR_RANK:String = "@rank";
      
      private static const XML_DISABLE:String = "disable";
      
      private static const XML_ATTR_PASTDAY:String = "@pastDay";
      
      private static const XML_PASTDAY:String = "pastDay";
      
      private static const XML_REWARDSWF:String = "rewardSwf";
      
      private static const XML_PRORATION:String = "proration";
      
      private static const XML_ATTR_MAXPRORATION:String = "@maxPercent";
      
      private static const OBJECT_MAX_PRORATION:String = "maxProration";
      
      private static const XML_STARTDATE:String = "startDate";
      
      private static const XML_ATTR_DAY:String = "@day";
      
      private static const XML_ATTR_RESETONMISS:String = "@resetOnMiss";
      
      private static const XML_ATTR_TEMPLATE:String = "@template";
      
      private static const XML_TEMPLATE:String = "template";
      
      private static const XML_IMAGES:String = "images";
      
      private static const XML_ITEMS:String = "items";
      
      private static const XML_REWARDS:String = "rewards";
      
      private static const XML_BACKGROUND:String = "mainBackground";
      
      private static const XML_TOP_BACKGROUND:String = "topBackground";
      
      private static const XML_TITLE_COLOR:String = "titleColor";
      
      private static const XML_TEXT_COLOR:String = "stringColor";
      
      private static const XML_BITMAP_COLOR:String = "bitmapColor";
      
      private static const XML_REWARD_BACKGROUND:String = "rewardBackground";
      
      private static const XML_SMART_TUNING:String = "smartSystemTuning";
      
      private static const FO_GIFT_GIVEN:String = "GiftName";
      
      private static const FO_ITEM_CREDITS:String = "GiftCredits";
      
      private static const FO_SLOT_UNLOCKED:String = "unlocked";
      
      private static const FULL_PERCENTAGE:Number = 100;
      
      public static const HOURS_BETWEEN_POSTS:Number = 3;
      
      private static const FEATUREFREQUENCY_NAME:String = "FarmStandReward";
      
      protected static var m_activeGiveaways:Object = {};
      
      protected static var m_lastAsks:Object = {};
      
      private static var m_latestGiftObject:Object = null;
      
      private static var m_prevGiftObject:Object = null;
      
      public function TimedSlotGiveawaysManager()
      {
         super();
      }
      
      public static function initializeGiveaways() : void
      {
         var giveawayData:XML = null;
         var giveawayObject:Object = null;
         var giveawayName:String = null;
         var iconData:Object = null;
         var tooltipZLocKey:String = null;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(TimedSlotGiveawaysManager.GIVEAWAY_FEATURENAME);
         var giveaways:XMLList = null;
         if(Boolean(feature) && feature.hasOwnProperty(TimedSlotGiveawaysManager.XML_SLOTGIVEAWAY))
         {
            giveaways = feature[TimedSlotGiveawaysManager.XML_SLOTGIVEAWAY];
         }
         if(giveaways)
         {
            for each(giveawayData in giveaways)
            {
               giveawayObject = TimedSlotGiveawaysManager.setUpGiveaway(giveawayData);
               if(Boolean(giveawayObject) && giveawayObject.hasOwnProperty(TimedSlotGiveawaysManager.XML_NAME))
               {
                  giveawayName = giveawayObject[TimedSlotGiveawaysManager.XML_NAME];
                  m_activeGiveaways[giveawayName] = giveawayObject;
                  iconData = {};
                  tooltipZLocKey = "FarmGame:Button_" + giveawayName;
                  if(ZLocUtils.hasString(tooltipZLocKey))
                  {
                     iconData.iconTooltip = ZLocUtils.tk_pk_asTitle(tooltipZLocKey);
                  }
                  Global.hud.rightSideIconQueue.addIcon(giveawayName,DynamicIconQueue.ADD_BY_PRIORITY,null,iconData);
               }
            }
         }
      }
      
      private static function getGiveawayOptionsDataByName(giveawayName:String) : Object
      {
         var giveawayObject:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName);
         if(giveawayObject == null)
         {
            rewardGiftsForOldGiveAway(giveawayName);
            giveawayObject = initGiveawaySmartSystemProgress(giveawayName);
         }
         return giveawayObject;
      }
      
      private static function initGiveawaySmartSystemProgress(giveawayName:String) : Object
      {
         var items:Array = null;
         var length:uint = 0;
         var item:Object = null;
         var prereqList:XMLList = null;
         var creditsNeeded:int = 0;
         var smartSystemMultiplier:Number = NaN;
         var smartSystemHelpCount:int = 0;
         var creditsKey:String = null;
         var unlockKey:String = null;
         var itemName:String = null;
         var daysSinceStart:int = 0;
         var i:int = 0;
         var prereq:Object = null;
         var giveawayObject:Object = {};
         if(isSmartTimedGiveawayEnabled(giveawayName))
         {
            items = getAllItemDataForGiveaway(giveawayName);
            if(items)
            {
               length = items.length;
               item = {};
               prereqList = null;
               creditsNeeded = 0;
               smartSystemMultiplier = Global.player.getSmartSystemFarmStandConfig().multiplier;
               smartSystemHelpCount = 0;
               creditsKey = "";
               unlockKey = "";
               itemName = "";
               daysSinceStart = getDaysSinceStart(giveawayName);
               for(i = 0; i < length; i++)
               {
                  item = items[i];
                  if(Boolean(item) && Boolean(item.hasOwnProperty(XML_PREREQ)) && item.hasOwnProperty(XML_NAME))
                  {
                     itemName = item[XML_NAME];
                     creditsKey = FO_ITEM_CREDITS + itemName;
                     prereqList = item[XML_PREREQ] as XMLList;
                     for each(prereq in prereqList)
                     {
                        if(prereq[XMLKeys.ATTR_TYPE] == PrerequisiteConstants.PREREQUISITE_FEATURE_OPTION)
                        {
                           creditsNeeded = int(prereq[XMLKeys.ATTR_VALUE]);
                           smartSystemHelpCount = Math.floor(creditsNeeded * smartSystemMultiplier);
                           giveawayObject[creditsKey] = smartSystemHelpCount;
                           break;
                        }
                     }
                     unlockKey = FO_SLOT_UNLOCKED + itemName;
                     if(item.hasOwnProperty(XML_PASTDAY) && int(item[XML_PASTDAY]) - 1 <= daysSinceStart)
                     {
                        giveawayObject[unlockKey] = true;
                     }
                  }
               }
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName,giveawayObject);
            }
         }
         return giveawayObject;
      }
      
      private static function isSmartTimedGiveawayEnabled(giveawayName:String) : Boolean
      {
         var giveaway:Object = null;
         var result:Boolean = false;
         if(m_activeGiveaways.hasOwnProperty(giveawayName))
         {
            giveaway = m_activeGiveaways[giveawayName];
            result = (giveaway[XML_SMART_TUNING] != "" || giveaway[XML_SMART_TUNING] != null) && Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_SMART_FARMSTAND) > 0;
         }
         return result;
      }
      
      public static function isTemplateUIEnabled(giveawayName:String) : Boolean
      {
         var giveaway:Object = null;
         var result:Boolean = false;
         if(m_activeGiveaways.hasOwnProperty(giveawayName))
         {
            giveaway = m_activeGiveaways[giveawayName];
            result = giveaway[XML_TEMPLATE] == true && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TEMPLATE_FARMSTAND) > 0;
         }
         return result;
      }
      
      public static function validGiveaway(giveawayName:String) : Boolean
      {
         var result:Boolean = false;
         if(!m_activeGiveaways.hasOwnProperty(giveawayName))
         {
            TimedSlotGiveawaysManager.initializeGiveaways();
         }
         if(m_activeGiveaways.hasOwnProperty(giveawayName))
         {
            result = true;
         }
         return result;
      }
      
      public static function showGiveawayWindow(giveawayName:String) : void
      {
         UI.displayPopup(new TimedGiveawayWindow(giveawayName),true,giveawayName + "Giveaway",true);
      }
      
      private static function setUpGiveaway(giveawayData:XML, preReqCheck:Boolean = true) : Object
      {
         var giveawayName:String = null;
         var preReqXML:XML = null;
         var isTemplate:Boolean = false;
         var prereqName:String = null;
         var leaderboardData:XMLList = null;
         var places:Object = null;
         var leaderboardDataXML:XML = null;
         var giveawayImages:XMLList = null;
         var images:Array = null;
         var giveawayImageXML:XML = null;
         var giveawayItems:XMLList = null;
         var items:Array = null;
         var giveawayItemXML:XML = null;
         var itemObject:Object = null;
         var result:Object = null;
         if(Boolean(giveawayData) && giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_NAME))
         {
            giveawayName = giveawayData.@name;
            result = {"name":giveawayName};
            preReqXML = null;
            if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_PREREQS))
            {
               preReqXML = giveawayData.child(TimedSlotGiveawaysManager.XML_PREREQS)[0];
            }
            if(preReqCheck == false || preReqXML == null || PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseXmlNodePrereqs(preReqXML.prereq)))
            {
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_SWF) && giveawayData[TimedSlotGiveawaysManager.XML_SWF].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PATH))
               {
                  result[TimedSlotGiveawaysManager.XML_SWF] = giveawayData[TimedSlotGiveawaysManager.XML_SWF][TimedSlotGiveawaysManager.XML_ATTR_PATH];
                  if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_SWF2) && giveawayData[TimedSlotGiveawaysManager.XML_SWF2].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PATH) && giveawayData[TimedSlotGiveawaysManager.XML_SWF2].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PREREQ))
                  {
                     prereqName = giveawayData[TimedSlotGiveawaysManager.XML_SWF2][TimedSlotGiveawaysManager.XML_ATTR_PREREQ];
                     if(PrerequisiteUtility.checkPrereqByName(prereqName))
                     {
                        result[TimedSlotGiveawaysManager.XML_SWF] = giveawayData[TimedSlotGiveawaysManager.XML_SWF2][TimedSlotGiveawaysManager.XML_ATTR_PATH];
                     }
                  }
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_LEADERBOARD))
               {
                  result[TimedSlotGiveawaysManager.XML_LEADERBOARD] = true;
                  if(giveawayData[TimedSlotGiveawaysManager.XML_LEADERBOARD].hasOwnProperty(TimedSlotGiveawaysManager.XML_PLACE))
                  {
                     leaderboardData = giveawayData[TimedSlotGiveawaysManager.XML_LEADERBOARD][TimedSlotGiveawaysManager.XML_PLACE];
                     places = new Object();
                     for each(leaderboardDataXML in leaderboardData)
                     {
                        places[leaderboardDataXML[TimedSlotGiveawaysManager.XML_ATTR_RANK]] = leaderboardDataXML[TimedSlotGiveawaysManager.XML_ATTR_GIFT];
                     }
                     result["leaderboardGift"] = places;
                  }
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_DISABLE) && giveawayData.disable.hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PASTDAY))
               {
                  result[TimedSlotGiveawaysManager.XML_DISABLE] = giveawayData[TimedSlotGiveawaysManager.XML_DISABLE][TimedSlotGiveawaysManager.XML_ATTR_PASTDAY];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_REWARDSWF) && giveawayData.rewardSwf.hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PATH))
               {
                  result[TimedSlotGiveawaysManager.XML_REWARDSWF] = giveawayData[TimedSlotGiveawaysManager.XML_REWARDSWF][TimedSlotGiveawaysManager.XML_ATTR_PATH];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_BACKGROUND) && giveawayData[TimedSlotGiveawaysManager.XML_BACKGROUND].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PATH))
               {
                  result[TimedSlotGiveawaysManager.XML_BACKGROUND] = giveawayData[TimedSlotGiveawaysManager.XML_BACKGROUND][TimedSlotGiveawaysManager.XML_ATTR_PATH];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_TOP_BACKGROUND) && giveawayData[TimedSlotGiveawaysManager.XML_TOP_BACKGROUND].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PATH))
               {
                  result[TimedSlotGiveawaysManager.XML_TOP_BACKGROUND] = giveawayData[TimedSlotGiveawaysManager.XML_TOP_BACKGROUND][TimedSlotGiveawaysManager.XML_ATTR_PATH];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_REWARD_BACKGROUND) && giveawayData[TimedSlotGiveawaysManager.XML_REWARD_BACKGROUND].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_PATH))
               {
                  result[TimedSlotGiveawaysManager.XML_REWARD_BACKGROUND] = giveawayData[TimedSlotGiveawaysManager.XML_REWARD_BACKGROUND][TimedSlotGiveawaysManager.XML_ATTR_PATH];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_SMART_TUNING))
               {
                  result[TimedSlotGiveawaysManager.XML_SMART_TUNING] = giveawayData[TimedSlotGiveawaysManager.XML_SMART_TUNING];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_PRORATION))
               {
                  if(giveawayData[TimedSlotGiveawaysManager.XML_PRORATION].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_MAXPRORATION))
                  {
                     result[TimedSlotGiveawaysManager.OBJECT_MAX_PRORATION] = giveawayData[TimedSlotGiveawaysManager.XML_PRORATION][TimedSlotGiveawaysManager.XML_ATTR_MAXPRORATION];
                  }
                  else
                  {
                     result[TimedSlotGiveawaysManager.OBJECT_MAX_PRORATION] = TimedSlotGiveawaysManager.FULL_PERCENTAGE;
                  }
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_STARTDATE) && giveawayData[TimedSlotGiveawaysManager.XML_STARTDATE].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_DAY))
               {
                  result[TimedSlotGiveawaysManager.XML_STARTDATE] = giveawayData[TimedSlotGiveawaysManager.XML_STARTDATE][TimedSlotGiveawaysManager.XML_ATTR_DAY];
               }
               else if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_RESETONMISS))
               {
                  result["resetOnMiss"] = giveawayData[TimedSlotGiveawaysManager.XML_ATTR_RESETONMISS];
               }
               isTemplate = false;
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_TEMPLATE))
               {
                  isTemplate = Boolean(giveawayData[TimedSlotGiveawaysManager.XML_ATTR_TEMPLATE]);
               }
               result[TimedSlotGiveawaysManager.XML_TEMPLATE] = isTemplate;
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_TITLE_COLOR))
               {
                  result[TimedSlotGiveawaysManager.XML_TITLE_COLOR] = giveawayData[TimedSlotGiveawaysManager.XML_TITLE_COLOR];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_TEXT_COLOR))
               {
                  result[TimedSlotGiveawaysManager.XML_TEXT_COLOR] = giveawayData[TimedSlotGiveawaysManager.XML_TEXT_COLOR];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_BITMAP_COLOR))
               {
                  result[TimedSlotGiveawaysManager.XML_BITMAP_COLOR] = giveawayData[TimedSlotGiveawaysManager.XML_BITMAP_COLOR];
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_IMAGES))
               {
                  giveawayImages = giveawayData[TimedSlotGiveawaysManager.XML_IMAGES];
                  images = new Array();
                  for each(giveawayImageXML in giveawayImages.children())
                  {
                     images.push(FarmGameSettingsManager.parseXmlAttributesToObject(giveawayImageXML));
                  }
                  result[TimedSlotGiveawaysManager.XML_IMAGES] = images;
               }
               if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_ITEMS))
               {
                  giveawayItems = giveawayData[TimedSlotGiveawaysManager.XML_ITEMS];
                  items = new Array();
                  for each(giveawayItemXML in giveawayItems.children())
                  {
                     itemObject = FarmGameSettingsManager.parseXmlAttributesToObject(giveawayItemXML);
                     if(ObjectUtil.pathExists(giveawayItemXML,[TimedSlotGiveawaysManager.XML_PREREQS,TimedSlotGiveawaysManager.XML_PREREQ]))
                     {
                        itemObject[TimedSlotGiveawaysManager.XML_PREREQ] = giveawayItemXML[TimedSlotGiveawaysManager.XML_PREREQS][TimedSlotGiveawaysManager.XML_PREREQ] as XMLList;
                     }
                     if(ObjectUtil.pathExists(giveawayItemXML,[TimedSlotGiveawaysManager.XML_REWARDS]))
                     {
                        itemObject[TimedSlotGiveawaysManager.XML_REWARDS] = giveawayItemXML[TimedSlotGiveawaysManager.XML_REWARDS] as XMLList;
                     }
                     items.push(itemObject);
                  }
                  result[TimedSlotGiveawaysManager.XML_ITEMS] = items;
               }
            }
            else
            {
               result = null;
            }
         }
         return result;
      }
      
      public static function getImageForGiveaway(giveawayName:String) : String
      {
         var daysSinceStart:int = 0;
         var imagesLength:int = 0;
         var index:int = 0;
         var imageObject:Object = null;
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("images"))
         {
            daysSinceStart = getDaysSinceStart(giveawayName);
            imagesLength = int(giveaway.images.length);
            for(index = 0; index < imagesLength; index++)
            {
               imageObject = giveaway.images[index];
               if(!(imageObject.hasOwnProperty("pastDay") && int(imageObject["pastDay"]) - 1 <= daysSinceStart))
               {
                  break;
               }
               result = imageObject["path"];
            }
         }
         return result;
      }
      
      public static function getItemDataByName(giveawayName:String, itemName:String) : Object
      {
         var len:uint = 0;
         var i:uint = 0;
         var result:Object = null;
         var items:Array = TimedSlotGiveawaysManager.getAllItemDataForGiveaway(giveawayName);
         if(items)
         {
            len = items.length;
            for(i = 0; i < len; i++)
            {
               if(Boolean(items[i].hasOwnProperty("name")) && items[i]["name"] == itemName)
               {
                  result = items[i];
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getAllItemDataForGiveaway(giveawayName:String) : Array
      {
         var giveaway:Object = null;
         var result:Array = null;
         if(Boolean(m_activeGiveaways) && m_activeGiveaways.hasOwnProperty(giveawayName))
         {
            giveaway = m_activeGiveaways[giveawayName];
            if(giveaway.hasOwnProperty("items"))
            {
               result = giveaway["items"];
            }
         }
         return result;
      }
      
      public static function getItemsForGiveaway(giveawayName:String) : Array
      {
         var daysSinceStart:int = 0;
         var giveawayObject:Object = null;
         var itemsList:Array = null;
         var itemsLength:int = 0;
         var oneUnlockableLeft:Boolean = false;
         var index:int = 0;
         var itemObject:Object = null;
         var unlocked:Boolean = false;
         var giftItem:FarmItem = null;
         var giftKey:String = null;
         var result:Array = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("items"))
         {
            result = new Array();
            daysSinceStart = getDaysSinceStart(giveawayName);
            giveawayObject = getGiveawayOptionsDataByName(giveawayName);
            itemsList = giveaway["items"];
            itemsLength = int(itemsList.length);
            oneUnlockableLeft = true;
            for(index = 0; index < itemsLength; index++)
            {
               itemObject = itemsList[index];
               unlocked = Boolean(giveawayObject) && giveawayObject[FO_SLOT_UNLOCKED + itemObject["name"]] != null && giveawayObject[FO_SLOT_UNLOCKED + itemObject["name"]] == true;
               if(itemObject != null && !unlocked && itemObject.hasOwnProperty("pastDay") && int(itemObject["pastDay"]) - 1 > daysSinceStart)
               {
                  itemObject[FO_SLOT_UNLOCKED] = false;
                  if(oneUnlockableLeft)
                  {
                     itemObject["unlockable"] = oneUnlockableLeft;
                     oneUnlockableLeft = false;
                  }
               }
               else
               {
                  itemObject[FO_SLOT_UNLOCKED] = true;
                  if(m_latestGiftObject == null)
                  {
                     m_latestGiftObject = {};
                  }
                  else if(m_latestGiftObject.hasOwnProperty(giveawayName))
                  {
                     if(m_prevGiftObject == null)
                     {
                        m_prevGiftObject = {};
                     }
                     m_prevGiftObject[giveawayName] = m_latestGiftObject[giveawayName];
                  }
                  m_latestGiftObject[giveawayName] = itemObject;
               }
               result[index] = itemObject;
            }
         }
         if(shouldResetOnMissForGiveaway(giveawayName) && m_prevGiftObject != null && m_prevGiftObject.hasOwnProperty(giveawayName))
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(m_prevGiftObject[giveawayName]["name"]);
            giftKey = TimedSlotGiveawaysManager.FO_GIFT_GIVEN + giftItem.name;
            if(!giveawayObject.hasOwnProperty(giftKey) || giveawayObject[giftKey] != true)
            {
               giveawayObject = {"lastMissed":GlobalEngine.serverTime / 1000};
               m_latestGiftObject = null;
               m_prevGiftObject = null;
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName,giveawayObject);
               result = getItemsForGiveaway(giveawayName);
            }
         }
         return result;
      }
      
      private static function isItemUnlockedbyDay(giveawayName:String, itemName:String) : Boolean
      {
         var len:uint = 0;
         var i:uint = 0;
         var result:Boolean = false;
         var items:Array = TimedSlotGiveawaysManager.getAllItemDataForGiveaway(giveawayName);
         var daysSinceStart:int = getDaysSinceStart(giveawayName);
         if(items)
         {
            len = items.length;
            for(i = 0; i < len; i++)
            {
               if(Boolean(items[i].hasOwnProperty("name")) && items[i]["name"] == itemName)
               {
                  if(Boolean(items[i].hasOwnProperty(XML_PASTDAY)) && int(items[i][XML_PASTDAY]) - 1 <= daysSinceStart)
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      public static function getSwfForGiveaway(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("swf"))
         {
            result = giveaway["swf"];
         }
         return result;
      }
      
      public static function getBackground(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty(XML_BACKGROUND))
         {
            result = giveaway[XML_BACKGROUND];
         }
         return result;
      }
      
      public static function getTopBackground(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty(XML_TOP_BACKGROUND))
         {
            result = giveaway[XML_TOP_BACKGROUND];
         }
         return result;
      }
      
      public static function getRewardBackground(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty(XML_REWARD_BACKGROUND))
         {
            result = giveaway[XML_REWARD_BACKGROUND];
         }
         return result;
      }
      
      public static function getTitleColor(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty(XML_TITLE_COLOR))
         {
            result = giveaway[XML_TITLE_COLOR];
         }
         return result;
      }
      
      public static function getTextColor(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty(XML_TEXT_COLOR))
         {
            result = giveaway[XML_TEXT_COLOR];
         }
         return result;
      }
      
      public static function getBitmapColor(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty(XML_BITMAP_COLOR))
         {
            result = giveaway[XML_BITMAP_COLOR];
         }
         return result;
      }
      
      public static function isDisabled(giveawayName:String) : Boolean
      {
         return TimedSlotGiveawaysManager.daysUntilDisabled(giveawayName) <= 0;
      }
      
      public static function awardLeaderboardGift(giveawayName:String, rank:int = 0) : Boolean
      {
         var result:Boolean = false;
         var itemName:String = TimedSlotGiveawaysManager.getLeaderboardGift(giveawayName,rank);
         var giveawayFOptions:Object = getGiveawayOptionsDataByName(giveawayName);
         var trophyKey:String = TimedSlotGiveawaysManager.FO_GIFT_GIVEN + itemName;
         if(Boolean(itemName != null) && Boolean(giveawayFOptions) && giveawayFOptions[trophyKey] != true)
         {
            Global.player.addGift(itemName);
            giveawayFOptions[trophyKey] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName,giveawayFOptions);
         }
         return result;
      }
      
      public static function daysUntilDisabled(giveawayName:String) : Number
      {
         var result:Number = 1;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("disable"))
         {
            result = giveaway["disable"] - TimedSlotGiveawaysManager.getDaysSinceStart(giveawayName);
         }
         return result;
      }
      
      public static function hasLeaderboard(giveawayName:String) : Boolean
      {
         var result:Boolean = false;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("leaderboard"))
         {
            result = Boolean(giveaway["leaderboard"]);
         }
         return result;
      }
      
      public static function getLeaderboardGift(giveawayName:String, rank:int = 0) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(rank == 0)
         {
            rank = 1;
         }
         if(Boolean(giveaway) && Boolean(giveaway.hasOwnProperty("leaderboardGift")) && Boolean(giveaway["leaderboardGift"].hasOwnProperty(rank)))
         {
            result = giveaway["leaderboardGift"][rank];
         }
         return result;
      }
      
      public static function shouldResetOnMissForGiveaway(giveawayName:String) : Boolean
      {
         var result:Boolean = false;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("resetOnMiss"))
         {
            result = giveaway.resetOnMiss == "true";
         }
         return result;
      }
      
      public static function getRewardSwfPath(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("rewardSwf"))
         {
            result = giveaway["rewardSwf"];
         }
         return result;
      }
      
      public static function getStartDateForGiveaway(giveawayName:String) : String
      {
         var result:String = null;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("startDate"))
         {
            result = giveaway["startDate"];
         }
         return result;
      }
      
      public static function getDaysSinceStart(giveawayName:String) : int
      {
         var currentSeconds:int = 0;
         var result:int = 0;
         var startDate:String = getStartDateForGiveaway(giveawayName);
         var savedGiveawayObject:Object = null;
         if(startDate)
         {
            result = FarmGameUtil.getDaysSinceStartDate(startDate);
         }
         else if(shouldResetOnMissForGiveaway(giveawayName))
         {
            savedGiveawayObject = getGiveawayOptionsDataByName(giveawayName);
            if(savedGiveawayObject != null && savedGiveawayObject.hasOwnProperty("lastDayMissed"))
            {
               currentSeconds = GlobalEngine.serverTime / 1000;
               result = (currentSeconds - int(savedGiveawayObject["lastDayMissed"])) / FarmGameUtil.NUM_SECS_IN_DAY;
            }
         }
         else if(Config.DEBUG_MODE)
         {
            UI.displayMessage("Giveaway is missing a start date and does not reset on miss, needs one or the other");
         }
         return result;
      }
      
      public static function getDaysSinceStartFromXML(giveawayData:XML) : int
      {
         var result:int = 99999;
         var startDate:String = "";
         if(giveawayData.hasOwnProperty(TimedSlotGiveawaysManager.XML_STARTDATE) && giveawayData[TimedSlotGiveawaysManager.XML_STARTDATE].hasOwnProperty(TimedSlotGiveawaysManager.XML_ATTR_DAY))
         {
            startDate = giveawayData[TimedSlotGiveawaysManager.XML_STARTDATE][TimedSlotGiveawaysManager.XML_ATTR_DAY];
            result = FarmGameUtil.getDaysSinceStartDate(startDate);
         }
         return result;
      }
      
      public static function getCurrentObjectPastDay(giveawayName:String) : String
      {
         if(m_latestGiftObject == null || !m_latestGiftObject.hasOwnProperty(giveawayName))
         {
            getItemsForGiveaway(giveawayName);
         }
         var result:String = null;
         if(Boolean(m_latestGiftObject) && Boolean(m_latestGiftObject.hasOwnProperty(giveawayName)) && Boolean(m_latestGiftObject[giveawayName].hasOwnProperty("pastDay")))
         {
            result = m_latestGiftObject[giveawayName]["pastDay"];
         }
         return result;
      }
      
      public static function getCurrentObjectName(giveawayName:String) : String
      {
         if(m_latestGiftObject == null || !m_latestGiftObject.hasOwnProperty(giveawayName))
         {
            getItemsForGiveaway(giveawayName);
         }
         var result:String = null;
         if(Boolean(m_latestGiftObject) && Boolean(m_latestGiftObject.hasOwnProperty(giveawayName)) && Boolean(m_latestGiftObject[giveawayName].hasOwnProperty("name")))
         {
            result = m_latestGiftObject[giveawayName]["name"];
         }
         return result;
      }
      
      public static function giveGifts(giveawayName:String) : void
      {
         if(m_latestGiftObject == null || !m_latestGiftObject.hasOwnProperty(giveawayName))
         {
            getItemsForGiveaway(giveawayName);
         }
         if(Boolean(m_latestGiftObject) && Boolean(m_latestGiftObject[giveawayName]) && Boolean(m_latestGiftObject[giveawayName].hasOwnProperty("name")))
         {
            if(TimedSlotGiveawaysManager.giveGiftsIfAllowed(giveawayName))
            {
               TransactionManager.addTransaction(new TransactionWithCallBack("TimedGiveawayService.giveawayItems",refreshGifts,giveawayName),true);
            }
         }
      }
      
      public static function refreshGifts(result:Object = null) : void
      {
         TransactionManager.addTransaction(new TRefreshGifts(),true);
      }
      
      private static function giveGiftsIfAllowed(giveawayName:String) : Boolean
      {
         var len:uint = 0;
         var i:uint = 0;
         var item:Object = null;
         var unlockedKey:String = null;
         var result:Boolean = false;
         var items:Array = TimedSlotGiveawaysManager.getItemsForGiveaway(giveawayName);
         var daysSinceStart:int = TimedSlotGiveawaysManager.getDaysSinceStart(giveawayName);
         var giveawayObject:Object = getGiveawayOptionsDataByName(giveawayName);
         if(items)
         {
            len = items.length;
            for(i = 0; i < len; i++)
            {
               item = items[i];
               if(item)
               {
                  unlockedKey = FO_SLOT_UNLOCKED + item["name"];
                  if(!item.hasOwnProperty("pastDay") || int(item["pastDay"]) - 1 <= daysSinceStart || giveawayObject.hasOwnProperty(unlockedKey) && giveawayObject[unlockedKey] == true)
                  {
                     if(item.hasOwnProperty("prereq"))
                     {
                        if(PrerequisiteUtility.evalPrereqsXML(item["prereq"] as XMLList))
                        {
                           result = giveGift(giveawayName,item["name"]) || result;
                        }
                     }
                     else if(m_latestGiftObject.hasOwnProperty(giveawayName) && item["name"] == m_latestGiftObject[giveawayName]["name"])
                     {
                        result = giveGift(giveawayName,item["name"]) || result;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      private static function giveGift(giveawayName:String, giftName:String) : Boolean
      {
         var featureOptionMan:FeatureOptionsManager = null;
         var giveawayObject:Object = null;
         var giftKey:String = null;
         var itemData:Object = null;
         var result:Boolean = false;
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(giftName);
         if(giftItem)
         {
            featureOptionMan = FeatureOptionsManager.getInstance();
            giveawayObject = getGiveawayOptionsDataByName(giveawayName);
            giftKey = TimedSlotGiveawaysManager.FO_GIFT_GIVEN + giftItem.name;
            if(!giveawayObject.hasOwnProperty(giftKey) || giveawayObject[giftKey] == false)
            {
               Global.player.addGift(giftItem.name);
               TimedSlotGiveawaysManager.showGiftRewardDialog(giveawayName,giftName);
               if(giveawayObject[giftKey] != true)
               {
                  itemData = TimedSlotGiveawaysManager.getItemDataByName(giveawayName,giftName);
                  UserRewardUtil.grantUserRewardsFromXml(new XML((itemData[TimedSlotGiveawaysManager.XML_REWARDS] as XMLList).toXMLString()));
               }
               giveawayObject[giftKey] = true;
               featureOptionMan.setFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName,giveawayObject);
               result = true;
            }
         }
         return result;
      }
      
      private static function showGiftRewardDialog(giveawayName:String, giftName:String) : void
      {
         var rewardAsset:String = null;
         var rewardWindow:TimedSlotRewardTemplatePopup = null;
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(giftName);
         if(giftItem != null)
         {
            rewardAsset = TimedSlotGiveawaysManager.getRewardSwfPath(giveawayName);
            if(rewardAsset == null)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","GiveawayGifted",{"gift":giftItem.friendlyTitle}),0,null,"",true);
            }
            else
            {
               rewardWindow = new TimedSlotRewardTemplatePopup(rewardAsset,giveawayName,giftItem);
               UI.displayPopup(rewardWindow,false);
            }
         }
      }
      
      public static function buyItem(giveawayName:String, giftName:String, cashCost:int) : void
      {
         var itemData:Object = null;
         var rewardList:XMLList = null;
         var rewardXMLString:String = null;
         var featureOptionMan:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var giveawayObject:Object = getGiveawayOptionsDataByName(giveawayName);
         var giftKey:String = TimedSlotGiveawaysManager.FO_GIFT_GIVEN + giftName;
         var firstEarn:Boolean = !giveawayObject[giftKey];
         giveawayObject[giftKey] = true;
         featureOptionMan.setFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName,giveawayObject);
         if(firstEarn)
         {
            itemData = TimedSlotGiveawaysManager.getItemDataByName(giveawayName,giftName);
            rewardList = itemData[TimedSlotGiveawaysManager.XML_REWARDS] as XMLList;
            if(rewardList != null)
            {
               rewardXMLString = rewardList.toXMLString();
               UserRewardUtil.grantUserRewardsFromXml(new XML(rewardXMLString));
            }
         }
         Global.player.addGift(giftName,"0",1);
         Global.player.cash -= cashCost;
         TransactionManager.addTransaction(new TransactionWithCallBack("TimedGiveawayService.buyItem",null,giveawayName,giftName),true);
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(giftName);
         ToasterManager.getInstance().addImmediate(new IconToasterWindow(giftItem.iconUrl,ZLocUtils.t_pk("Dialogs","FindInGiftbox",{"itemName":giftItem.friendlyTitle})));
      }
      
      public static function getCreditsForGiveawayItem(giveawayName:String, giftName:String) : Number
      {
         var unlockedKey:String = null;
         var result:Number = 0;
         var giveawayObject:Object = getGiveawayOptionsDataByName(giveawayName);
         var creditKey:String = TimedSlotGiveawaysManager.FO_ITEM_CREDITS + giftName;
         if(isSmartTimedGiveawayEnabled(giveawayName))
         {
            unlockedKey = FO_SLOT_UNLOCKED + giftName;
            if(Boolean(giveawayObject) && giveawayObject.hasOwnProperty(creditKey))
            {
               if(TimedSlotGiveawaysManager.isItemUnlockedbyDay(giveawayName,giftName) || giveawayObject.hasOwnProperty(unlockedKey) && giveawayObject[unlockedKey] == true)
               {
                  result = Number(giveawayObject[creditKey]);
               }
            }
         }
         else if(Boolean(giveawayObject) && giveawayObject.hasOwnProperty(creditKey))
         {
            result = Number(giveawayObject[creditKey]);
         }
         return result;
      }
      
      public static function getCreditsNeededForGiveawayItem(giveawayName:String, giftName:String) : Number
      {
         var prereqList:XMLList = null;
         var prereq:Object = null;
         var result:Number = 0;
         var itemData:Object = TimedSlotGiveawaysManager.getItemDataByName(giveawayName,giftName);
         if(Boolean(itemData) && itemData.hasOwnProperty(TimedSlotGiveawaysManager.XML_PREREQ))
         {
            prereqList = itemData[TimedSlotGiveawaysManager.XML_PREREQ] as XMLList;
            for each(prereq in prereqList)
            {
               if(prereq["@type"] == PrerequisiteConstants.PREREQUISITE_FEATURE_OPTION)
               {
                  result = Number(prereq["@value"]);
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getTotalCredits(giveawayName:String) : Number
      {
         var len:uint = 0;
         var i:uint = 0;
         var item:Object = null;
         var result:Number = 0;
         var items:Array = TimedSlotGiveawaysManager.getAllItemDataForGiveaway(giveawayName);
         if(items)
         {
            len = items.length;
            for(i = 0; i < len; i++)
            {
               item = items[i];
               if(item.hasOwnProperty("name"))
               {
                  result += getCreditsForGiveawayItem(giveawayName,item["name"]);
               }
            }
         }
         return result;
      }
      
      public static function isProrated(giveawayName:String) : Boolean
      {
         var result:Boolean = false;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && Boolean(giveaway.hasOwnProperty("maxProration")) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMSTAND_PRORATED) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            result = true;
         }
         return result;
      }
      
      public static function getMaxProration(giveawayName:String) : Number
      {
         var result:Number = 0;
         var giveaway:Object = m_activeGiveaways[giveawayName];
         if(Boolean(giveaway) && giveaway.hasOwnProperty("maxProration"))
         {
            result = giveaway.maxProration / TimedSlotGiveawaysManager.FULL_PERCENTAGE;
         }
         return result;
      }
      
      public static function canAsk(giveawayName:String) : Boolean
      {
         return !TimedSlotGiveawaysManager.isDisabled(giveawayName) && Global.player.canShowFeatureWithFeatureFrequencyInSeconds(TimedSlotGiveawaysManager.FEATUREFREQUENCY_NAME,FarmGameUtil.NUM_SECS_IN_HOUR * TimedSlotGiveawaysManager.HOURS_BETWEEN_POSTS);
      }
      
      public static function askForItem(giveawayName:String, giftName:String) : void
      {
         m_lastAsks[giveawayName] = Global.player.getFeatureLastShown(TimedSlotGiveawaysManager.FEATUREFREQUENCY_NAME);
         Global.player.setFeatureLastShown(TimedSlotGiveawaysManager.FEATUREFREQUENCY_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TransactionWithCallBack("TimedGiveawayService.askForItem",ZCacheUtil.applyPartial(TimedSlotGiveawaysManager.askCallback,null,[giveawayName]),giveawayName,giftName));
      }
      
      private static function askCallback(giveawayName:String, result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(TimedSlotGiveawaysManager.friendRewardCallback,null,[giveawayName,result]));
         }
         if(!result || result.hasOwnProperty("postSuccessful") && !result.postSuccessful)
         {
            TimedSlotGiveawaysManager.resetAsksForFailure(giveawayName);
         }
      }
      
      private static function friendRewardCallback(giveawayName:String, result:Object, success:Boolean) : void
      {
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
         if(success)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(TimedSlotGiveawaysManager.FEATUREFREQUENCY_NAME),true);
         }
         else
         {
            TimedSlotGiveawaysManager.resetAsksForFailure(giveawayName);
         }
      }
      
      private static function resetAsksForFailure(giveawayName:String) : void
      {
         Global.player.setFeatureLastShown(TimedSlotGiveawaysManager.FEATUREFREQUENCY_NAME,m_lastAsks[giveawayName],false);
         var currPopup:TimedGiveawayWindow = UI.getCurrentPopup() as TimedGiveawayWindow;
         if(currPopup != null && currPopup.getFeatureName() == giveawayName)
         {
            currPopup.refreshWindow();
         }
      }
      
      public static function unlock(giveawayName:String, giftName:String, unlockCost:Number) : void
      {
         var giveawayObject:Object = null;
         if(Global.player.canBuyCash(unlockCost))
         {
            Global.player.cash -= unlockCost;
            giveawayObject = getGiveawayOptionsDataByName(giveawayName);
            giveawayObject[FO_SLOT_UNLOCKED + giftName] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName,giveawayObject);
            TransactionManager.addTransaction(new TransactionWithCallBack("TimedGiveawayService.unlockItem",null,giveawayName,giftName));
         }
      }
      
      private static function rewardGiftsForOldGiveAway(newGiveawayName:String) : Boolean
      {
         var giveawayOldObjects:Object = null;
         var oldGiveAwayName:String = null;
         var oldGiveawayXML:XML = null;
         var giveawayOldObject:Object = null;
         var result:Boolean = false;
         var newGiveawayObject:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,newGiveawayName);
         if(newGiveawayObject == null)
         {
            giveawayOldObjects = FeatureOptionsManager.getInstance().getFeatureData(FeatureOptionsManager.TIMED_GIVEAWAY);
            if(giveawayOldObjects)
            {
               for(oldGiveAwayName in giveawayOldObjects)
               {
                  oldGiveawayXML = Global.farmGameSettingsManager.getFeatureXMLByName(TimedSlotGiveawaysManager.GIVEAWAY_FEATURENAME,TimedSlotGiveawaysManager.XML_SLOTGIVEAWAY,oldGiveAwayName);
                  if(oldGiveawayXML)
                  {
                     if(TimedSlotGiveawaysManager.getDaysSinceStartFromXML(oldGiveawayXML) < 28)
                     {
                        giveawayOldObject = TimedSlotGiveawaysManager.setUpOldGiveaway(oldGiveawayXML);
                        if(giveawayOldObject)
                        {
                           m_activeGiveaways[oldGiveAwayName] = giveawayOldObject;
                           result = TimedSlotGiveawaysManager.giveGiftsIfAllowed(oldGiveAwayName);
                        }
                     }
                  }
               }
               if(result)
               {
                  TransactionManager.addTransaction(new TransactionWithCallBack("TimedGiveawayService.giveawayItems",refreshGifts,newGiveawayName),true);
               }
            }
         }
         return result;
      }
      
      private static function setUpOldGiveaway(giveawayData:XML) : Object
      {
         return setUpGiveaway(giveawayData,false);
      }
   }
}

