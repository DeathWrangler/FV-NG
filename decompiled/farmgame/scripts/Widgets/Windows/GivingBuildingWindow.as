package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.ImageLoader;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Managers.Crafting.CraftingManager;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GivingBuildingSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GivingBuildingWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private var m_featureBuilding:FeatureBuilding;
      
      protected var m_locPrefix:String = this.m_featureBuilding.bldgName;
      
      private var m_npcUrl:String;
      
      private var m_subtitleTextField:ZwTextField;
      
      private var m_whatisthisBtn:FarmAnimatedButton;
      
      protected var m_currencyFrame:ZwFrame;
      
      protected var m_makeButton:FarmAnimatedTextButton;
      
      protected var m_currencyCountTextField:ZwTextField;
      
      private var m_prizeFrame:GivingBuildingSlotFrame;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_npcLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_npcIcon:DisplayObject = null;
      
      private var m_slotBGIcon:DisplayObject;
      
      private var m_whatIsThisImagePrefix:String;
      
      public function GivingBuildingWindow(building:StorageBuilding)
      {
         this.m_featureBuilding = building as FeatureBuilding;
         var windowURL:String = this.m_featureBuilding.getItem().getDialogConfig("storage").path;
         var tutorialFrameCount:int = Global.farmGameSettingsManager.getNumber("tutorial_frameCount_" + building.getItemName(),NUM_TUTORIAL_SCENES);
         super(this.m_featureBuilding.bldgName,windowURL,tutorialFrameCount);
         var windowBgURL:String = this.m_featureBuilding.getItem().getDialogConfig("storage").bgPath;
         this.m_npcUrl = this.m_featureBuilding.getItem().getDialogConfig("storage").npcUrl;
         if(windowBgURL != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(windowBgURL));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         if(this.m_npcUrl != null)
         {
            this.m_npcLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_npcUrl));
            this.m_npcLoader.getContent(this.onNpcLoad);
         }
         this.m_whatIsThisImagePrefix = this.m_featureBuilding.getItem().getDialogConfig("storage").whatIsThisImagePrefix;
      }
      
      public static function showReminderToaster(params:XML) : void
      {
         var featureName:String = null;
         var assetPath:String = null;
         var buildingName:String = null;
         var item:FarmItem = null;
         var title:String = null;
         var text:String = null;
         var buttonText:String = null;
         var now:Number = NaN;
         var itemCount:int = Global.player.getGiftCountForItem(params.itemName);
         if(itemCount > 0)
         {
            featureName = params.featureName;
            assetPath = params.toasterAsset;
            buildingName = params.buildingName;
            item = Global.farmGameSettingsManager.getFarmItemByName(params.itemName);
            title = ZLocUtils.t("Dialogs",featureName + "ToasterTitle",{"count":itemCount});
            text = ZLocUtils.t("Dialogs",featureName + "ToasterText",{"count":itemCount});
            buttonText = ZLocUtils.t("Dialogs",featureName + "ToasterButtonText");
            ToasterManager.getInstance().add(new GenericSingleButtonTitleToaster(assetPath,title,text,buttonText,openBuildingUI,buildingName));
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(featureName + "ToasterLastSeen",now,true);
         }
      }
      
      public static function openBuildingUI(buildingName:String) : void
      {
         var storageBuilding:StorageBuilding = null;
         var buildingObjects:Array = Global.world.getObjectsByName(buildingName);
         if(buildingObjects)
         {
            storageBuilding = buildingObjects[0];
            if(storageBuilding)
            {
               storageBuilding.displayStorageDialog();
            }
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function onNpcLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_npcIcon = dispObj;
      }
      
      private function conditionallyDisplayJungleInnovationCard() : void
      {
         if(m_window.innovation_mc)
         {
            m_window.innovation_mc.visible = false;
            if(JMInnovationManager.getInstance().isActive())
            {
               m_window.innovation_mc.visible = true;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var tutorialSeenFlag:String = null;
         var ringIcon:FarmIcon = null;
         var worldCode:String = null;
         var result:Array = null;
         var partName:String = null;
         var consumableIcon:FarmIcon = null;
         var partItem:FarmItem = null;
         var levelIndex:int = 0;
         if(Boolean(m_tutorialFeatureName) && Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_DISABLE_AUTOPOP_FTUE) > 0)
         {
            tutorialSeenFlag = m_tutorialFeatureName + "_Tutorial";
            Global.player.setSeenFlag(tutorialSeenFlag);
         }
         super.postLoadComplete();
         this.conditionallyDisplayJungleInnovationCard();
         tutorialButtonText = ZLocUtils.t("Dialogs",this.m_locPrefix + "TutorialButtonText");
         if(m_window.whatisthis_mc)
         {
            addWidget(this.m_whatisthisBtn = new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick));
         }
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "Title")));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
               TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
               TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
            }
         }
         if(m_window.description_tf != null)
         {
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.description_tf);
            }
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "Description")));
         }
         if(m_window.body_tf != null)
         {
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.body_tf);
            }
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "Body")));
         }
         if(Boolean(m_window.mc_NPC) && Boolean(this.m_npcIcon))
         {
            m_window.mc_NPC.addChild(this.m_npcIcon);
            m_window.mc_NPC.visible = true;
         }
         if(m_window.hasOwnProperty("mc_UnwitherRing"))
         {
            ringIcon = new FarmIcon(m_window.mc_UnwitherRing) as FarmIcon;
            ringIcon.setIconSize(150,150);
            ringIcon.setSmoothing(true);
            worldCode = this.m_featureBuilding.getItemName();
            result = worldCode.split("_");
            worldCode = result[1];
            ringIcon.loadIcon(Global.getAssetURL("assets/decorations/" + worldCode + "_unwitherringgoldruby_200.png"));
            ringIcon.visible = true;
         }
         if(m_window.currencyframe_mc != null)
         {
            addWidget(this.m_currencyFrame = new ZwFrame(m_window.currencyframe_mc));
            this.m_currencyFrame.addWidget(this.m_makeButton = new FarmAnimatedTextButton(m_window.currencyframe_mc.make_bt,ZLocUtils.t("Dialogs",this.m_locPrefix + "MakeCurrency"),this.onMakeCurrency));
            partName = this.getPartName();
            this.m_currencyFrame.addWidget(this.m_currencyCountTextField = new ZwTextField(m_window.currencyframe_mc.count_tf,Global.player.getGiftCountForItem(partName).toString()));
            this.m_currencyFrame.addWidget(new ZwTextField(m_window.currencyframe_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "GenericCurrency")));
            this.m_currencyFrame.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_locPrefix + "CurrencyTooltip")));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.currencyframe_mc.count_tf);
               TemplateUIUtility.applyExpansionGlowFilter(m_window.currencyframe_mc.generic_tf);
            }
            if(m_window["currencyframe_mc"].hasOwnProperty("mc_HarvestConsumable"))
            {
               consumableIcon = new FarmIcon(m_window["currencyframe_mc"].mc_HarvestConsumable) as FarmIcon;
               partItem = Global.farmGameSettingsManager.getFarmItemByName(partName);
               consumableIcon.setIconSize(100,100);
               consumableIcon.setSmoothing(true);
               consumableIcon.loadIcon(partItem.icon);
               consumableIcon.visible = true;
            }
         }
         addWidget(this.m_prizeFrame = new GivingBuildingSlotFrame(m_window.slotFrame_mc,this.m_featureBuilding,this));
         if(Boolean(m_window.mc_AnimalFrame_big) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame_big));
         }
         var slotH60BGPath:String = Global.worldSettingsManager.getSlotBGImagePath("H60");
         if(slotH60BGPath)
         {
            ImageLoader.getInstance(Global.getAssetURL(slotH60BGPath)).getContent(this.onSlotUrlLoaded);
            for(levelIndex = 0; m_window.hasOwnProperty("mc_Slot_H_" + levelIndex); levelIndex++)
            {
               if(this.m_slotBGIcon)
               {
                  m_window["mc_Slot_H_" + levelIndex].addChild(this.m_slotBGIcon);
                  m_window["mc_Slot_H_" + levelIndex].visible = true;
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      protected function getPartName() : String
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var partFarmItem:FarmItem = null;
         var partName:String = this.m_featureBuilding.expand.getExpansionPartString();
         if(partName == null || partName == "")
         {
            buildingExpansionData = this.m_featureBuilding.getBuildingExpansionDataByLevel(this.m_featureBuilding.storageLevel);
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               if(parts)
               {
                  for each(part in parts)
                  {
                     if(part)
                     {
                        partFarmItem = part.item;
                        if(partFarmItem)
                        {
                           partName = partFarmItem.name;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return partName;
      }
      
      override protected function release() : void
      {
         this.m_subtitleTextField = null;
         this.m_whatisthisBtn = null;
         this.m_currencyFrame = null;
         this.m_currencyCountTextField = null;
         this.m_prizeFrame = null;
         super.release();
      }
      
      private function onWhatIsThisClick(event:Event) : void
      {
         if(this.m_whatIsThisImagePrefix != null)
         {
            this.onClickHowDoesThisWork();
         }
         else
         {
            showTutorial();
         }
      }
      
      protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         TutorialUI.displayBuildingTutorialWindow(this.m_featureBuilding as FeatureBuilding,this.m_whatIsThisImagePrefix);
      }
      
      public function refreshWidgets() : void
      {
         var partName:String = this.getPartName();
         if(this.m_currencyCountTextField != null)
         {
            this.m_currencyCountTextField.text = Global.player.getGiftCountForItem(partName).toString();
         }
         this.m_prizeFrame.refreshSlots();
      }
      
      protected function onMakeCurrency(event:Event) : void
      {
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),ZLocUtils.t("Dialogs",this.m_locPrefix + "GenericCurrency"),this);
      }
   }
}

