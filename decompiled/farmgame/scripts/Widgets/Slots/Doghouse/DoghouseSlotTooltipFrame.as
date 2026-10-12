package Widgets.Slots.Doghouse
{
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.Mastery;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Doghouse.DoghouseContentsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class DoghouseSlotTooltipFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 40;
      
      private static const PROGRESS_BAR_MAX_WIDTH:int = 54;
      
      private var m_parentSlot:DoghouseSlot;
      
      private var m_partIcon:FarmIcon;
      
      private var m_partCountTextField:ZwTextField;
      
      private var m_progressBar:ZwWidget;
      
      private var m_progressTrack:ZwWidget;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_masteryFrame:MarketSlotMasteryFrame;
      
      private var m_removeButton:FarmAnimatedTextButton;
      
      private var m_featureButton:FarmAnimatedTextButton;
      
      private var m_emptyTextField:FarmTextField;
      
      private var m_largeBackgroundWidget:ZwWidget;
      
      private var m_smallBackgroundWidget:ZwWidget;
      
      public function DoghouseSlotTooltipFrame(element:DisplayObject, parentSlot:DoghouseSlot)
      {
         super(element);
         this.m_parentSlot = parentSlot;
         this.m_partIcon = addWidget(new FarmIcon(m_element.item_mc)) as FarmIcon;
         this.m_partIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_partCountTextField = addWidget(new ZwTextField(m_element.itemAmount_tf,ZLocUtils.t("Dialogs","Doghouse_Slot_PartCount"))) as ZwTextField;
         this.m_progressBar = addWidget(new ZwWidget(m_element.progressBar2_mc)) as ZwWidget;
         this.m_progressTrack = addWidget(new ZwWidget(m_element.progressTrack_mc)) as ZwWidget;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Doghouse_Slot_BuyButton"),"00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
         this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         this.m_removeButton = addWidget(new FarmAnimatedTextButton(m_element.generic_btn,ZLocUtils.t("Dialogs","Doghouse_Slot_RemoveButton"),this.onRemoveButtonClick)) as FarmAnimatedTextButton;
         this.m_featureButton = addWidget(new FarmAnimatedTextButton(m_element.check_btn,ZLocUtils.t("Dialogs","Doghouse_Slot_FeatureButton"),this.onFeatureButtonClick)) as FarmAnimatedTextButton;
         this.m_emptyTextField = addWidget(new FarmTextField(m_element.callhome_tf,ZLocUtils.t("Dialogs","Doghouse_Slot_EmptyText"))) as FarmTextField;
         this.m_largeBackgroundWidget = addWidget(new ZwWidget(m_element.bubbleLG_mc)) as ZwWidget;
         this.m_smallBackgroundWidget = addWidget(new ZwWidget(m_element.bubbleSM_mc)) as ZwWidget;
      }
      
      override public function release() : void
      {
         this.m_parentSlot = null;
         this.m_partCountTextField = null;
         this.m_partIcon = null;
         this.m_progressBar = null;
         this.m_progressTrack = null;
         this.m_buyButton = null;
         this.m_masteryFrame = null;
         this.m_removeButton = null;
         this.m_featureButton = null;
         this.m_emptyTextField = null;
         this.m_largeBackgroundWidget = null;
         this.m_smallBackgroundWidget = null;
         super.release();
      }
      
      public function populate(data:Object) : void
      {
         var building:FeatureBuilding = null;
         var partName:String = null;
         var partNeeded:int = 0;
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
         var upgradeData:XML = null;
         var partList:XMLList = null;
         var partItem:FarmItem = null;
         var partCount:int = 0;
         var percentage:Number = NaN;
         var mastery:Mastery = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(data.isExpansion)
         {
            building = (this.m_parentSlot.getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow).building;
            if(StorageBuilding.isDynamicPartsExperimentOn())
            {
               buildingExpansionData = building.getBuildingExpansionDataByLevel(data.storageLevel as int);
               if(buildingExpansionData)
               {
                  parts = buildingExpansionData.parts;
                  if(parts.length > 1)
                  {
                     GlobalEngine.assert(false,"Doghouse expansion level " + data.storageLevel + " has more than one part defined.  One and only one was expected.");
                  }
                  partName = parts[0].item.name;
                  partNeeded = parts[0].qtyNeeded;
               }
            }
            else if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = building.getItem().getUpgradeDataSource(data.storageLevel as int);
               if(upgradeDataSource)
               {
                  partDataArray = upgradeDataSource.getArray("part");
                  if(partDataArray.length > 0)
                  {
                     if(partDataArray.length > 1)
                     {
                        GlobalEngine.assert(false,"Doghouse expansion level " + data.storageLevel + " has more than one part defined.  One and only one was expected.");
                     }
                     partData = partDataArray[0];
                     partName = partData.getString("name");
                     partNeeded = partData.getInt("need");
                  }
               }
            }
            else
            {
               upgradeData = building.getItem().getUpgradeData(data.storageLevel as int);
               if(Boolean(upgradeData) && upgradeData.part.length() > 0)
               {
                  partList = upgradeData.part;
                  if(partList.length() > 1)
                  {
                     GlobalEngine.assert(false,"Doghouse expansion level " + data.storageLevel + " has more than one part defined.  One and only one was expected.");
                  }
                  partName = String(partList[0].@name);
                  partNeeded = int(partList[0].@need);
               }
            }
            if(partName)
            {
               partItem = Global.farmGameSettingsManager.getFarmItemByName(partName);
               if(partItem)
               {
                  this.m_partIcon.loadIcon(partItem.iconUrl);
                  this.m_partIcon.visible = true;
                  partCount = 0;
                  if(data.isNextExpansion)
                  {
                     partCount = building.getExpansionPartCount(partItem.code);
                     this.m_buyButton.setAmountText(String(building.nextExpansionCashNeeded()));
                     this.m_buyButton.visible = true;
                  }
                  else
                  {
                     partCount = 0;
                     this.m_buyButton.visible = false;
                  }
                  this.m_partCountTextField.text = ZLocUtils.t("Dialogs","Doghouse_Slot_PartCount",{
                     "count":partCount,
                     "total":partNeeded
                  });
                  this.m_partCountTextField.visible = true;
                  percentage = partNeeded <= 0 ? 0 : partCount / partNeeded;
                  percentage = Math.max(Math.min(percentage,1),0);
                  this.m_progressBar.width = Math.round(percentage * PROGRESS_BAR_MAX_WIDTH);
                  this.m_progressBar.visible = true;
                  this.m_progressTrack.visible = true;
               }
            }
            this.m_featureButton.visible = false;
            this.m_masteryFrame.visible = false;
            this.m_removeButton.visible = false;
            this.m_emptyTextField.visible = false;
         }
         else
         {
            if(item is HarvestableItem && (item as HarvestableItem).isMasterable())
            {
               mastery = (item as HarvestableItem).mastery;
               this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
               this.m_masteryFrame.visible = true;
            }
            else
            {
               this.m_masteryFrame.visible = false;
            }
            this.m_removeButton.visible = data.quantity > 0;
            this.m_featureButton.visible = data.quantity > 0 && !data.isFeatured;
            this.m_emptyTextField.visible = data.quantity == 0;
            this.m_partIcon.visible = false;
            this.m_partCountTextField.visible = false;
            this.m_progressBar.visible = false;
            this.m_progressTrack.visible = false;
            this.m_buyButton.visible = false;
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         this.m_parentSlot.onBuyButtonClick(event);
      }
      
      private function onFeatureButtonClick(event:MouseEvent) : void
      {
         this.m_parentSlot.onFeatureButtonClick(event);
      }
      
      private function onRemoveButtonClick(event:MouseEvent) : void
      {
         this.m_parentSlot.onRemoveButtonClick(event);
      }
   }
}

