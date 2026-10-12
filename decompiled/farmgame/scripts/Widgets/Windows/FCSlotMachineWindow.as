package Widgets.Windows
{
   import Classes.Constants.FCSlotMachineRewards;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FCSlotMachine.FCSlotMachinePrizeFrame;
   import Widgets.Frames.FCSlotMachine.FCSlotMachineSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class FCSlotMachineWindow extends FarmWindow
   {
      
      public static const ENTRY_POINT_GAME_TENT:String = "game_tent";
      
      public static const ENTRY_POINT_MARKET_AD:String = "market_place";
      
      public static const ENTRY_POINT_MOTD:String = "motd";
      
      public static const ENTRY_POINT_MOTD_AUTOPOP:String = "motd_autopop";
      
      public static const ENTRY_POINT_HUD:String = "hud";
      
      public static const WINDOW_NAME:String = "fcSlotMachine";
      
      public static const REWARDS_LOADED:String = "fcSlotMachineRewardsLoaded";
      
      private static const ASSET_SWF:String = "assets/dialogs/FV_SlotMachine.swf";
      
      private static const SPIN_COST:int = 3;
      
      private static const INITIAL_FREE_SPINS:int = 1;
      
      private static const STATS_COUNTER:String = "slots";
      
      private static const SPIN_AUTO_STOP_DELAY:int = 500;
      
      private static const FARM_SLOTS_MIN_SPIN_DELAY_MS:String = "FARM_SLOTS_MIN_SPIN_DELAY_MS";
      
      private static const NUM_SLOTS:int = 3;
      
      private static const NUM_ICONS_PER_REEL:int = 8;
      
      private static const REEL_SPIN_END_INDEX:int = 5;
      
      private static const SFX_PULL_LEVER_URL:String = "assets/sounds/fcslotmachine/FV_slots_pull_lever.mp3";
      
      private static const SFX_PULL_LEVER_ID:String = "fcSlotMachinePullLever";
      
      private static const SFX_WIN_HIGH_URL:String = "assets/sounds/fcslotmachine/FV_slots_end_success.mp3";
      
      private static const SFX_WIN_HIGH_ID:String = "fcSlotMachineWinHigh";
      
      private static const SFX_WIN_MEDIUM_URL:String = "assets/sounds/fcslotmachine/FV_slotswin_high.mp3";
      
      private static const SFX_WIN_MEDIUM_ID:String = "fcSlotMachineWinMedium";
      
      private static const SFX_WIN_LOW_URL:String = "assets/sounds/fcslotmachine/FV_slots_win_low.mp3";
      
      private static const SFX_WIN_LOW_ID:String = "fcSlotMachineWinLow";
      
      private static const SFX_REEL_SPIN_URL:String = "assets/sounds/fcslotmachine/FV_slots_reel_spin_01.mp3";
      
      private static const SFX_REEL_SPIN_ID:String = "fcSlotMachineSpinReel";
      
      private static const SFX_DING_URL:String = "assets/sounds/fcslotmachine/FV_slots_reel_stop_ding.mp3";
      
      public static const SFX_DING_ID:String = "fcSlotMachineDing";
      
      private const BULB_WIN_INDEX:int = 0;
      
      private const BULB_IDLE_INDEX:int = 1;
      
      private const BULB_START_INDEX:int = 2;
      
      private var m_entryPoint:String;
      
      private var m_minSpinDelay:int;
      
      private var m_allRewards:Array;
      
      private var m_mysteryGameRewards:Array;
      
      private var m_freeSpinButton:FarmAnimatedTextButton = null;
      
      private var m_paidSpinButton:FarmAnimatedTextButton = null;
      
      private var m_bulbBorder:ZwFrame = null;
      
      private var m_congratsPop:ZwFrame = null;
      
      private var m_congratsText:ZwTextField = null;
      
      private var m_pullLever:ZwFrame = null;
      
      private var m_slotsContainer:FCSlotMachineSlotFrame = null;
      
      private var m_prizesOverview:ZwFrame = null;
      
      private var m_prizesContainer:FCSlotMachinePrizeFrame = null;
      
      private var m_prizeDetail:ZwFrame = null;
      
      private var m_prizeDetailText:ZwTextField = null;
      
      private var m_prizeDetailIcon:FarmIcon = null;
      
      private var m_windowDesc:ZwTextField = null;
      
      private var m_spinTimer:Timer = null;
      
      private var m_spinResult:Object = null;
      
      private var m_soundsOn:Boolean = false;
      
      public function FCSlotMachineWindow(entryPoint:String)
      {
         super(ASSET_SWF,true,true);
         this.m_entryPoint = entryPoint;
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_windowDesc = addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","FCSlotMachine_description")),true) as ZwTextField;
         this.addSoundEffects();
         this.m_bulbBorder = addWidget(new ZwFrame(m_window.bulbBorder_start_mc)) as ZwFrame;
         this.flashBulbs(this.BULB_IDLE_INDEX);
         this.m_congratsPop = addWidget(new ZwFrame(m_window.congrats_mc),false) as ZwFrame;
         var textContainer:ZwFrame = addWidget(new ZwFrame(this.m_congratsPop.element.prizeText_mc)) as ZwFrame;
         this.m_congratsText = addWidget(new ZwTextField(textContainer.element.generic_tf,"")) as ZwTextField;
         this.m_pullLever = addWidget(new ZwFrame(m_window.slotLever_mc)) as ZwFrame;
         this.m_prizesOverview = addWidget(new ZwFrame(m_window.prizes_mc),true) as ZwFrame;
         this.m_freeSpinButton = addWidget(new FarmAnimatedTextButton(m_window.spin_bt,ZLocUtils.t("Dialogs","FCSlotMachine_freespin"),this.onFreeSpin),false) as FarmAnimatedTextButton;
         this.addBuySpinButton();
         if(FCSlotMachineRewards.isInitialized())
         {
            this.loadRewardsAndActivate();
         }
         else
         {
            FarmStatsManager.count(STATS_COUNTER,"rewards_load_pending");
            this.waitForRewardsInit();
         }
         var impressionType:String = this.getFreeSpins() > 0 ? "free_play" : "paid";
         FarmStatsManager.count("dialog",STATS_COUNTER,"impression",impressionType,this.m_entryPoint);
         super.postLoadComplete();
      }
      
      private function addBuySpinButton() : void
      {
         var greenButton:FarmAnimatedTextButton = addWidget(new FarmAnimatedTextButton(m_window.buy_mc,ZLocUtils.t("Dialogs","FCSlotMachine_spin"),this.onPaidSpin),false) as FarmAnimatedTextButton;
         this.m_paidSpinButton = greenButton;
      }
      
      private function addSoundEffects() : void
      {
         this.m_soundsOn = true;
         SoundManager.addSound(SFX_PULL_LEVER_ID,Global.getAssetURL(SFX_PULL_LEVER_URL),false);
         SoundManager.addSound(SFX_WIN_HIGH_ID,Global.getAssetURL(SFX_WIN_HIGH_URL),false);
         SoundManager.addSound(SFX_WIN_MEDIUM_ID,Global.getAssetURL(SFX_WIN_MEDIUM_URL),false);
         SoundManager.addSound(SFX_WIN_LOW_ID,Global.getAssetURL(SFX_WIN_LOW_URL),false);
         SoundManager.addSound(SFX_REEL_SPIN_ID,Global.getAssetURL(SFX_REEL_SPIN_URL),false);
         SoundManager.addSound(SFX_DING_ID,Global.getAssetURL(SFX_DING_URL),false);
      }
      
      private function loadRewardsAndActivate() : void
      {
         this.m_freeSpinButton.text = ZLocUtils.t("Dialogs","FCSlotMachine_freespin");
         this.toggleButton(this.m_freeSpinButton,true);
         this.setSpinButtons();
         this.m_allRewards = FCSlotMachineRewards.getAllRewards();
         this.m_mysteryGameRewards = FCSlotMachineRewards.getMysteryGameRewards();
         this.m_slotsContainer = addWidget(new FCSlotMachineSlotFrame(m_window.slots_mc,this.getSlotValues(this.m_allRewards))) as FCSlotMachineSlotFrame;
         this.m_minSpinDelay = SPIN_AUTO_STOP_DELAY;
         var runtimeSpinDelay:int = parseInt(GlobalEngine.getFlashVar(FARM_SLOTS_MIN_SPIN_DELAY_MS) as String);
         if(!isNaN(runtimeSpinDelay))
         {
            this.m_minSpinDelay = runtimeSpinDelay;
         }
         this.m_spinTimer = new Timer(this.m_minSpinDelay,1);
         this.m_prizeDetail = addWidget(new ZwFrame(m_window.largePrize_mc),false) as ZwFrame;
         this.m_prizeDetailText = addWidget(new ZwTextField(this.m_prizeDetail.element.prize_tf,""),true) as ZwTextField;
         this.m_prizeDetailIcon = addWidget(new FarmIcon(this.m_prizeDetail.element.icon_mc),true) as FarmIcon;
         this.m_prizesContainer = addWidget(new FCSlotMachinePrizeFrame(m_window.weekPrizes_mc,this.m_mysteryGameRewards,this)) as FCSlotMachinePrizeFrame;
      }
      
      private function waitForRewardsInit() : void
      {
         this.m_freeSpinButton.visible = true;
         this.m_freeSpinButton.text = ZLocUtils.t("Dialogs","FCSlotMachine_loading");
         this.toggleButton(this.m_freeSpinButton,false);
         GlobalEventManager.getInstance().addEventListener(REWARDS_LOADED,this.onRewardsLoaded);
      }
      
      private function onRewardsLoaded(e:Event) : void
      {
         GlobalEventManager.getInstance().removeEventListener(REWARDS_LOADED,this.onRewardsLoaded);
         this.loadRewardsAndActivate();
      }
      
      override protected function onClose(event:Event) : void
      {
         CarnivalBoothWindow.promoteCarnivalBooth();
         FarmStatsManager.count("dialog",STATS_COUNTER,"click","close",this.m_entryPoint);
         super.onClose(event);
      }
      
      public function showPrizeDetails(item:FarmItem) : void
      {
         this.m_prizesOverview.visible = false;
         this.m_prizeDetailIcon.loadIcon(item.icon);
         this.m_prizeDetailText.text = item.friendlyTitle;
         this.m_prizeDetail.visible = true;
      }
      
      public function hideItemDetails() : void
      {
         this.m_prizeDetail.visible = false;
         this.m_prizesOverview.visible = true;
      }
      
      private function setSpinButtons() : void
      {
         var freeSpin:Boolean = this.getFreeSpins() > 0;
         this.m_freeSpinButton.visible = freeSpin;
         this.m_paidSpinButton.visible = !freeSpin;
      }
      
      private function getSlotValues(spinEndValues:Array) : Array
      {
         var i:int = 0;
         var j:int = 0;
         var slots:Array = new Array(NUM_SLOTS);
         for(i = 0; i < NUM_SLOTS; i++)
         {
            slots[i] = new Array(NUM_ICONS_PER_REEL);
         }
         for(i = 0; i < NUM_SLOTS; i++)
         {
            for(j = 0; j < NUM_ICONS_PER_REEL; j++)
            {
               slots[i][j] = this.m_allRewards[int(Math.round(Math.random() * (this.m_allRewards.length - 1)))];
            }
         }
         for(i = 0; i < NUM_SLOTS; i++)
         {
            slots[i][REEL_SPIN_END_INDEX] = spinEndValues[i];
         }
         return slots;
      }
      
      private function flashBulbs(stateIndex:int) : void
      {
         switch(stateIndex)
         {
            case this.BULB_IDLE_INDEX:
               (this.m_bulbBorder.element as MovieClip).gotoAndStop(1);
               break;
            case this.BULB_START_INDEX:
               (this.m_bulbBorder.element as MovieClip).gotoAndPlay(2);
               break;
            case this.BULB_WIN_INDEX:
               (this.m_bulbBorder.element as MovieClip).gotoAndPlay(30);
         }
      }
      
      private function onFreeSpin(event:Event) : void
      {
         FarmStatsManager.count("dialog",STATS_COUNTER,"click","free_play",this.m_entryPoint);
         this.toggleButton(this.m_freeSpinButton,false);
         var freeSpins:int = this.getFreeSpins();
         if(freeSpins > 0)
         {
            this.setFreeSpins(freeSpins - 1);
            this.spin();
         }
         else
         {
            this.setSpinButtons();
         }
      }
      
      private function onPaidSpin(event:Event) : void
      {
         FarmStatsManager.count("dialog",STATS_COUNTER,"click","paid",this.m_entryPoint);
         if(Global.player.cash >= SPIN_COST)
         {
            FarmStatsManager.count("fv_cash_buy","mini_game",STATS_COUNTER,String(SPIN_COST),this.m_entryPoint);
            this.toggleButton(this.m_paidSpinButton,false);
            Global.player.cash -= SPIN_COST;
            this.spin();
         }
         else
         {
            FarmStatsManager.count(STATS_COUNTER,"out_of_cash");
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",SPIN_COST,STATS_COUNTER);
         }
      }
      
      private function spin() : void
      {
         this.m_congratsPop.visible = false;
         this.playSound(SFX_PULL_LEVER_ID);
         this.playSound(SFX_REEL_SPIN_ID);
         this.toggleButton(m_closeButton,false);
         this.flashBulbs(this.BULB_START_INDEX);
         (this.m_pullLever.element as MovieClip).gotoAndPlay(1);
         this.m_slotsContainer.startSpin();
         this.m_spinResult = null;
         TransactionManager.addTransaction(new TGenericTransaction("SlotService","spin",this.onSpinTransactionComplete,[]),true);
         this.m_spinTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onSpinnerTimeOut);
         this.m_spinTimer.start();
      }
      
      private function playSound(id:String) : void
      {
         if(this.m_soundsOn)
         {
            SoundManager.playSound(id);
         }
      }
      
      private function onSpinnerTimeOut(event:TimerEvent) : void
      {
         this.m_spinTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onSpinnerTimeOut);
         if(this.m_spinResult)
         {
            this.stopSpin();
         }
      }
      
      public function onSpinTransactionComplete(result:Object) : void
      {
         this.m_spinResult = result;
         if(!this.m_spinTimer.running)
         {
            this.stopSpin();
         }
      }
      
      private function stopSpin() : void
      {
         this.m_slotsContainer.repopulateData(this.getSlotValues(this.m_spinResult.slots));
         this.setMatchFields(true);
         this.m_slotsContainer.stopSpin(this.onStoppedSpin);
      }
      
      private function setMatchFields(start:Boolean) : void
      {
         var slotMatch:Array = new Array(NUM_SLOTS);
         if(start)
         {
            slotMatch[0] = true;
            slotMatch[1] = this.compareSlots(this.m_spinResult.slots[0],this.m_spinResult.slots[1]);
            slotMatch[2] = slotMatch[1] && this.compareSlots(this.m_spinResult.slots[0],this.m_spinResult.slots[2]);
         }
         else
         {
            slotMatch[0] = slotMatch[1] = slotMatch[2] = false;
         }
         this.m_slotsContainer.setMatchField(slotMatch);
      }
      
      public function onStoppedSpin() : void
      {
         SoundManager.stopSound(SFX_REEL_SPIN_ID);
         if(this.m_spinResult.payOut)
         {
            this.grantReward(this.m_spinResult.payOut);
            this.flashBulbs(this.BULB_WIN_INDEX);
            FarmStatsManager.count("dialog","slots_win","impression","",this.m_entryPoint);
         }
         else
         {
            this.playSound(SFX_DING_ID);
            this.setMatchFields(false);
            FarmStatsManager.count("dialog","slots_loss","impression","",this.m_entryPoint);
         }
         this.setSpinButtons();
         this.toggleButton(m_closeButton,true);
         this.toggleButton(this.m_freeSpinButton,true);
         this.toggleButton(this.m_paidSpinButton,true);
         this.m_spinResult = null;
      }
      
      private function grantReward(payOut:Object) : void
      {
         var item:FarmItem = null;
         var value:String = null;
         var error:Boolean = false;
         var rewardText:String = "";
         var quantity:int = parseInt(payOut.quantity);
         var quantityString:String = Utilities.formatNumber(quantity);
         switch(payOut.type)
         {
            case "cash":
               Global.player.cash += quantity;
               rewardText = ZLocUtils.t("Dialogs","FCSlotMachine_rewardCash",{"quantity":quantityString});
               break;
            case "coins":
               Global.player.gold += quantity;
               rewardText = ZLocUtils.t("Dialogs","FCSlotMachine_rewardCoins",{"quantity":quantityString});
               break;
            case "coconuts":
               Global.player.updateWorldCurrency(Currency.COCONUTS,quantity);
               rewardText = ZLocUtils.t("Dialogs","FCSlotMachine_rewardCoconuts",{"quantity":quantityString});
               break;
            case "free_spin":
               this.setFreeSpins(this.getFreeSpins() + quantity);
               rewardText = ZLocUtils.t("Dialogs","FCSlotMachine_rewardspin",{"quantity":quantityString});
               break;
            case "item_grant":
               Global.player.addGift(payOut.value as String,"0",quantity);
               item = Global.farmGameSettingsManager.getFarmItemByName(payOut.value);
               if(quantity > 1)
               {
                  rewardText = ZLocUtils.tk_pk_asTitlePlural(item.friendlyName);
               }
               if(rewardText == "")
               {
                  rewardText = item.friendlyTitle;
               }
               rewardText = quantity + " " + rewardText;
               break;
            case "turbo_charger":
               Global.player.turboChargers += quantity;
               rewardText = ZLocUtils.t("Dialogs","FCSlotMachine_rewardTurbo",{"quantity":quantityString});
               break;
            default:
               error = true;
         }
         if(error)
         {
            value = payOut.value ? payOut.value as String : "";
            ErrorManager.addError("Invalid reward [type: " + (payOut.type as String) + " value: " + value + "quantity: " + quantity + "]");
            FarmStatsManager.count(STATS_COUNTER,"error","invalid_reward_type",payOut.type);
         }
         else
         {
            switch(payOut.classType as String)
            {
               case "1":
                  this.playSound(SFX_WIN_LOW_ID);
                  break;
               case "2":
                  this.playSound(SFX_WIN_MEDIUM_ID);
                  break;
               case "3":
                  this.playSound(SFX_WIN_HIGH_ID);
                  break;
               default:
                  this.playSound(SFX_WIN_LOW_ID);
                  FarmStatsManager.count(STATS_COUNTER,"error","invalid_reward_class",payOut.classType);
            }
            this.m_congratsText.text = rewardText;
            this.m_congratsPop.visible = true;
            (this.m_congratsPop.element as MovieClip).gotoAndPlay(1);
         }
      }
      
      private function toggleButton(btn:FarmButton, enabled:Boolean) : void
      {
         btn.enabled = enabled;
         btn.applyGrayOut = !enabled;
      }
      
      private function getFreeSpins() : int
      {
         var freeSpins:int = 0;
         var spins:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SLOT_MACHINE,FeatureOptionsManager.SLOT_MACHINE_FREESPINS);
         if(spins === null)
         {
            freeSpins = INITIAL_FREE_SPINS;
            this.setFreeSpins(freeSpins);
         }
         else
         {
            freeSpins = spins as Number;
            if(isNaN(freeSpins))
            {
               FarmStatsManager.count(STATS_COUNTER,"error","invalid_spins_count");
               freeSpins = 0;
            }
         }
         return freeSpins;
      }
      
      private function setFreeSpins(spins:int) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.SLOT_MACHINE,FeatureOptionsManager.SLOT_MACHINE_FREESPINS,spins);
      }
      
      private function compareSlots(slot1:Object, slot2:Object) : Boolean
      {
         if(slot1.type != slot2.type || slot1.quantity != slot2.quantity || slot1["value"] != slot2["value"])
         {
            return false;
         }
         return true;
      }
   }
}

