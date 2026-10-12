package Widgets.Windows
{
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Managers.AOEManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class AOEResourceSurfaceWindow extends FarmWindow
   {
      
      private static const FEATURE_SURFACING_FLAG:String = "surfacing_prompt";
      
      private static const BACK_OFF_TIME_IN_SEC:Number = 30 * FarmGameUtil.NUM_SECS_IN_DAY;
      
      protected var m_surfaceRewardItem:FarmItem = null;
      
      protected var m_targetItem:FarmItem = null;
      
      private var m_hasAoeResource:Boolean = false;
      
      public function AOEResourceSurfaceWindow(assetUrl:String, surfaceRewardItem:FarmItem, targetItem:FarmItem, hasAoeResource:Boolean)
      {
         super(assetUrl);
         this.m_surfaceRewardItem = surfaceRewardItem;
         this.m_hasAoeResource = hasAoeResource;
         this.m_targetItem = targetItem;
      }
      
      private static function getFeatureFreqKey(featureKey:String) : String
      {
         return featureKey + FEATURE_SURFACING_FLAG;
      }
      
      public static function conditionallyShowPrompt(harvestedResource:MapResource, featureConfigName:String, buildingName:String) : Boolean
      {
         var potentialAOEResources:Array = null;
         var shouldShowPrompt:Boolean = false;
         var hasAoeResource:Boolean = false;
         var arrClassNameSearched:Array = null;
         var className:String = null;
         var hasCheckedClass:Array = null;
         var i:int = 0;
         var rawXml:XML = null;
         var surfaceRewardItem:FarmItem = null;
         var xml:XMLList = null;
         var surfaceRewardItemName:String = null;
         var assetUrl:String = null;
         var showedUi:Boolean = false;
         var aoeManager:AOEManager = AOEManager.getInstance();
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var coolDown:Number = Global.player.getFeatureLastShown(getFeatureFreqKey(featureConfigName)) + BACK_OFF_TIME_IN_SEC;
         if(coolDown <= now)
         {
            shouldShowPrompt = false;
            hasAoeResource = false;
            arrClassNameSearched = new Array();
            if(harvestedResource.hasAreasOfEffect())
            {
               className = harvestedResource.getFarmItemClassName();
               shouldShowPrompt = !aoeManager.aoeResourceClassHasFreeAreas(className);
               hasAoeResource = true;
            }
            else
            {
               potentialAOEResources = aoeManager.getPotentialAoeResources(harvestedResource);
               if(potentialAOEResources.length == 0)
               {
                  shouldShowPrompt = true;
               }
               else
               {
                  hasCheckedClass = new Array();
                  for(i = 0; i < potentialAOEResources.length; i++)
                  {
                     className = potentialAOEResources[0].getFarmItemClassName();
                     if(className != null && className != "" && !hasCheckedClass[className])
                     {
                        shouldShowPrompt = !aoeManager.aoeResourceClassHasFreeAreas(className);
                        hasCheckedClass[className] = true;
                     }
                  }
                  hasAoeResource = true;
               }
            }
            if(shouldShowPrompt && !isObjectInWorldByAttribute("buildingName",buildingName))
            {
               rawXml = Global.farmGameSettingsManager.getFeatureXML(featureConfigName);
               if(Boolean(rawXml) && rawXml.hasOwnProperty("onboard"))
               {
                  xml = rawXml.onboard;
                  surfaceRewardItemName = xml["surfaceRewardItem"];
                  if(Boolean(surfaceRewardItemName) && surfaceRewardItemName != "")
                  {
                     surfaceRewardItem = Global.farmGameSettingsManager.getFarmItemByName(surfaceRewardItemName);
                  }
                  assetUrl = xml["surfaceDialogUrl"];
               }
               if(surfaceRewardItem != null && assetUrl != "")
               {
                  showedUi = true;
                  Global.player.setFeatureLastShown(getFeatureFreqKey(featureConfigName),GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
                  UI.displayPopup(new AOEResourceSurfaceWindow(assetUrl,surfaceRewardItem,harvestedResource.getItem(),hasAoeResource));
               }
            }
         }
         return showedUi;
      }
      
      private static function isObjectInWorldByAttribute(attribute:String, value:String) : Boolean
      {
         var attrVal:String = null;
         var worldObj:WorldObject = null;
         var item:FarmItem = null;
         var result:Boolean = false;
         var objects:Array = Global.world.getObjects();
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         var foundAttribute:Boolean = false;
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            worldObj = objects[objIdx] as WorldObject;
            if(worldObj != null && worldObj is ItemInstance)
            {
               item = (worldObj as ItemInstance).getItem();
               if(isInDataSourceExperiment)
               {
                  attrVal = item.getStringFromDataSource(attribute);
                  foundAttribute = attrVal == value;
               }
               else
               {
                  foundAttribute = Boolean(item.xml) && item.xml.hasOwnProperty("@" + attribute) && item.xml["@" + attribute] == value;
               }
               if(foundAttribute)
               {
                  result = true;
                  break;
               }
            }
            objIdx++;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var titleLocKey:String = null;
         var prefix:String = null;
         var itemXml:XML = null;
         super.postLoadComplete();
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","TreeHarvestOrchard_accept"),this.onAccept));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","TreeHarvestOrchardSurfacing_title")));
         var buildingName:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(this.m_surfaceRewardItem.hasPropertyInDataSource("buildingName"))
            {
               buildingName = this.m_surfaceRewardItem.getStringFromDataSource("buildingName");
            }
         }
         else
         {
            itemXml = this.m_surfaceRewardItem.xml;
            if(Boolean(itemXml != null) && Boolean(itemXml.hasOwnProperty("@buildingName")) && Boolean(itemXml.@buildingName.length()))
            {
               buildingName = itemXml.@buildingName;
            }
         }
         if(buildingName)
         {
            prefix = buildingName;
         }
         else
         {
            prefix = this.m_surfaceRewardItem.name;
         }
         if(this.m_hasAoeResource)
         {
            titleLocKey = prefix + "Surfacing_body_full";
         }
         else
         {
            titleLocKey = prefix + "Surfacing_body_none";
         }
         var message:String = ZLocUtils.t("Dialogs",titleLocKey);
         addWidget(new ZwTextField(m_window.popupBox_tf,message));
      }
      
      protected function onAccept(event:Event) : void
      {
         close();
         var surfaceRewardItemName:String = this.m_surfaceRewardItem.name;
         var fromMarket:Boolean = Global.player.getGiftCountForItem(surfaceRewardItemName) > 0 ? false : true;
         Global.world.enterForcePlaceMode(surfaceRewardItemName,fromMarket,0,true,!fromMarket);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}

