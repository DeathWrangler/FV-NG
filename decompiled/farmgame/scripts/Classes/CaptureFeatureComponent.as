package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Engine.Classes.Observer.IObserver;
   import Managers.CaptureFeatureManager;
   import Managers.FeatureOptionsManager;
   
   public class CaptureFeatureComponent implements IObserver
   {
      
      public static const FEATURE_SEEN_INCREMENT:int = 30000;
      
      protected var m_featureName:String = null;
      
      protected var m_data:Object = null;
      
      private var m_featureData:Object;
      
      private var m_featureItems:Array;
      
      private var m_treatPrice:int = 2;
      
      private var m_defaultItem:String = null;
      
      private var m_buildingData:Array;
      
      private var m_feedData:Object;
      
      private var m_isDataLoaded:Boolean = false;
      
      private var m_stringsPrefix:String = "";
      
      private var m_statsPrefix:String = "";
      
      public function CaptureFeatureComponent(featureName:String)
      {
         var featureItem:XML = null;
         var name:String = null;
         var item:FarmItem = null;
         var requirements:XML = null;
         var buildingLevel:int = 0;
         var level:XML = null;
         var feedData:XML = null;
         this.m_featureData = {};
         this.m_featureItems = [];
         this.m_buildingData = new Array();
         this.m_feedData = {};
         super();
         this.m_featureName = featureName;
         this.m_featureData = new Object();
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         var newFeatureItemsPerBuildingLevel:Object = {};
         this.m_treatPrice = feature.hasOwnProperty("@treatPrice") ? int(feature.@treatPrice) : this.m_treatPrice;
         this.m_defaultItem = feature.hasOwnProperty("@defaultItem") ? feature.@defaultItem : this.m_defaultItem;
         this.m_stringsPrefix = feature.hasOwnProperty("@stringsPrefix") ? feature.@stringsPrefix : this.m_stringsPrefix;
         this.m_statsPrefix = feature.hasOwnProperty("@statsPrefix") ? feature.@statsPrefix : this.m_statsPrefix;
         var list:XMLList = feature.featureItems.item;
         var length:int = list.length();
         for(var i:int = 0; i < length; i++)
         {
            featureItem = list[i];
            if(featureItem.hasOwnProperty("@name"))
            {
               name = featureItem.@name;
               this.m_featureData[name] = featureItem;
               item = Global.farmGameSettingsManager.getFarmItemByName(name);
               if(item)
               {
                  this.m_featureItems.push(item);
               }
               requirements = featureItem.requirements[0];
               if(requirements.hasOwnProperty("@building_level"))
               {
                  buildingLevel = parseInt(requirements.@building_level.toString());
                  if(!newFeatureItemsPerBuildingLevel[buildingLevel])
                  {
                     newFeatureItemsPerBuildingLevel[buildingLevel] = 1;
                  }
                  else
                  {
                     ++newFeatureItemsPerBuildingLevel[buildingLevel];
                  }
               }
            }
         }
         this.m_buildingData = new Array();
         var buildingLevelList:XMLList = feature.buildingProgression.level;
         length = buildingLevelList.length();
         for(i = 0; i < length; i++)
         {
            level = buildingLevelList[i];
            this.m_buildingData.push({
               "level":i,
               "capturedGophers":level.@capturedGophers,
               "maxTreats":level.@maxTreats,
               "image":level.@image,
               "newGophersCount":newFeatureItemsPerBuildingLevel[i]
            });
         }
         this.m_feedData = {};
         var feedTypes:XMLList = feature.feedConfig.feed;
         length = feedTypes.length();
         for(var j:int = 0; j < length; j++)
         {
            feedData = feedTypes[j];
            this.m_feedData[feedData.@source] = {
               "source":feedData.@source,
               "throttle":feedData.@throttle,
               "throttleTime":feedData.@throttleTime
            };
         }
         this.m_isDataLoaded = true;
         this.m_data = this.getFeatureData();
      }
      
      public function notify(event:String, data:Object) : void
      {
      }
      
      protected function shouldShowFeature() : Boolean
      {
         var showChance:Number = NaN;
         var show:Boolean = false;
         if(this.isPlayerOptedIn())
         {
            showChance = Global.flashHotParams["GOPHER_GARDEN_FEATURE_SHOW_CHANCE"] ? Number(Global.flashHotParams["GOPHER_GARDEN_FEATURE_SHOW_CHANCE"]) : CaptureFeatureManager.FEATURE_SHOW_CHANCE_IN;
         }
         else
         {
            showChance = Global.flashHotParams["GOPHER_GARDEN_FEATURE_SHOW_CHANCE_OUT"] ? Number(Global.flashHotParams["GOPHER_GARDEN_FEATURE_SHOW_CHANCE_OUT"]) : CaptureFeatureManager.FEATURE_SHOW_CHANCE_OUT;
         }
         var serverTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(serverTime >= this.m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_TIME])
         {
            show = Math.random() < showChance;
         }
         return show;
      }
      
      public function isPlayerOptedIn() : Boolean
      {
         return this.m_data[CaptureFeatureManager.FEATURE_OPT_STATUS] == CaptureFeatureManager.FEATURE_OPT_IN;
      }
      
      protected function getSecondsFeatureShouldShow() : int
      {
         return Global.farmGameSettingsManager.getInt(this.m_featureName + "_secondsGopherShouldShow",90);
      }
      
      protected function getNextTimeAfterSeen() : Number
      {
         var serverTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return serverTime + FEATURE_SEEN_INCREMENT;
      }
      
      public function getFeatureData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,this.m_featureName);
         if(!data)
         {
            data = this.createFeatureData();
         }
         return data;
      }
      
      public function setFeatureData(data:Object = null) : void
      {
         if(data)
         {
            this.m_data = data;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,this.m_featureName,this.m_data);
      }
      
      public function createFeatureData() : Object
      {
         var data:Object = new Object();
         var currentTimeInSeconds:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_TIME] = currentTimeInSeconds;
         data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_FEATURE_ITEM] = this.m_defaultItem;
         data[CaptureFeatureManager.FEATURE_CAPTURED_COUNT] = new Object();
         data[CaptureFeatureManager.FEATURE_TREAT_COUNT] = 1;
         data[CaptureFeatureManager.FEATURE_OPT_STATUS] = 1;
         this.m_data = data;
         this.setFeatureData();
         return data;
      }
      
      public function get buildingData() : Array
      {
         return this.m_buildingData;
      }
      
      public function get featureData() : Object
      {
         return this.m_featureData;
      }
      
      public function get featureItems() : Array
      {
         return this.m_featureItems;
      }
      
      public function get feedData() : Object
      {
         return this.m_feedData;
      }
      
      public function get treatPrice() : int
      {
         return this.m_treatPrice;
      }
      
      public function get dataLoaded() : Boolean
      {
         return this.m_isDataLoaded;
      }
      
      public function get statsPrefix() : String
      {
         return this.m_statsPrefix;
      }
      
      public function get stringsPrefix() : String
      {
         return this.m_stringsPrefix;
      }
   }
}

