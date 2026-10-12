package Widgets.Windows.Doghouse
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.AnimalItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Managers.DoghouseManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Doghouse.DoghouseSlotContainerFrame;
   import Widgets.Frames.Doghouse.DoghouseTreatsFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class DoghouseContentsWindow extends FarmWindow
   {
      
      private static const DISPLAY_SETTINGS_DIALOG_NAME:String = "content";
      
      private static const STATS_SAMPLE_RATE:int = 100;
      
      private var m_building:FeatureBuilding;
      
      private var m_title:ZwTextField;
      
      private var m_description:ZwTextField;
      
      private var m_capacity_tf:ZwTextField;
      
      private var m_current_tf:ZwTextField;
      
      private var m_slotContainerFrame:DoghouseSlotContainerFrame;
      
      private var m_fetchButton:FarmAnimatedCashButton;
      
      private var m_fetchAmount:int;
      
      private var m_treatsFrame:DoghouseTreatsFrame;
      
      private var m_contents:Dictionary = new Dictionary();
      
      private var m_storageItems:Array = new Array();
      
      private var m_animals:Array = new Array();
      
      public function DoghouseContentsWindow(building:FeatureBuilding)
      {
         DoghouseManager.currentContentsWindow = this;
         this.m_building = building;
         FarmStatsManager.sample(STATS_SAMPLE_RATE,"dialog",this.m_building.getItemName(),"view");
         var dialogConfig:Object = this.m_building.getItem().getDialogConfig("storage");
         if(dialogConfig == null)
         {
            dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(this.m_building.getItemName());
         }
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwWidget(m_window.background_mc)) as ZwWidget;
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onTutorialButtonClick)) as FarmAnimatedButton;
         this.m_title = addWidget(new ZwTextField(m_window.title_tf,this.getLocalizedString("_Title"))) as ZwTextField;
         this.m_description = addWidget(new ZwTextField(m_window.description_tf,"")) as ZwTextField;
         this.m_slotContainerFrame = addWidget(new DoghouseSlotContainerFrame(m_window.category_mc)) as DoghouseSlotContainerFrame;
         this.m_fetchButton = addWidget(new FarmAnimatedCashButton(m_window.fetch_mc,ZLocUtils.t("Dialogs","Doghouse_FetchButton"),"00",this.onFetchButtonClick)) as FarmAnimatedCashButton;
         this.m_treatsFrame = addWidget(new DoghouseTreatsFrame(m_window.treats_mc)) as DoghouseTreatsFrame;
         this.refresh();
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_title = null;
         this.m_capacity_tf = null;
         this.m_current_tf = null;
         this.m_slotContainerFrame = null;
         this.m_fetchButton = null;
         this.m_treatsFrame = null;
         if(DoghouseManager.currentContentsWindow == this)
         {
            DoghouseManager.currentContentsWindow = null;
         }
         super.release();
      }
      
      override public function tintWindow() : void
      {
         if(m_window)
         {
            super.tintWindow();
            enableInput = false;
         }
      }
      
      override public function untintWindow() : void
      {
         if(m_window)
         {
            super.untintWindow();
            enableInput = true;
         }
      }
      
      public function get building() : FeatureBuilding
      {
         return this.m_building;
      }
      
      public function refresh() : void
      {
         if(m_window)
         {
            this.m_contents = this.m_building.contents;
            this.m_animals = this.getContents();
            this.m_slotContainerFrame.items = this.m_animals;
            this.m_treatsFrame.refresh();
            if(!this.m_building.hasNextExpansion())
            {
               this.m_description.text = ZLocUtils.t("Dialogs","Doghouse_DescriptionMaxed");
               if(Global.flashHotParams["DOGHOUSE_FETCH_ENABLED"])
               {
                  this.m_fetchAmount = Math.min(DoghouseManager.getFetchConsumableItemCount(this.m_building),int(Global.flashHotParams["DOGHOUSE_FETCH_THRESHOLD_RARE"]));
                  this.m_fetchButton.setAmountText(String(this.m_fetchAmount));
                  this.m_fetchButton.enabled = !DoghouseManager.transactionPending && this.m_fetchAmount >= int(Global.flashHotParams["DOGHOUSE_FETCH_THRESHOLD_COMMON"]);
                  this.m_fetchButton.visible = true;
               }
               else
               {
                  this.m_fetchButton.visible = false;
               }
            }
            else
            {
               this.m_description.text = ZLocUtils.t("Dialogs","Doghouse_Description");
               this.m_fetchButton.visible = false;
            }
         }
      }
      
      private function getLocalizedString(keySuffix:String, params:Object = null) : String
      {
         var result:String = "";
         var localizationKey:String = this.m_building.bldgName + keySuffix;
         if(ZLocUtils.hasString("Dialogs",localizationKey))
         {
            result = ZLocUtils.t("Dialogs",localizationKey,params);
         }
         return result;
      }
      
      private function getContents() : Array
      {
         var data:Object = null;
         var itemCode:String = null;
         var featuredItems:Object = null;
         var featuredItem:Object = null;
         var buildingDisplaySettings:Object = null;
         var storageLevel:int = 0;
         var item:FarmItem = null;
         var metadataList:Array = null;
         var metadata:Object = null;
         var itemDisplaySettings:Object = null;
         var extraDataKey:String = null;
         var result:Array = new Array();
         this.m_storageItems = Global.storageSettings.getStorageItems(this.m_building.getItem().storageClass);
         for(var i:int = 0; i < this.m_storageItems.length; i++)
         {
            if(this.m_storageItems[i] is AnimalItem)
            {
               storageLevel = i + 1;
               item = this.m_storageItems[i] as AnimalItem;
               if(item)
               {
                  data = {
                     "code":item.code,
                     "itemName":item.name,
                     "friendlyName":item.friendlyTitle,
                     "quantity":0,
                     "storageLevel":storageLevel,
                     "isExpansion":storageLevel > this.m_building.storageLevel,
                     "isNextExpansion":storageLevel == this.m_building.storageLevel + 1,
                     "isFeatured":false
                  };
                  result.push(data);
               }
            }
         }
         var buildingContents:Dictionary = this.m_building.contents;
         for(itemCode in buildingContents)
         {
            for each(data in result)
            {
               if(data["code"] == itemCode)
               {
                  data["quantity"] = this.m_contents[itemCode];
                  metadataList = this.m_building.getStorageMetaDataForCode(itemCode);
                  if(metadataList)
                  {
                     for each(metadata in metadataList)
                     {
                        if(metadata["data"])
                        {
                           data["metadata"] = metadata;
                           break;
                        }
                     }
                  }
               }
            }
         }
         featuredItems = this.m_building.getFeaturedItems();
         for each(featuredItem in featuredItems)
         {
            for each(data in result)
            {
               if(data["code"] == featuredItem["itemCode"])
               {
                  data["isFeatured"] = true;
               }
            }
         }
         buildingDisplaySettings = Global.farmGameSettingsManager.getDialogDisplaySettings(this.m_building.getItem().name,DISPLAY_SETTINGS_DIALOG_NAME);
         if(buildingDisplaySettings)
         {
            for each(data in result)
            {
               itemDisplaySettings = buildingDisplaySettings[data.itemName];
               if(Boolean(itemDisplaySettings) && itemDisplaySettings.hasOwnProperty("image"))
               {
                  for(extraDataKey in itemDisplaySettings.image)
                  {
                     data[extraDataKey] = itemDisplaySettings.image[extraDataKey];
                  }
               }
            }
         }
         return result;
      }
      
      private function onTutorialButtonClick(event:Event) : void
      {
         FarmStatsManager.sample(STATS_SAMPLE_RATE,"dialog",this.m_building.getItemName(),"what_is_this");
         TutorialUI.displayBundleTutorialWindow("Dialogs","Doghouse","assets/dialogs/4d_elements/Doghouse/Doghouse",false,this.onTutorialWindowClose);
      }
      
      private function onTutorialWindowClose() : void
      {
         FarmStatsManager.sample(STATS_SAMPLE_RATE,"dialog",this.m_building.getItemName(),"what_is_this","close");
      }
      
      private function onFetchButtonClick(event:MouseEvent) : void
      {
         if(this.m_fetchButton.enabled)
         {
            this.m_fetchButton.enabled = false;
            DoghouseManager.fetch(this.m_building,this.m_fetchAmount);
         }
      }
   }
}

