package Widgets.Windows
{
   import AvatarMode.AMAirplane;
   import Classes.Airplane;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import GameMode.GMAirplaneFly;
   import GameMode.GMDefault;
   import Managers.FarmStatsManager;
   import Managers.InstagrowHelper;
   import Managers.MapResourceHelper;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Instagrow.InstagrowFailFrame;
   import Widgets.Frames.Instagrow.InstagrowSelectionFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class InstagrowWindow extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_AnimalInstantReady.swf";
      
      protected static const DIALOG_ASSET_4TABS:String = "assets/dialogs/FV_AnimalInstantReady2C.swf";
      
      private var m_instagrowHelper:InstagrowHelper = null;
      
      private var m_cropsFrame:InstagrowSelectionFrame = null;
      
      private var m_treesFrame:InstagrowSelectionFrame = null;
      
      private var m_animalsFrame:InstagrowSelectionFrame = null;
      
      private var m_bloomsFrame:InstagrowSelectionFrame = null;
      
      private var m_failFrame:InstagrowFailFrame = null;
      
      private var m_airplane:Airplane = null;
      
      private var m_discountEnoughSelected:Boolean = false;
      
      private var m_discountEnoughPossible:Boolean = false;
      
      private var m_cropsAvail:Boolean = false;
      
      private var m_treesAvail:Boolean = false;
      
      private var m_animalsAvail:Boolean = false;
      
      private var m_bloomsAvail:Boolean = false;
      
      private var m_source:String = null;
      
      private var m_isInBloomsExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BLOOMS) > 0;
      
      private var m_AutoHarvestExperimentVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INSTAGROW_AUTO_PPH);
      
      private var m_harvestCropCheckMark:FarmAnimatedTextButton = null;
      
      private var m_harvestTreeCheckMark:FarmAnimatedTextButton = null;
      
      private var m_harvestAnimalCheckMark:FarmAnimatedTextButton = null;
      
      private var m_harvestBloomCheckMark:FarmAnimatedTextButton = null;
      
      private var m_isInAutoHarvestAllExp:Boolean = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_AUTOHARVEST) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      
      public function InstagrowWindow(airplane:Airplane, instagrowHelper:InstagrowHelper, source:String)
      {
         super(this.m_isInBloomsExperiment ? DIALOG_ASSET_4TABS : DIALOG_ASSET);
         this.m_airplane = airplane;
         this.m_instagrowHelper = instagrowHelper;
         this.m_source = source;
      }
      
      override protected function postLoadComplete() : void
      {
         var bloomCost:int = 0;
         var harvestCropButton:ZwButton = null;
         var tooltipMessage:String = null;
         var tooltip:FarmTextTooltip = null;
         var harvestTreeButton:ZwButton = null;
         var harvestAnimalButton:ZwButton = null;
         var harvestBloomButton:ZwButton = null;
         var inGameSecsPerHour:Number = NaN;
         var totalAnimalHours:int = 0;
         var totalAnimalsGrown:Number = NaN;
         var totalPlotHours:int = 0;
         var totalPlotsGrown:Number = NaN;
         var totalTreeHours:int = 0;
         var totalTreesGrown:Number = NaN;
         var totalBloomHours:int = 0;
         var totalBloomsGrown:Number = NaN;
         var discountPercent:String = null;
         var totalDiscountCost:Number = NaN;
         var hasResourcesToGrow:Boolean = this.m_instagrowHelper.hasResourcesToActOn();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","InstantGrow_DialogHeader")),hasResourcesToGrow);
         var cropsCost:int = this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_PLOTS);
         this.m_cropsFrame = new InstagrowSelectionFrame(m_window.crops_mc,MapResourceHelper.TYPE_PLOTS,cropsCost,this.onSelectionFrameToggle);
         this.m_cropsFrame.setSelected(cropsCost > 0);
         addWidget(this.m_cropsFrame,hasResourcesToGrow);
         var treesCost:int = this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_TREES);
         this.m_treesFrame = new InstagrowSelectionFrame(m_window.trees_mc,MapResourceHelper.TYPE_TREES,treesCost,this.onSelectionFrameToggle);
         this.m_treesFrame.setSelected(treesCost > 0);
         addWidget(this.m_treesFrame,hasResourcesToGrow);
         var animalsCost:int = this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_ANIMALS);
         this.m_animalsFrame = new InstagrowSelectionFrame(m_window.animals_mc,MapResourceHelper.TYPE_ANIMALS,animalsCost,this.onSelectionFrameToggle);
         this.m_animalsFrame.setSelected(animalsCost > 0);
         addWidget(this.m_animalsFrame,hasResourcesToGrow);
         if(this.m_isInBloomsExperiment)
         {
            bloomCost = this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_BLOOMS);
            this.m_bloomsFrame = new InstagrowSelectionFrame(m_window.blooms_mc,MapResourceHelper.TYPE_BLOOMS,bloomCost,this.onSelectionFrameToggle);
            this.m_bloomsFrame.setSelected(bloomCost > 0);
            addWidget(this.m_bloomsFrame,hasResourcesToGrow);
         }
         var showCropHarvestOption:Boolean = this.m_AutoHarvestExperimentVariant > 1 && hasResourcesToGrow && Boolean(cropsCost) && this.m_isInBloomsExperiment;
         if(showCropHarvestOption && m_window.harvestCrops_mc !== null)
         {
            harvestCropButton = new ZwButton(m_window.harvestCrops_mc,this.onHarvestCheckClick);
            addWidget(harvestCropButton);
            tooltipMessage = ZLocUtils.t("Dialogs","InstantGrow_TooltipAutoPlantBody");
            tooltip = new FarmTextTooltip(tooltipMessage);
            harvestCropButton.attachTooltip(tooltip);
            this.m_harvestCropCheckMark = new FarmAnimatedTextButton(m_window.harvestCrops_mc.check_mc,"",null);
            (this.m_harvestCropCheckMark.element as MovieClip).mouseEnabled = false;
            addWidget(this.m_harvestCropCheckMark);
            if(this.m_AutoHarvestExperimentVariant == 2 || this.m_AutoHarvestExperimentVariant == 4)
            {
               this.m_harvestCropCheckMark.visible = false;
            }
         }
         else if(this.m_harvestCropCheckMark !== null)
         {
            this.m_harvestCropCheckMark.visible = false;
         }
         var showTreeHarvestOption:Boolean = this.m_AutoHarvestExperimentVariant > 1 && hasResourcesToGrow && treesCost && this.m_isInBloomsExperiment && this.m_isInAutoHarvestAllExp;
         if(showTreeHarvestOption && m_window.harvestTree_mc !== null)
         {
            harvestTreeButton = new ZwButton(m_window.harvestTree_mc,this.onHarvestCheckClick);
            addWidget(harvestTreeButton);
            this.m_harvestTreeCheckMark = new FarmAnimatedTextButton(m_window.harvestTree_mc.checkTree_mc,"",null);
            (this.m_harvestTreeCheckMark.element as MovieClip).mouseEnabled = false;
            addWidget(this.m_harvestTreeCheckMark);
            if(this.m_AutoHarvestExperimentVariant == 2 || this.m_AutoHarvestExperimentVariant == 4)
            {
               this.m_harvestTreeCheckMark.visible = false;
            }
         }
         else if(this.m_harvestTreeCheckMark !== null)
         {
            this.m_harvestTreeCheckMark.visible = false;
         }
         var showAnimalHarvestOption:Boolean = this.m_AutoHarvestExperimentVariant > 1 && hasResourcesToGrow && animalsCost && this.m_isInBloomsExperiment && this.m_isInAutoHarvestAllExp;
         if(showAnimalHarvestOption && m_window.harvestAnimal_mc !== null)
         {
            harvestAnimalButton = new ZwButton(m_window.harvestAnimal_mc,this.onHarvestCheckClick);
            addWidget(harvestAnimalButton);
            this.m_harvestAnimalCheckMark = new FarmAnimatedTextButton(m_window.harvestAnimal_mc.checkAnimal_mc,"",null);
            (this.m_harvestAnimalCheckMark.element as MovieClip).mouseEnabled = false;
            addWidget(this.m_harvestAnimalCheckMark);
            if(this.m_AutoHarvestExperimentVariant == 2 || this.m_AutoHarvestExperimentVariant == 4)
            {
               this.m_harvestAnimalCheckMark.visible = false;
            }
         }
         else if(this.m_harvestAnimalCheckMark !== null)
         {
            this.m_harvestAnimalCheckMark.visible = false;
         }
         var showBloomHarvestOption:Boolean = this.m_AutoHarvestExperimentVariant > 1 && hasResourcesToGrow && bloomCost && this.m_isInBloomsExperiment && this.m_isInAutoHarvestAllExp;
         if(showBloomHarvestOption && m_window.harvestBlooms_mc !== null)
         {
            harvestBloomButton = new ZwButton(m_window.harvestBlooms_mc,this.onHarvestCheckClick);
            addWidget(harvestBloomButton);
            this.m_harvestBloomCheckMark = new FarmAnimatedTextButton(m_window.harvestBlooms_mc.checkBlooms_mc,"",null);
            (this.m_harvestBloomCheckMark.element as MovieClip).mouseEnabled = false;
            addWidget(this.m_harvestBloomCheckMark);
            if(this.m_AutoHarvestExperimentVariant == 2 || this.m_AutoHarvestExperimentVariant == 4)
            {
               this.m_harvestBloomCheckMark.visible = false;
            }
         }
         else if(this.m_harvestBloomCheckMark !== null)
         {
            this.m_harvestBloomCheckMark.visible = false;
         }
         addWidget(new ZwTextField(m_window.text_tf,ZLocUtils.t("FarmGame","Cost")),hasResourcesToGrow);
         var totalCost:Number = this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_ALL);
         addWidget(new ZwTextField(m_window.price_tf,totalCost.toString()),hasResourcesToGrow);
         if(hasResourcesToGrow)
         {
            inGameSecsPerHour = Global.farmGameSettingsManager.getInt("inGameDaySeconds") / 24;
            totalAnimalHours = int(this.m_instagrowHelper.totalAnimalTime() / inGameSecsPerHour);
            totalAnimalsGrown = this.m_instagrowHelper.getTotalAnimals().length;
            totalPlotHours = int(this.m_instagrowHelper.totalPlotTime() / inGameSecsPerHour);
            totalPlotsGrown = this.m_instagrowHelper.getTotalPlots().length;
            totalTreeHours = int(this.m_instagrowHelper.totalTreeTime() / inGameSecsPerHour);
            totalTreesGrown = this.m_instagrowHelper.getTotalTrees().length;
            FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER_REPRICING,MapResourceHelper.getCounterName(MapResourceHelper.TYPE_ANIMALS),InstagrowUtils.INSTA_GROW_VIEW,String(animalsCost),String(totalAnimalHours),String(totalAnimalsGrown));
            FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER_REPRICING,MapResourceHelper.getCounterName(MapResourceHelper.TYPE_PLOTS),InstagrowUtils.INSTA_GROW_VIEW,String(cropsCost),String(totalPlotHours),String(totalPlotsGrown));
            FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER_REPRICING,MapResourceHelper.getCounterName(MapResourceHelper.TYPE_TREES),InstagrowUtils.INSTA_GROW_VIEW,String(treesCost),String(totalTreeHours),String(totalTreesGrown));
            if(this.m_isInBloomsExperiment)
            {
               totalBloomHours = int(this.m_instagrowHelper.totalBloomTime() / inGameSecsPerHour);
               totalBloomsGrown = this.m_instagrowHelper.getTotalBlooms().length;
               FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER_REPRICING,MapResourceHelper.getCounterName(MapResourceHelper.TYPE_BLOOMS),InstagrowUtils.INSTA_GROW_VIEW,String(bloomCost),String(totalBloomHours),String(totalBloomsGrown));
            }
         }
         this.m_cropsAvail = this.m_cropsFrame.haveThisResource();
         this.m_treesAvail = this.m_treesFrame.haveThisResource();
         this.m_animalsAvail = this.m_animalsFrame.haveThisResource();
         if(this.m_isInBloomsExperiment)
         {
            this.m_bloomsAvail = this.m_bloomsFrame.haveThisResource();
         }
         this.checkNumSelections();
         if(this.shouldApplyDiscount())
         {
            addWidget(new ZwFrame(m_window.discountBurst_mc),hasResourcesToGrow);
            discountPercent = ZLocUtils.t("Dialogs","Instagrow_DialogPercentSign",{"quantity":this.m_instagrowHelper.getDiscount() * 100});
            addWidget(new ZwTextField(m_window.discountBurst_mc.discountPercent_tf,discountPercent),hasResourcesToGrow);
            addWidget(new ZwTextField(m_window.discountBurst_mc.off_tf,ZLocUtils.t("Dialogs","Instagrow_DialogBurstOff")),hasResourcesToGrow);
            addWidget(new ZwFrame(m_window.priceSlash_mc),hasResourcesToGrow);
            totalDiscountCost = this.m_instagrowHelper.applyDiscount(totalCost);
            addWidget(new ZwTextField(m_window.discountPrice_tf,ZLocUtils.t("Dialogs","Instantgrow_DialogDiscountPrice",{"quantity":totalDiscountCost})),hasResourcesToGrow);
         }
         addWidget(new FarmAnimatedTextButton(m_window.growNow_bt,ZLocUtils.t("Dialogs","Instagrow_Choose_BuyButton"),this.onBuyInstagrow),hasResourcesToGrow);
         addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Dialogs","MoreInfo"),this.onMoreInfo),hasResourcesToGrow);
         var temp:String = this.getStatString("",this.m_cropsAvail,this.m_treesAvail,this.m_animalsAvail,this.m_bloomsAvail);
         FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"dialog_view",temp,"","","Dialog for " + temp + " options appears");
      }
      
      private function onHarvestCheckClick(event:MouseEvent) : void
      {
         var priceText:String = null;
         var harvestButton:MovieClip = event.currentTarget as MovieClip;
         switch(harvestButton)
         {
            case m_window.harvestCrops_mc:
               if(this.m_harvestCropCheckMark != null)
               {
                  this.m_harvestCropCheckMark.visible = !this.m_harvestCropCheckMark.visible;
               }
               break;
            case m_window.harvestTree_mc:
               this.m_instagrowHelper.setAutoTH(false);
               if(this.m_harvestTreeCheckMark != null)
               {
                  this.m_harvestTreeCheckMark.visible = !this.m_harvestTreeCheckMark.visible;
                  if(this.m_harvestTreeCheckMark.visible)
                  {
                     this.m_instagrowHelper.setAutoTH(true);
                  }
                  priceText = String(this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_TREES));
                  this.m_treesFrame.updateCost(priceText);
               }
               break;
            case m_window.harvestAnimal_mc:
               this.m_instagrowHelper.setAutoAH(false);
               if(this.m_harvestAnimalCheckMark != null)
               {
                  this.m_harvestAnimalCheckMark.visible = !this.m_harvestAnimalCheckMark.visible;
                  if(this.m_harvestAnimalCheckMark.visible)
                  {
                     this.m_instagrowHelper.setAutoAH(true);
                  }
                  priceText = String(this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_ANIMALS));
                  this.m_animalsFrame.updateCost(priceText);
               }
               break;
            case m_window.harvestBlooms_mc:
               this.m_instagrowHelper.setAutoBH(false);
               if(this.m_harvestBloomCheckMark != null)
               {
                  this.m_harvestBloomCheckMark.visible = !this.m_harvestBloomCheckMark.visible;
                  if(this.m_harvestBloomCheckMark.visible)
                  {
                     this.m_instagrowHelper.setAutoBH(true);
                  }
                  priceText = String(this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_BLOOMS));
                  this.m_bloomsFrame.updateCost(priceText);
               }
         }
         this.onSelectionFrameToggle(event);
      }
      
      private function onSelectionFrameToggle(event:Event) : void
      {
         var priceText:String = null;
         var button:FarmAnimatedTextButton = getWidget(m_window.growNow_bt) as FarmAnimatedTextButton;
         this.checkNumSelections();
         if(!this.m_animalsFrame.getSelected() && !this.m_cropsFrame.getSelected() && !this.m_treesFrame.getSelected() && (this.m_isInBloomsExperiment && !this.m_bloomsFrame.getSelected()))
         {
            button.applyGrayOut = true;
            button.enabled = false;
         }
         else
         {
            button.applyGrayOut = false;
            button.enabled = true;
         }
         if(!this.m_cropsFrame.getSelected())
         {
            if(this.m_harvestCropCheckMark !== null)
            {
               this.m_harvestCropCheckMark.visible = false;
            }
            this.m_instagrowHelper.setAutoPPH(false);
         }
         if(!this.m_treesFrame.getSelected())
         {
            if(this.m_harvestTreeCheckMark !== null)
            {
               this.m_harvestTreeCheckMark.visible = false;
            }
            this.m_instagrowHelper.setAutoTH(false);
            priceText = String(this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_TREES));
            this.m_treesFrame.updateCost(priceText);
         }
         if(!this.m_animalsFrame.getSelected())
         {
            if(this.m_harvestAnimalCheckMark !== null)
            {
               this.m_harvestAnimalCheckMark.visible = false;
            }
            this.m_instagrowHelper.setAutoAH(false);
            priceText = String(this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_ANIMALS));
            this.m_animalsFrame.updateCost(priceText);
         }
         if(!this.m_bloomsFrame.getSelected())
         {
            if(this.m_harvestBloomCheckMark !== null)
            {
               this.m_harvestBloomCheckMark.visible = false;
            }
            this.m_instagrowHelper.setAutoBH(false);
            priceText = String(this.m_instagrowHelper.calculateCost(MapResourceHelper.TYPE_BLOOMS));
            this.m_bloomsFrame.updateCost(priceText);
         }
         this.updateWindow(this.calculateCost());
      }
      
      private function updateWindow(aCost:Number) : void
      {
         var totalDiscountCost:Number = NaN;
         var priceText:ZwTextField = getWidget(m_window.price_tf) as ZwTextField;
         var discountPriceText:ZwTextField = getWidget(m_window.discountPrice_tf) as ZwTextField;
         if(priceText)
         {
            priceText.text = aCost.toString();
         }
         if(discountPriceText)
         {
            totalDiscountCost = this.m_instagrowHelper.applyDiscount(aCost);
            discountPriceText.text = ZLocUtils.t("Dialogs","Instantgrow_DialogDiscountPrice",{"quantity":totalDiscountCost});
         }
         if(this.m_discountEnoughPossible && this.m_instagrowHelper.getDiscount() != 0)
         {
            if(!this.m_discountEnoughSelected)
            {
               getWidget(m_window.discountBurst_mc).visible = false;
               getWidget(m_window.discountBurst_mc.discountPercent_tf).visible = false;
               getWidget(m_window.discountBurst_mc.off_tf).visible = false;
               getWidget(m_window.priceSlash_mc).visible = false;
               getWidget(m_window.discountPrice_tf).visible = false;
            }
            else
            {
               getWidget(m_window.discountBurst_mc).visible = true;
               getWidget(m_window.discountBurst_mc.discountPercent_tf).visible = true;
               getWidget(m_window.discountBurst_mc.off_tf).visible = true;
               getWidget(m_window.priceSlash_mc).visible = true;
               getWidget(m_window.discountPrice_tf).visible = true;
            }
         }
      }
      
      private function shouldApplyDiscount() : Boolean
      {
         var result:Boolean = false;
         if(this.m_instagrowHelper.getDiscount() != 0 && this.m_discountEnoughSelected && this.m_discountEnoughPossible)
         {
            result = true;
         }
         return result;
      }
      
      private function onBuyInstagrow(event:Event) : void
      {
         var boughtType:String = null;
         var avatar:FarmAvatar = null;
         var cost:int = this.calculateCost();
         if(this.shouldApplyDiscount())
         {
            cost = this.m_instagrowHelper.applyDiscount(cost);
         }
         if(this.m_AutoHarvestExperimentVariant > 1)
         {
            if(this.m_cropsFrame.getSelected())
            {
               if(this.m_harvestCropCheckMark !== null && this.m_harvestCropCheckMark.visible)
               {
                  this.m_instagrowHelper.setAutoPPH(true);
                  if(this.m_AutoHarvestExperimentVariant >= 4)
                  {
                     this.m_instagrowHelper.setRePop(true);
                  }
               }
            }
            else
            {
               this.m_instagrowHelper.setAutoPPH(false);
               this.m_instagrowHelper.setRePop(false);
            }
            if(this.m_treesFrame.getSelected())
            {
               if(this.m_harvestTreeCheckMark !== null && this.m_harvestTreeCheckMark.visible)
               {
                  this.m_instagrowHelper.setAutoTH(true);
               }
            }
            else
            {
               this.m_instagrowHelper.setAutoTH(false);
            }
            if(this.m_animalsFrame.getSelected())
            {
               if(this.m_harvestAnimalCheckMark !== null && this.m_harvestAnimalCheckMark.visible)
               {
                  this.m_instagrowHelper.setAutoAH(true);
               }
            }
            else
            {
               this.m_instagrowHelper.setAutoAH(false);
            }
            if(this.m_bloomsFrame.getSelected())
            {
               if(this.m_harvestBloomCheckMark !== null && this.m_harvestBloomCheckMark.visible)
               {
                  this.m_instagrowHelper.setAutoBH(true);
               }
            }
            else
            {
               this.m_instagrowHelper.setAutoBH(false);
            }
            if(this.m_AutoHarvestExperimentVariant == 2 || this.m_AutoHarvestExperimentVariant == 4)
            {
               if(this.m_harvestCropCheckMark !== null && this.m_harvestCropCheckMark.visible)
               {
                  FarmStatsManager.count("InstaGrow","SelectAutoHarvestReplantCrops","check");
               }
               if(this.m_isInAutoHarvestAllExp)
               {
                  if(this.m_harvestTreeCheckMark !== null && this.m_harvestTreeCheckMark.visible)
                  {
                     FarmStatsManager.count("InstaGrow","SelectAutoHarvestTrees","check");
                  }
                  if(this.m_harvestAnimalCheckMark !== null && this.m_harvestAnimalCheckMark.visible)
                  {
                     FarmStatsManager.count("InstaGrow","SelectAutoHarvestAnimals","check");
                  }
                  if(this.m_harvestBloomCheckMark !== null && this.m_harvestBloomCheckMark.visible)
                  {
                     FarmStatsManager.count("InstaGrow","SelectAutoHarvestBlooms","check");
                  }
               }
            }
            else if(this.m_AutoHarvestExperimentVariant == 3 || this.m_AutoHarvestExperimentVariant == 5)
            {
               if(this.m_harvestCropCheckMark !== null && !this.m_harvestCropCheckMark.visible)
               {
                  FarmStatsManager.count("InstaGrow","SelectAutoHarvestReplantCrops","uncheck");
               }
               if(this.m_isInAutoHarvestAllExp)
               {
                  if(this.m_harvestTreeCheckMark !== null && this.m_harvestTreeCheckMark.visible)
                  {
                     FarmStatsManager.count("InstaGrow","SelectAutoHarvestTrees","uncheck");
                  }
                  if(this.m_harvestAnimalCheckMark !== null && this.m_harvestAnimalCheckMark.visible)
                  {
                     FarmStatsManager.count("InstaGrow","SelectAutoHarvestAnimals","uncheck");
                  }
                  if(this.m_harvestBloomCheckMark !== null && this.m_harvestBloomCheckMark.visible)
                  {
                     FarmStatsManager.count("InstaGrow","SelectAutoHarvestBlooms","uncheck");
                  }
               }
            }
         }
         var canBuy:Boolean = Global.player.canBuyCash(cost);
         if(canBuy && cost > 0)
         {
            Global.player.cash -= cost;
            avatar = Global.selectedAvatar;
            avatar.getStateMachine().addState(new AMAirplane(avatar,this.m_instagrowHelper,this.m_airplane as Airplane),true);
            close();
         }
         var boughtInfo:Object = new Object();
         boughtInfo.crop = this.m_cropsFrame.getSelected();
         boughtInfo.tree = this.m_treesFrame.getSelected();
         boughtInfo.animal = this.m_animalsFrame.getSelected();
         boughtInfo.bloom = this.m_isInBloomsExperiment && this.m_bloomsFrame.getSelected();
         var buyString:String = this.getStatString("buy_",boughtInfo.crop,boughtInfo.tree,boughtInfo.animal,boughtInfo.bloom);
         var availString:String = this.getStatString("",this.m_cropsAvail,this.m_treesAvail,this.m_animalsAvail,this.m_bloomsAvail);
         var sampleRate:int = Global.flashHotParams.hasOwnProperty("INSTAGROW_STAT_SAMPLE") ? Global.flashHotParams["INSTAGROW_STAT_SAMPLE"] as int : 100;
         FarmStatsManager.sample(sampleRate,InstagrowUtils.INSTA_GROW_COUNTER,"dialog_click",availString,buyString,"","Dialog for " + availString + " options appears, user selects " + buyString + " options and clicks button \'grow now\'");
         for(boughtType in boughtInfo)
         {
            if(boughtInfo[boughtType] == true)
            {
               FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,this.m_source,"buys",boughtType);
            }
         }
      }
      
      private function checkNumSelections() : void
      {
         this.m_discountEnoughSelected = true;
         this.m_discountEnoughPossible = true;
         var numSelected:int = 0;
         numSelected += this.m_animalsFrame.getSelected() ? 1 : 0;
         numSelected += this.m_cropsFrame.getSelected() ? 1 : 0;
         numSelected += this.m_treesFrame.getSelected() ? 1 : 0;
         if(this.m_isInBloomsExperiment)
         {
            numSelected += this.m_bloomsFrame.getSelected() ? 1 : 0;
         }
         if(numSelected <= 1)
         {
            this.m_discountEnoughSelected = false;
         }
         var numAvailable:int = 0;
         numSelected += this.m_animalsAvail ? 1 : 0;
         numSelected += this.m_cropsAvail ? 1 : 0;
         numSelected += this.m_treesAvail ? 1 : 0;
         if(this.m_isInBloomsExperiment)
         {
            numSelected += this.m_bloomsAvail ? 1 : 0;
         }
         if(numAvailable <= 1)
         {
            this.m_discountEnoughPossible = false;
         }
      }
      
      private function onMoreInfo(event:Event) : void
      {
         var dialogMessage:String = ZLocUtils.t("Dialogs","Instagrow_DialogMoreInfo");
         UI.showMessage(dialogMessage,UI.BUTTON_LAYOUT_OK,null,null,false);
      }
      
      private function getStatString(prefix:String, crops:Boolean, trees:Boolean, animals:Boolean, blooms:Boolean) : String
      {
         var result:String = prefix;
         var count:int = 0;
         if(crops)
         {
            result = "crop";
            count++;
         }
         if(trees)
         {
            if(count > 0)
            {
               result += "_";
            }
            result += "tree";
            count++;
         }
         if(animals)
         {
            if(count > 0)
            {
               result += "_";
            }
            result += "animal";
            count++;
         }
         if(blooms)
         {
            if(count > 0)
            {
               result += "_";
            }
            result += "bloom";
            count++;
         }
         if(count == 1)
         {
            result += "_only";
         }
         return result;
      }
      
      private function calculateCost() : int
      {
         var result:int = 0;
         var instagrowType:uint = 0;
         if(this.m_cropsFrame.getSelected())
         {
            instagrowType |= MapResourceHelper.TYPE_PLOTS;
         }
         if(this.m_treesFrame.getSelected())
         {
            instagrowType |= MapResourceHelper.TYPE_TREES;
         }
         if(this.m_animalsFrame.getSelected())
         {
            instagrowType |= MapResourceHelper.TYPE_ANIMALS;
         }
         if(this.m_isInBloomsExperiment && this.m_bloomsFrame.getSelected())
         {
            instagrowType |= MapResourceHelper.TYPE_BLOOMS;
         }
         return this.m_instagrowHelper.calculateCost(instagrowType);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(Global.world.getTopGameMode() is GMAirplaneFly)
         {
            Global.world.getTopGameMode().disableMode();
            Global.world.addGameMode(new GMDefault());
         }
         close();
         var availString:String = this.getStatString("",this.m_cropsAvail,this.m_treesAvail,this.m_animalsAvail,this.m_bloomsAvail);
         var sampleRate:int = Global.flashHotParams.hasOwnProperty("INSTAGROW_STAT_SAMPLE") ? Global.flashHotParams["INSTAGROW_STAT_SAMPLE"] as int : 100;
         FarmStatsManager.sample(sampleRate,InstagrowUtils.INSTA_GROW_COUNTER,"dialog_click",availString,"cancel","","Dialog for " + availString + " options appears, user selects cancel");
      }
   }
}

