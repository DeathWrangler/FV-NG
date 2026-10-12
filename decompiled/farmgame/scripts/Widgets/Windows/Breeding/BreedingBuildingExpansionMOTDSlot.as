package Widgets.Windows.Breeding
{
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BreedingBuildingExpansionMOTDSlot extends ZwSlotFrame
   {
      
      public static const STATE_EXPANDED_ONCE:int = 0;
      
      public static const STATE_IN_PROGRESS:int = 1;
      
      public static const STATE_NO_BUILDINGS:int = 2;
      
      public static const STATE_UNEXPANDED:int = 3;
      
      public static const STATE_FULLY_EXPANDED:int = 4;
      
      public static const EVENT_BUY:String = "buy";
      
      public static const EVENT_FIRST_EXPAND:String = "first_expand";
      
      public static const EVENT_ADVANCED_EXPAND:String = "advanced_expand";
      
      public static const EVENT_COMPLETE_NOW:String = "complete_now";
      
      public static const BUY_BUILDING_CLICKED_EVENT:String = "buy_building";
      
      public static const BUY_EXPANSION_CLICKED_EVENT:String = "buy_expansion";
      
      private var m_priceWidget:ZwBaseWidget;
      
      private var m_salePriceWidget:ZwBaseWidget;
      
      private var m_longButton:FarmAnimatedTextButton;
      
      private var m_shortButton:FarmAnimatedTextButton;
      
      private var m_buildingImage:FarmIcon;
      
      private var m_state:int;
      
      private var m_constructableBuilding:FarmItem;
      
      private var m_finishedBuilding:FarmItem;
      
      private var m_placedBuilding:MapResource;
      
      private var m_rollover:ZwBaseWidget;
      
      private var m_rollover2:ZwBaseWidget;
      
      private var m_activeRollOver:ZwBaseWidget;
      
      private var m_buildingNameText:FarmTextField;
      
      private var m_buildingCountWidget:FarmTextField;
      
      private var m_numActionCompletedBuildings:int = 0;
      
      private var m_numTotalBuildings:int = 0;
      
      public function BreedingBuildingExpansionMOTDSlot(element:DisplayObject)
      {
         super(element);
         this.m_priceWidget = addWidget(new ZwBaseWidget(m_element.price_mc));
         this.m_salePriceWidget = addWidget(new ZwBaseWidget(m_element.priceSale_mc));
         this.m_shortButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt)) as FarmAnimatedTextButton;
         this.m_longButton = addWidget(new FarmAnimatedTextButton(m_element.buyWide_btn)) as FarmAnimatedTextButton;
         this.m_buildingImage = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         var slotNum:int = Number((element as MovieClip).name.charAt(5));
         var displayObj:DisplayObject = (element as MovieClip).parent.getChildByName("mouseover_" + slotNum + "_mc");
         this.m_rollover = addWidget(new ZwBaseWidget(displayObj));
         displayObj = (element as MovieClip).parent.getChildByName("mouseover2_" + slotNum + "_mc");
         this.m_rollover2 = addWidget(new ZwBaseWidget(displayObj));
         this.m_buildingCountWidget = addWidget(new FarmTextField(m_element.progress_tf)) as FarmTextField;
         this.m_buildingNameText = addWidget(new FarmTextField(m_element.title_tf)) as FarmTextField;
      }
      
      public function get placedBuilding() : MapResource
      {
         return this.m_placedBuilding;
      }
      
      public function get buildingType() : String
      {
         return this.m_constructableBuilding.name;
      }
      
      override public function populate(data:Object) : void
      {
         if(data.numBuildings)
         {
            this.m_numTotalBuildings = data.numBuildings;
            this.m_numActionCompletedBuildings = 0;
         }
         else
         {
            this.m_numActionCompletedBuildings += 1;
         }
         this.m_state = data.state;
         this.m_placedBuilding = data.building;
         this.m_buildingNameText.visible = true;
         this.m_constructableBuilding = Global.farmGameSettingsManager.getFarmItemByName(data.type);
         this.m_finishedBuilding = Global.farmGameSettingsManager.getFarmItemByName(this.m_constructableBuilding.getFinishedName());
         this.m_buildingNameText.text = ZLocUtils.tk_pk_asTitle(this.m_finishedBuilding.friendlyName);
         this.m_buildingImage.visible = true;
         switch(this.m_state)
         {
            case STATE_UNEXPANDED:
               this.populateUnexpanded();
               break;
            case STATE_NO_BUILDINGS:
               this.populateNoBuildings();
               break;
            case STATE_IN_PROGRESS:
               this.populateInProgress();
               break;
            case STATE_EXPANDED_ONCE:
               this.populateExpandedOnce();
               break;
            case STATE_FULLY_EXPANDED:
               this.populateFullyExpanded();
         }
      }
      
      private function enableBuildingCount(enable:Boolean) : void
      {
         if(enable)
         {
            this.m_buildingCountWidget.visible = true;
            this.m_buildingCountWidget.text = this.m_numActionCompletedBuildings + "/" + this.m_numTotalBuildings;
         }
         else
         {
            this.m_buildingCountWidget.visible = false;
         }
      }
      
      private function enableRollOver(enable:Boolean) : void
      {
         var featureBuilding:FeatureBuilding = null;
         var newCapacity:int = 0;
         var plusCapacity:int = 0;
         this.m_rollover.visible = false;
         this.m_rollover2.visible = false;
         if(enable)
         {
            this.m_shortButton.registerEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_shortButton.registerEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            this.m_longButton.registerEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_longButton.registerEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            if(this.m_activeRollOver == this.m_rollover)
            {
               featureBuilding = this.m_placedBuilding as FeatureBuilding;
               newCapacity = featureBuilding.getNextExpansionCapacity();
               plusCapacity = newCapacity - featureBuilding.capacity;
               this.m_activeRollOver.element.info_tf.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_RolloverExpandMessage");
               this.m_activeRollOver.element.storage_tf.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_RolloverPlusStorage",{"numStorage":plusCapacity});
               this.m_activeRollOver.element.title_tf.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_RolloverTotalStorage",{"numStorage":newCapacity});
            }
            else if(this.m_state == STATE_NO_BUILDINGS)
            {
               this.m_activeRollOver.element.info_tf.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_RolloverBuyMessage");
               this.m_activeRollOver.element.title_tf.text = ZLocUtils.tk_pk_asTitle(this.m_finishedBuilding.friendlyName) + "!";
            }
            else
            {
               this.m_activeRollOver.element.info_tf.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_RolloverCompleteNowMessage");
               this.m_activeRollOver.element.title_tf.text = ZLocUtils.tk_pk_asTitle(this.m_finishedBuilding.friendlyName) + "!";
            }
         }
         else
         {
            this.m_shortButton.unregisterEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_shortButton.unregisterEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            this.m_longButton.unregisterEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_longButton.unregisterEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         }
      }
      
      private function populateInProgress() : void
      {
         this.m_buildingCountWidget.visible = true;
         this.m_activeRollOver = this.m_rollover2;
         this.enableRollOver(true);
         this.enableBuildingCount(true);
         this.m_buildingImage.loadIcon(this.m_constructableBuilding.iconUrl);
         this.m_priceWidget.element.price_tf.text = (this.m_placedBuilding as ConstructionBuilding).getCashNeeded();
         this.m_priceWidget.visible = true;
         this.m_shortButton.visible = false;
         this.m_shortButton.unregisterEventListener(MouseEvent.CLICK,this.onButtonClick);
         this.m_longButton.visible = true;
         this.m_longButton.text = ZLocUtils.t("Dialogs","FeatureBuildingCompleteNow");
         this.m_longButton.registerEventListener(MouseEvent.CLICK,this.onButtonClick);
      }
      
      private function populateNoBuildings() : void
      {
         this.m_activeRollOver = this.m_rollover2;
         this.enableRollOver(true);
         this.enableBuildingCount(false);
         this.m_buildingImage.loadIcon(this.m_finishedBuilding.iconUrl);
         this.m_priceWidget.visible = true;
         this.m_priceWidget.element.price_tf.text = this.m_finishedBuilding.cash;
         this.m_longButton.visible = false;
         this.m_longButton.unregisterEventListener(MouseEvent.CLICK,this.onButtonClick);
         this.m_shortButton.visible = true;
         this.m_shortButton.text = this.m_shortButton.text = ZLocUtils.t("Dialogs","Buy");
         this.m_shortButton.registerEventListener(MouseEvent.CLICK,this.onButtonClick);
      }
      
      private function populateFullyExpanded() : void
      {
         element.expandedIcon_mc.visible = true;
         this.enableRollOver(false);
         this.enableBuildingCount(false);
         this.m_buildingImage.loadIcon(this.m_finishedBuilding.getImageByName("icon_2"));
         this.m_priceWidget.visible = false;
         this.m_salePriceWidget.visible = false;
         this.m_shortButton.visible = false;
         this.m_shortButton.unregisterEventListener(MouseEvent.CLICK,this.onButtonClick);
         this.m_longButton.visible = false;
         this.m_longButton.unregisterEventListener(MouseEvent.CLICK,this.onButtonClick);
      }
      
      private function populateExpandedOnce() : void
      {
         this.m_activeRollOver = this.m_rollover;
         this.enableRollOver(true);
         this.enableBuildingCount(true);
         this.m_buildingImage.loadIcon(this.m_finishedBuilding.getImageByName("icon_2"));
         this.renderExpandPrice();
         this.m_shortButton.visible = false;
         this.m_shortButton.unregisterEventListener(MouseEvent.CLICK,this.onButtonClick);
         this.m_longButton.visible = true;
         this.m_longButton.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExapansion_Expand2Button",{"level":2});
         this.m_longButton.registerEventListener(MouseEvent.CLICK,this.onButtonClick);
      }
      
      private function populateUnexpanded() : void
      {
         this.m_activeRollOver = this.m_rollover;
         this.enableRollOver(true);
         this.enableBuildingCount(true);
         this.m_buildingImage.loadIcon(this.m_finishedBuilding.getImageByName("icon_1"));
         this.renderExpandPrice();
         this.m_longButton.visible = false;
         this.m_longButton.unregisterEventListener(MouseEvent.CLICK,this.onButtonClick);
         this.m_shortButton.visible = true;
         this.m_shortButton.text = ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExapansion_Expand1Button");
         this.m_shortButton.registerEventListener(MouseEvent.CLICK,this.onButtonClick);
      }
      
      private function renderExpandPrice() : void
      {
         var multiplier:Number = (this.m_placedBuilding as FeatureBuilding).expand.expandPriceMultiplier;
         if(multiplier > 0 && multiplier < 1)
         {
            this.m_priceWidget.visible = false;
            this.m_salePriceWidget.visible = true;
            this.m_salePriceWidget.element.price_tf.text = (this.m_placedBuilding as FeatureBuilding).nextExpansionCashNeeded();
            this.m_salePriceWidget.element.oldPrice_tf.text = (this.m_placedBuilding as FeatureBuilding).getRawExpansionPartsCost();
         }
         else
         {
            this.m_priceWidget.visible = true;
            this.m_salePriceWidget.visible = false;
            this.m_priceWidget.element.price_tf.text = (this.m_placedBuilding as FeatureBuilding).nextExpansionCashNeeded();
         }
      }
      
      private function onRollOver(event:MouseEvent) : void
      {
         this.m_activeRollOver.visible = true;
      }
      
      private function onRollOut(event:MouseEvent) : void
      {
         this.m_activeRollOver.visible = false;
      }
      
      private function onButtonClick(event:MouseEvent) : void
      {
         var transaction:TBuyItemPutGiftbox = null;
         if(this.m_state == STATE_UNEXPANDED || this.m_state == STATE_EXPANDED_ONCE)
         {
            if(this.m_state == STATE_UNEXPANDED)
            {
               this.m_shortButton.enabled = false;
            }
            else
            {
               this.m_longButton.enabled = false;
            }
            (this.m_placedBuilding as FeatureBuilding).frictionlessExpand(this.onExpandBuildingSuccess);
         }
         else if(this.m_state == STATE_IN_PROGRESS)
         {
            this.m_longButton.enabled = false;
            (this.m_placedBuilding as ConstructionBuilding).frictionlessCompleteNow(true,this.onCompleteNowSuccess);
         }
         else if(this.m_state == STATE_NO_BUILDINGS)
         {
            if(Global.player.canBuyCash(this.m_finishedBuilding.realCashCost))
            {
               this.m_shortButton.enabled = false;
               transaction = new TBuyItemPutGiftbox(this.m_finishedBuilding,Currency.CASH,1,false,false,this.onPurchaseBuildingSuccess);
               TransactionManager.addTransaction(transaction,true);
            }
         }
      }
      
      private function onCompleteNowSuccess(result:Object) : void
      {
         this.m_placedBuilding = result.transformedBuilding;
         dispatchEvent(new Event(EVENT_COMPLETE_NOW));
         this.m_longButton.enabled = true;
         FarmStatsManager.count("dialog","animal_breeding_expand_MOTD",this.buildingType + "_complete_now");
      }
      
      private function onExpandBuildingSuccess(result:Object) : void
      {
         var trackLabel:String = this.m_state == STATE_UNEXPANDED ? "_expand2" : "_expand3";
         dispatchEvent(new Event(this.m_state == STATE_UNEXPANDED ? EVENT_FIRST_EXPAND : EVENT_ADVANCED_EXPAND));
         FarmStatsManager.count("dialog","animal_breeding_expand_MOTD",this.buildingType + trackLabel);
         if(this.m_state == STATE_UNEXPANDED)
         {
            this.m_shortButton.enabled = true;
         }
         else
         {
            this.m_longButton.enabled = true;
         }
         dispatchEvent(new Event(BUY_EXPANSION_CLICKED_EVENT));
      }
      
      private function onPurchaseBuildingSuccess(result:Object) : void
      {
         this.m_shortButton.enabled = true;
         FarmStatsManager.count("dialog","animal_breeding_expand_MOTD",this.buildingType + "_buy");
         dispatchEvent(new Event(BUY_BUILDING_CLICKED_EVENT));
      }
   }
}

