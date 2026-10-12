package Classes
{
   import Classes.Constants.SuperCropConstants;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.SuperCropFriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Engine.Constants;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.Market.MarketSuperCropUnlockWindow;
   import flash.events.MouseEvent;
   
   public class SuperEnabledMasterySign extends Decoration
   {
      
      private static const ASK_FOR_VOUCHES:String = "askForVouches";
      
      private static const CLICKED_SEEN_FLAG:String = "hasClickedSuperEnabledMasterySign";
      
      private static const SUPER_ENABLED_SIGN_COUNTER:String = "cropmasterysign";
      
      private var m_superCropCode:String;
      
      private var m_regularCropCode:String;
      
      private var m_regularCropName:String;
      
      private var m_friendSet:SuperCropFriendSet;
      
      private var m_hasClicked:Boolean;
      
      private var m_isHighlighted:Boolean;
      
      private var m_hasRequestedFriendSet:Boolean;
      
      public function SuperEnabledMasterySign(itemName:String = null)
      {
         super(itemName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_superCropCode = m_item.getStringFromDataSource("superItemCode");
            this.m_regularCropCode = m_item.getStringFromDataSource("masteredItemCode");
         }
         else
         {
            this.m_superCropCode = m_item.xml.superItemCode;
            this.m_regularCropCode = m_item.xml.masteredItemCode;
         }
         this.m_regularCropName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_regularCropCode);
         this.m_hasClicked = true;
         this.m_hasRequestedFriendSet = false;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(!this.m_hasRequestedFriendSet && TransactionManager.canSendTransactions())
         {
            if(!Global.worldManager.isVisiting() && !Global.player.isSuperCropUnlocked(this.m_superCropCode))
            {
               this.m_friendSet = new SuperCropFriendSet(SuperCropConstants.SUPERCROP_UNLOCK_FRIEND_SET,this.m_superCropCode,this.onGetFriendSetData);
               this.m_friendSet.initializeData();
            }
            this.m_hasRequestedFriendSet = true;
         }
      }
      
      private function onGetFriendSetData(friendSet:FriendSet, result:Object) : void
      {
         this.m_hasClicked = Global.player.getSeenFlag(CLICKED_SEEN_FLAG + "_" + this.m_item.name);
         if(Boolean(result) && Boolean(result.error) && result.error == "alreadyUnlocked")
         {
            this.m_friendSet = null;
            Global.player.unlockSuperCrop(this.m_superCropCode);
         }
         else if(Boolean(result) && Boolean(result.error) && result.error == "notMastered")
         {
            this.m_friendSet = null;
         }
         if(!this.m_hasClicked && this.canAskForVouches())
         {
            this.highlight(true);
         }
      }
      
      private function highlight(isHighlight:Boolean) : void
      {
         this.m_isHighlighted = isHighlight;
         this.showHighlight(isHighlight,Constants.COLOR_HIGHLIGHT_BLUE);
      }
      
      override public function onClick() : void
      {
         if(!this.m_hasClicked && this.canAskForVouches())
         {
            Global.player.setSeenFlag(CLICKED_SEEN_FLAG + "_" + this.m_item.name,true);
            this.onAskForVouches();
            StatsManager.count(SuperCropConstants.SUPERCROP_COUNTER,SUPER_ENABLED_SIGN_COUNTER,this.m_regularCropName,"glow","click",Global.worldManager.currentWorldType);
            this.m_hasClicked = true;
            this.highlight(false);
         }
         else
         {
            super.onClick();
         }
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.highlight(this.m_isHighlighted);
      }
      
      override protected function getMenuItems() : Array
      {
         var superCrop:FarmItem = null;
         var label:String = null;
         var items:Array = super.getMenuItems();
         if(this.canAskForVouches())
         {
            superCrop = Global.farmGameSettingsManager.getFarmItemByCode(this.m_superCropCode);
            label = ZLocUtils.t("Dialogs","SuperCrops_Ask_For_Vouches",{"item":ZLocUtils.tk_pk(superCrop.friendlyName)});
            items.push({
               "label":label,
               "action":ASK_FOR_VOUCHES
            });
         }
         return items;
      }
      
      private function canAskForVouches() : Boolean
      {
         return !Global.worldManager.isVisiting() && !Global.player.isSuperCropUnlocked(this.m_superCropCode) && Boolean(this.m_friendSet) && this.m_friendSet.initialized;
      }
      
      private function onAskForVouches() : void
      {
         var regularCrop:HarvestableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_regularCropCode) as HarvestableItem;
         var superCrop:HarvestableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_superCropCode) as HarvestableItem;
         var dialog:MarketSuperCropUnlockWindow = new MarketSuperCropUnlockWindow(superCrop,regularCrop,null,null,this.m_friendSet);
         UI.displayPopup(dialog,false);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case ASK_FOR_VOUCHES:
                  StatsManager.count(SuperCropConstants.SUPERCROP_COUNTER,SUPER_ENABLED_SIGN_COUNTER,this.m_regularCropName,"askFriends","",Global.worldManager.currentWorldType);
                  this.onAskForVouches();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override protected function get defaultTooltip() : String
      {
         return DynamicMasterySign.getDefaultTooltip(this.m_item);
      }
   }
}

