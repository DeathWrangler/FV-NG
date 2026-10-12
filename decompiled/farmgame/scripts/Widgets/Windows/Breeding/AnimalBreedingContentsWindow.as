package Widgets.Windows.Breeding
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.StorageContentsSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Breeding.AnimalBreedingContentsSlot;
   import Widgets.Windows.Mastery.MasteryWindow;
   import Widgets.Windows.StorageContentsWindow;
   import flash.display.DisplayObject;
   
   public class AnimalBreedingContentsWindow extends StorageContentsWindow
   {
      
      private var m_vipTag:ZwWidget;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_bgImageIcon:DisplayObject = null;
      
      public function AnimalBreedingContentsWindow(building:FeatureBuilding)
      {
         super(building);
         var dialogConfig:Object = m_building.getItem().getDialogConfig("storage");
         if(dialogConfig == null)
         {
            dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(m_building.getItemName());
         }
         if(Boolean(dialogConfig) && Boolean(dialogConfig.bgPath))
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogConfig.bgPath));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         if(Boolean(dialogConfig) && Boolean(dialogConfig.bgImage))
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogConfig.bgImage));
            this.m_bgLoader.getContent(this.onBgImageLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function onBgImageLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgImageIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var bgIndex:int = 0;
         super.postLoadComplete();
         if(Boolean(m_capacity_tf) && Boolean(m_current_tf) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ANIMAL_PEN_LEVEL_CAP) == 2)
         {
            TemplateUIUtility.applyTextScaling(m_capacity_tf,TemplateUIUtility.BUILDABLE);
            TemplateUIUtility.applyTextScaling(m_current_tf,TemplateUIUtility.BUILDABLE);
         }
         if(m_window.hasOwnProperty("mc_AnimalFrame_big_noBG") && Boolean(this.m_bgIcon))
         {
            index = m_window.getChildIndex(m_window.mc_AnimalFrame_big_noBG);
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame_big_noBG) + 1);
         }
         if(m_window.hasOwnProperty("mc_AnimalPenBG") && Boolean(this.m_bgImageIcon))
         {
            bgIndex = m_window.getChildIndex(m_window.mc_AnimalPenBG);
            m_window.mc_AnimalPenBG.addChild(this.m_bgImageIcon);
            m_window.mc_AnimalPenBG.visible = true;
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
         }
      }
      
      override protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return new StorageContentsSlotFrame(m_window.animals_mc,m_contents,this,AnimalBreedingContentsSlot);
      }
      
      override protected function initFeatureWidgets() : void
      {
         var buttonBGPath:String = null;
         var animalName:String = null;
         var farmItem:FarmItem = null;
         var animal:Animal = null;
         var animalsInMarket:Array = null;
         var iAnimal:int = 0;
         var slotH60Path:String = null;
         var farmIcon:FarmIcon = null;
         m_contentTab_bt = new FarmAnimatedTextButton(m_window.animalsTab_mc,ZLocUtils.t("Dialogs","Animals"),onShowContents);
         if(m_window.animalsTab_mc.hasOwnProperty("mc_Button"))
         {
            buttonBGPath = Global.worldSettingsManager.getSlotBGImagePath("Button100");
            if(buttonBGPath)
            {
               m_slotBGIcon = null;
               ImageLoader.getInstance(Global.getAssetURL(buttonBGPath)).getContent(this.onSlotUrlLoaded);
               if(m_slotBGIcon)
               {
                  m_window.animalsTab_mc["mc_Button"].addChild(m_slotBGIcon);
                  m_window.animalsTab_mc["mc_Button"].visible = true;
               }
            }
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.animalsTab_mc.generic_tf);
         }
         super.initFeatureWidgets();
         var featuredExperimentName:String = Experiments.EXPERIMENT_ANIMAL_BREEDING_FEATURED + m_building.bldgName.toLowerCase();
         var runtimeVariableName:String = m_building.bldgName.toUpperCase();
         if(Global.experimentManager.getExperimentVariant(featuredExperimentName))
         {
            animalName = Global.flashHotParams[runtimeVariableName];
            if(animalName)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(animalName);
               if(farmItem != null)
               {
                  animal = new Animal(animalName);
                  animalsInMarket = Global.farmGameSettingsManager.getFarmItemsArray(MasteryWindow.TYPE_ANIMAL);
                  iAnimal = animalsInMarket.indexOf(farmItem);
                  if(iAnimal >= 0 && farmItem.isCash && FeatureBuildingSurfacingManager.canAddToBuilding(m_building,animal))
                  {
                     m_featuredFrame = addWidget(new ZwFrame(m_window.featured_mc)) as ZwFrame;
                     slotH60Path = Global.worldSettingsManager.getSlotBGImagePath("H60");
                     if(slotH60Path)
                     {
                        m_slotBGIcon = null;
                        ImageLoader.getInstance(Global.getAssetURL(slotH60Path)).getContent(this.onSlotUrlLoaded);
                        if(m_slotBGIcon)
                        {
                           m_window.featured_mc["mc_Slot_H_0"].addChild(m_slotBGIcon);
                           m_window.featured_mc["mc_Slot_H_0"].visible = true;
                        }
                     }
                     m_featuredFrame.addWidget(new ZwTextField(m_window.featured_mc.featuredTitle_tf,ZLocUtils.t("Dialogs",m_building.bldgName + "_Dialog_FeatureAnimalTitle")));
                     m_featuredFrame.addWidget(new ZwTextField(m_window.featured_mc.cost_tf,farmItem.cash.toString()));
                     m_featuredFrame.addWidget(new ZwTextField(m_window.featured_mc.featuredAnimal_tf,farmItem.friendlyTitle));
                     if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
                     {
                        TemplateUIUtility.applyExpansionSubTextColor(m_window.featured_mc.cost_tf);
                        TemplateUIUtility.applyExpansionGlowFilter(m_window.featured_mc.featuredAnimal_tf);
                     }
                     if(m_window.featured_mc.viptag_L_mc)
                     {
                        m_featuredFrame.addWidget(this.m_vipTag = new ZwWidget(m_window.featured_mc.viptag_L_mc),false);
                        this.m_vipTag.visible = false;
                     }
                     farmIcon = new FarmIcon(m_window.featured_mc.icon_mc,farmItem.iconUrl);
                     farmIcon.setIconSize(100,100);
                     m_featuredFrame.addWidget(farmIcon,true);
                     m_featuredFrame.addWidget(new FarmAnimatedTextButton(m_window.featured_mc.buy_bt,ZLocUtils.t("Dialogs","BuyParts"),onClickMarket));
                  }
               }
            }
         }
      }
      
      override protected function openMiniMarket(runtimeVariableName:String, createWindow:Function) : void
      {
         UI.displayMiniMarketDialog([Global.flashHotParams[runtimeVariableName]],"animal","animal",createWindow,true);
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         m_slotBGIcon = dispObj;
      }
   }
}

