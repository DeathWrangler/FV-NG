package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.QueuedIcon;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.IconToasterWindow;
   import Widgets.Windows.MOTD.LongWeekEndDelightMOTD;
   
   public class WeekendDelightManager
   {
      
      private static var m_instance:WeekendDelightManager;
      
      public static const FEATURE_OPTION:String = "long_weekend_delight_data";
      
      private static const ACTION_GRANT_REWARD:String = "grantRewardOfTheDay";
      
      private var m_featureXML:XML = null;
      
      private const SERVICE_CLASS:String = "WeekendDelightService";
      
      private var m_item:FarmItem = null;
      
      private var m_currentDayNum:int = -1;
      
      public function WeekendDelightManager(enforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : WeekendDelightManager
      {
         if(!m_instance)
         {
            m_instance = new WeekendDelightManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public function getStartDate() : Date
      {
         return new Date(2015,1,13,0,0);
      }
      
      public function getItemForSlot(index:int) : FarmItem
      {
         var name:String = null;
         if(this.m_featureXML == null)
         {
            this.m_featureXML = Global.farmGameSettingsManager.getFeatureXML("LongWeekendDeligt");
         }
         var list:XMLList = this.m_featureXML.items.item;
         var length:int = list.length();
         var featureItem:XML = list[index];
         if(featureItem.hasOwnProperty("@name"))
         {
            name = featureItem.@name;
         }
         return Global.farmGameSettingsManager.getFarmItemByName(name);
      }
      
      public function getItemOfTheDay() : FarmItem
      {
         if(this.m_item == null)
         {
            this.m_item = this.getItemForSlot(this.getCurrentDayNumber());
         }
         return this.m_item;
      }
      
      public function getCurrentDayNumber() : int
      {
         var itemsList:XMLList = null;
         var itemXML:XML = null;
         var itemInfo:Object = null;
         var startDate:String = null;
         if(this.m_currentDayNum == -1)
         {
            if(this.m_featureXML == null)
            {
               this.m_featureXML = Global.farmGameSettingsManager.getFeatureXML("LongWeekendDeligt");
            }
            if(this.m_featureXML)
            {
               itemsList = this.m_featureXML.prereqs.prereq as XMLList;
               for each(itemXML in itemsList)
               {
                  itemInfo = FarmGameSettingsManager.parseXmlAttributesToObject(itemXML);
                  if(itemInfo.hasOwnProperty("type") && itemInfo["type"] == "start_time")
                  {
                     startDate = itemInfo["value"];
                  }
               }
               if(startDate)
               {
                  this.m_currentDayNum = FarmGameUtil.getDaysSinceStartDate(startDate);
               }
            }
         }
         if(this.m_currentDayNum < 0)
         {
            this.m_currentDayNum = 0;
         }
         return this.m_currentDayNum;
      }
      
      public function grantItemOfTheDay() : void
      {
         var data:Object = null;
         var dayNumber:int = 0;
         var dayString:String = null;
         var prizeName:FarmItem = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LONG_WEEKEND_DELIGHT) > 0)
         {
            data = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LONG_WEEKEND_DELIGHT,WeekendDelightManager.FEATURE_OPTION);
            dayNumber = WeekendDelightManager.getInstance().getCurrentDayNumber();
            dayString = "day" + dayNumber.toString();
            if(!(Boolean(data) && Boolean(data.hasOwnProperty(dayString)) && 1 == data[dayString]))
            {
               if(data == null)
               {
                  data = new Object();
               }
               data[dayString] = 1;
               prizeName = this.getItemOfTheDay();
               if(prizeName.type == "seed")
               {
                  FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LONG_WEEKEND_DELIGHT,prizeName.name,1);
               }
               else
               {
                  Global.player.addGift(prizeName.name,"0",1);
               }
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LONG_WEEKEND_DELIGHT,WeekendDelightManager.FEATURE_OPTION,data);
               TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,ACTION_GRANT_REWARD,this.onGrantComplete,["selected"]),true);
               if(LongWeekEndDelightMOTD.selected == true)
               {
                  GlobalEngine.socialNetwork.publishFeedStory("WeekendDelight",{
                     "gift_name":WeekendDelightManager.getInstance().getItemOfTheDay().friendlyTitle,
                     "images":[{
                        "href":"{SN_APP_URL}",
                        "src":WeekendDelightManager.getInstance().getItemOfTheDay().icon
                     }]
                  },[],false);
               }
               this.logButtonClick();
            }
         }
      }
      
      private function onGrantComplete(result:Object) : void
      {
         var item:FarmItem = null;
         if(!(Boolean(result) && result.hasOwnProperty("error")))
         {
            item = this.getItemOfTheDay();
            if(item.type == "seed")
            {
               ToasterManager.getInstance().addImmediate(new IconToasterWindow(item.iconUrl,ZLocUtils.t_pk("Dialogs","WeekendDelight_crop_unlock_toaster",{"itemName":item.friendlyTitle})));
            }
            else
            {
               ToasterManager.getInstance().addImmediate(new IconToasterWindow(item.iconUrl,ZLocUtils.t_pk("Dialogs","FindInGiftbox",{"itemName":item.friendlyTitle})));
            }
         }
      }
      
      public function isItemeCollected(dayNumber:int) : Boolean
      {
         var result:Boolean = false;
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LONG_WEEKEND_DELIGHT,WeekendDelightManager.FEATURE_OPTION);
         var dayString:String = "day" + dayNumber.toString();
         if(Boolean(data) && Boolean(data.hasOwnProperty(dayString)) && 1 == data[dayString])
         {
            result = true;
         }
         return result;
      }
      
      public function hideWeekendDelightHud() : void
      {
         if(this.isItemeCollected(this.getCurrentDayNumber()))
         {
            this.removeFeatureHudIcon();
         }
      }
      
      public function removeFeatureHudIcon() : void
      {
         var hudIcon1:QueuedIcon = null;
         var hudIcon:QueuedIcon = null;
         if(Global.hud.rightSideIconQueue)
         {
            hudIcon1 = Global.hud.rightSideIconQueue.getIconByImage("assets/hud/hud_icon_queue/HUD_WeekendDelight2015.png");
            hudIcon = Global.hud.rightSideIconQueue.getIconByFeatureName("LongWeekendDeligt");
            if(hudIcon)
            {
               Global.hud.rightSideIconQueue.removeIcon(hudIcon);
            }
            Global.hud.refreshIconVisibility();
         }
      }
      
      private function logButtonClick() : void
      {
         FarmStatsManager.count("long_weekend_delight","button_clicked");
      }
      
      public function shouldTaskBeShown() : Boolean
      {
         var result:Boolean = false;
         if(this.isItemeCollected(this.getCurrentDayNumber()))
         {
            result = false;
         }
         else
         {
            result = true;
         }
         return result;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
