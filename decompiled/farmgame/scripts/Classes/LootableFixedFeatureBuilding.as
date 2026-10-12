package Classes
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Events.SuperBuildingCompleteEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.OlyInnovationManager;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.LootableFixedFeatureBuilding.PostBuildingCompleteWindow;
   import Widgets.Windows.LootableFixedFeatureBuilding.PostHarvestWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   
   public class LootableFixedFeatureBuilding extends FixedFeatureBuilding
   {
      
      private static const DEFAULT_ARROW_ICON_URL:String = "assets/decorations/giftIcon.png";
      
      private static const declareDynamicClasses:Array = [PostHarvestWindow];
      
      public function LootableFixedFeatureBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function setArrowPosition() : void
      {
         super.setArrowPosition();
         var offset:Point = this.getHarvestArrowOffset();
         m_arrow.x += offset.x;
         m_arrow.y += offset.y;
      }
      
      protected function getArrowIconUrl() : String
      {
         return DEFAULT_ARROW_ICON_URL;
      }
      
      override public function isShareFeedHandledByHarvester() : Boolean
      {
         return false;
      }
      
      override public function isFrictionLessExpansionCompleteFlow(source:int = 0) : Boolean
      {
         var result:Boolean = false;
         if(source == FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI)
         {
            result = true;
         }
         else if(source == FeatureBuilding.ACTION_SOURCE_CONTEXT_MENU)
         {
            result = false;
         }
         return result;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var delieveredItem:FarmItem = null;
         var futureItem:FarmItem = null;
         var numRewards:int = 0;
         var className:String = null;
         var tempClass:Class = null;
         var dialogUrl:String = null;
         var dialogBgUrl:String = null;
         var locPrefix:String = null;
         var npcUrl:String = null;
         super.onHarvestComplete(result);
         if(Boolean(result.rewardItem) && Boolean(result.rewardLink) && Boolean(result.postHarvestData))
         {
            delieveredItem = Global.farmGameSettingsManager.getFarmItemByName(result.rewardItem);
            futureItem = Global.farmGameSettingsManager.getFarmItemByCode(result.postHarvestData.itemCode);
            numRewards = int(result.numRewards);
            if(Boolean(delieveredItem) && Boolean(futureItem))
            {
               if(this.hasReachedMaxExpansionLevel())
               {
                  futureItem = null;
               }
               className = this.getHarvestWindowClassName();
               if(className != null)
               {
                  try
                  {
                     tempClass = getDefinitionByName(className) as Class;
                     if(tempClass != null)
                     {
                        dialogUrl = this.getHarvestWindowDialogUrl();
                        dialogBgUrl = this.getHarvestWindowDialogBgUrl();
                        locPrefix = this.getHarvestWindowLocPrefix();
                        npcUrl = this.getHarvestWindowNpcUrl();
                        UI.displayPopup(new tempClass(dialogUrl,delieveredItem,numRewards,futureItem,result.rewardLink,locPrefix,this.getItemName(),dialogBgUrl,npcUrl));
                     }
                  }
                  catch(e:ReferenceError)
                  {
                     ErrorManager.addError("onHarvestComplete dialog class not found: " + className,ErrorManager.ERROR_FAILED_TO_LOAD);
                  }
               }
            }
         }
      }
      
      override public function beginCompleteExpansionFlow(source:int = 0, forceExpansionFlow:Boolean = false) : void
      {
         super.beginCompleteExpansionFlow(source,!hasReachedMaxExpansionLevel());
      }
      
      override protected function generateHarvestArrow() : DisplayObject
      {
         var arrowIndicator:ArrowIndicatorWindow = null;
         var iconPath:String = Global.getAssetURL(this.getArrowIconUrl());
         arrowIndicator = new ArrowIndicatorWindow(iconPath,"","");
         arrowIndicator.visible = true;
         return arrowIndicator;
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         var dialogUrl:String = null;
         var dialogBgUrl:String = null;
         var dialog:PostBuildingCompleteWindow = null;
         super.onStoreComplete(result);
         if(result.completeRewardItem)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               dialogUrl = this.getItem().getStringFromDataSource("completeRewardDialog");
               dialogBgUrl = this.getItem().getStringFromDataSource("completeRewardDialogBackground");
            }
            else
            {
               dialogUrl = this.getItem().xml.completeRewardDialog.toString();
               dialogBgUrl = this.getItem().xml.completeRewardDialogBackground.toString();
            }
            dialog = new PostBuildingCompleteWindow(dialogUrl,Global.farmGameSettingsManager.getFarmItemByName(result.completeRewardItem),this.getItemName(),this,dialogBgUrl);
            UI.displayPopup(dialog);
            Global.player.addGift(result.completeRewardItem);
            if(hasReachedMaxExpansionLevel())
            {
               GlobalEventManager.getInstance().dispatchEvent(new Event(OlyInnovationManager.EVENT_BB_COMPLETE));
               GlobalEventManager.getInstance().dispatchEvent(new SuperBuildingCompleteEvent(SuperBuildingCompleteEvent.BUILDING_COMPLETED,{"name":m_itemName}));
            }
         }
      }
   }
}

