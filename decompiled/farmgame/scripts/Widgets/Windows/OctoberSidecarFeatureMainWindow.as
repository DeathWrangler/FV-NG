package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OctoberSidecarFeatureManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class OctoberSidecarFeatureMainWindow extends FarmWindowWithTutorial
   {
      
      public static const FEATURE_NAME:String = "GilroysParade";
      
      public static const MAIN_FTUE_SEEN_FLAG:String = FEATURE_NAME + "_main_ftue_seen";
      
      private var m_featureName:String = null;
      
      private const COST_SKIP_SEARCH:int = 2;
      
      private const STAGE_BAR_FULL_WIDTH:int = 120;
      
      private const SEARCH_TIME_BAR_WIDTH:int = 304;
      
      private var m_subtitle_tf:ZwTextField;
      
      private var m_howdoesthiswork_bt:FarmAnimatedTextButton;
      
      private var m_craft_mc:MovieClip;
      
      private var m_search_mc:MovieClip;
      
      private var m_stage_mc:MovieClip;
      
      private var m_conscraft_bt:Array = [];
      
      private var m_consbuy_bt:Array = [];
      
      private var m_conscount_tf:Array = [];
      
      private var m_searchtitle_tf:ZwTextField;
      
      private var m_searchcons_mc:Array = [];
      
      private var m_sendsearch_mc:MovieClip;
      
      private var m_send_bt:FarmAnimatedTextButton;
      
      private var m_chancepercent_tf:ZwTextField;
      
      private var m_cluecount_tf:ZwTextField;
      
      private var m_stagetitle_tf:ZwTextField;
      
      private var m_stage_tf:ZwTextField;
      
      private var m_stageitem_icon:FarmIcon;
      
      private var m_stagebar_mc:MovieClip;
      
      private var m_cluebarfill_mc:MovieClip;
      
      private var m_stageclues_tf:ZwTextField;
      
      private var m_checkmark_mc:MovieClip;
      
      private var m_collections_mc:MovieClip;
      
      private var m_featuretime_tf:ZwTextField;
      
      private var m_searching_mc:MovieClip;
      
      private var m_skipsearch_bt:FarmAnimatedCashButton;
      
      private var m_searchbar_mc:MovieClip;
      
      private var m_endreveal_mc:MovieClip;
      
      private var m_endoverlay_mc:MovieClip;
      
      private var m_endscreen_bt:FarmAnimatedTextButton;
      
      private var m_searchtimer_tf:ZwTextField;
      
      private var m_featureTimer:Timer;
      
      private var m_searchTimer:Timer;
      
      private var m_tutorial_button:FarmAnimatedTextButton;
      
      private var m_tutorialCurrentScene:int = 1;
      
      private var m_tutorialTotalScenes:int = 0;
      
      public function OctoberSidecarFeatureMainWindow(featureName:String = "GilroysParade", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         super(FEATURE_NAME,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var craft_bt:String = null;
         var buy_bt:String = null;
         var count_tf:String = null;
         var cashValue:String = null;
         var consumable_mc:String = null;
         var cluecount_mc:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"The Mooresville Mystery"));
         }
         if(m_window.hasOwnProperty("mainbody_tf"))
         {
            addWidget(this.m_subtitle_tf = new ZwTextField(m_window["mainbody_tf"],"Help Maggie find clues by crafting all the items"));
         }
         if(m_window.hasOwnProperty("timeremains_tf"))
         {
            this.m_featuretime_tf = new ZwTextField(m_window["timeremains_tf"],"");
            this.m_featuretime_tf.visible = true;
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(this.m_howdoesthiswork_bt = new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(Boolean(m_window.hasOwnProperty("tutorial_mc")) && Boolean(m_window["tutorial_mc"].hasOwnProperty("okay_bt")) && Boolean(m_tutorial))
         {
            this.m_tutorialTotalScenes = m_tutorial.element.totalFrames;
            this.m_tutorial_button = new FarmAnimatedTextButton(m_window.tutorial_mc.okay_bt,"Let\'s Go!",this.handleTutorialButtonClick);
         }
         if(m_window.hasOwnProperty("get_cons_mc"))
         {
            this.m_craft_mc = m_window["get_cons_mc"] as MovieClip;
            for(index = 0; index < this.manager.NUM_CONSUMABLES; index++)
            {
               craft_bt = "okay_" + index.toString() + "_bt";
               if(this.m_craft_mc.hasOwnProperty(craft_bt))
               {
                  this.m_conscraft_bt[index] = new FarmAnimatedTextButton(this.m_craft_mc[craft_bt],"Craft",this.onCraftConsumableClick(index));
                  this.m_conscraft_bt[index].visible = true;
               }
               buy_bt = "buy_" + index.toString() + "_bt";
               if(this.m_craft_mc.hasOwnProperty(buy_bt))
               {
                  cashValue = this.manager.CONSUMABLES_BUY_COST[index] + "";
                  this.m_consbuy_bt[index] = new FarmAnimatedCashButton(this.m_craft_mc[buy_bt],"Buy",cashValue,this.onBuyConsumableClick(index));
                  this.m_consbuy_bt[index].visible = true;
               }
               count_tf = "count_" + index.toString() + "_tf";
               if(this.m_craft_mc.hasOwnProperty(count_tf))
               {
                  this.m_conscount_tf[index] = new ZwTextField(this.m_craft_mc[count_tf]);
               }
            }
            this.m_craft_mc.visible = true;
         }
         if(m_window.hasOwnProperty("search_mc"))
         {
            this.m_search_mc = m_window["search_mc"] as MovieClip;
            if(this.m_search_mc.hasOwnProperty("slotmc_tittle_tf"))
            {
               this.m_searchtitle_tf = new ZwTextField(this.m_search_mc["slotmc_tittle_tf"]);
            }
            if(this.m_search_mc.hasOwnProperty("send_search_mc"))
            {
               this.m_sendsearch_mc = this.m_search_mc["send_search_mc"] as MovieClip;
               this.m_sendsearch_mc.visible = true;
               for(index = 0; index < this.manager.NUM_CONSUMABLES; index++)
               {
                  consumable_mc = "req_cons_" + index.toString() + "_mc";
                  if(this.m_sendsearch_mc.hasOwnProperty(consumable_mc))
                  {
                     this.m_searchcons_mc[index] = this.m_sendsearch_mc[consumable_mc] as MovieClip;
                     this.m_searchcons_mc[index].visible = true;
                  }
               }
               if(this.m_sendsearch_mc.hasOwnProperty("finding_chance_tf"))
               {
                  this.m_chancepercent_tf = new ZwTextField(this.m_sendsearch_mc["finding_chance_tf"]);
               }
               if(this.m_sendsearch_mc.hasOwnProperty("cluecount_mc"))
               {
                  cluecount_mc = this.m_sendsearch_mc["cluecount_mc"] as MovieClip;
                  if(cluecount_mc.hasOwnProperty("multiplier_count_tf"))
                  {
                     this.m_cluecount_tf = new ZwTextField(cluecount_mc["multiplier_count_tf"]);
                  }
                  if(cluecount_mc.hasOwnProperty("increase_bt"))
                  {
                     addWidget(new FarmAnimatedTextButton(cluecount_mc["increase_bt"],"Improve",this.onClueTilesDetailsClick));
                  }
               }
               if(this.m_sendsearch_mc.hasOwnProperty("okay_bt"))
               {
                  this.m_send_bt = new FarmAnimatedTextButton(this.m_sendsearch_mc["okay_bt"],"Go Search",this.onSendSearchClick);
                  this.m_send_bt.visible = true;
               }
            }
            if(this.m_search_mc.hasOwnProperty("skip_search_mc"))
            {
               this.m_searching_mc = this.m_search_mc["skip_search_mc"] as MovieClip;
               if(this.m_searching_mc.hasOwnProperty("time_remaining_tf"))
               {
                  addWidget(this.m_searchtimer_tf = new ZwTextField(this.m_searching_mc["time_remaining_tf"],""));
               }
               if(this.m_searching_mc.hasOwnProperty("fill_meter_mc"))
               {
                  this.m_searchbar_mc = this.m_searching_mc["fill_meter_mc"] as MovieClip;
               }
               if(this.m_searching_mc.hasOwnProperty("buy_bt"))
               {
                  addWidget(this.m_skipsearch_bt = new FarmAnimatedCashButton(this.m_searching_mc["buy_bt"],"Skip",this.COST_SKIP_SEARCH.toString(),this.onSkipSearchClick));
               }
               this.m_searching_mc.visible = false;
            }
            this.m_search_mc.visible = true;
         }
         if(m_window.hasOwnProperty("stolen_item_mc"))
         {
            this.m_stage_mc = m_window["stolen_item_mc"] as MovieClip;
            if(this.m_stage_mc.hasOwnProperty("stolen_item_title_tf"))
            {
               this.m_stagetitle_tf = new ZwTextField(this.m_stage_mc["stolen_item_title_tf"],"STOLEN ITEM");
            }
            if(this.m_stage_mc.hasOwnProperty("stage_tf"))
            {
               this.m_stage_tf = new ZwTextField(this.m_stage_mc["stage_tf"]);
            }
            if(this.m_stage_mc.hasOwnProperty("antique_icon"))
            {
               this.m_stageitem_icon = new FarmIcon(this.m_stage_mc["antique_icon"]);
            }
            if(this.m_stage_mc.hasOwnProperty("clue_progressbar_mc"))
            {
               this.m_stagebar_mc = this.m_stage_mc["clue_progressbar_mc"] as MovieClip;
               if(this.m_stagebar_mc.hasOwnProperty("bar_fill_mc"))
               {
                  this.m_cluebarfill_mc = this.m_stagebar_mc["bar_fill_mc"] as MovieClip;
               }
               this.m_stagebar_mc.visible = true;
            }
            if(this.m_stage_mc.hasOwnProperty("clue_count_tf"))
            {
               this.m_stageclues_tf = new ZwTextField(this.m_stage_mc["clue_count_tf"]);
            }
            if(this.m_stage_mc.hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmark_mc = this.m_stage_mc["checkmark_mc"] as MovieClip;
               this.m_checkmark_mc.visible = false;
            }
            this.m_stage_mc.visible = true;
         }
         if(m_window.hasOwnProperty("antiquecollection"))
         {
            this.m_collections_mc = m_window["antiquecollection"] as MovieClip;
            this.m_collections_mc.visible = true;
            if(this.m_collections_mc.hasOwnProperty("antiquecollection_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_collections_mc["antiquecollection_bt"],"Open",this.onCollectionsViewClick));
            }
         }
         if(m_window.hasOwnProperty("she_did_it_overlay_mc"))
         {
            this.m_endoverlay_mc = m_window["she_did_it_overlay_mc"] as MovieClip;
            if(this.m_endoverlay_mc.hasOwnProperty("Open_Okay_bt"))
            {
               addWidget(this.m_endscreen_bt = new FarmAnimatedTextButton(this.m_endoverlay_mc["Open_Okay_bt"],"Open",this.onCollectionsViewClick));
            }
            this.m_endoverlay_mc.visible = false;
         }
         if(m_window.hasOwnProperty("she_did_it_mc"))
         {
            this.m_endreveal_mc = m_window["she_did_it_mc"] as MovieClip;
            this.m_endreveal_mc.visible = false;
         }
         if(this.manager.isFeatureCompletedByUser())
         {
            this.showEndRevealScreen();
         }
         if(this.manager.isSearchingState() == 1)
         {
            this.startSearchTimer();
         }
         if(this.manager.isFeatureActive())
         {
            this.startFeatureTimer();
         }
         this.manager.stopNotifyTimer();
         this.updateConsumableSection();
         this.updateSearchSection();
         this.updateStageProgressSection(true);
         if(!Global.player.getSeenFlag(MAIN_FTUE_SEEN_FLAG))
         {
            this.playFirstTimeTutorial(1);
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_tutorial_button)
         {
            this.m_tutorial_button.text = "Let\'s Go!";
         }
         this.playFirstTimeTutorial(1);
      }
      
      public function playFirstTimeTutorial(sceneNumber:int) : void
      {
         var element:MovieClip = null;
         this.m_tutorialCurrentScene = sceneNumber;
         if(this.m_tutorial_button)
         {
            this.m_tutorial_button.callback = this.handleTutorialButtonClick;
         }
         if(Boolean(m_tutorial) && Boolean(this.m_tutorial_button))
         {
            if(this.m_tutorialCurrentScene == this.m_tutorialTotalScenes)
            {
               this.m_tutorial_button.text = "Alright!";
            }
            element = m_tutorial.element as MovieClip;
            element.gotoAndStop(sceneNumber);
            m_tutorial.visible = true;
         }
      }
      
      private function handleTutorialButtonClick(e:Event = null) : void
      {
         var element:MovieClip = null;
         if(this.m_tutorial_button)
         {
            this.m_tutorial_button.text = "Okay!";
         }
         if(this.m_tutorialCurrentScene < this.m_tutorialTotalScenes)
         {
            this.m_tutorialCurrentScene += 1;
            if(!Global.player.getSeenFlag(MAIN_FTUE_SEEN_FLAG))
            {
               this.updateTutorialButtonCallback();
            }
            if(Boolean(m_tutorial) && Boolean(this.m_tutorial_button))
            {
               if(this.m_tutorialCurrentScene == this.m_tutorialTotalScenes)
               {
                  this.m_tutorial_button.text = "Alright!";
               }
               element = m_tutorial.element as MovieClip;
               element.gotoAndStop(this.m_tutorialCurrentScene);
               m_tutorial.visible = true;
            }
         }
         else
         {
            Global.player.setSeenFlag(MAIN_FTUE_SEEN_FLAG);
            (m_tutorial.element as MovieClip).stop();
            m_tutorial.visible = false;
         }
      }
      
      private function updateTutorialButtonCallback() : void
      {
         if(this.m_tutorial_button)
         {
            if(this.m_tutorialCurrentScene == 2)
            {
               this.m_tutorial_button.callback = this.onCollectionsViewClick;
            }
            else if(this.m_tutorialCurrentScene == 7)
            {
               this.m_tutorial_button.callback = this.onClueTilesDetailsClick;
            }
            else
            {
               this.m_tutorial_button.callback = this.handleTutorialButtonClick;
            }
         }
      }
      
      public function updateConsumableSection() : void
      {
         for(var index:int = 0; index < this.manager.NUM_CONSUMABLES; index++)
         {
            if(this.m_conscount_tf[index])
            {
               this.m_conscount_tf[index].text = "x" + this.manager.getConsumableCount(index);
               this.m_conscount_tf[index].visible = true;
            }
         }
      }
      
      public function updateSearchSection() : void
      {
         var index:int = 0;
         var frameNumber:int = 0;
         if(this.manager.isSearchingState() == 1)
         {
            if(this.m_sendsearch_mc)
            {
               this.m_sendsearch_mc.visible = false;
            }
            if(this.m_searching_mc)
            {
               this.m_searching_mc.visible = true;
            }
            if(this.m_searchtitle_tf)
            {
               this.m_searchtitle_tf.text = "Maggie is searching for clues!";
               this.m_searchtitle_tf.visible = true;
            }
         }
         else
         {
            if(this.m_sendsearch_mc)
            {
               this.m_sendsearch_mc.visible = true;
            }
            if(this.m_searching_mc)
            {
               this.m_searching_mc.visible = false;
            }
            if(this.m_searchtitle_tf)
            {
               this.m_searchtitle_tf.text = "Send Maggie to find clues";
               this.m_searchtitle_tf.visible = true;
            }
            for(index = 0; index < this.manager.NUM_CONSUMABLES; index++)
            {
               if(this.m_searchcons_mc[index])
               {
                  frameNumber = this.manager.getConsumableCount(index) > 0 ? 2 : 1;
                  this.m_searchcons_mc[index].gotoAndStop(frameNumber);
               }
            }
            if(this.m_cluecount_tf)
            {
               this.m_cluecount_tf.text = "x" + (this.manager.currentTileUnlockCount + 1).toString();
               this.m_cluecount_tf.visible = true;
            }
            if(this.m_chancepercent_tf)
            {
               this.m_chancepercent_tf.text = this.manager.currentDropChanceRange;
               this.m_chancepercent_tf.visible = true;
            }
         }
      }
      
      public function updateStageProgressSection(onOpenWindow:Boolean = false) : void
      {
         if(this.manager.isFeatureCompletedByUser())
         {
            return;
         }
         var stageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.currentActiveItem);
         var cluesPerStage:int = this.manager.activeStageClueCount;
         var currentStage:int = this.manager.activeItemStage + 1;
         var stageIconUrl:String = this.manager.PREFIX_STAGE_ICON_PATH + this.manager.currentActiveItem + "_stage" + currentStage + this.manager.SUFFIX_STAGE_ICON_PATH;
         if(Boolean(this.m_stageitem_icon) && Boolean(stageItem))
         {
            this.m_stageitem_icon.loadIcon(stageIconUrl);
            this.m_stageitem_icon.visible = true;
         }
         if(Boolean(this.m_stagetitle_tf) && Boolean(stageItem))
         {
            this.m_stagetitle_tf.text = stageItem.friendlyTitle;
            this.m_stagetitle_tf.visible = true;
         }
         if(this.m_stage_tf)
         {
            this.m_stage_tf.text = "Stage: " + currentStage + "/" + this.manager.NUM_STAGES_PER_ITEM;
            this.m_stage_tf.visible = true;
         }
         if(this.m_stageclues_tf)
         {
            this.m_stageclues_tf.text = cluesPerStage + "/" + this.manager.NUM_PARTS_PER_STAGE;
            this.m_stageclues_tf.visible = true;
         }
         var barLength:Number = cluesPerStage * this.STAGE_BAR_FULL_WIDTH / this.manager.NUM_PARTS_PER_STAGE;
         if(this.m_cluebarfill_mc)
         {
            if(cluesPerStage < 0)
            {
               this.m_cluebarfill_mc.width = 0;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_cluebarfill_mc,2,{"width":barLength});
            }
            else
            {
               this.m_cluebarfill_mc.width = barLength;
            }
         }
      }
      
      private function onSendSearchClick(e:Event = null) : void
      {
         this.startSearchTimer();
         this.manager.sendForSearch();
         this.updateSearchSection();
         this.disableSkipSearchButton();
      }
      
      private function onSkipSearchClick(e:Event = null) : void
      {
         this.stopSearchTimer();
         this.manager.onSkipSearchByCash();
         this.updateSearchSection();
      }
      
      override public function refreshWindow() : void
      {
         this.updateConsumableSection();
         this.updateSearchSection();
         this.updateStageProgressSection(false);
      }
      
      private function onCraftConsumableClick(itemIndex:int) : Function
      {
         return function(e:Event = null):void
         {
            manager.craftConsumable(itemIndex);
         };
      }
      
      private function onBuyConsumableClick(itemIndex:int) : Function
      {
         return function(e:Event = null):void
         {
            enableInput = false;
            tintWindow();
            UI.displayMessage(manager.getConsumableBuyConfirmText(itemIndex),GenericPopup.TYPE_ACCEPTCANCEL,onConfirmBuyConsumable(itemIndex),"",true);
         };
      }
      
      private function onConfirmBuyConsumable(itemIndex:int) : *
      {
         return function(event:GenericPopupEvent):void
         {
            if(event.button == GenericPopup.ACCEPT)
            {
               manager.buyConsumable(itemIndex);
            }
            untintWindow();
            enableInput = true;
         };
      }
      
      private function onCollectionsViewClick(e:Event = null) : void
      {
         this.manager.showCollectionsWindow();
      }
      
      private function onClueTilesDetailsClick(e:Event = null) : void
      {
         this.manager.showTilesInfoWindow();
      }
      
      public function showEndRevealScreen() : void
      {
         if(this.m_endreveal_mc)
         {
            this.m_endreveal_mc.visible = true;
         }
         if(this.m_endoverlay_mc)
         {
            this.m_endoverlay_mc.visible = true;
         }
         if(this.m_subtitle_tf)
         {
            this.m_subtitle_tf.text = "Congrats! You have helped Maggie find all the stolen items!";
            this.m_subtitle_tf.visible = true;
         }
         if(this.m_howdoesthiswork_bt)
         {
            this.m_howdoesthiswork_bt.visible = false;
         }
      }
      
      public function disableSkipSearchButton() : void
      {
         if(this.m_skipsearch_bt)
         {
            this.m_skipsearch_bt.enabled = false;
         }
      }
      
      public function enableSkipSearchButton() : void
      {
         if(this.m_skipsearch_bt)
         {
            this.m_skipsearch_bt.enabled = true;
         }
      }
      
      private function startSearchTimer() : void
      {
         this.m_searchTimer = new Timer(1000);
         this.m_searchTimer.addEventListener(TimerEvent.TIMER,this.onSearchTimer);
         this.m_searchTimer.start();
      }
      
      private function onSearchTimer(event:TimerEvent) : void
      {
         var barLength:Number = NaN;
         var timebar_mc:MovieClip = null;
         if(this.manager.isSearchTimeExpired())
         {
            this.stopSearchTimer();
            this.manager.onSearchTimeExpire();
         }
         else
         {
            if(this.m_searchtimer_tf)
            {
               this.m_searchtimer_tf.text = HUD.getformattedTimeLeft(this.manager.getSearchTimeRemaining()) + " left!";
            }
            barLength = this.manager.getSearchTimeRunningFraction() * this.SEARCH_TIME_BAR_WIDTH;
            if(this.m_searchbar_mc.hasOwnProperty("bar_fill_mc"))
            {
               timebar_mc = this.m_searchbar_mc["bar_fill_mc"] as MovieClip;
               TweenMax.to(timebar_mc,0.1,{"x":this.SEARCH_TIME_BAR_WIDTH - barLength});
               timebar_mc.visible = true;
            }
         }
      }
      
      public function stopSearchTimer() : void
      {
         if(this.m_searchTimer)
         {
            this.m_searchTimer.stop();
            this.m_searchTimer.removeEventListener(TimerEvent.TIMER,this.onSearchTimer);
            this.m_searchTimer = null;
         }
      }
      
      private function startFeatureTimer() : void
      {
         this.m_featureTimer = new Timer(1000);
         this.m_featureTimer.addEventListener(TimerEvent.TIMER,this.onFeatureTimer);
         this.m_featureTimer.start();
      }
      
      private function onFeatureTimer(event:TimerEvent) : void
      {
         if(this.m_featuretime_tf)
         {
            this.m_featuretime_tf.text = this.manager.getFeatureEndDaysLeftText();
         }
      }
      
      private function stopFeatureTimer() : void
      {
         if(this.m_featureTimer)
         {
            this.m_featureTimer.stop();
            this.m_featureTimer.removeEventListener(TimerEvent.TIMER,this.onFeatureTimer);
            this.m_featureTimer = null;
         }
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         this.stopSearchTimer();
         this.stopFeatureTimer();
         if(this.manager.isSearchingState() == 1)
         {
            this.manager.startNotifyTimer();
         }
         FarmStatsManager.count(this.manager.FEATURE_TRACKING,"main_ui","close");
         super.close();
      }
   }
}

